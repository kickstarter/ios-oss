//
//  STPAPIClient.h
//  StripeExample
//
//  Created by Jack Flintermann on 12/18/14.
//  Copyright (c) 2014 Stripe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PassKit/PassKit.h>

#import "FauxPasAnnotations.h"
#import "STPBlocks.h"
#import "STPFile.h"

NS_ASSUME_NONNULL_BEGIN

/**
 The current version of this library.
 */
static NSString *const STPSDKVersion = @"13.2.0";

@class STPBankAccount, STPBankAccountParams, STPCard, STPCardParams, STPConnectAccountParams;
@class STPPaymentConfiguration, STPPaymentIntentParams, STPSourceParams, STPToken;

/**
 A top-level class that imports the rest of the Stripe SDK.
 */
@interface Stripe : NSObject FAUXPAS_IGNORED_ON_LINE(UnprefixedClass);

/**
 Set your Stripe API key with this method. New instances of STPAPIClient will be initialized with this value. You should call this method as early as
 possible in your application's lifecycle, preferably in your AppDelegate.

 @param   publishableKey Your publishable key, obtained from https://stripe.com/account/apikeys
 @warning Make sure not to ship your test API keys to the App Store! This will log a warning if you use your test key in a release build.
 */
+ (void)setDefaultPublishableKey:(NSString *)publishableKey;

/**
 The current default publishable key.
 */
+ (nullable NSString *)defaultPublishableKey;

@end

/**
 A client for making connections to the Stripe API.
 */
@interface STPAPIClient : NSObject

/**
 A shared singleton API client. Its API key will be initially equal to [Stripe defaultPublishableKey].
 */
+ (instancetype)sharedClient;


/**
 Initializes an API client with the given configuration. Its API key will be
 set to the configuration's publishable key.

 @param configuration The configuration to use.
 @return An instance of STPAPIClient.
 */
- (instancetype)initWithConfiguration:(STPPaymentConfiguration *)configuration NS_DESIGNATED_INITIALIZER;

/**
 Initializes an API client with the given publishable key.

 @param publishableKey The publishable key to use.
 @return An instance of STPAPIClient.
 */
- (instancetype)initWithPublishableKey:(NSString *)publishableKey;

/**
 The client's publishable key.
 */
@property (nonatomic, copy, nullable) NSString *publishableKey;

/**
 The client's configuration.
 */
@property (nonatomic, copy) STPPaymentConfiguration *configuration;


/**
 In order to perform API requests on behalf of a connected account, e.g. to
 create a source on a connected account, set this property to the ID of the
 account for which this request is being made.

 @see https://stripe.com/docs/connect/authentication#authentication-via-the-stripe-account-header
 */
@property (nonatomic, copy, nullable) NSString *stripeAccount;

@end

#pragma mark Bank Accounts

/**
 STPAPIClient extensions to create Stripe tokens from bank accounts.
 */
@interface STPAPIClient (BankAccounts)

/**
 Converts an STPBankAccount object into a Stripe token using the Stripe API.

 @param bankAccount The user's bank account details. Cannot be nil. @see https://stripe.com/docs/api#create_bank_account_token
 @param completion  The callback to run with the returned Stripe token (and any errors that may have occurred).
 */
- (void)createTokenWithBankAccount:(STPBankAccountParams *)bankAccount completion:(__nullable STPTokenCompletionBlock)completion;

@end

#pragma mark Personally Identifiable Information

/**
 STPAPIClient extensions to create Stripe tokens from a personal identification number.
 */
@interface STPAPIClient (PII)

/**
 Converts a personal identification number into a Stripe token using the Stripe API.

 @param pii The user's personal identification number. Cannot be nil. @see https://stripe.com/docs/api#create_pii_token
 @param completion  The callback to run with the returned Stripe token (and any errors that may have occurred).
 */
- (void)createTokenWithPersonalIDNumber:(NSString *)pii completion:(__nullable STPTokenCompletionBlock)completion;

@end

#pragma mark Connect Accounts

/**
 STPAPIClient extensions for working with Connect Accounts
 */
@interface STPAPIClient (ConnectAccounts)


/**
 Converts an `STPConnectAccountParams` object into a Stripe token using the Stripe API.

 This allows the connected account to accept the Terms of Service, and/or send Legal Entity information.

 @param account The Connect Account parameters. Cannot be nil.
 @param completion The callback to run with the returned Stripe token (and any errors that may have occurred).
 */
- (void)createTokenWithConnectAccount:(STPConnectAccountParams *)account completion:(__nullable STPTokenCompletionBlock)completion;

@end

#pragma mark Upload

/**
 STPAPIClient extensions to upload files.
 */
@interface STPAPIClient (Upload)


/**
 Uses the Stripe file upload API to upload an image. This can be used for
 identity verification and evidence disputes.

 @param image The image to be uploaded. The maximum allowed file size is 4MB
        for identity documents and 8MB for evidence disputes. Cannot be nil.
        Your image will be automatically resized down if you pass in one that
        is too large
 @param purpose The purpose of this file. This can be either an identifing
        document or an evidence dispute.
 @param completion The callback to run with the returned Stripe file
        (and any errors that may have occurred).

 @see https://stripe.com/docs/file-upload
 */
- (void)uploadImage:(UIImage *)image
            purpose:(STPFilePurpose)purpose
         completion:(nullable STPFileCompletionBlock)completion;

@end

#pragma mark Credit Cards

/**
 STPAPIClient extensions to create Stripe tokens from credit or debit cards.
 */
@interface STPAPIClient (CreditCards)

/**
 Converts an STPCardParams object into a Stripe token using the Stripe API.

 @param card        The user's card details. Cannot be nil. @see https://stripe.com/docs/api#create_card_token
 @param completion  The callback to run with the returned Stripe token (and any errors that may have occurred).
 */
- (void)createTokenWithCard:(STPCardParams *)card completion:(nullable STPTokenCompletionBlock)completion;

@end

/**
 Convenience methods for working with Apple Pay.
 */
@interface Stripe(ApplePay)

/**
 Whether or not this device is capable of using Apple Pay. This checks both
 whether the device supports Apple Pay, as well as whether or not they have
 stored Apple Pay cards on their device.

 @param paymentRequest The return value of this method depends on the
 `supportedNetworks` property of this payment request, which by default should be
 `@[PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa, PKPaymentNetworkDiscover]`.

 @return whether or not the user is currently able to pay with Apple Pay.
*/
+ (BOOL)canSubmitPaymentRequest:(PKPaymentRequest *)paymentRequest;

/**
 Whether or not this can make Apple Pay payments via a card network supported
 by Stripe.

 The Stripe supported Apple Pay card networks are:
 American Express, Visa, Mastercard, Discover.

 @return YES if the device is currently able to make Apple Pay payments via one
 of the supported networks. NO if the user does not have a saved card of a
 supported type, or other restrictions prevent payment (such as parental controls).
 */
+ (BOOL)deviceSupportsApplePay;

/**
 A convenience method to build a `PKPaymentRequest` with sane default values.
 You will still need to configure the `paymentSummaryItems` property to indicate
 what the user is purchasing, as well as the optional `requiredShippingAddressFields`,
 `requiredBillingAddressFields`, and `shippingMethods` properties to indicate
 what contact information your application requires.
 Note that this method sets the payment request's countryCode to "US" and its
 currencyCode to "USD".

 @param merchantIdentifier Your Apple Merchant ID.

 @return a `PKPaymentRequest` with proper default values. Returns nil if running on < iOS8.
 @deprecated Use `paymentRequestWithMerchantIdentifier:country:currency:` instead.
 Apple Pay is available in many countries and currencies, and you should use
 the appropriate values for your business.
 */
+ (PKPaymentRequest *)paymentRequestWithMerchantIdentifier:(NSString *)merchantIdentifier __attribute__((deprecated));

/**
 A convenience method to build a `PKPaymentRequest` with sane default values.
 You will still need to configure the `paymentSummaryItems` property to indicate
 what the user is purchasing, as well as the optional `requiredShippingAddressFields`,
 `requiredBillingAddressFields`, and `shippingMethods` properties to indicate
 what contact information your application requires.

 @param merchantIdentifier Your Apple Merchant ID.
 @param countryCode        The two-letter code for the country where the payment
 will be processed. This should be the country of your Stripe account.
 @param currencyCode       The three-letter code for the currency used by this
 payment request. Apple Pay interprets the amounts provided by the summary items
 attached to this request as amounts in this currency.

 @return a `PKPaymentRequest` with proper default values. Returns nil if running on < iOS8.
 */
+ (PKPaymentRequest *)paymentRequestWithMerchantIdentifier:(NSString *)merchantIdentifier
                                                   country:(NSString *)countryCode
                                                  currency:(NSString *)currencyCode;

@end

#pragma mark Sources

/**
 STPAPIClient extensions for working with Source objects
 */
@interface STPAPIClient (Sources)

/**
 Creates a Source object using the provided details.
 Note: in order to create a source on a connected account, you can set your
 API client's `stripeAccount` property to the ID of the account.
 @see https://stripe.com/docs/sources/connect#creating-direct-charges

 @param params      The details of the source to create. Cannot be nil. @see https://stripe.com/docs/api#create_source
 @param completion  The callback to run with the returned Source object, or an error.
 */
- (void)createSourceWithParams:(STPSourceParams *)params completion:(STPSourceCompletionBlock)completion;

/**
 Retrieves the Source object with the given ID. @see https://stripe.com/docs/api#retrieve_source

 @param identifier  The identifier of the source to be retrieved. Cannot be nil.
 @param secret      The client secret of the source. Cannot be nil.
 @param completion  The callback to run with the returned Source object, or an error.
 */
- (void)retrieveSourceWithId:(NSString *)identifier clientSecret:(NSString *)secret completion:(STPSourceCompletionBlock)completion;

/**
 Starts polling the Source object with the given ID. For payment methods that require
 additional customer action (e.g. authorizing a payment with their bank), polling
 allows you to determine if the action was successful. Polling will stop and the
 provided callback will be called once the source's status is no longer `pending`,
 or if the given timeout is reached and the source is still `pending`. If polling
 stops due to an error, the callback will be fired with the latest retrieved
 source and the error.

 Note that if a poll is already running for a source, subsequent calls to `startPolling`
 with the same source ID will do nothing.

 @param identifier  The identifier of the source to be retrieved. Cannot be nil.
 @param secret      The client secret of the source. Cannot be nil.
 @param timeout     The timeout for the polling operation, in seconds. Timeouts are capped at 5 minutes.
 @param completion  The callback to run with the returned Source object, or an error.
 */
- (void)startPollingSourceWithId:(NSString *)identifier clientSecret:(NSString *)secret timeout:(NSTimeInterval)timeout completion:(STPSourceCompletionBlock)completion NS_EXTENSION_UNAVAILABLE("Source polling is not available in extensions") DEPRECATED_MSG_ATTRIBUTE("You should poll your own backend to update based on source status change webhook events it may receive.");

/**
 Stops polling the Source object with the given ID. Note that the completion block passed to
 `startPolling` will not be fired when `stopPolling` is called.

 @param identifier  The identifier of the source to be retrieved. Cannot be nil.
 */
- (void)stopPollingSourceWithId:(NSString *)identifier NS_EXTENSION_UNAVAILABLE("Source polling is not available in extensions") DEPRECATED_ATTRIBUTE;

@end

#pragma mark Payment Intents

/**
 STPAPIClient extensions for working with PaymentIntent objects.
 */
@interface STPAPIClient (PaymentIntents)

/**
 Retrieves the PaymentIntent object using the given secret. @see https://stripe.com/docs/api#retrieve_payment_intent

 @param secret      The client secret of the payment intent to be retrieved. Cannot be nil.
 @param completion  The callback to run with the returned PaymentIntent object, or an error.
 */
- (void)retrievePaymentIntentWithClientSecret:(NSString *)secret
                                   completion:(STPPaymentIntentCompletionBlock)completion;

/**
 Confirms the PaymentIntent object with the provided params object.

 At a minimum, the params object must include the `clientSecret`.

 @see https://stripe.com/docs/api#confirm_payment_intent

 @param paymentIntentParams  The `STPPaymentIntentParams` to pass to `/confirm`
 @param completion           The callback to run with the returned PaymentIntent object, or an error.
 */
- (void)confirmPaymentIntentWithParams:(STPPaymentIntentParams *)paymentIntentParams
                            completion:(STPPaymentIntentCompletionBlock)completion;

@end

#pragma mark URL callbacks

/**
 Stripe extensions for working with URL callbacks
 */
@interface Stripe (STPURLCallbackHandlerAdditions)

/**
 Call this method in your app delegate whenever you receive an URL in your
 app delegate for a Stripe callback.

 For convenience, you can pass all URL's you receive in your app delegate
 to this method first, and check the return value
 to easily determine whether it is a callback URL that Stripe will handle
 or if your app should process it normally.

 If you are using a universal link URL, you will receive the callback in `application:continueUserActivity:restorationHandler:`
 To learn more about universal links, see https://developer.apple.com/library/content/documentation/General/Conceptual/AppSearch/UniversalLinks.html

 If you are using a native scheme URL, you will receive the callback in `application:openURL:options:`
 To learn more about native url schemes, see https://developer.apple.com/library/content/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/Inter-AppCommunication/Inter-AppCommunication.html#//apple_ref/doc/uid/TP40007072-CH6-SW10

 @param url The URL that you received in your app delegate

 @return YES if the URL is expected and will be handled by Stripe. NO otherwise.
 */
+ (BOOL)handleStripeURLCallbackWithURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
