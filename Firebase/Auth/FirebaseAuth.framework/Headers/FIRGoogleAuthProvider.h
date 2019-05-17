/** @file FIRGoogleAuthProvider.h
    @brief Firebase Auth SDK
    @copyright Copyright 2016 Google Inc.
    @remarks Use of this SDK is subject to the Google APIs Terms of Service:
        https://developers.google.com/terms/
 */

#import <Foundation/Foundation.h>

@class FIRAuthCredential;

NS_ASSUME_NONNULL_BEGIN

/** @var FIRGoogleAuthProviderID
    @brief A string constant identifying the Google identity provider.
 */
extern NSString *const FIRGoogleAuthProviderID;

/** @class FIRGoogleAuthProvider
    @brief Utility class for constructing Google Sign In credentials.
 */
@interface FIRGoogleAuthProvider : NSObject

/** @fn credentialWithIDToken:accessToken:
    @brief Creates an @c FIRAuthCredential for a Google sign in.
    @param IDToken The ID Token from Google.
    @param accessToken The Access Token from Google.
    @return A @c FIRAuthCredential containing the Google credentials.
 */
+ (FIRAuthCredential *)credentialWithIDToken:(NSString *)IDToken
                                 accessToken:(NSString *)accessToken;

/** @fn init
    @brief This class should not be initialized.
 */
- (nullable instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
