#import <Foundation/Foundation.h>
#import <Tracker/Tracker-Swift.h>

#import "BatchATInternetDispatcherCore.h"
#import "BatchXtor.h"

NSString* const BatchAtInternetXtor = @"xtor";
NSString* const BatchAtInternetDefaultCampaign = @"[batch-default-campaign]";

NSString* const BatchAtInternetCampaignTracker = @"batch-campaign-tracker";
NSString* const BatchAtInternetPublisherTracker = @"batch-publisher-tracker";

@implementation BatchATInternetDispatcher
{
    NSMutableDictionary *_trackerCache;
}

+ (void)load {
    [BatchEventDispatcher addDispatcher:[self instance]];
}

+ (instancetype)instance
{
    static BatchATInternetDispatcher *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BatchATInternetDispatcher alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _trackerCache = [NSMutableDictionary new];
    }
    return self;
}
- (Tracker*)trackerNamed:(nonnull NSString*)name
{
    if (name == nil) {
        return nil;
    }
    
    Tracker *cachedTracker = [_trackerCache objectForKey:name];
    
    if (cachedTracker != nil) {
        return cachedTracker;
    }
    
    @synchronized (_trackerCache) {
        cachedTracker = [[ATInternet sharedInstance] tracker:name];
        if (cachedTracker != nil) {
            [_trackerCache setObject:cachedTracker forKey:name];
        }
    }
    
    return cachedTracker;
}

- (void)dispatchEventWithType:(BatchEventDispatcherType)type payload:(nonnull id<BatchEventDispatcherPayload>)payload
{
    NSString *eventName = [self stringFromEventType:type];
    NSString *xtorTag = [self xtorFromPayload:payload];
    
    if ([self isImpression:type] || [self isClick:type]) {
        [self dispatchAsOnSiteAdsWithType:type payload:payload andXtor:xtorTag];
    }
    
    Tracker *campaignTracker = [self trackerNamed:BatchAtInternetCampaignTracker];
    Screen *screen = [campaignTracker.screens add:eventName];
    if (xtorTag != nil) {
        screen.campaign = [[Campaign alloc] initWithCampaignId:xtorTag];
    }
    [screen sendView];
}

- (void)dispatchAsOnSiteAdsWithType:(BatchEventDispatcherType)type payload:(nonnull id<BatchEventDispatcherPayload>)payload andXtor:(nullable NSString*)xtorTag
{
    Tracker *publisherTracker = [self trackerNamed:BatchAtInternetPublisherTracker];
    Publisher *publisher = nil;
    NSString *campaignId = nil;
    
    if (xtorTag != nil) {
        BatchXtor *xtor = [[BatchXtor alloc] initWithTag:xtorTag];
        if ([xtor isValid]) {
            campaignId = [xtor partAtIndex:1];
        }
    }

    if ([campaignId length] == 0) {
        publisher = [publisherTracker.publishers add:BatchAtInternetDefaultCampaign];
    } else {
        publisher = [publisherTracker.publishers add:campaignId];
    }
    
    if ([BatchEventDispatcher isNotificationEvent:type]) {
        publisher.format = @"[push]";
    } else if ([BatchEventDispatcher isMessagingEvent:type]) {
        publisher.format = @"[in-app]";
    }
    publisher.advertiserId = @"[batch]";
    
    if ([self isImpression:type]) {
        [publisher sendImpression];
    } else if ([self isClick:type] && payload.isPositiveAction) {
        [publisher sendTouch];
    }
    
    if (type == BatchEventDispatcherTypeNotificationOpen) {
        // We don't have evvent when a push is received/dispalyed
        // So we send a impression when a push is opened to keep a consistent CTR on AT dashboard
        [publisher sendImpression];
    }
}

- (nullable NSString*)xtorFromPayload:(nonnull id<BatchEventDispatcherPayload>)payload
{
    NSString *xtor = payload.trackingId;
    if (xtor != nil) {
        return xtor;
    }
    
    NSString *deeplink = payload.deeplink;
    if (deeplink != nil) {
        xtor = [self xtorFromDeeplink:deeplink];
        if (xtor != nil) {
            return xtor;
        }
    }
    
    NSObject *value = [payload customValueForKey:BatchAtInternetXtor];
    if (value != nil && [value isKindOfClass:[NSString class]]) {
        return (NSString*)value;
    }
    return nil;
}

- (nullable NSString*)xtorFromDeeplink:(nonnull NSString *)deeplink
{
    deeplink = [deeplink stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSURL *url = [NSURL URLWithString:deeplink];
    if (url != nil) {
        NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:false];
        if (components != nil) {
            // Find XTOR in query vars
            for (NSURLQueryItem *item in components.queryItems) {
                if ([BatchAtInternetXtor caseInsensitiveCompare:item.name] == NSOrderedSame) {
                    return item.value;
                }
            }
            
            // Find XTOR in fragment vars
            if (components.fragment != nil) {
                NSDictionary *fragments = [self dictFragment:components.fragment];
                NSString *value = [fragments objectForKey:BatchAtInternetXtor];
                if (value != nil) {
                    return value;
                }
            }
        }
    }
    return nil;
}

- (BOOL)isImpression:(BatchEventDispatcherType)type
{
    return type == BatchEventDispatcherTypeMessagingShow;
}

- (BOOL)isClick:(BatchEventDispatcherType)type
{
    return type == BatchEventDispatcherTypeNotificationOpen ||
    type == BatchEventDispatcherTypeMessagingClick;
}

-(NSDictionary*)dictFragment:(nonnull NSString*)fragment
{
    NSMutableDictionary<NSString *, id> *fragments = [NSMutableDictionary dictionary];
    NSArray *fragmentComponents = [fragment componentsSeparatedByString:@"&"];
    for (NSString *keyValuePair in fragmentComponents) {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [[[pairComponents firstObject] stringByRemovingPercentEncoding] lowercaseString];
        NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];

        [fragments setObject:value forKey:key];
    }
    return fragments;
}

- (nonnull NSString*)stringFromEventType:(BatchEventDispatcherType)eventType
{
    switch (eventType) {
        case BatchEventDispatcherTypeNotificationOpen:
            return @"OpenedBatchPushNotification";
        case BatchEventDispatcherTypeMessagingShow:
            return @"ShowedBatchInAppMessage";
        case BatchEventDispatcherTypeMessagingClose:
            return @"ClosedBatchInAppMessage";
        case BatchEventDispatcherTypeMessagingAutoClose:
            return @"AutoClosedBatchInAppMessage";
        case BatchEventDispatcherTypeMessagingClick:
            return @"ClickedBatchInAppMessage";
        default:
            return @"UnknownBatchMessage";
    }
}

@end
