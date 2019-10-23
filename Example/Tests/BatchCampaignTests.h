//
//  BatchCampaignTests.h
//  Batch-AtInternet-Dispatcher_Tests
//
//  Created by Elliot Gouy on 24/10/2019.
//  Copyright © 2019 elliot. All rights reserved.
//

#import <Tracker/Tracker-Swift.h>

@interface BatchCampaignTest : NSObject

+ (nonnull instancetype)campaignSelector:(nonnull NSString*)campaignId;

- (nonnull instancetype)initWithCampaignId:(nonnull NSString*)campaignId;

- (BOOL)compareToCampaign:(nonnull Campaign *)campaign;

@end
