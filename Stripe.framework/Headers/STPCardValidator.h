//
//  STPCardValidator.h
//  Stripe
//
//  Created by Jack Flintermann on 7/15/15.
//  Copyright (c) 2015 Stripe, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STPCardBrand.h"
#import "STPCardParams.h"
#import "STPCardValidationState.h"

NS_ASSUME_NONNULL_BEGIN

/**
 This class contains static methods to validate card numbers, expiration dates, 
 and CVCs. For a list of test card numbers to use with this code, 
 see https://stripe.com/docs/testing
 */
@interface STPCardValidator : NSObject

/**
 Returns a copy of the passed string with all non-numeric characters removed.
 */
+ (NSString *)sanitizedNumericStringForString:(NSString *)string;

/**
 Whether or not the target string contains only numeric characters.
 */
+ (BOOL)stringIsNumeric:(NSString *)string;

/**
 Validates a card number, passed as a string. This will return 
 STPCardValidationStateInvalid for numbers that are too short or long, contain 
 invalid characters, do not pass Luhn validation, or (optionally) do not match 
 a number format issued by a major card brand.

 @param cardNumber The card number to validate. Ex. @"4242424242424242"
 @param validatingCardBrand Whether or not to enforce that the number appears to
 be issued by a major card brand (or could be). For example, no issuing card 
 network currently issues card numbers beginning with the digit 9; if an 
 otherwise correct-length and luhn-valid card number beginning with 9 
 (example: 9999999999999995) were passed to this method, it would return 
 STPCardValidationStateInvalid if this parameter were YES and 
 STPCardValidationStateValid if this parameter were NO. If unsure, you should 
 use YES for this value.

 @return STPCardValidationStateValid if the number is valid, 
 STPCardValidationStateInvalid if the number is invalid, or 
 STPCardValidationStateIncomplete if the number is a substring of a valid 
 card (e.g. @"4242").
 */
+ (STPCardValidationState)validationStateForNumber:(nullable NSString *)cardNumber
                               validatingCardBrand:(BOOL)validatingCardBrand;

/**
 The card brand for a card number or substring thereof.

 @param cardNumber A card number, or partial card number. For 
 example, @"4242", @"5555555555554444", or @"123".

 @return The brand for that card number. The example parameters would 
 return STPCardBrandVisa, STPCardBrandMasterCard, and 
 STPCardBrandUnknown, respectively.
 */
+ (STPCardBrand)brandForNumber:(NSString *)cardNumber;

/**
 The possible number lengths for cards associated with a card brand. For
 example, Discover card numbers contain 16 characters, while American Express
 cards contain 15 characters.

 @param brand The brand to return lengths for.

 @return The set of possible lengths cards associated with that brand can be.
 */
+ (NSSet<NSNumber *>*)lengthsForCardBrand:(STPCardBrand)brand;


/**
 The maximum possible length the number of a card associated with the specified
 brand could be. 
 
 For example, Visa cards could be either 13 or 16 characters, so this method
 would return 16 for the that card brand.

 @param brand The brand to return the max length for.

 @return The maximum length card numbers associated with that brand could be.
 */
+ (NSInteger)maxLengthForCardBrand:(STPCardBrand)brand;

/**
 The length of the final grouping of digits to use when formatting a card number
 for display. 
 
 For example, Visa cards display their final 4 numbers, e.g. "4242", while
 American Express cards display their final 5 digits, e.g. "10005".
 

 @param brand The brand to return the fragment length for.

 @return The final fragment length card numbers associated with that brand use.
 */
+ (NSInteger)fragmentLengthForCardBrand:(STPCardBrand)brand;

/**
 Validates an expiration month, passed as an (optionally 0-padded) string. 
 
 Example valid values are "3", "12", and "08". Example invalid values are "99", 
 "a", and "00". Incomplete values include "0" and "1".

 @param expirationMonth A string representing a 2-digit expiration month for a 
 payment card.

 @return STPCardValidationStateValid if the month is valid, 
 STPCardValidationStateInvalid if the month is invalid, or 
 STPCardValidationStateIncomplete if the month is a substring of a valid 
 month (e.g. @"0" or @"1").
 */
+ (STPCardValidationState)validationStateForExpirationMonth:(NSString *)expirationMonth;

/**
 Validates an expiration year, passed as a string representing the final 
 2 digits of the year. 
 
 This considers the period between the current year until 2099 as valid times. 
 An example valid year value would be "16" (assuming the current year, as 
 determined by [NSDate date], is 2015). 
 
 Will return STPCardValidationStateInvalid for a month/year combination that 
 is earlier than the current date (i.e. @"15" and @"04" in October 2015).
 Example invalid year values are "00", "a", and "13". Any 1-digit year string 
 will return STPCardValidationStateIncomplete.

 @param expirationYear A string representing a 2-digit expiration year for a 
 payment card.
 @param expirationMonth A string representing a valid 2-digit expiration month 
 for a payment card. If the month is invalid 
 (see `validationStateForExpirationMonth`), this will
 return STPCardValidationStateInvalid.

 @return STPCardValidationStateValid if the year is valid,
 STPCardValidationStateInvalid if the year is invalid, or 
 STPCardValidationStateIncomplete if the year is a substring of a valid 
 year (e.g. @"1" or @"2").
 */
+ (STPCardValidationState)validationStateForExpirationYear:(NSString *)expirationYear
                                                   inMonth:(NSString *)expirationMonth;

/**
 The max CVC length for a card brand (for example, American Express CVCs are
 4 digits, while all others are 3).

 @param brand The brand to return the max CVC length for.

 @return The maximum length of CVC numbers for cards associated with that brand.
 */
+ (NSUInteger)maxCVCLengthForCardBrand:(STPCardBrand)brand;

/**
 Validates a card's CVC, passed as a numeric string, for the given card brand.

 @param cvc   the CVC to validate
 @param brand the card brand (can be determined from the card's number 
 using `brandForNumber`)

 @return Whether the CVC represents a valid CVC for that card brand. For 
 example, would return STPCardValidationStateValid for @"123" and 
 STPCardBrandVisa, STPCardValidationStateValid for @"1234" and
 STPCardBrandAmericanExpress, STPCardValidationStateIncomplete for @"12" and 
 STPCardBrandVisa, and STPCardValidationStateInvalid for @"12345" and any brand.
 */
+ (STPCardValidationState)validationStateForCVC:(NSString *)cvc
                                      cardBrand:(STPCardBrand)brand;

/**
 Validates the given card details.

 @param card The card details to validate.

 @return STPCardValidationStateValid if all fields are valid, 
 STPCardValidationStateInvalid if any field is invalid, or 
 STPCardValidationStateIncomplete if all fields are either incomplete or valid.
 */
+ (STPCardValidationState)validationStateForCard:(STPCardParams *)card;


@end

NS_ASSUME_NONNULL_END
