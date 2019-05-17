/** @file FIRGitHubAuthProvider.h
    @brief Firebase Auth SDK
    @copyright Copyright 2016 Google Inc.
    @remarks Use of this SDK is subject to the Google APIs Terms of Service:
        https://developers.google.com/terms/
 */

#import <Foundation/Foundation.h>

@class FIRAuthCredential;

NS_ASSUME_NONNULL_BEGIN

/** @var FIRGitHubAuthProviderID
    @brief A string constant identifying the GitHub identity provider.
 */
extern NSString *const FIRGitHubAuthProviderID;

/** @class FIRGitHubAuthProvider
    @brief Utility class for constructing GitHub credentials.
 */
@interface FIRGitHubAuthProvider : NSObject

/** @fn credentialWithToken:
    @brief Creates an @c FIRAuthCredential for a GitHub sign in.
    @param token The GitHub OAuth access token.
    @return A @c FIRAuthCredential containing the GitHub credential.
 */
+ (FIRAuthCredential *)credentialWithToken:(NSString *)token;

/** @fn init
    @brief This class is not meant to be initialized.
 */
- (nullable instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
