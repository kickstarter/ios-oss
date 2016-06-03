#import <Foundation/Foundation.h>

#import "HockeySDKFeatureConfig.h"
#import "HockeySDKEnums.h"
#import "HockeySDKNullability.h"

#import "BITHockeyManager.h"
#import "BITHockeyManagerDelegate.h"

#if HOCKEYSDK_FEATURE_CRASH_REPORTER
#import "BITCrashManager.h"
#import "BITCrashAttachment.h"
#import "BITCrashManagerDelegate.h"
#import "BITCrashDetails.h"
#import "BITCrashMetaData.h"
#endif /* HOCKEYSDK_FEATURE_CRASH_REPORTER */

#if HOCKEYSDK_FEATURE_UPDATES
#import "BITUpdateManager.h"
#import "BITUpdateManagerDelegate.h"
#endif /* HOCKEYSDK_FEATURE_UPDATES */

#if HOCKEYSDK_FEATURE_AUTHENTICATOR
#import "BITAuthenticator.h"
#endif /* HOCKEYSDK_FEATURE_AUTHENTICATOR */

#if HOCKEYSDK_FEATURE_METRICS
#import "BITMetricsManager.h"
#endif /* HOCKEYSDK_FEATURE_METRICS */

// Notification message which HockeyManager is listening to, to retry requesting updated from the server.
// This can be used by app developers to trigger additional points where the HockeySDK can try sending
// pending crash reports or feedback messages.
// By default the SDK retries sending pending data only when the app becomes active.
#define BITHockeyNetworkDidBecomeReachableNotification @"BITHockeyNetworkDidBecomeReachable"

extern NSString *const __attribute__((unused)) kBITCrashErrorDomain;
extern NSString *const __attribute__((unused)) kBITUpdateErrorDomain;
extern NSString *const __attribute__((unused)) kBITFeedbackErrorDomain;
extern NSString *const __attribute__((unused)) kBITAuthenticatorErrorDomain;
extern NSString *const __attribute__((unused)) kBITHockeyErrorDomain;

