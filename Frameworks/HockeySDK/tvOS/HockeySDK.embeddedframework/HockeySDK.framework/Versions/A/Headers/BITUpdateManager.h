#import "BITHockeyBaseManager.h"

/**
 *  Update check interval
 */
typedef NS_ENUM (NSUInteger, BITUpdateSetting) {
  /**
   *  On every startup or or when the app comes to the foreground
   */
  BITUpdateCheckStartup = 0,
  /**
   *  Once a day
   */
  BITUpdateCheckDaily = 1,
  /**
   *  Manually
   */
  BITUpdateCheckManually = 2
};

@protocol BITUpdateManagerDelegate;

@class BITAppVersionMetaInfo;

/**
 The update manager module.
 
 This is the HockeySDK module for handling app updates when using Ad-Hoc or Enterprise provisioning profiles.
 This module handles version updates, presents update and version information in an App Store like user interface,
 collects usage information and provides additional authorization options when using Ad-Hoc provisioning profiles.
 
 By default, this module automatically disables itself when running in an App Store build!
 
 The protocol `BITUpdateManagerDelegate` provides delegates to inform about events and adjust a few behaviors.
 
 To use the server side restriction feature, to provide updates only to specific users, you need to setup the
 `BITAuthenticator` class. This allows the update request to tell the server which user is using the app on the
 current device and then let the server decide which updates the device may see.
 
 */

@interface BITUpdateManager : BITHockeyBaseManager

///-----------------------------------------------------------------------------
/// @name Update Checking
///-----------------------------------------------------------------------------

// see HockeyUpdateSetting-enum. Will be saved in user defaults.
// default value: HockeyUpdateCheckStartup
/**
 When to check for new updates.
 
 Defines when the SDK should check if there is a new update available on the
 server. This must be assigned one of the following, see `BITUpdateSetting`:
 
 - `BITUpdateCheckStartup`: On every startup or or when the app comes to the foreground
 - `BITUpdateCheckDaily`: Once a day
 - `BITUpdateCheckManually`: Manually
 
 When running the app from the App Store, this setting is ignored.

 **Default**: BITUpdateCheckStartup
 
 @warning When setting this to `BITUpdateCheckManually` you need to either
 invoke the update checking process yourself with `checkForUpdate` somehow, e.g. by
 proving an update check button for the user or integrating the Update View into your
 user interface.
 @see BITUpdateSetting
 @see checkForUpdateOnLaunch
 @see checkForUpdate
 */
@property (nonatomic, assign) BITUpdateSetting updateSetting;


/**
 Flag that determines whether the automatic update checks should be done.
 
 If this is enabled the update checks will be performed automatically depending on the
 `updateSetting` property. If this is disabled the `updateSetting` property will have
 no effect, and checking for updates is totally up to be done by yourself.
 
 When running the app from the App Store, this setting is ignored.

 *Default*: _YES_

 @warning When setting this to `NO` you need to invoke update checks yourself!
 @see updateSetting
 @see checkForUpdate
 */
@property (nonatomic, assign, getter=isCheckForUpdateOnLaunch) BOOL checkForUpdateOnLaunch;


// manually start an update check
/**
 Check for an update
 
 Call this to trigger a check if there is a new update available on the HockeyApp servers.
 
 When running the app from the App Store, this method call is ignored.

 @see updateSetting
 @see checkForUpdateOnLaunch
 */
- (void)checkForUpdate;


///-----------------------------------------------------------------------------
/// @name Update Notification
///-----------------------------------------------------------------------------

/**
 Flag that determines if update alerts should be repeatedly shown
 
 If enabled the update alert shows on every startup and whenever the app becomes active,
 until the update is installed.
 If disabled the update alert is only shown once ever and it is up to you to provide an
 alternate way for the user to navigate to the update UI or update in another way.
 
 When running the app from the App Store, this setting is ignored.

 *Default*: _YES_
 */
@property (nonatomic, assign) BOOL alwaysShowUpdateReminder;

///-----------------------------------------------------------------------------
/// @name Expiry
///-----------------------------------------------------------------------------

/**
 Expiry date of the current app version
 
 If set, the app will get unusable at the given date by presenting a blocking view on
 top of the apps UI so that no interaction is possible. To present a custom UI, check
 the documentation of the 
 `[BITUpdateManagerDelegate shouldDisplayExpiryAlertForUpdateManager:]` delegate.
 
 Once the expiry date is reached, the app will no longer check for updates or
 send any usage data to the server!
 
 When running the app from the App Store, this setting is ignored.
 
 *Default*: nil
 @see disableUpdateCheckOptionWhenExpired
 @see [BITUpdateManagerDelegate shouldDisplayExpiryAlertForUpdateManager:]
 @see [BITUpdateManagerDelegate didDisplayExpiryAlertForUpdateManager:]
 @warning This only works when using Ad-Hoc provisioning profiles!
 */
@property (nonatomic, strong) NSDate *expiryDate;

/**
 Disable the update check button from expiry screen or alerts

 If do not want your users to be able to check for updates once a version is expired,
 then enable this property.
 
 If this is not enabled, the users will be able to check for updates and install them
 if any is available for the current device.

 *Default*: NO
 @see expiryDate
 @see [BITUpdateManagerDelegate shouldDisplayExpiryAlertForUpdateManager:]
 @see [BITUpdateManagerDelegate didDisplayExpiryAlertForUpdateManager:]
 @warning This only works when using Ad-Hoc provisioning profiles!
*/
@property (nonatomic) BOOL disableUpdateCheckOptionWhenExpired;

@end
