#import <Tracker/Tracker-Swift.h>

@interface BatchCampaignTest : NSObject

+ (nonnull instancetype)campaignSelector:(nonnull NSString*)campaignId;

- (nonnull instancetype)initWithCampaignId:(nonnull NSString*)campaignId;

- (BOOL)compareToCampaign:(nonnull Campaign *)campaign;

@end
