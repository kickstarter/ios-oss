//
//  STPBlocks.h
//  Stripe
//
//  Created by Jack Flintermann on 3/23/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PassKit/PassKit.h>

@class STPToken;
@class STPFile;
@class STPSource;
@class STPCustomer;
@protocol STPSourceProtocol;
@class STPPaymentIntent;

/**
 These values control the labels used in the shipping info collection form.
 */
typedef NS_ENUM(NSUInteger, STPShippingType) {
    /**
     Shipping the purchase to the provided address using a third-party
     shipping company.
     */
    STPShippingTypeShipping,
    /**
     Delivering the purchase by the seller.
     */
    STPShippingTypeDelivery,
};

/**
 An enum representing the status of a shipping address validation.
 */
typedef NS_ENUM(NSUInteger, STPShippingStatus) {
    /**
     The shipping address is valid.
     */
    STPShippingStatusValid,
    /**
     The shipping address is invalid.
     */
    STPShippingStatusInvalid,
};

/**
 An enum representing the status of a payment requested from the user.
 */
typedef NS_ENUM(NSUInteger, STPPaymentStatus) {
    /**
     The payment succeeded.
     */
    STPPaymentStatusSuccess,
    /**
     The payment failed due to an unforeseen error, such as the user's Internet connection being offline.
     */
    STPPaymentStatusError,
    /**
     The user cancelled the payment (for example, by hitting "cancel" in the Apple Pay dialog).
     */
    STPPaymentStatusUserCancellation,
};

/**
 An empty block, called with no arguments, returning nothing.
 */
typedef void (^STPVoidBlock)(void);

/**
 A block that may optionally be called with an error.

 @param error The error that occurred, if any.
 */
typedef void (^STPErrorBlock)(NSError * __nullable error);

/**
 A callback to be run with a JSON response.

 @param jsonResponse  The JSON response, or nil if an error occured.
 @param error         The error that occurred, if any.
 */
typedef void (^STPJSONResponseCompletionBlock)(NSDictionary * __nullable jsonResponse, NSError * __nullable error);

/**
 A callback to be run with a token response from the Stripe API.

 @param token The Stripe token from the response. Will be nil if an error occurs. @see STPToken
 @param error The error returned from the response, or nil if none occurs. @see StripeError.h for possible values.
 */
typedef void (^STPTokenCompletionBlock)(STPToken * __nullable token, NSError * __nullable error);

/**
 A callback to be run with a source response from the Stripe API.

 @param source The Stripe source from the response. Will be nil if an error occurs. @see STPSource
 @param error The error returned from the response, or nil if none occurs. @see StripeError.h for possible values.
 */
typedef void (^STPSourceCompletionBlock)(STPSource * __nullable source, NSError * __nullable error);

/**
 A callback to be run with a source or card response from the Stripe API.

 @param source The Stripe source from the response. Will be nil if an error occurs. @see STPSourceProtocol
 @param error The error returned from the response, or nil if none occurs. @see StripeError.h for possible values.
 */
typedef void (^STPSourceProtocolCompletionBlock)(id<STPSourceProtocol> __nullable source, NSError * __nullable error);

/**
 A callback to be run with a PaymentIntent response from the Stripe API.

 @param paymentIntent The Stripe PaymentIntent from the response. Will be nil if an error occurs. @see STPPaymentIntent
 @param error The error returned from the response, or nil if none occurs. @see StripeError.h for possible values.
 */
typedef void (^STPPaymentIntentCompletionBlock)(STPPaymentIntent * __nullable paymentIntent, NSError * __nullable error);

/**
 A callback to be run with a validation result and shipping methods for a 
 shipping address.

 @param status An enum representing whether the shipping address is valid.
 @param shippingValidationError If the shipping address is invalid, an error describing the issue with the address. If no error is given and the address is invalid, the default error message will be used.
 @param shippingMethods The shipping methods available for the address.
 @param selectedShippingMethod The default selected shipping method for the address.
 */
typedef void (^STPShippingMethodsCompletionBlock)(STPShippingStatus status, NSError * __nullable shippingValidationError, NSArray<PKShippingMethod *>* __nullable shippingMethods, PKShippingMethod * __nullable selectedShippingMethod);

/**
 A callback to be run with a file response from the Stripe API.

 @param file The Stripe file from the response. Will be nil if an error occurs. @see STPFile
 @param error The error returned from the response, or nil if none occurs. @see StripeError.h for possible values.
 */
typedef void (^STPFileCompletionBlock)(STPFile * __nullable file, NSError * __nullable error);

/**
 A callback to be run with a customer response from the Stripe API.

 @param customer     The Stripe customer from the response, or nil if an error occurred. @see STPCustomer
 @param error        The error returned from the response, or nil if none occurs.
 */
typedef void (^STPCustomerCompletionBlock)(STPCustomer * __nullable customer, NSError * __nullable error);
