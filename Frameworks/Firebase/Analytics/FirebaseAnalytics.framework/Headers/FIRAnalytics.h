#import <Foundation/Foundation.h>

#import "FIREventNames.h"
#import "FIRParameterNames.h"
#import "FIRUserPropertyNames.h"

/// The top level Firebase Analytics singleton that provides methods for logging events and setting
/// user properties. See <a href="http://goo.gl/gz8SLz">the developer guides</a> for general
/// information on using Firebase Analytics in your apps.
@interface FIRAnalytics : NSObject

/// Logs an app event. The event can have up to 25 parameters. Events with the same name must have
/// the same parameters. Up to 500 event names are supported. Using predefined events and/or
/// parameters is recommended for optimal reporting.
///
/// The following event names are reserved and cannot be used:
/// <ul>
///     <li>app_clear_data</li>
///     <li>app_uninstall</li>
///     <li>app_update</li>
///     <li>error</li>
///     <li>first_open</li>
///     <li>in_app_purchase</li>
///     <li>notification_dismiss</li>
///     <li>notification_foreground</li>
///     <li>notification_open</li>
///     <li>notification_receive</li>
///     <li>os_update</li>
///     <li>session_start</li>
///     <li>user_engagement</li>
/// </ul>
///
/// @param name The name of the event. Should contain 1 to 32 alphanumeric characters or
///     underscores. The name must start with an alphabetic character. Some event names are
///     reserved. See FIREventNames.h for the list of reserved event names. The "firebase_" prefix
///     is reserved and should not be used. Note that event names are case-sensitive and that
///     logging two events whose names differ only in case will result in two distinct events.
/// @param parameters The dictionary of event parameters. Passing nil indicates that the event has
///     no parameters. Parameter names can be up to 24 characters long and must start with an
///     alphabetic character and contain only alphanumeric characters and underscores. Only NSString
///     and NSNumber (signed 64-bit integer and 64-bit floating-point number) parameter types are
///     supported. NSString parameter values can be up to 36 characters long. The "firebase_" prefix
///     is reserved and should not be used for parameter names.
+ (void)logEventWithName:(nonnull NSString *)name
              parameters:(nullable NSDictionary<NSString *, NSObject *> *)parameters;

/// Sets a user property to a given value. Up to 25 user property names are supported. Once set,
/// user property values persist throughout the app lifecycle and across sessions.
///
/// The following user property names are reserved and cannot be used:
/// <ul>
///     <li>first_open_time</li>
///     <li>last_deep_link_referrer</li>
///     <li>user_id</li>
/// </ul>
///
/// @param value The value of the user property. Values can be up to 36 characters long. Setting the
///     value to nil removes the user property.
/// @param name The name of the user property to set. Should contain 1 to 24 alphanumeric characters
///     or underscores and must start with an alphabetic character. The "firebase_" prefix is
///     reserved and should not be used for user property names.
+ (void)setUserPropertyString:(nullable NSString *)value forName:(nonnull NSString *)name;

/// Sets the user ID property. This feature must be used in accordance with
/// <a href="https://www.google.com/policies/privacy">Google's Privacy Policy</a>
///
/// @param userID The user ID to ascribe to the user of this app on this device, which must be
///     non-empty and no more than 36 characters long. Setting userID to nil removes the user ID.
+ (void)setUserID:(nullable NSString *)userID;

@end
