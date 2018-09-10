//
//  STPSourceSEPADebitDetails.h
//  Stripe
//
//  Created by Brian Dorfman on 2/24/17.
//  Copyright © 2017 Stripe, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STPAPIResponseDecodable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 This class provides typed access to the contents of an STPSource `details`
 dictionary for SEPA Debit sources.
 */
@interface STPSourceSEPADebitDetails : NSObject <STPAPIResponseDecodable>

/**
 You cannot directly instantiate an `STPSourceSEPADebitDetails`. 
 You should only use one that is part of an existing `STPSource` object.
 */
- (instancetype)init __attribute__((unavailable("You cannot directly instantiate an STPSourceSEPADebitDetails. You should only use one that is part of an existing STPSource object.")));

/**
 The last 4 digits of the account number.
 */
@property (nonatomic, nullable, readonly) NSString *last4;

/**
 The account's bank code.
 */
@property (nonatomic, nullable, readonly) NSString *bankCode;

/**
 Two-letter ISO code representing the country of the bank account.
 */
@property (nonatomic, nullable, readonly) NSString *country;

/**
 The account's fingerprint.
 */
@property (nonatomic, nullable, readonly) NSString *fingerprint;

/**
 The reference of the mandate accepted by your customer.
 */
@property (nonatomic, nullable, readonly) NSString *mandateReference;

/**
 The details of the mandate accepted by your customer.
 */
@property (nonatomic, nullable, readonly) NSURL *mandateURL;

@end

NS_ASSUME_NONNULL_END
