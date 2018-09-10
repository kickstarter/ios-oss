//
//  STPPaymentConfiguration.h
//  Stripe
//
//  Created by Jack Flintermann on 5/18/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STPBackendAPIAdapter.h"
#import "STPPaymentMethod.h"
#import "STPTheme.h"

NS_ASSUME_NONNULL_BEGIN

/**
 An `STPPaymentConfiguration` represents all the options you can set or change
 around a payment. 
 
 You provide an `STPPaymentConfiguration` object to your `STPPaymentContext` 
 when making a charge. The configuration generally has settings that
 will not change from payment to payment and thus is reusable, while the context 
 is specific to a single particular payment instance.
 */
@interface STPPaymentConfiguration : NSObject<NSCopying>

/**
 This is a convenience singleton configuration that uses the default values for
 every property
 */
+ (instancetype)sharedConfiguration;

/**
 Your Stripe publishable key
 
 @see https://dashboard.stripe.com/account/apikeys
 */
@property (nonatomic, copy, readwrite) NSString *publishableKey;

/**
 An enum value representing which payment methods you will accept from your user
 in addition to credit cards. Unless you have a very specific reason not to, you
 should leave this at the default, `STPPaymentMethodTypeAll`.
 */
@property (nonatomic, assign, readwrite) STPPaymentMethodType additionalPaymentMethods;

/**
 The billing address fields the user must fill out when prompted for their 
 payment details. These fields will all be present on the returned token from 
 Stripe.
 
 @see https://stripe.com/docs/api#create_card_token
 */
@property (nonatomic, assign, readwrite) STPBillingAddressFields requiredBillingAddressFields;

/**
 The shipping address fields the user must fill out when prompted for their
 shipping info. Set to nil if shipping address is not required.

 The default value is nil.
 */
@property (nonatomic, copy, nullable, readwrite) NSSet<STPContactField> *requiredShippingAddressFields;

/**
 Whether the user should be prompted to verify prefilled shipping information.
 
 The default value is YES.
 */
@property (nonatomic, assign, readwrite) BOOL verifyPrefilledShippingAddress;

/**
 The type of shipping for this purchase. This property sets the labels displayed
 when the user is prompted for shipping info, and whether they should also be
 asked to select a shipping method.
 
 The default value is STPShippingTypeShipping.
 */
@property (nonatomic, assign, readwrite) STPShippingType shippingType;

/**
 The name of your company, for displaying to the user during payment flows. For 
 example, when using Apple Pay, the payment sheet's final line item will read
 "PAY {companyName}". 
 
 The default value is the name of your iOS application which is derived from the
 `kCFBundleNameKey` of `[NSBundle mainBundle]`.
 */
@property (nonatomic, copy, readwrite) NSString *companyName;

/**
 The Apple Merchant Identifier to use during Apple Pay transactions. To create 
 one of these, see our guide at https://stripe.com/docs/mobile/apple-pay . You 
 must set this to a valid identifier in order to automatically enable Apple Pay.
 */
@property (nonatomic, copy, nullable, readwrite) NSString *appleMerchantIdentifier;

/**
 Determines whether or not the user is able to delete payment methods
 
 This is only relevant to the `STPPaymentMethodsViewController` which, if 
 enabled, will allow the user to delete payment methods by tapping the "Edit" 
 button in the navigation bar or by swiping left on a payment method and tapping
 "Delete". Currently, the user is not allowed to delete the selected payment 
 method but this may change in the future.

 Default value is YES but will only work if `STPPaymentMethodsViewController` is
 initialized with a `STPCustomerContext` either through the `STPPaymentContext` 
 or directly as an init parameter.
 */
@property (nonatomic, assign, readwrite) BOOL canDeletePaymentMethods;

/**
 If the value of this property is true, when your user adds a card in our UI,
 a card source will be created and added to their Stripe Customer. The default
 value is false.

 @see https://stripe.com/docs/sources/cards#create-source
 */
@property (nonatomic, assign) BOOL createCardSources;

/**
 In order to perform API requests on behalf of a connected account, e.g. to
 create a source on a connected account, set this property to the ID of the
 account for which this request is being made.

 @see https://stripe.com/docs/connect/authentication#authentication-via-the-stripe-account-header
 */
@property (nonatomic, copy, nullable) NSString *stripeAccount;

@end

NS_ASSUME_NONNULL_END
