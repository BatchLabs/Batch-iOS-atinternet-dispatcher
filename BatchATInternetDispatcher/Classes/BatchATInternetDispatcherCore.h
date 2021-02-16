#import <Batch/BatchEventDispatcher.h>
#import <Tracker/Tracker-Swift.h>

@interface BatchATInternetDispatcher : NSObject <BatchEventDispatcherDelegate>

+ (nonnull instancetype)instance;

/// ATInternet tracker instance override.
/// If this is nil, Batch will instantiate and use two trackers ("batch-campaign-tracker", "batch-publisher-tracker)
/// using [ATInternet.sharedInstance tracker]. This can cause issue if you configure a tracker instance manually,
/// without using ATInternet's plist-based configuration.
/// Change this property to provide your own tracker instance.
/// nil by default.
@property (nullable) Tracker *trackerOverride;

@end
