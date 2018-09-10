//
//  STPBankAccount.h
//  Stripe
//
//  Created by Charles Scalesse on 10/1/14.
//
//

#import <Foundation/Foundation.h>

#import "STPBankAccountParams.h"
#import "STPAPIResponseDecodable.h"
#import "STPSourceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Possible validation states for a bank account.
 */
typedef NS_ENUM(NSInteger, STPBankAccountStatus) {
    /**
     The account has had no activity or validation performed
     */
    STPBankAccountStatusNew,

    /**
     Stripe has determined this bank account exists.
     */
    STPBankAccountStatusValidated,

    /**
     Bank account verification has succeeded.
     */
    STPBankAccountStatusVerified,

    /**
     Verification for this bank account has failed.
     */
    STPBankAccountStatusVerificationFailed,

    /**
     A transfer sent to this bank account has failed.
     */
    STPBankAccountStatusErrored,
};

/**
 Representation of a user's bank account details that have been tokenized with
 the Stripe API.

 @see https://stripe.com/docs/api#bank_accounts
 */
@interface STPBankAccount : NSObject<STPAPIResponseDecodable, STPSourceProtocol>

/**
 You cannot directly instantiate an `STPBankAccount`. You should only use one 
 that has been returned from an `STPAPIClient` callback.
 */
- (instancetype)init __attribute__((unavailable("You cannot directly instantiate an STPBankAccount. You should only use one that has been returned from an STPAPIClient callback.")));

/**
 The routing number for the bank account. This should be the ACH routing number,
 not the wire routing number.
 */
@property (nonatomic, nullable, readonly) NSString *routingNumber;

/**
 Two-letter ISO code representing the country the bank account is located in.
 */
@property (nonatomic, readonly) NSString *country;

/**
 The default currency for the bank account.
 */
@property (nonatomic, readonly) NSString *currency;

/**
 The last 4 digits of the account number.
 */
@property (nonatomic, readonly) NSString *last4;

/**
 The name of the bank that owns the account.
 */
@property (nonatomic, readonly) NSString *bankName;

/**
 The name of the person or business that owns the bank account.
 */
@property (nonatomic, nullable, readonly) NSString *accountHolderName;

/**
 The type of entity that holds the account.
 */
@property (nonatomic, readonly) STPBankAccountHolderType accountHolderType;

/**
 A proxy for the account number, this uniquely identifies the account and can be 
 used to compare equality of different bank accounts.
 */
@property (nonatomic, nullable, readonly) NSString *fingerprint;

/**
 A set of key/value pairs associated with the bank account object.

 @see https://stripe.com/docs/api#metadata
 */
@property (nonatomic, copy, nullable, readonly) NSDictionary<NSString *, NSString *> *metadata;

/**
 The validation status of the bank account. @see STPBankAccountStatus
 */
@property (nonatomic, readonly) STPBankAccountStatus status;

#pragma mark - Deprecated methods

/**
 The Stripe ID for the bank account.
 */
@property (nonatomic, readonly) NSString *bankAccountId DEPRECATED_MSG_ATTRIBUTE("Use stripeID (defined in STPSourceProtocol)");

@end

NS_ASSUME_NONNULL_END
