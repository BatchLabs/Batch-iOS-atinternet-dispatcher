#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "BatchXtor.h"

@interface BatchXtorTests : XCTestCase

@end

@implementation BatchXtorTests

- (void)setUp
{
    [super setUp];
    self.continueAfterFailure = false;
}

- (void)compareXtor:(NSArray<NSString *> *)expectedParts with:(BatchXtor *)xtor
{
   XCTAssertEqual(expectedParts.count, xtor.parts.count);
    for (int i = 0; i < expectedParts.count; ++i) {
        XCTAssertTrue([[expectedParts objectAtIndex:i] isEqualToString:[xtor.parts objectAtIndex:i]]);
        XCTAssertTrue([[expectedParts objectAtIndex:i] isEqualToString:[xtor partAtIndex:i]]);
    }
}

- (void)testValidXtor
{
    NSString *xtorTag = @"EPR-50-[BA_notification_2019_09_24]-20190924-[WEB_BA_notification]";
    BatchXtor *xtor = [[BatchXtor alloc] initWithTag:xtorTag];
    
    NSArray<NSString *> *expectedParts = @[
        @"EPR",
        @"50",
        @"[BA_notification_2019_09_24]",
        @"20190924",
        @"[WEB_BA_notification]"
    ];
    
    [self compareXtor:expectedParts with:xtor];
    XCTAssertTrue([xtor isValid]);
}

- (void)testValidXtor2
{
    NSString *xtorTag = @"CS1-[mylabeltest]-test-15[sef]";
    BatchXtor *xtor = [[BatchXtor alloc] initWithTag:xtorTag];
    
    NSArray<NSString *> *expectedParts = @[
        @"CS1",
        @"[mylabeltest]",
        @"test",
        @"15[sef]",
    ];
    
    [self compareXtor:expectedParts with:xtor];
    XCTAssertTrue([xtor isValid]);
}

- (void)testValidPartialXtor
{
    NSString *xtorTag = @"EPR-2413";
    BatchXtor *xtor = [[BatchXtor alloc] initWithTag:xtorTag];
    
    NSArray<NSString *> *expectedParts = @[
        @"EPR",
        @"2413",
    ];
    
    [self compareXtor:expectedParts with:xtor];
    XCTAssertTrue([xtor isValid]);
}

- (void)testValidXtorWithEmptyLabel
{
    NSString *xtorTag = @"EPR-50-[BA-notification-2019-09-23]-20190923-[WEB_BA_notification]-[]-[]-";
    BatchXtor *xtor = [[BatchXtor alloc] initWithTag:xtorTag];
    
    NSArray<NSString *> *expectedParts = @[
        @"EPR",
        @"50",
        @"[BA-notification-2019-09-23]",
        @"20190923",
        @"[WEB_BA_notification]",
        @"[]",
        @"[]"
    ];
    
    [self compareXtor:expectedParts with:xtor];
    XCTAssertTrue([xtor isValid]);
}

- (void)testInvalidXtor
{
    NSString *xtorTag = @"---";
    BatchXtor *xtor = [[BatchXtor alloc] initWithTag:xtorTag];
    
    NSArray<NSString *> *expectedParts = @[
        @"",
        @"",
        @""
    ];
    
    [self compareXtor:expectedParts with:xtor];
    XCTAssertFalse([xtor isValid]);
}

- (void)testInvalidXtor2
{
    NSString *xtorTag = @"salut salut";
    BatchXtor *xtor = [[BatchXtor alloc] initWithTag:xtorTag];
    
    NSArray<NSString *> *expectedParts = @[
        @"salut salut"
    ];
    
    [self compareXtor:expectedParts with:xtor];
    XCTAssertFalse([xtor isValid]);
}

- (void)testInvalidXtor3
{
    NSString *xtorTag = @"-test-15[sefsef]--";
    BatchXtor *xtor = [[BatchXtor alloc] initWithTag:xtorTag];
    
    NSArray<NSString *> *expectedParts = @[
        @"",
        @"test",
        @"15[sefsef]",
        @"",
    ];
    
    [self compareXtor:expectedParts with:xtor];
    XCTAssertFalse([xtor isValid]);
}

@end
