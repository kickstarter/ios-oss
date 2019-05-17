#import <Foundation/Foundation.h>

/**
 * This class provides constant fields of Google APIs.
 */
@interface FIROptions : NSObject<NSCopying>

/**
 * Returns the default options.
 */
+ (FIROptions *)defaultOptions;

/**
 * An iOS API key used for authenticating requests from your app, e.g.
 * @"AIzaSyDdVgKwhZl0sTTTLZ7iTmt1r3N2cJLnaDk", used to identify your app to Google servers.
 */
@property(nonatomic, readonly, copy) NSString *APIKey;

/**
 * The OAuth2 client ID for iOS application used to authenticate Google users, for example
 * @"12345.apps.googleusercontent.com", used for signing in with Google.
 */
@property(nonatomic, readonly, copy) NSString *clientID;

/**
 * The tracking ID for Google Analytics, e.g. @"UA-12345678-1", used to configure Google Analytics.
 */
@property(nonatomic, readonly, copy) NSString *trackingID;

/**
 * The Project Number from the Google Developer's console, for example @"012345678901", used to
 * configure Google Cloud Messaging.
 */
@property(nonatomic, readonly, copy) NSString *GCMSenderID;

/**
 * The Android client ID used in Google AppInvite when an iOS app has its Android version, for
 * example @"12345.apps.googleusercontent.com".
 */
@property(nonatomic, readonly, copy) NSString *androidClientID;

/**
 * The Google App ID that is used to uniquely identify an instance of an app.
 */
@property(nonatomic, readonly, copy) NSString *googleAppID;

/**
 * The database root URL, e.g. @"http://abc-xyz-123.firebaseio.com".
 */
@property(nonatomic, readonly, copy) NSString *databaseURL;

/**
 * The URL scheme used to set up Durable Deep Link service.
 */
@property(nonatomic, readwrite, copy) NSString *deepLinkURLScheme;

/**
 * The Google Cloud Storage bucket name, e.g. @"abc-xyz-123.storage.firebase.com".
 */
@property(nonatomic, readonly, copy) NSString *storageBucket;

/**
 * Initializes a customized instance of FIROptions with keys. googleAppID, bundleID and GCMSenderID
 * are required. Other keys may required for configuring specific services.
 */
- (instancetype)initWithGoogleAppID:(NSString *)googleAppID
                           bundleID:(NSString *)bundleID
                        GCMSenderID:(NSString *)GCMSenderID
                             APIKey:(NSString *)APIKey
                           clientID:(NSString *)clientID
                         trackingID:(NSString *)trackingID
                    androidClientID:(NSString *)androidClientID
                        databaseURL:(NSString *)databaseURL
                      storageBucket:(NSString *)storageBucket
                  deepLinkURLScheme:(NSString *)deepLinkURLScheme;

/**
 * Initializes a customized instance of FIROptions from the file at the given plist file path.
 * For example,
 * NSString *filePath =
 *     [[NSBundle mainBundle] pathForResource:@"GoogleService-Info" ofType:@"plist"];
 * FIROptions *options = [[FIROptions alloc] initWithContentsOfFile:filePath];
 * Returns nil if the plist file does not exist or is invalid.
 */
- (instancetype)initWithContentsOfFile:(NSString *)plistPath;

@end
