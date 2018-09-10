//
//  STPCardParams.h
//  Stripe
//
//  Created by Jack Flintermann on 10/4/15.
//  Copyright © 2015 Stripe, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STPFormEncodable.h"
#if TARGET_OS_IPHONE
#import "STPAddress.h"
#endif

/**
 Representation of a user's credit card details. You can assemble these with
 information that your user enters and then create Stripe tokens with them using 
 an STPAPIClient.

 @see https://stripe.com/docs/api#cards
 */
@interface STPCardParams : NSObject<STPFormEncodable>

/**
 The card's number.
 */
@property (nonatomic, copy, nullable) NSString *number;

/**
 The last 4 digits of the card's number, if it's been set, otherwise nil.
 */
- (nullable NSString *)last4;

/**
 The card's expiration month.
 */
@property (nonatomic) NSUInteger expMonth;

/**
 The card's expiration year.
 */
@property (nonatomic) NSUInteger expYear;

/**
 The card's security code, found on the back.
 */
@property (nonatomic, copy, nullable) NSString *cvc;

/**
 The cardholder's name.
 
 @note Changing this property will also changing the name of the 
 param's `address` property.
 */
@property (nonatomic, copy, nullable) NSString *name;

/**
 The cardholder's address.
 
 @note Changing this property will also changing the name of the 
 param's `name` property
 */
@property (nonatomic, strong, nonnull) STPAddress *address;

/**
 Three-letter ISO currency code representing the currency paid out to the bank 
 account. This is only applicable when tokenizing debit cards to issue payouts 
 to managed accounts. You should not set it otherwise. The card can then be 
 used as a transfer destination for funds in this currency.
 */
@property (nonatomic, copy, nullable) NSString *currency;


#pragma mark - Deprecated methods

/**
 The first line of the cardholder's address
 */
@property (nonatomic, copy, nullable) NSString *addressLine1 DEPRECATED_MSG_ATTRIBUTE("Use address.line1");

/**
 The second line of the cardholder's address
 */
@property (nonatomic, copy, nullable) NSString *addressLine2 DEPRECATED_MSG_ATTRIBUTE("Use address.line2");

/**
 The city of the cardholder's address
 */
@property (nonatomic, copy, nullable) NSString *addressCity DEPRECATED_MSG_ATTRIBUTE("Use address.city");

/**
 The state of the cardholder's address
 */
@property (nonatomic, copy, nullable) NSString *addressState DEPRECATED_MSG_ATTRIBUTE("Use address.state");

/**
 The zip code of the cardholder's address
 */
@property (nonatomic, copy, nullable) NSString *addressZip DEPRECATED_MSG_ATTRIBUTE("Use address.postalCode");

/**
 The country of the cardholder's address
 */
@property (nonatomic, copy, nullable) NSString *addressCountry DEPRECATED_MSG_ATTRIBUTE("Use address.country");


@end
