#import <Foundation/Foundation.h>

#import "BatchPayloadDispatcherTests.h"

@implementation BatchPayloadDispatcherTest

@synthesize notificationUserInfo;
@synthesize sourceMessage;

- (nonnull instancetype)init
{
    self = [super init];
    if (self) {
        self.isPositiveAction = true;
    }
    return self;
}

- (nullable NSObject *)customValueForKey:(nonnull NSString *)key {
    if (self.customPayload != nil) {
        return [self.customPayload objectForKey:key];
    }
    return nil;
}

@end
