/** @file FIRFacebookAuthProvider.h
    @brief Firebase Auth SDK
    @copyright Copyright 2016 Google Inc.
    @remarks Use of this SDK is subject to the Google APIs Terms of Service:
        https://developers.google.com/terms/
 */

#import <Foundation/Foundation.h>

@class FIRAuthCredential;

NS_ASSUME_NONNULL_BEGIN

/** @var FIRFacebookAuthProviderID
    @brief A string constant identifying the Facebook identity provider.
 */
extern NSString *const FIRFacebookAuthProviderID;

/** @class FIRFacebookAuthProvider
    @brief Utility class for constructing Facebook credentials.
 */
@interface FIRFacebookAuthProvider : NSObject

/** @fn credentialWithAccessToken:
    @brief Creates an @c FIRAuthCredential for a Facebook sign in.
    @param accessToken The Access Token from Facebook.
    @return A @c FIRAuthCredential containing the Facebook credentials.
 */
+ (FIRAuthCredential *)credentialWithAccessToken:(NSString *)accessToken;

/** @fn init
    @brief This class should not be initialized.
 */
- (nullable instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
