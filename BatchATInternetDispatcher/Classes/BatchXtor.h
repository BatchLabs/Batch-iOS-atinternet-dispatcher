@interface BatchXtor : NSObject

@property (nonnull, readonly) NSArray<NSString *> *parts;

- (nonnull instancetype)initWithTag:(nonnull NSString*)xtorTag;

- (BOOL)isValid;

- (nullable NSString*)partAtIndex:(NSUInteger)idx;

@end
