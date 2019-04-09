/** @file FIRUser.h
    @brief Firebase Auth SDK
    @copyright Copyright 2015 Google Inc.
    @remarks Use of this SDK is subject to the Google APIs Terms of Service:
        https://developers.google.com/terms/
 */

#import <Foundation/Foundation.h>

#import <FirebaseAuth/FIRAuth.h>
#import <FirebaseAuth/FIRUserInfo.h>

@class FIRUserProfileChangeRequest;

NS_ASSUME_NONNULL_BEGIN

/** @typedef FIRAuthTokenCallback
    @brief The type of block called when a token is ready for use.
    @see FIRUser.getTokenWithCompletion:
    @see FIRUser.getTokenForcingRefresh:withCompletion:
    @param token Optionally; an access token if the request was successful.
    @param error Optionally; the error which occurred - or nil if the request was successful.
    @remarks One of: @c token or @c error will always be non-nil.
 */
typedef void (^FIRAuthTokenCallback)(NSString *_Nullable token, NSError *_Nullable error);

/** @typedef FIRUserProfileChangeCallback
    @brief The type of block called when a user profile change has finished.
    @param error Optionally; the error which occurred - or nil if the request was successful.
 */
typedef void (^FIRUserProfileChangeCallback)(NSError *_Nullable error);

/** @typedef FIRSendEmailVerificationCallback
    @brief The type of block called when a request to send an email verification has finished.
    @param error Optionally; the error which occurred - or nil if the request was successful.
 */
typedef void (^FIRSendEmailVerificationCallback)(NSError *_Nullable error);

/** @class FIRUser
    @brief Represents a user.
    @remarks This class is thread-safe.
 */
@interface FIRUser : NSObject <FIRUserInfo>

/** @property anonymous
    @brief Indicates the user represents an anonymous user.
 */
@property(nonatomic, readonly, getter=isAnonymous) BOOL anonymous;

/** @property emailVerified
    @brief Indicates the email address associated with this user has been verified.
 */
@property(nonatomic, readonly, getter=isEmailVerified) BOOL emailVerified;

/** @property refreshToken
    @brief A refresh token; useful for obtaining new access tokens independently.
    @remarks This property should only be used for advanced scenarios, and is not typically needed.
 */
@property(nonatomic, readonly, nullable) NSString *refreshToken;

/** @property providerData
    @brief Profile data for each identity provider, if any.
    @remarks This data is cached on sign-in and updated when linking or unlinking.
 */
@property(nonatomic, readonly, nonnull) NSArray<id<FIRUserInfo>> *providerData;

/** @fn init
    @brief This class should not be instantiated.
    @remarks To retrieve the current user, use @c FIRAuth.currentUser. To sign a user
        in or out, use the methods on @c FIRAuth.
 */
- (nullable instancetype)init NS_UNAVAILABLE;

/** @fn updateEmail:completion:
    @brief Updates the email address for the user. On success, the cached user profile data is
        updated.
    @remarks May fail if there is already an account with this email address that was created using
        email and password authentication.
    @param email The email address for the user.
    @param completion Optionally; the block invoked when the user profile change has finished.
        Invoked asynchronously on the main thread in the future.
    @remarks Possible error codes:
        - @c FIRAuthErrorCodeEmailAlreadyInUse - Indicates the email is already in use by another
            account.
        - @c FIRAuthErrorCodeInvalidEmail - Indicates the email address is malformed.
        - @c FIRAuthErrorCodeRequiresRecentLogin - Updating a user’s email is a security sensitive
            operation that requires a recent login from the user. This error indicates the user has
            not signed in recently enough. To resolve, reauthenticate the user by invoking
            reauthenticateWithCredential:completion: on FIRUser.
        - See @c FIRAuthErrors for a list of error codes that are common to all FIRUser operations.
 */
- (void)updateEmail:(NSString *)email completion:(nullable FIRUserProfileChangeCallback)completion;

/** @fn updatePassword:completion:
    @brief Updates the password for the user. On success, the cached user profile data is updated.
    @param password The new password for the user.
    @param completion Optionally; the block invoked when the user profile change has finished.
        Invoked asynchronously on the main thread in the future.
    @remarks Possible error codes:
        - @c FIRAuthErrorCodeOperationNotAllowed - Indicates the administrator disabled sign in with
            the specified identity provider.
        - @c FIRAuthErrorCodeRequiresRecentLogin - Updating a user’s password is a security
            sensitive operation that requires a recent login from the user. This error indicates the
            user has not signed in recently enough. To resolve, reauthenticate the user by invoking
            reauthenticateWithCredential:completion: on FIRUser.
        - @c FIRAuthErrorCodeWeakPassword - Indicates an attempt to set a password that is
            considered too weak. The NSLocalizedFailureReasonErrorKey field in the NSError.userInfo
            dictionary object will contain more detailed explanation that can be shown to the user.
        - See @c FIRAuthErrors for a list of error codes that are common to all FIRUser operations.
 */
- (void)updatePassword:(NSString *)password
            completion:(nullable FIRUserProfileChangeCallback)completion;

/** @fn profileChangeRequest
    @brief Creates an object which may be used to change the user's profile data.
    @remarks Set the properties of the returned object, then call
        @c FIRUserProfileChangeRequest.commitChangesWithCallback: to perform the updates atomically.
    @return An object which may be used to change the user's profile data atomically.
 */
- (FIRUserProfileChangeRequest *)profileChangeRequest;

/** @fn reloadWithCompletion:
    @brief Reloads the user's profile data from the server.
    @param completion Optionally; the block invoked when the reload has finished. Invoked
        asynchronously on the main thread in the future.
    @remarks May fail with a @c FIRAuthErrorCodeCredentialTooOld error code. In this case you should
        call @c FIRUser.reauthenticateWithCredential:completion: before re-invoking
        @c FIRUser.updateEmail:completion:.
    @remarks Possible error codes:
        - See @c FIRAuthErrors for a list of error codes that are common to all API methods.
 */
- (void)reloadWithCompletion:(nullable FIRUserProfileChangeCallback)completion;

/** @fn reauthenticateWithCredential:completion:
    @brief Renews the user's authentication tokens by validating a fresh set of credentials supplied
        by the user.
    @param credential A user-supplied credential, which will be validated by the server. This can be
        a successful third-party identity provider sign-in, or an email address and password.
    @param completion Optionally; the block invoked when the re-authentication operation has
        finished. Invoked asynchronously on the main thread in the future.
    @remarks If the user associated with the supplied credential is different from the current user,
        or if the validation of the supplied credentials fails; an error is returned and the current
        user remains signed in.
    @remarks Possible error codes:
        - @c FIRAuthErrorCodeInvalidCredential Indicates the supplied credential is invalid. This
                could happen if it has expired or it is malformed.
        - @c FIRAuthErrorCodeOperationNotAllowed Indicates that accounts with the identity provider
            represented by the credential are not enabled. Enable them in the Auth section of the
            Firebase console.
        - @c FIRAuthErrorCodeEmailAlreadyInUse Indicates the email asserted by the credential
            (e.g. the email in a Facebook access token) is already in use by an existing account,
            that cannot be authenticated with this method. Call fetchProvidersForEmail for
            this user’s email and then prompt them to sign in with any of the sign-in providers
            returned. This error will only be thrown if the “One account per email address”
            setting is enabled in the Firebase console, under Auth settings. - Please note that the
            error code raised in this specific situation may not be the same on Web and Android.
        - @c FIRAuthErrorCodeUserDisabled Indicates the user's account is disabled.
        - @c FIRAuthErrorCodeWrongPassword Indicates the user attempted reauthentication with an
            incorrect password, if credential is of the type EmailPasswordAuthCredential.
        - @c FIRAuthErrorCodeUserMismatch Indicates that an attempt was made to reauthenticate with
            a user which is not the current user.
        - See @c FIRAuthErrors for a list of error codes that are common to all API methods.
 */
- (void)reauthenticateWithCredential:(FIRAuthCredential *)credential
                          completion:(nullable FIRUserProfileChangeCallback)completion;

/** @fn getTokenWithCompletion:
    @brief Retrieves the Firebase authentication token, possibly refreshing it if it has expired.
    @param completion Optionally; the block invoked when the token is available. Invoked
        asynchronously on the main thread in the future.
    @remarks Possible error codes:
        - See @c FIRAuthErrors for a list of error codes that are common to all API methods.
 */
- (void)getTokenWithCompletion:(nullable FIRAuthTokenCallback)completion;

/** @fn getTokenForcingRefresh:completion:
    @brief Retrieves the Firebase authentication token, possibly refreshing it if it has expired.
    @param forceRefresh Forces a token refresh. Useful if the token becomes invalid for some reason
        other than an expiration.
    @param completion Optionally; the block invoked when the token is available. Invoked
        asynchronously on the main thread in the future.
    @remarks The authentication token will be refreshed (by making a network request) if it has
        expired, or if @c forceRefresh is YES.
    @remarks Possible error codes:
        - See @c FIRAuthErrors for a list of error codes that are common to all API methods.
 */
- (void)getTokenForcingRefresh:(BOOL)forceRefresh
                    completion:(nullable FIRAuthTokenCallback)completion;

/** @fn linkWithCredential:completion:
    @brief Associates a user account from a third-party identity provider with this user.
    @param credential The credential for the identity provider.
    @param completion Optionally; the block invoked when the unlinking is complete, or fails.
        Invoked asynchronously on the main thread in the future.
    @remarks Possible error codes:
        - @c FIRAuthErrorCodeProviderAlreadyLinked - Indicates an attempt to link a provider of a
            type already linked to this account.
        - @c FIRAuthErrorCodeCredentialAlreadyInUse - Indicates an attempt to link with a credential
            that has already been linked with a different Firebase account.
        - @c FIRAuthErrorCodeOperationNotAllowed - Indicates that accounts with the identity
            provider represented by the credential are not enabled. Enable them in the Auth section
            of the Firebase console.
        - This method may also return error codes associated with updateEmail:completion: and
            updatePassword:completion: on FIRUser.
        - See @c FIRAuthErrors for a list of error codes that are common to all FIRUser operations.
 */
- (void)linkWithCredential:(FIRAuthCredential *)credential
                completion:(nullable FIRAuthResultCallback)completion;

/** @fn unlinkFromProvider:completion:
    @brief Disassociates a user account from a third-party identity provider with this user.
    @param provider The provider ID of the provider to unlink.
    @param completion Optionally; the block invoked when the unlinking is complete, or fails.
        Invoked asynchronously on the main thread in the future.
    @remarks Possible error codes:
        - @c FIRAuthErrorCodeNoSuchProvider - Indicates an attempt to unlink a provider that is not
            linked to the account.
        - @c FIRAuthErrorCodeRequiresRecentLogin - Updating email is a security sensitive operation
            that requires a recent login from the user. This error indicates the user has not signed
            in recently enough. To resolve, reauthenticate the user by invoking
            reauthenticateWithCredential:completion: on FIRUser.
        - See @c FIRAuthErrors for a list of error codes that are common to all FIRUser operations.
 */
- (void)unlinkFromProvider:(NSString *)provider
                completion:(nullable FIRAuthResultCallback)completion;

/** @fn sendEmailVerificationWithCompletion:
    @brief Initiates email verification for the user.
    @param completion Optionally; the block invoked when the request to send an email verification
        is complete, or fails. Invoked asynchronously on the main thread in the future.
    @remarks Possible error codes:
        - @c FIRAuthErrorCodeUserNotFound - Indicates the user account was not found.
        - See @c FIRAuthErrors for a list of error codes that are common to all FIRUser operations.
 */
- (void)sendEmailVerificationWithCompletion:(nullable FIRSendEmailVerificationCallback)completion;

/** @fn deleteWithCompletion:
    @brief Deletes the user account (also signs out the user, if this was the current user).
    @param completion Optionally; the block invoked when the request to delete the account is
        complete, or fails. Invoked asynchronously on the main thread in the future.
    @remarks Possible error codes:
        - @c FIRAuthErrorCodeRequiresRecentLogin - Updating email is a security sensitive operation
            that requires a recent login from the user. This error indicates the user has not signed
            in recently enough. To resolve, reauthenticate the user by invoking
            reauthenticateWithCredential:completion: on FIRUser.
        - See @c FIRAuthErrors for a list of error codes that are common to all FIRUser operations.
 */
- (void)deleteWithCompletion:(nullable FIRUserProfileChangeCallback)completion;

@end

/** @class FIRUserProfileChangeRequest
    @brief Represents an object capable of updating a user's profile data.
    @remarks Properties are marked as being part of a profile update when they are set. Setting a
        property value to nil is not the same as leaving the property unassigned.
 */
@interface FIRUserProfileChangeRequest : NSObject

/** @fn init
    @brief Please use @c FIRUser.profileChangeRequest
 */
- (nullable instancetype)init NS_UNAVAILABLE;

/** @property displayName
    @brief The user's display name.
    @remarks It is an error to set this property after calling
        @c FIRUserProfileChangeRequest.commitChangesWithCallback:
 */
@property(nonatomic, copy, nullable) NSString *displayName;

/** @property photoURL
    @brief The user's photo URL.
    @remarks It is an error to set this property after calling
        @c FIRUserProfileChangeRequest.commitChangesWithCallback:
 */
@property(nonatomic, copy, nullable) NSURL *photoURL;

/** @fn commitChangesWithCompletion:
    @brief Commits any pending changes.
    @remarks This method should only be called once. Once called, property values should not be
        changed.
    @param completion Optionally; the block invoked when the user profile change has been applied.
        Invoked asynchronously on the main thread in the future.
 */
- (void)commitChangesWithCompletion:(nullable FIRUserProfileChangeCallback)completion;

@end

NS_ASSUME_NONNULL_END
