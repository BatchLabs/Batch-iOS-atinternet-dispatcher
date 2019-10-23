//
//  BatchCampaignTests.m
//  Batch-AtInternet-Dispatcher_Tests
//
//  Created by Elliot Gouy on 24/10/2019.
//  Copyright © 2019 elliot. All rights reserved.
//

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
