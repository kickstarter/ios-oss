#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class FIROptions;

NS_ASSUME_NONNULL_BEGIN

typedef void (^FIRAppVoidBoolCallback)(BOOL success);

/**
 * The entry point of Firebase SDKs.
 *
 * Initialize and configure FIRApp using [FIRApp configure];
 * Or other customized ways as shown below.
 */
@interface FIRApp : NSObject

/**
 * Configures a default Firebase app. Raises an exception if any configuration step fails. The
 * default app is named "__FIRAPP_DEFAULT". This method should be called after the app is launched
 * and before using Firebase services. This method is thread safe.
 */
+ (void)configure;

/**
 * Configures the default Firebase app with the provided options. The default app is named
 * "__FIRAPP_DEFAULT". Raises an exception if any configuration step fails. This method is thread
 * safe.
 *
 * @param options The Firebase application options used to configure the service.
 */
+ (void)configureWithOptions:(FIROptions *)options;

/**
 * Configures a Firebase app with the given name and options. Raises an exception if any
 * configuration step fails. This method is thread safe.
 *
 * @param name The application's name given by the developer. The name should should only contain
               Letters, Numbers and Underscore.
 * @param options The Firebase application options used to configure the services.
 */
+ (void)configureWithName:(NSString *)name options:(FIROptions *)options;

/**
 * Returns the default app, or nil if the default app does not exist.
 */
+ (nullable FIRApp *)defaultApp NS_SWIFT_NAME(defaultApp());

/**
 * Returns a previously created FIRApp instance with the given name, or nil if no such app exists.
 * This method is thread safe.
 */
+ (nullable FIRApp *)appNamed:(NSString *)name;

/**
 * Returns the set of all extant FIRApp instances, or nil if there is no FIRApp instance. This
 * method is thread safe.
 */
+ (nullable NSDictionary *)allApps;

/**
 * Cleans up the current FIRApp, freeing associated data and returning its name to the pool for
 * future use. This method is thread safe in class level.
 */
- (void)deleteApp:(FIRAppVoidBoolCallback)completion;

/**
 * FIRFirebaseApp instances should not be initialized directly. Call |FIRApp configure|, or
 * |FIRApp configureWithOptions:|, or |FIRApp configureWithNames:options| directly.
 */
- (nullable instancetype)init NS_UNAVAILABLE;

/**
 * Gets the name of this app.
 */
@property(nonatomic, copy, readonly) NSString *name;

/**
 * Gets the options for this app.
 */
@property(nonatomic, readonly) FIROptions *options;

@end

NS_ASSUME_NONNULL_END
