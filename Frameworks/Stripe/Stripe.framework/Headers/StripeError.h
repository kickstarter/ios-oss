//
//  StripeError.h
//  Stripe
//
//  Created by Saikat Chakrabarti on 11/4/12.
//
//

#import <Foundation/Foundation.h>

/**
 *  All Stripe iOS errors will be under this domain.
 */
FOUNDATION_EXPORT NSString * __nonnull const StripeDomain;

typedef NS_ENUM(NSInteger, STPErrorCode) {
    STPConnectionError = 40,     // Trouble connecting to Stripe.
    STPInvalidRequestError = 50, // Your request had invalid parameters.
    STPAPIError = 60,            // General-purpose API error (should be rare).
    STPCardError = 70,           // Something was wrong with the given card (most common).
    STPCancellationError = 80,   // The operation was cancelled.
    STPCheckoutUnknownError = 5000,   // Checkout failed
    STPCheckoutTooManyAttemptsError = 5001,   // Too many incorrect code attempts
};

#pragma mark userInfo keys

// A developer-friendly error message that explains what went wrong. You probably
// shouldn't show this to your users, but might want to use it yourself.
FOUNDATION_EXPORT NSString * __nonnull const STPErrorMessageKey;

// What went wrong with your STPCard (e.g., STPInvalidCVC. See below for full list).
FOUNDATION_EXPORT NSString * __nonnull const STPCardErrorCodeKey;

// Which parameter on the STPCard had an error (e.g., "cvc"). Useful for marking up the
// right UI element.
FOUNDATION_EXPORT NSString * __nonnull const STPErrorParameterKey;

#pragma mark STPCardErrorCodeKeys

// (Usually determined locally:)
FOUNDATION_EXPORT NSString * __nonnull const STPInvalidNumber;
FOUNDATION_EXPORT NSString * __nonnull const STPInvalidExpMonth;
FOUNDATION_EXPORT NSString * __nonnull const STPInvalidExpYear;
FOUNDATION_EXPORT NSString * __nonnull const STPInvalidCVC;

// (Usually sent from the server:)
FOUNDATION_EXPORT NSString * __nonnull const STPIncorrectNumber;
FOUNDATION_EXPORT NSString * __nonnull const STPExpiredCard;
FOUNDATION_EXPORT NSString * __nonnull const STPCardDeclined;
FOUNDATION_EXPORT NSString * __nonnull const STPProcessingError;
FOUNDATION_EXPORT NSString * __nonnull const STPIncorrectCVC;

#pragma mark Strings

#define STPCardErrorInvalidNumberUserMessage NSLocalizedString(@"Your card's number is invalid", @"Error when the card number is not valid")
#define STPCardErrorInvalidCVCUserMessage NSLocalizedString(@"Your card's security code is invalid", @"Error when the card's CVC is not valid")
#define STPCardErrorInvalidExpMonthUserMessage                                                                                                                 \
    NSLocalizedString(@"Your card's expiration month is invalid", @"Error when the card's expiration month is not valid")
#define STPCardErrorInvalidExpYearUserMessage                                                                                                                  \
    NSLocalizedString(@"Your card's expiration year is invalid", @"Error when the card's expiration year is not valid")
#define STPCardErrorExpiredCardUserMessage NSLocalizedString(@"Your card has expired", @"Error when the card has already expired")
#define STPCardErrorDeclinedUserMessage NSLocalizedString(@"Your card was declined", @"Error when the card was declined by the credit card networks")
#define STPUnexpectedError                                                                                                                                     \
    NSLocalizedString(@"There was an unexpected error -- try again in a few seconds", @"Unexpected error, such as a 500 from Stripe or a JSON parse error")
#define STPCardErrorProcessingErrorUserMessage                                                                                                                 \
    NSLocalizedString(@"There was an error processing your card -- try again in a few seconds", @"Error when there is a problem processing the credit card")

@interface NSError(Stripe)

+ (nullable NSError *)stp_errorFromStripeResponse:(nullable NSDictionary *)jsonDictionary;
+ (nonnull NSError *)stp_genericFailedToParseResponseError;
- (BOOL)stp_isUnknownCheckoutError;
- (BOOL)stp_isURLSessionCancellationError;

@end
