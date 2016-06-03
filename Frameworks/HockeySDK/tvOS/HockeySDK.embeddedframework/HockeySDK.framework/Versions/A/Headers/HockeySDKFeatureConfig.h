#ifndef HockeySDK_HockeySDKFeatureConfig_h
#define HockeySDK_HockeySDKFeatureConfig_h

/**
 * If true, include support for handling crash reports
 *
 * _Default_: Enabled
 */
#ifndef HOCKEYSDK_FEATURE_CRASH_REPORTER
#    define HOCKEYSDK_FEATURE_CRASH_REPORTER 1
#endif /* HOCKEYSDK_FEATURE_CRASH_REPORTER */

/**
 * If true, include support for handling in-app updates for Ad-Hoc and Enterprise builds
 *
 * _Default_: Enabled
 */
#ifndef HOCKEYSDK_FEATURE_UPDATES
#    define HOCKEYSDK_FEATURE_UPDATES 1
#endif /* HOCKEYSDK_FEATURE_UPDATES */

/**
 * If true, include support for authentication installations for Ad-Hoc and Enterprise builds
 *
 * _Default_: Enabled
 */
#ifndef HOCKEYSDK_FEATURE_AUTHENTICATOR
#    define HOCKEYSDK_FEATURE_AUTHENTICATOR 1
#endif /* HOCKEYSDK_FEATURE_AUTHENTICATOR */

/**
 * If true, include support for auto collecting metrics data such as sessions and user
 *
 * _Default_: Enabled
 */
#ifndef HOCKEYSDK_FEATURE_METRICS
#    define HOCKEYSDK_FEATURE_METRICS 1
#endif /* HOCKEYSDK_FEATURE_METRICS */

#endif /* HockeySDK_HockeySDKFeatureConfig_h */
