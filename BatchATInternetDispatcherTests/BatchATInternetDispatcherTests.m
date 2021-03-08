#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <Tracker/Tracker-Swift.h>

#import "BatchATInternetDispatcher.h"
#import "BatchPayloadDispatcherTests.h"
#import "BatchCampaignTests.h"

@interface BatchAtInternetDispatcherTests : XCTestCase

@property (nonatomic) id screenMock;
@property (nonatomic) Screens *screensMock;
@property (nonatomic) id publisherMock;
@property (nonatomic) Publishers *publishersMock;
@property (nonatomic) id trackerMock;
@property (nonatomic) id atInternetMock;
@property (nonatomic) BatchATInternetDispatcher *dispatcher;

@end

@implementation BatchAtInternetDispatcherTests

- (void)setUp
{
    [super setUp];

    _screenMock = OCMClassMock([Screen class]);
    _screensMock = OCMClassMock([Screens class]);
    _publisherMock = OCMClassMock([Publisher class]);
    _publishersMock = OCMClassMock([Publishers class]);
    _trackerMock = OCMClassMock([Tracker class]);
    
    OCMStub([_trackerMock publishers]).andReturn(_publishersMock);
    OCMStub([_trackerMock screens]).andReturn(_screensMock);
    
    _dispatcher = [BatchATInternetDispatcher instance];
    _dispatcher.trackerOverride = _trackerMock;
}

- (void)tearDown
{
    [super tearDown];
    
    [_screenMock stopMocking];
    _screenMock = nil;
    
    [(id)_screensMock stopMocking];
    _screensMock = nil;
    
    [_publisherMock stopMocking];
    _publisherMock = nil;
    
    [(id)_publishersMock stopMocking];
    _publishersMock = nil;
    
    [_trackerMock stopMocking];
    _trackerMock = nil;
    
    [_atInternetMock stopMocking];
    _atInternetMock = nil;
}

- (void)testNotificationOpen
{
    OCMStub([_publishersMock add:@"[batch-default-campaign]"]).andReturn(_publisherMock);
    OCMStub([_screensMock add:@"OpenedBatchPushNotification"]).andReturn(_screenMock);
    OCMReject([_screenMock setCampaign:[OCMArg any]]);
    
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen payload:testPayload];
    
    OCMVerify([_publishersMock add:@"[batch-default-campaign]"]);
    OCMVerify([_publisherMock setAdvertiserId:@"[batch]"]);
    OCMVerify([_publisherMock setFormat:@"[push]"]);
    OCMVerify([_publisherMock sendTouch]);
    OCMVerify([_publisherMock sendImpression]);
    
    OCMVerify([_screensMock add:@"OpenedBatchPushNotification"]);
    OCMVerify([_screenMock sendView]);
}

- (void)testNotificationOpenCampaignLabelFragment
{
    NSString *xtor = @"CS1-[mylabeltest]-test-15[sef]";
    NSString *campaignExpected = @"[mylabeltest]";
    
    OCMStub([_publishersMock add:campaignExpected]).andReturn(_publisherMock);
    OCMStub([_screensMock add:@"OpenedBatchPushNotification"]).andReturn(_screenMock);
    
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = [NSString stringWithFormat:@"https://batch.com/test#xtor=%@", xtor];
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen payload:testPayload];
    
    OCMVerify([_publishersMock add:campaignExpected]);
    OCMVerify([_publisherMock setAdvertiserId:@"[batch]"]);
    OCMVerify([_publisherMock setFormat:@"[push]"]);
    OCMVerify([_publisherMock sendTouch]);
    OCMVerify([_publisherMock sendImpression]);
    
    OCMVerify([_screensMock add:@"OpenedBatchPushNotification"]);
    OCMVerify([_screenMock setCampaign:[OCMArg checkWithBlock:^BOOL(id value) {
        return [xtor isEqualToString:((Campaign *)value).campaignId];
    }]]);
    OCMVerify([_screenMock sendView]);
}

- (void)testNotificationOpenCampaignLabelFragmentEncode
{
    NSString *xtor = @"CS1-%5Bmylabeltest%5D-test-15%5Bsef%5D";
    NSString *decodedXtor = @"CS1-[mylabeltest]-test-15[sef]";
    NSString *campaignExpected = @"[mylabeltest]";
    
    OCMStub([_publishersMock add:campaignExpected]).andReturn(_publisherMock);
    OCMStub([_screensMock add:@"OpenedBatchPushNotification"]).andReturn(_screenMock);
    
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = [NSString stringWithFormat:@"https://batch.com/test#xtor=%@", xtor];
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen payload:testPayload];
    
    OCMVerify([_publishersMock add:campaignExpected]);
    OCMVerify([_publisherMock setAdvertiserId:@"[batch]"]);
    OCMVerify([_publisherMock setFormat:@"[push]"]);
    OCMVerify([_publisherMock sendTouch]);
    OCMVerify([_publisherMock sendImpression]);
    
    OCMVerify([_screensMock add:@"OpenedBatchPushNotification"]);
    OCMVerify([_screenMock setCampaign:[OCMArg checkWithBlock:^BOOL(id value) {
        return [decodedXtor isEqualToString:((Campaign *)value).campaignId];
    }]]);
    OCMVerify([_screenMock sendView]);
}

- (void)testNotificationOpenCampaignLabelQuery
{
    NSString *xtor = @"CS2-[mylabeltesttoto]-test-15[sef]";
    NSString *campaignExpected = @"[mylabeltesttoto]";
    
    OCMStub([_publishersMock add:campaignExpected]).andReturn(_publisherMock);
    OCMStub([_screensMock add:@"OpenedBatchPushNotification"]).andReturn(_screenMock);
    
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = [NSString stringWithFormat:@"https://batch.com/test?xtor=%@", xtor];
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen payload:testPayload];
    
    OCMVerify([_publishersMock add:campaignExpected]);
    OCMVerify([_publisherMock setAdvertiserId:@"[batch]"]);
    OCMVerify([_publisherMock setFormat:@"[push]"]);
    OCMVerify([_publisherMock sendTouch]);
    OCMVerify([_publisherMock sendImpression]);
    
    OCMVerify([_screensMock add:@"OpenedBatchPushNotification"]);
    OCMVerify([_screenMock setCampaign:[OCMArg checkWithBlock:^BOOL(id value) {
        return [xtor isEqualToString:((Campaign *)value).campaignId];
    }]]);
    OCMVerify([_screenMock sendView]);
}

- (void)testNotificationOpenHostLessDeeplinkQuery
{
    NSString *xtor = @"CS2-[mylabeltesttoto]-test-15[sef]";
    NSString *campaignExpected = @"[mylabeltesttoto]";
    
    OCMStub([_publishersMock add:campaignExpected]).andReturn(_publisherMock);
    OCMStub([_screensMock add:@"OpenedBatchPushNotification"]).andReturn(_screenMock);
    
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = [NSString stringWithFormat:@"batch://?xtor=%@", xtor];
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen payload:testPayload];
    
    OCMVerify([_publishersMock add:campaignExpected]);
    OCMVerify([_publisherMock setAdvertiserId:@"[batch]"]);
    OCMVerify([_publisherMock setFormat:@"[push]"]);
    OCMVerify([_publisherMock sendTouch]);
    OCMVerify([_publisherMock sendImpression]);
    
    OCMVerify([_screensMock add:@"OpenedBatchPushNotification"]);
    OCMVerify([_screenMock setCampaign:[OCMArg checkWithBlock:^BOOL(id value) {
        return [xtor isEqualToString:((Campaign *)value).campaignId];
    }]]);
    OCMVerify([_screenMock sendView]);
}

- (void)testNotificationOpenHostLessDeeplinkFragment
{
    NSString *xtor = @"CS2-[mylabeltesttoto]-test-15[sef]";
    NSString *campaignExpected = @"[mylabeltesttoto]";
    
    OCMStub([_publishersMock add:campaignExpected]).andReturn(_publisherMock);
    OCMStub([_screensMock add:@"OpenedBatchPushNotification"]).andReturn(_screenMock);
    
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = [NSString stringWithFormat:@"batch://#xtor=%@", xtor];
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen payload:testPayload];
    
    OCMVerify([_publishersMock add:campaignExpected]);
    OCMVerify([_publisherMock setAdvertiserId:@"[batch]"]);
    OCMVerify([_publisherMock setFormat:@"[push]"]);
    OCMVerify([_publisherMock sendTouch]);
    OCMVerify([_publisherMock sendImpression]);
    
    OCMVerify([_screensMock add:@"OpenedBatchPushNotification"]);
    OCMVerify([_screenMock setCampaign:[OCMArg checkWithBlock:^BOOL(id value) {
        return [xtor isEqualToString:((Campaign *)value).campaignId];
    }]]);
    OCMVerify([_screenMock sendView]);
}

- (void)testNotificationOpenCampaignLabelQueryEncode
{
    NSString *xtor = @"CS2-%5Bmylabeltesttoto%5D-test-15%5Bsef%5D";
    NSString *decodedXtor = @"CS2-[mylabeltesttoto]-test-15[sef]";
    NSString *campaignExpected = @"[mylabeltesttoto]";
    
    OCMStub([_publishersMock add:campaignExpected]).andReturn(_publisherMock);
    OCMStub([_screensMock add:@"OpenedBatchPushNotification"]).andReturn(_screenMock);
    
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = [NSString stringWithFormat:@"https://batch.com/test?xtor=%@", xtor];
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen payload:testPayload];
    
    OCMVerify([_publishersMock add:campaignExpected]);
    OCMVerify([_publisherMock setAdvertiserId:@"[batch]"]);
    OCMVerify([_publisherMock setFormat:@"[push]"]);
    OCMVerify([_publisherMock sendTouch]);
    OCMVerify([_publisherMock sendImpression]);
    
    OCMVerify([_screensMock add:@"OpenedBatchPushNotification"]);
    OCMVerify([_screenMock setCampaign:[OCMArg checkWithBlock:^BOOL(id value) {
        return [decodedXtor isEqualToString:((Campaign *)value).campaignId];
    }]]);
    OCMVerify([_screenMock sendView]);
}

- (void)testNotificationOpenCampaignLabelCustomPayload
{
    NSString *xtor = @"CS3-[mytoto]-test-15[sef]";
    NSString *campaignExpected = @"[mytoto]";
    
    OCMStub([_publishersMock add:campaignExpected]).andReturn(_publisherMock);
    OCMStub([_screensMock add:@"OpenedBatchPushNotification"]).andReturn(_screenMock);
    
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.customPayload = @{
        @"xtor": xtor,
    };
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen payload:testPayload];
    
    OCMVerify([_publishersMock add:campaignExpected]);
    OCMVerify([_publisherMock setAdvertiserId:@"[batch]"]);
    OCMVerify([_publisherMock setFormat:@"[push]"]);
    OCMVerify([_publisherMock sendTouch]);
    OCMVerify([_publisherMock sendImpression]);
    
    OCMVerify([_screensMock add:@"OpenedBatchPushNotification"]);
    OCMVerify([_screenMock setCampaign:[OCMArg checkWithBlock:^BOOL(id value) {
        return [xtor isEqualToString:((Campaign *)value).campaignId];
    }]]);
    OCMVerify([_screenMock sendView]);
}

- (void)testNotificationOpenCampaignLabelTrackingID
{
    NSString *xtor = @"CS3-[mytoto]-test-15[sef]";
    NSString *campaignExpected = @"[mytoto]";
    
    OCMStub([_publishersMock add:campaignExpected]).andReturn(_publisherMock);
    OCMStub([_screensMock add:@"OpenedBatchPushNotification"]).andReturn(_screenMock);
    
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.trackingId = xtor;
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen payload:testPayload];
    
    OCMVerify([_publishersMock add:campaignExpected]);
    OCMVerify([_publisherMock setAdvertiserId:@"[batch]"]);
    OCMVerify([_publisherMock setFormat:@"[push]"]);
    OCMVerify([_publisherMock sendTouch]);
    OCMVerify([_publisherMock sendImpression]);
    
    OCMVerify([_screensMock add:@"OpenedBatchPushNotification"]);
    OCMVerify([_screenMock setCampaign:[OCMArg checkWithBlock:^BOOL(id value) {
        return [xtor isEqualToString:((Campaign *)value).campaignId];
    }]]);
    OCMVerify([_screenMock sendView]);
}

- (void)testNotificationOpenNonPositive
{
    OCMStub([_publishersMock add:@"[batch-default-campaign]"]).andReturn(_publisherMock);
    OCMStub([_screensMock add:@"OpenedBatchPushNotification"]).andReturn(_screenMock);
    OCMReject([_screenMock setCampaign:[OCMArg any]]);
    OCMReject([_publisherMock sendTouch]);
    
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.isPositiveAction = false;
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen payload:testPayload];
    
    OCMVerify([_publishersMock add:@"[batch-default-campaign]"]);
    OCMVerify([_publisherMock setAdvertiserId:@"[batch]"]);
    OCMVerify([_publisherMock setFormat:@"[push]"]);
    OCMVerify([_publisherMock sendImpression]);
    
    OCMVerify([_screensMock add:@"OpenedBatchPushNotification"]);
    OCMVerify([_screenMock sendView]);
}

- (void)testNotificationOpenCampaignLabelPriority
{
    NSString *xtor = @"CS3-[mytoto]-test-15[sef]";
    NSString *campaignExpected = @"[mytoto]";
    
    OCMStub([_publishersMock add:campaignExpected]).andReturn(_publisherMock);
    OCMStub([_screensMock add:@"OpenedBatchPushNotification"]).andReturn(_screenMock);
    
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.trackingId = xtor;
    testPayload.deeplink = @"https://batch.com/test?xtor=AD-[fake]#xtor=CS8-[fake2]";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen payload:testPayload];
    
    OCMVerify([_publishersMock add:campaignExpected]);
    OCMVerify([_publisherMock setAdvertiserId:@"[batch]"]);
    OCMVerify([_publisherMock setFormat:@"[push]"]);
    OCMVerify([_publisherMock sendTouch]);
    OCMVerify([_publisherMock sendImpression]);
    
    OCMVerify([_screensMock add:@"OpenedBatchPushNotification"]);
    OCMVerify([_screenMock setCampaign:[OCMArg checkWithBlock:^BOOL(id value) {
        return [xtor isEqualToString:((Campaign *)value).campaignId];
    }]]);
    OCMVerify([_screenMock sendView]);
}

- (void)testNotificationOpenCampaignLabelNonTrimmed
{
    NSString *campaignExpected = @"[fake]";
    
    OCMStub([_publishersMock add:campaignExpected]).andReturn(_publisherMock);
    OCMStub([_screensMock add:@"OpenedBatchPushNotification"]).andReturn(_screenMock);
    
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @" \n              https://batch.com/test?xtor=AD-[fake]#xtor=CS8-[fake2]           \n";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen payload:testPayload];
    
    OCMVerify([_publishersMock add:campaignExpected]);
    OCMVerify([_publisherMock setAdvertiserId:@"[batch]"]);
    OCMVerify([_publisherMock setFormat:@"[push]"]);
    OCMVerify([_publisherMock sendTouch]);
    OCMVerify([_publisherMock sendImpression]);
    
    OCMVerify([_screensMock add:@"OpenedBatchPushNotification"]);
    OCMVerify([_screenMock setCampaign:[OCMArg checkWithBlock:^BOOL(id value) {
        return [@"AD-[fake]" isEqualToString:((Campaign *)value).campaignId];
    }]]);
    OCMVerify([_screenMock sendView]);
}

- (void)testInAppShow
{
    OCMStub([_publishersMock add:@"[batch-default-campaign]"]).andReturn(_publisherMock);
    OCMStub([_screensMock add:@"ShowedBatchInAppMessage"]).andReturn(_screenMock);
    OCMReject([_screenMock setCampaign:[OCMArg any]]);
    OCMReject([_publisherMock sendTouch]);
    
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeMessagingShow payload:testPayload];
    
    OCMVerify([_publishersMock add:@"[batch-default-campaign]"]);
    OCMVerify([_publisherMock setAdvertiserId:@"[batch]"]);
    OCMVerify([_publisherMock setFormat:@"[in-app]"]);
    OCMVerify([_publisherMock sendImpression]);
    
    OCMVerify([_screensMock add:@"ShowedBatchInAppMessage"]);
    OCMVerify([_screenMock sendView]);
}

- (void)testInAppShowCampaignId
{
    NSString *xtor = @"AD-4242-yolo-swag";
    NSString *campaignExpected = @"4242";
    
    OCMStub([_publishersMock add:campaignExpected]).andReturn(_publisherMock);
    OCMStub([_screensMock add:@"ShowedBatchInAppMessage"]).andReturn(_screenMock);
    
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.trackingId = xtor;
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeMessagingShow payload:testPayload];
    
    OCMVerify([_publishersMock add:campaignExpected]);
    OCMVerify([_publisherMock setAdvertiserId:@"[batch]"]);
    OCMVerify([_publisherMock setFormat:@"[in-app]"]);
    OCMVerify([_publisherMock sendImpression]);
    
    OCMVerify([_screensMock add:@"ShowedBatchInAppMessage"]);
    OCMVerify([_screenMock setCampaign:[OCMArg checkWithBlock:^BOOL(id value) {
        return [xtor isEqualToString:((Campaign *)value).campaignId];
    }]]);
    OCMVerify([_screenMock sendView]);
}

- (void)testInAppShowCampaignLabelFragmentUppercase
{
    NSString *xtor = @"CS1-[mylabeltest]-test-15[sef]";
    NSString *campaignExpected = @"[mylabeltest]";
    
    OCMStub([_publishersMock add:campaignExpected]).andReturn(_publisherMock);
    OCMStub([_screensMock add:@"ShowedBatchInAppMessage"]).andReturn(_screenMock);
    
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = [NSString stringWithFormat:@"https://batch.com/test#XtOr=%@", xtor];
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeMessagingShow payload:testPayload];
    
    OCMVerify([_publishersMock add:campaignExpected]);
    OCMVerify([_publisherMock setAdvertiserId:@"[batch]"]);
    OCMVerify([_publisherMock setFormat:@"[in-app]"]);
    OCMVerify([_publisherMock sendImpression]);
    
    OCMVerify([_screensMock add:@"ShowedBatchInAppMessage"]);
    OCMVerify([_screenMock setCampaign:[OCMArg checkWithBlock:^BOOL(id value) {
        return [xtor isEqualToString:((Campaign *)value).campaignId];
    }]]);
    OCMVerify([_screenMock sendView]);
}

- (void)testInAppShowCampaignLabelQueryUppercase
{
    NSString *xtor = @"CS1-[mylabeltest]-test-15[sef]";
    NSString *campaignExpected = @"[mylabeltest]";
    
    OCMStub([_publishersMock add:campaignExpected]).andReturn(_publisherMock);
    OCMStub([_screensMock add:@"ShowedBatchInAppMessage"]).andReturn(_screenMock);
    
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = [NSString stringWithFormat:@"https://batch.com/test?XTor=%@", xtor];
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeMessagingShow payload:testPayload];
    
    OCMVerify([_publishersMock add:campaignExpected]);
    OCMVerify([_publisherMock setAdvertiserId:@"[batch]"]);
    OCMVerify([_publisherMock setFormat:@"[in-app]"]);
    OCMVerify([_publisherMock sendImpression]);
    
    OCMVerify([_screensMock add:@"ShowedBatchInAppMessage"]);
    OCMVerify([_screenMock setCampaign:[OCMArg checkWithBlock:^BOOL(id value) {
        return [xtor isEqualToString:((Campaign *)value).campaignId];
    }]]);
    OCMVerify([_screenMock sendView]);
}

- (void)testInAppClickCampaignLabel
{
    NSString *xtor = @"EPR-[mylabel]-totot-titi";
    NSString *campaignExpected = @"[mylabel]";
    
    OCMStub([_publishersMock add:campaignExpected]).andReturn(_publisherMock);
    OCMStub([_screensMock add:@"ClickedBatchInAppMessage"]).andReturn(_screenMock);
    
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.trackingId = xtor;
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeMessagingClick payload:testPayload];
    
    OCMVerify([_publishersMock add:campaignExpected]);
    OCMVerify([_publisherMock setAdvertiserId:@"[batch]"]);
    OCMVerify([_publisherMock setFormat:@"[in-app]"]);
    OCMVerify([_publisherMock sendTouch]);
    
    OCMVerify([_screensMock add:@"ClickedBatchInAppMessage"]);
    OCMVerify([_screenMock setCampaign:[OCMArg checkWithBlock:^BOOL(id value) {
        return [xtor isEqualToString:((Campaign *)value).campaignId];
    }]]);
    OCMVerify([_screenMock sendView]);
}

- (void)testInAppWebViewClickButtonId
{
    NSString *xtor = @"EPR-[mylabel]-totot-titi";
    NSString *campaignExpected = @"[mylabel]";
    NSString *webViewButtonId = @"jesuisunbouton";
    
    OCMStub([_publishersMock add:campaignExpected]).andReturn(_publisherMock);
    OCMStub([_screensMock add:@"WebViewClickedBatchInAppMessage"]).andReturn(_screenMock);
    
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.webViewAnalyticsIdentifier = webViewButtonId;
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeMessagingWebViewClick payload:testPayload];
    
    OCMVerify([_publishersMock add:campaignExpected]);
    OCMVerify([_publisherMock setAdvertiserId:@"[batch]"]);
    OCMVerify([_publisherMock setFormat:@"[in-app]"]);
    OCMVerify([_publisherMock setVariant:@"[jesuisunbouton]"]);
    OCMVerify([_publisherMock sendTouch]);
    
    OCMVerify([_screensMock add:@"WebViewClickedBatchInAppMessage"]);
    OCMVerify([_screenMock setCampaign:[OCMArg checkWithBlock:^BOOL(id value) {
        return [xtor isEqualToString:((Campaign *)value).campaignId];
    }]]);
    OCMVerify([_screenMock sendView]);
}

- (void)testInAppClickNonPositive
{
    OCMStub([_publishersMock add:@"[batch-default-campaign]"]).andReturn(_publisherMock);
    OCMStub([_screensMock add:@"ClickedBatchInAppMessage"]).andReturn(_screenMock);
    OCMReject([_screenMock setCampaign:[OCMArg any]]);
    OCMReject([_publisherMock sendImpression]);
    OCMReject([_publisherMock sendTouch]);
    
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.isPositiveAction = false;
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeMessagingClick payload:testPayload];
    
    OCMVerify([_publishersMock add:@"[batch-default-campaign]"]);
    OCMVerify([_publisherMock setAdvertiserId:@"[batch]"]);
    OCMVerify([_publisherMock setFormat:@"[in-app]"]);
    
    OCMVerify([_screensMock add:@"ClickedBatchInAppMessage"]);
    OCMVerify([_screenMock sendView]);
}

- (void)testInAppGlobalTap
{
    OCMStub([_publishersMock add:@"[batch-default-campaign]"]).andReturn(_publisherMock);
    OCMStub([_screensMock add:@"ClickedBatchInAppMessage"]).andReturn(_screenMock);
    OCMReject([_screenMock setCampaign:[OCMArg any]]);
    OCMReject([_publisherMock sendImpression]);
    
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeMessagingClick payload:testPayload];
    
    OCMVerify([_publishersMock add:@"[batch-default-campaign]"]);
    OCMVerify([_publisherMock setAdvertiserId:@"[batch]"]);
    OCMVerify([_publisherMock setFormat:@"[in-app]"]);
    OCMVerify([_publisherMock sendTouch]);
    
    OCMVerify([_screensMock add:@"ClickedBatchInAppMessage"]);
    OCMVerify([_screenMock sendView]);
}

- (void)testInAppClose
{
    OCMStub([_publishersMock add:@"[batch-default-campaign]"]).andReturn(_publisherMock);
    OCMStub([_screensMock add:@"ClosedBatchInAppMessage"]).andReturn(_screenMock);
    OCMReject([_screenMock setCampaign:[OCMArg any]]);
    OCMReject([_publisherMock sendImpression]);
    OCMReject([_publisherMock sendTouch]);
    
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.isPositiveAction = false;
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeMessagingClose payload:testPayload];
    
    OCMVerify([_screensMock add:@"ClosedBatchInAppMessage"]);
    OCMVerify([_screenMock sendView]);
}

- (void)testInAppAutoClose
{
    OCMStub([_publishersMock add:@"[batch-default-campaign]"]).andReturn(_publisherMock);
    OCMStub([_screensMock add:@"AutoClosedBatchInAppMessage"]).andReturn(_screenMock);
    OCMReject([_screenMock setCampaign:[OCMArg any]]);
    OCMReject([_publisherMock sendImpression]);
    OCMReject([_publisherMock sendTouch]);
    
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.isPositiveAction = false;
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeMessagingAutoClose payload:testPayload];
    
    OCMVerify([_screensMock add:@"AutoClosedBatchInAppMessage"]);
    OCMVerify([_screenMock sendView]);
}

- (void)testInvalidEventType
{
    OCMStub([_publishersMock add:@"[batch-default-campaign]"]).andReturn(_publisherMock);
    OCMStub([_screensMock add:@"UnknownBatchMessage"]).andReturn(_screenMock);
    OCMReject([_screenMock setCampaign:[OCMArg any]]);
    OCMReject([_publisherMock sendImpression]);
    OCMReject([_publisherMock sendTouch]);
    
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    
    [self.dispatcher dispatchEventWithType:-654 payload:testPayload];
    
    OCMVerify([_screensMock add:@"UnknownBatchMessage"]);
    OCMVerify([_screenMock sendView]);
}

@end
