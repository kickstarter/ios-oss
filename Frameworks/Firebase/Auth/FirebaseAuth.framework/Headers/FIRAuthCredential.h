/** @file FIRAuthCredential.h
    @brief Firebase Auth SDK
    @copyright Copyright 2015 Google Inc.
    @remarks Use of this SDK is subject to the Google APIs Terms of Service:
        https://developers.google.com/terms/
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** @class FIRAuthCredential
    @brief Represents a credential.
 */
@interface FIRAuthCredential : NSObject

/** @property provider
    @brief Gets the name of the identity provider for the credential.
 */
@property(nonatomic, copy, readonly) NSString *provider;

/** @fn init
    @brief This is an abstract base class. Concrete instances should be created via factory
        methods available in the various authentication provider libraries (like the Facebook
        provider or the Google provider libraries.)
 */
- (nullable instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
