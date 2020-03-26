#import <Foundation/Foundation.h>

#import "BatchCampaignTests.h"

@implementation BatchCampaignTest {
    NSString *campaignId;
}

+ (nonnull instancetype)campaignSelector:(nonnull NSString*)campaignId
{
    return [[BatchCampaignTest alloc] initWithCampaignId:campaignId];
}

- (nonnull instancetype)initWithCampaignId:(nonnull NSString*)campaignId
{
    self = [super init];
    if (self) {
        campaignId = campaignId;
    }
    return self;
}

- (BOOL)compareToCampaign:(nonnull Campaign *)campaign {
    return [campaign.campaignId isEqualToString:campaignId];
}

@end
