#import <Foundation/Foundation.h>

#import "FIRAnalyticsConfiguration.h"

/**
 * The log levels used by FIRConfiguration.
 */
typedef NS_ENUM(NSInteger, FIRLogLevel) {
  kFIRLogLevelError = 0,
  kFIRLogLevelWarning,
  kFIRLogLevelInfo,
  kFIRLogLevelDebug,
  kFIRLogLevelAssert,
  kFIRLogLevelMax = kFIRLogLevelAssert
};

/**
 * This interface provides global level properties that the developer can tweak, and the singleton
 * of each Google service configuration class.
 */
@interface FIRConfiguration : NSObject

+ (FIRConfiguration *)sharedInstance;

// The configuration class for Firebase Analytics.
@property(nonatomic, readwrite) FIRAnalyticsConfiguration *analyticsConfiguration;

// Global log level. Defaults to kFIRLogLevelError.
@property(nonatomic, readwrite, assign) FIRLogLevel logLevel;

@end
