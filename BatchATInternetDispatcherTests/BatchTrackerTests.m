//
//  Copyright © Batch. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Tracker/Tracker-Swift.h>
#import <OCMock/OCMock.h>

#import "BatchATInternetDispatcher.h"
#import "BatchPayloadDispatcherTests.h"

// Expose private APIs to only test which tracker is

@interface BatchTrackerTests : XCTestCase

@end

@implementation BatchTrackerTests

/// Test that the dispatcher uses two trackers based on the default configuration
- (void)testUseDefaultTracker {
    id atInternetMock = OCMClassMock([ATInternet class]);
    
    id screenMock = OCMClassMock([Screen class]);
    id screensMock = OCMClassMock([Screens class]);
    OCMStub([(Screens*)screensMock add:[OCMArg any]]).andReturn(screenMock);
    
    id campaignTrackerMock = OCMClassMock([Tracker class]);
    OCMStub([campaignTrackerMock screens]).andReturn(screensMock);
    
    id publisherMock = OCMClassMock([Publisher class]);
    id publishersMock = OCMClassMock([Publishers class]);
    OCMStub([(Publishers*)publishersMock add:[OCMArg any]]).andReturn(publisherMock);
    
    id publisherTrackerMock = OCMClassMock([Tracker class]);
    OCMStub([publisherTrackerMock publishers]).andReturn(publishersMock);

    OCMStub(ClassMethod([atInternetMock sharedInstance])).andReturn(atInternetMock);
    
    OCMStub([atInternetMock tracker:@"batch-campaign-tracker"]).andReturn(campaignTrackerMock);
    OCMStub([atInternetMock tracker:@"batch-publisher-tracker"]).andReturn(publisherTrackerMock);
    
    [self sendTestEventUsingDispatcher:[BatchATInternetDispatcher new]];
    
    OCMVerify([screenMock sendView]);
    OCMVerify([publisherMock sendImpression]);
}

/// Test that the dispatcher uses the overriden tracker in any case
- (void)testOverrideTracker {
    // Make sure ATInternet is never asked for anything: a strict mock
    // will throw on any message
    id atInternetMock = OCMStrictClassMock([ATInternet class]);
    OCMStub(ClassMethod([atInternetMock sharedInstance])).andReturn(atInternetMock);
    
    // -----
    // Setup our mock override tracker
    
    id screenMock = OCMClassMock([Screen class]);
    id screensMock = OCMClassMock([Screens class]);
    OCMStub([(Screens*)screensMock add:[OCMArg any]]).andReturn(screenMock);

    id publisherMock = OCMClassMock([Publisher class]);
    id publishersMock = OCMClassMock([Publishers class]);
    OCMStub([(Publishers*)publishersMock add:[OCMArg any]]).andReturn(publisherMock);
    
    id trackerMock = OCMClassMock([Tracker class]);
    OCMStub([trackerMock screens]).andReturn(screensMock);
    OCMStub([trackerMock publishers]).andReturn(publishersMock);

    // -----
    
    BatchATInternetDispatcher *dispatcher = [BatchATInternetDispatcher new];
    dispatcher.trackerOverride = trackerMock;
    [self sendTestEventUsingDispatcher:dispatcher];
    
    OCMVerify([screenMock sendView]);
    OCMVerify([publisherMock sendImpression]);
}

- (void)sendTestEventUsingDispatcher:(BatchATInternetDispatcher*)dispatcher {
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com/test?xtor=CS2-[mylabeltesttoto]-test-15[sef]";
    
    [dispatcher dispatchEventWithType:BatchEventDispatcherTypeMessagingShow payload:testPayload];
}

@end
