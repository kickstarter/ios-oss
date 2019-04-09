/** @file FIREmailPasswordAuthProvider.h
    @brief Firebase Auth SDK
    @copyright Copyright 2016 Google Inc.
    @remarks Use of this SDK is subject to the Google APIs Terms of Service:
        https://developers.google.com/terms/
 */

#import <Foundation/Foundation.h>

@class FIRAuthCredential;

NS_ASSUME_NONNULL_BEGIN

/** @var FIREmailPasswordAuthProviderID
    @brief A string constant identifying the email & password identity provider.
 */
extern NSString *const FIREmailPasswordAuthProviderID;

/** @class FIREmailPasswordAuthProvider
    @brief A concrete implementation of @c FIRAuthProvider for Email & Password Sign In.
 */
@interface FIREmailPasswordAuthProvider : NSObject

/** @fn credentialWithEmail:password:
    @brief Creates an @c FIRAuthCredential for an email & password sign in.
    @param email The user's email address.
    @param password The user's password.
    @return A @c FIRAuthCredential containing the email & password credential.
 */
+ (FIRAuthCredential *)credentialWithEmail:(NSString *)email password:(NSString *)password;

/** @fn init
    @brief This class is not meant to be initialized.
 */
- (nullable instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
