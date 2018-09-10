//
//  STPSourceParams.h
//  Stripe
//
//  Created by Ben Guo on 1/23/17.
//  Copyright © 2017 Stripe, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STPFormEncodable.h"
#import "STPSource.h"

NS_ASSUME_NONNULL_BEGIN

@class STPCardParams;

/**
 An object representing parameters used to create a Source object. 
 @see https://stripe.com/docs/api#create_source
 */
@interface STPSourceParams : NSObject<STPFormEncodable, NSCopying>

/**
 The type of the source to create. Required.
 */
@property (nonatomic, assign) STPSourceType type;

/**
 The raw underlying type string sent to the server.
 
 Generally you should use `type` instead unless you have a reason not to.
 You can use this if you want to create a param of a type not yet supported
 by the current version of the SDK's `STPSourceType` enum.
 
 Setting this to a value not known by the SDK causes `type` to 
 return `STPSourceTypeUnknown`
 */
@property (nonatomic, copy) NSString *rawTypeString;

/**
 A positive integer in the smallest currency unit representing the
 amount to charge the customer (e.g., @1099 for a €10.99 payment).
 Required for `single_use` sources.
 */
@property (nonatomic, copy, nullable) NSNumber *amount;

/**
 The currency associated with the source. This is the currency for which the source 
 will be chargeable once ready.
 */
@property (nonatomic, copy, nullable) NSString *currency;

/**
 The authentication flow of the source to create. `flow` may be "redirect",
 "receiver", "verification", or "none". It is generally inferred unless a type
 supports multiple flows.
 */
@property (nonatomic, assign) STPSourceFlow flow;

/**
 A set of key/value pairs that you can attach to a source object.
 */
@property (nonatomic, copy, nullable) NSDictionary *metadata;

/**
 Information about the owner of the payment instrument. May be used or required
 by particular source types.
 */
@property (nonatomic, copy, nullable) NSDictionary *owner;

/**
 Parameters required for the redirect flow. Required if the source is 
 authenticated by a redirect (`flow` is "redirect").
 */
@property (nonatomic, copy, nullable) NSDictionary *redirect;

/**
 An optional token used to create the source. When passed, token properties will 
 override source parameters.
 */
@property (nonatomic, copy, nullable) NSString *token;

/**
 Whether this source should be reusable or not. `usage` may be "reusable" or 
 "single_use". Some source types may or may not be reusable by construction, 
 while other may leave the option at creation.
 */
@property (nonatomic, assign) STPSourceUsage usage;

/**
 Creates params for a Bancontact source.
 @see https://stripe.com/docs/bancontact#create-source
 
 @param amount               The amount to charge the customer in EUR.
 @param name                 The full name of the account holder.
 @param returnURL            The URL the customer should be redirected to after 
 they have successfully verified the payment.
 @param statementDescriptor  (Optional) A custom statement descriptor for 
 the payment.

 @note The currency for Bancontact must be "eur". This will be set automatically 
 for you.

 @return an STPSourceParams object populated with the provided values.
 */
+ (STPSourceParams *)bancontactParamsWithAmount:(NSUInteger)amount
                                           name:(NSString *)name
                                      returnURL:(NSString *)returnURL
                            statementDescriptor:(nullable NSString *)statementDescriptor;

/**
 Creates params for a Card source.
 @see https://stripe.com/docs/sources/cards#create-source
 
 @param card        An object containing the user's card details
 
 @return an STPSourceParams object populated with the provided card details.
 */
+ (STPSourceParams *)cardParamsWithCard:(STPCardParams *)card;

/**
 Creates params for a Giropay source.
 @see https://stripe.com/docs/sources/giropay#create-source
 
 @param amount               The amount to charge the customer in EUR.
 @param name                 The full name of the account holder.
 @param returnURL            The URL the customer should be redirected to after 
 they have successfully verified the payment.
 @param statementDescriptor  (Optional) A custom statement descriptor for
 the payment.
 
 @note The currency for Giropay must be "eur". This will be set automatically 
 for you.

 @return an STPSourceParams object populated with the provided values.
 */
+ (STPSourceParams *)giropayParamsWithAmount:(NSUInteger)amount
                                        name:(NSString *)name
                                   returnURL:(NSString *)returnURL
                         statementDescriptor:(nullable NSString *)statementDescriptor;

/**
 Creates params for an iDEAL source.
 @see https://stripe.com/docs/sources/ideal#create-source
 
 @param amount               The amount to charge the customer in EUR.
 @param name                 (Optional) The full name of the account holder.
 @param returnURL            The URL the customer should be redirected to after
 they have successfully verified the payment.
 @param statementDescriptor  (Optional) A custom statement descriptor for t
 he payment.
 @param bank                 (Optional) The customer's bank.
 
 @note The currency for iDEAL must be "eur". This will be set automatically 
 for you.

 @return an STPSourceParams object populated with the provided values.
 */
+ (STPSourceParams *)idealParamsWithAmount:(NSUInteger)amount
                                      name:(nullable NSString *)name
                                 returnURL:(NSString *)returnURL
                       statementDescriptor:(nullable NSString *)statementDescriptor
                                      bank:(nullable NSString *)bank;

/**
 Creates params for a SEPA Debit source.
 @see https://stripe.com/docs/sources/sepa-debit#create-source
 
 @param name         The full name of the account holder.
 @param iban         The IBAN number for the bank account you wish to debit.
 @param addressLine1 (Optional) The bank account holder's first address line.
 @param city         (Optional) The bank account holder's city.
 @param postalCode   (Optional) The bank account holder's postal code.
 @param country      (Optional) The bank account holder's two-letter
 country code.

 @note The currency for SEPA Debit must be "eur". This will be set automatically
 for you.

 @return an STPSourceParams object populated with the provided values.
 */
+ (STPSourceParams *)sepaDebitParamsWithName:(NSString *)name
                                        iban:(NSString *)iban
                                addressLine1:(nullable NSString *)addressLine1
                                        city:(nullable NSString *)city
                                  postalCode:(nullable NSString *)postalCode
                                     country:(nullable NSString *)country;

/**
 Creates params for a Sofort source.
 @see https://stripe.com/docs/sources/sofort#create-source

 @param amount               The amount to charge the customer in EUR.
 @param returnURL            The URL the customer should be redirected to after
 they have successfully verified the payment.
 @param country              The country code of the customer's bank.
 @param statementDescriptor  (Optional) A custom statement descriptor for
 the payment.
 
 @note The currency for Sofort must be "eur". This will be set automatically 
 for you.

 @return an STPSourceParams object populated with the provided values.
 */
+ (STPSourceParams *)sofortParamsWithAmount:(NSUInteger)amount
                                  returnURL:(NSString *)returnURL
                                    country:(NSString *)country
                        statementDescriptor:(nullable NSString *)statementDescriptor;

/**
 Creates params for a 3DS source.
 @see https://stripe.com/docs/sources/three-d-secure#create-3ds-source
 
 @param amount      The amount to charge the customer.
 @param currency    The currency the payment is being created in.
 @param returnURL   The URL the customer should be redirected to after they have
 successfully verified the payment.
 @param card        The ID of the card source.
 
 @return an STPSourceParams object populated with the provided card details.
 */
+ (STPSourceParams *)threeDSecureParamsWithAmount:(NSUInteger)amount
                                         currency:(NSString *)currency
                                        returnURL:(NSString *)returnURL
                                             card:(NSString *)card;

/**
 Creates params for a single-use Alipay source
 @see https://stripe.com/docs/sources/alipay#create-source

 @param amount      The amount to charge the customer.
 @param currency    The currency the payment is being created in.
 @param returnURL   The URL the customer should be redirected to after they have
 successfully verified the payment.

 @return An STPSourceParams object populated with the provided values
 */
+ (STPSourceParams *)alipayParamsWithAmount:(NSUInteger)amount
                                   currency:(NSString *)currency
                                  returnURL:(NSString *)returnURL;

/**
 Creates params for a reusable Alipay source
 @see https://stripe.com/docs/sources/alipay#create-source

 @param currency    The currency the payment is being created in.
 @param returnURL   The URL the customer should be redirected to after they have
 successfully verified the payment.

 @return An STPSourceParams object populated with the provided values
 */
+ (STPSourceParams *)alipayReusableParamsWithCurrency:(NSString *)currency
                                            returnURL:(NSString *)returnURL;

/**
 Creates params for a P24 source
 @see https://stripe.com/docs/sources/p24#create-source

 @param amount      The amount to charge the customer.
 @param currency    The currency the payment is being created in (this must be 
 EUR or PLN)
 @param email       The email address of the account holder.
 @param name        The full name of the account holder (optional).
 @param returnURL   The URL the customer should be redirected to after they have

 @return An STPSourceParams object populated with the provided values.
 */
+ (STPSourceParams *)p24ParamsWithAmount:(NSUInteger)amount
                                currency:(NSString *)currency
                                   email:(NSString *)email
                                    name:(nullable NSString *)name
                               returnURL:(NSString *)returnURL;


/**
 Creates params for a card source created from Visa Checkout.
 @see https://stripe.com/docs/visa-checkout

 @note Creating an STPSource with these params will give you a
 source with type == STPSourceTypeCard

 @param callId The callId property from a `VisaCheckoutResult` object.
 @return An STPSourceParams object populated with the provided values.
 */
+ (STPSourceParams *)visaCheckoutParamsWithCallId:(NSString *)callId;


/**
 Creates params for a card source created from Masterpass.
 @see https://stripe.com/docs/masterpass

 @note Creating an STPSource with these params will give you a
 source with type == STPSourceTypeCard

 @param cartId The cartId from a `MCCCheckoutResponse` object.
 @param transactionId The transactionid from a `MCCCheckoutResponse` object.
 @return An STPSourceParams object populated with the provided values.
 */
+ (STPSourceParams *)masterpassParamsWithCartId:(NSString *)cartId
                                  transactionId:(NSString *)transactionId;

/**
 Create params for an EPS source
 @see https://stripe.com/docs/sources/eps

 @param amount                  The amount to charge the customer.
 @param name                    The full name of the account holder.
 @param returnURL               The URL the customer should be redirected to
 after the authorization process.
 @param statementDescriptor     A custom statement descriptor for the
 payment (optional).

 @return An STPSourceParams object populated with the provided values.
 */
+ (STPSourceParams *)epsParamsWithAmount:(NSUInteger)amount
                                    name:(NSString *)name
                               returnURL:(NSString *)returnURL
                     statementDescriptor:(nullable NSString *)statementDescriptor;

/**
 Create params for a Multibanco source
 @see https://stripe.com/docs/sources/multibanco

 @param amount      The amount to charge the customer.
 @param returnURL   The URL the customer should be redirected to after the
 authorization process.
 @param email       The full email address of the customer.

 @return An STPSourceParams object populated with the provided values.
 */
+ (STPSourceParams *)multibancoParamsWithAmount:(NSUInteger)amount
                                      returnURL:(NSString *)returnURL
                                          email:(NSString *)email;

@end

NS_ASSUME_NONNULL_END
