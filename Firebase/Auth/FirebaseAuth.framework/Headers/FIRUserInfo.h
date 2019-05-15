/** @file FIRUserInfo.h
    @brief Firebase Auth SDK
    @copyright Copyright 2015 Google Inc.
    @remarks Use of this SDK is subject to the Google APIs Terms of Service:
        https://developers.google.com/terms/
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** @protocol FIRUserInfo
    @brief Represents user data returned from an identity provider.
 */
@protocol FIRUserInfo <NSObject>

/** @property providerID
    @brief The provider identifier.
 */
@property(nonatomic, copy, readonly) NSString *providerID;

/** @property uid
    @brief The provider's user ID for the user.
 */
@property(nonatomic, copy, readonly) NSString *uid;

/** @property displayName
    @brief The name of the user.
 */
@property(nonatomic, copy, readonly, nullable) NSString *displayName;

/** @property photoURL
    @brief The URL of the user's profile photo.
 */
@property(nonatomic, copy, readonly, nullable) NSURL *photoURL;

/** @property email
    @brief The user's email address.
 */
@property(nonatomic, copy, readonly, nullable) NSString *email;

@end

NS_ASSUME_NONNULL_END
