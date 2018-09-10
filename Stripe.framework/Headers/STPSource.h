//
//  STPSource.h
//  Stripe
//
//  Created by Ben Guo on 1/23/17.
//  Copyright © 2017 Stripe, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STPAPIResponseDecodable.h"
#import "STPSourceCardDetails.h"
#import "STPSourceEnums.h"
#import "STPSourceOwner.h"
#import "STPSourceProtocol.h"
#import "STPSourceReceiver.h"
#import "STPSourceRedirect.h"
#import "STPSourceSEPADebitDetails.h"
#import "STPSourceVerification.h"

NS_ASSUME_NONNULL_BEGIN

@class STPSourceOwner, STPSourceReceiver, STPSourceRedirect, STPSourceVerification;

/**
 Representation of a customer's payment instrument created with the Stripe API. @see https://stripe.com/docs/api#sources
 */
@interface STPSource : NSObject<STPAPIResponseDecodable, STPSourceProtocol, STPPaymentMethod>

/**
 You cannot directly instantiate an `STPSource`. You should only use one that 
 has been returned from an `STPAPIClient` callback.
 */
- (instancetype)init __attribute__((unavailable("You cannot directly instantiate an STPSource. You should only use one that has been returned from an STPAPIClient callback.")));

/**
 The amount associated with the source.
 */
@property (nonatomic, nullable, readonly) NSNumber *amount;

/**
 The client secret of the source. Used for client-side fetching of a source
 using a publishable key.
 */
@property (nonatomic, nullable, readonly) NSString *clientSecret;

/**
 When the source was created.
 */
@property (nonatomic, nullable, readonly) NSDate *created;

/**
 The currency associated with the source.
 */
@property (nonatomic, nullable, readonly) NSString *currency;

/**
 The authentication flow of the source.
 */
@property (nonatomic, readonly) STPSourceFlow flow;

/**
 Whether or not this source was created in livemode.
 */
@property (nonatomic, readonly) BOOL livemode;

/**
 A set of key/value pairs associated with the source object.

 @see https://stripe.com/docs/api#metadata
 */
@property (nonatomic, copy, nullable, readonly) NSDictionary<NSString *, NSString *> *metadata;

/**
 Information about the owner of the payment instrument.
 */
@property (nonatomic, nullable, readonly) STPSourceOwner *owner;

/**
 Information related to the receiver flow. Present if the source's flow 
 is receiver.
 */
@property (nonatomic, nullable, readonly) STPSourceReceiver *receiver;

/**
 Information related to the redirect flow. Present if the source's flow 
 is redirect.
 */
@property (nonatomic, nullable, readonly) STPSourceRedirect *redirect;

/**
 The status of the source.
 */
@property (nonatomic, readonly) STPSourceStatus status;

/**
 The type of the source.
 */
@property (nonatomic, readonly) STPSourceType type;

/**
  Whether this source should be reusable or not.
 */
@property (nonatomic, readonly) STPSourceUsage usage;

/**
 Information related to the verification flow. Present if the source's flow
 is verification.
 */
@property (nonatomic, nullable, readonly) STPSourceVerification *verification;

/**
 Information about the source specific to its type
 */
@property (nonatomic, nullable, readonly) NSDictionary *details;

/**
 If this is a card source, this property provides typed access to the
 contents of the `details` dictionary.
 */
@property (nonatomic, nullable, readonly) STPSourceCardDetails *cardDetails;

/**
 If this is a SEPA Debit source, this property provides typed access to the
 contents of the `details` dictionary.
 */
@property (nonatomic, nullable, readonly) STPSourceSEPADebitDetails *sepaDebitDetails;

@end

NS_ASSUME_NONNULL_END
