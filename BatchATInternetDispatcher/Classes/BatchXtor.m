#import <Foundation/Foundation.h>

#import "BatchXtor.h"

@implementation BatchXtor

- (nonnull instancetype)initWithTag:(nonnull NSString*)xtorTag
{
    self = [super init];
    if (self) {
        NSMutableArray *array = [NSMutableArray array];
        BOOL isEscaped = false;
        NSUInteger partStart = 0;
        
        for (NSUInteger i = 0; i < xtorTag.length; i++) {
            unichar c = [xtorTag characterAtIndex:i];
            switch (c) {
                case '[':
                    isEscaped = true;
                    break;
                case ']':
                    isEscaped = false;
                    break;
                case '-':
                    if (!isEscaped) {
                        NSString *newPart = [xtorTag substringWithRange: NSMakeRange(partStart, i - partStart)];
                        [array addObject:newPart];
                        partStart = i + 1;
                    }
                    break;
            }
        }

        if (!isEscaped && partStart < xtorTag.length) {
            [array addObject:[xtorTag substringFromIndex:partStart]];
        }
        _parts = [array copy];
    }
    return self;
}

- (BOOL)isValid
{
    NSArray* xtorPrefixes = @[
        @"AD", // Advertisement
        @"AL", // Affiliation
        @"SEC", // Sponsored link
        @"EREC", // Email marketing - Acquisition
        @"EPR", // Email marketing - Retention
        @"ES", // Email marketing - Promotion
        @"CS", // Custom marketing campaigns
        @"PUB", // On-site ads
        @"INT" // Self-promotion
    ];
    
    if (self.parts != nil && self.parts.count >= 2) {
        for (NSString *prefix in xtorPrefixes) {
            if ([self.parts.firstObject hasPrefix:prefix]) {
                return true;
            }
        }
    }
    return false;
}

- (nullable NSString*)partAtIndex:(NSUInteger)idx
{
    return [self.parts objectAtIndex:idx];
}

@end
