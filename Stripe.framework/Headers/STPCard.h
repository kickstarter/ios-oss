//
//  STPCard.h
//  Stripe
//
//  Created by Saikat Chakrabarti on 11/2/12.
//
//

#import <Foundation/Foundation.h>

#import "STPAPIResponseDecodable.h"
#import "STPCardBrand.h"
#import "STPCardParams.h"
#import "STPPaymentMethod.h"
#import "STPSourceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 The various funding sources for a payment card.
 */
typedef NS_ENUM(NSInteger, STPCardFundingType) {
    /**
     Debit card funding
     */
    STPCardFundingTypeDebit,

    /**
     Credit card funding
     */
    STPCardFundingTypeCredit,

    /**
     Prepaid card funding
     */
    STPCardFundingTypePrepaid,

    /**
     An other or unknown type of funding source.
     */
    STPCardFundingTypeOther,
};

/**
 Representation of a user's credit card details that have been tokenized with 
 the Stripe API

 @see https://stripe.com/docs/api#cards
 */
@interface STPCard : NSObject<STPAPIResponseDecodable, STPPaymentMethod, STPSourceProtocol>

/**
 You cannot directly instantiate an `STPCard`. You should only use one that has 
 been returned from an `STPAPIClient` callback.
 */
- (instancetype) init __attribute__((unavailable("You cannot directly instantiate an STPCard. You should only use one that has been returned from an STPAPIClient callback.")));

/**
 The last 4 digits of the card.
 */
@property (nonatomic, readonly) NSString *last4;

/**
 For cards made with Apple Pay, this refers to the last 4 digits of the 
 "Device Account Number" for the tokenized card. For regular cards, it will
 be nil.
 */
@property (nonatomic, nullable, readonly) NSString *dynamicLast4;

/**
 Whether or not the card originated from Apple Pay.
 */
@property (nonatomic, readonly) BOOL isApplePayCard;

/**
 The card's expiration month. 1-indexed (i.e. 1 == January)
 */
@property (nonatomic, readonly) NSUInteger expMonth;

/**
 The card's expiration year.
 */
@property (nonatomic, readonly) NSUInteger expYear;

/**
 The cardholder's name.
 */
@property (nonatomic, nullable, readonly) NSString *name;

/**
 The cardholder's address.
 */
@property (nonatomic, readonly) STPAddress *address;

/**
 The issuer of the card.
 */
@property (nonatomic, readonly) STPCardBrand brand;

/**
 The funding source for the card (credit, debit, prepaid, or other)
 */
@property (nonatomic, readonly) STPCardFundingType funding;

/**
 Two-letter ISO code representing the issuing country of the card.
 */
@property (nonatomic, nullable, readonly) NSString *country;

/**
 This is only applicable when tokenizing debit cards to issue payouts to managed
 accounts. You should not set it otherwise. The card can then be used as a 
 transfer destination for funds in this currency.
 */
@property (nonatomic, nullable, readonly) NSString *currency;

/**
 A set of key/value pairs associated with the card object.

 @see https://stripe.com/docs/api#metadata
 */
@property (nonatomic, copy, nullable, readonly) NSDictionary<NSString *, NSString *> *metadata;

/**
 Returns a string representation for the provided card brand; 
 i.e. `[NSString stringFromBrand:STPCardBrandVisa] ==  @"Visa"`.

 @param brand the brand you want to convert to a string

 @return A string representing the brand, suitable for displaying to a user.
 */
+ (NSString *)stringFromBrand:(STPCardBrand)brand;

/**
 This parses a string representing a card's brand into the appropriate
 STPCardBrand enum value,
 i.e. `[STPCard brandFromString:@"American Express"] == STPCardBrandAmex`.

 The string values themselves are specific to Stripe as listed in the Stripe API
 documentation.

 @see https://stripe.com/docs/api#card_object-brand

 @param string a string representing the card's brand as returned from
 the Stripe API

 @return an enum value mapped to that string. If the string is unrecognized,
 returns STPCardBrandUnknown.
 */
+ (STPCardBrand)brandFromString:(NSString *)string;

#pragma mark - Deprecated methods

/**
 The Stripe ID for the card.
 */
@property (nonatomic, readonly) NSString *cardId DEPRECATED_MSG_ATTRIBUTE("Use stripeID (defined in STPSourceProtocol)");

/**
 The first line of the cardholder's address
 */
@property (nonatomic, nullable, readonly) NSString *addressLine1 DEPRECATED_MSG_ATTRIBUTE("Use address.line1");

/**
 The second line of the cardholder's address
 */
@property (nonatomic, nullable, readonly) NSString *addressLine2 DEPRECATED_MSG_ATTRIBUTE("Use address.line2");

/**
 The city of the cardholder's address
 */
@property (nonatomic, nullable, readonly) NSString *addressCity DEPRECATED_MSG_ATTRIBUTE("Use address.city");

/**
 The state of the cardholder's address
 */
@property (nonatomic, nullable, readonly) NSString *addressState DEPRECATED_MSG_ATTRIBUTE("Use address.state");

/**
 The zip code of the cardholder's address
 */
@property (nonatomic, nullable, readonly) NSString *addressZip DEPRECATED_MSG_ATTRIBUTE("Use address.postalCode");

/**
 The country of the cardholder's address
 */
@property (nonatomic, nullable, readonly) NSString *addressCountry DEPRECATED_MSG_ATTRIBUTE("Use address.country");

/**
 Create an STPCard from a Stripe API response.

 @param cardID   The Stripe ID of the card, e.g. `card_185iQx4JYtv6MPZKfcuXwkOx`
 @param brand    The brand of the card (e.g. "Visa". To obtain this enum value 
 from a string, use `[STPCardBrand brandFromString:string]`;
 @param last4    The last 4 digits of the card, e.g. 4242
 @param expMonth The card's expiration month, 1-indexed (i.e. 1 = January)
 @param expYear  The card's expiration year
 @param funding  The card's funding type (credit, debit, or prepaid). To obtain 
 this enum value from a string, use `[STPCardBrand fundingFromString:string]`.

 @return an STPCard instance populated with the provided values.
 */
- (instancetype)initWithID:(NSString *)cardID
                     brand:(STPCardBrand)brand
                     last4:(NSString *)last4
                  expMonth:(NSUInteger)expMonth
                   expYear:(NSUInteger)expYear
                   funding:(STPCardFundingType)funding DEPRECATED_MSG_ATTRIBUTE("You cannot directly instantiate an STPCard. You should only use one that has been returned from an STPAPIClient callback.");

/**
 This parses a string representing a card's funding type into the appropriate 
 `STPCardFundingType` enum value, 
 i.e. `[STPCard fundingFromString:@"prepaid"] == STPCardFundingTypePrepaid`.

 @param string a string representing the card's funding type as returned from 
 the Stripe API

 @return an enum value mapped to that string. If the string is unrecognized, 
 returns `STPCardFundingTypeOther`.
 */
+ (STPCardFundingType)fundingFromString:(NSString *)string DEPRECATED_ATTRIBUTE;

@end

NS_ASSUME_NONNULL_END
