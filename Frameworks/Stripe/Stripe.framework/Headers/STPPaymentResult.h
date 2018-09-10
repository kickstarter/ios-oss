//
//  STPPaymentResult.h
//  Stripe
//
//  Created by Jack Flintermann on 1/15/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STPSourceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class STPAddress;

/**
 When you're using `STPPaymentContext` to request your user's payment details, this is the object that will be returned to your application when they've successfully made a payment. It currently just contains a `source`, but in the future will include any relevant metadata as well. You should pass `source.stripeID` to your server, and call the charge creation endpoint. This assumes you are charging a Customer, so you should specify the `customer` parameter to be that customer's ID and the `source` parameter to the value returned here. For more information, see https://stripe.com/docs/api#create_charge
 */
@interface STPPaymentResult : NSObject

/**
 The returned source that the user has selected. This may come from a variety of different payment methods, such as an Apple Pay payment or a stored credit card. @see STPSource.h
 */
@property (nonatomic, readonly) id<STPSourceProtocol> source;

/**
 Initializes the payment result with a given source. This is invoked by `STPPaymentContext` internally; you shouldn't have to call it directly.
 */
- (nonnull instancetype)initWithSource:(id<STPSourceProtocol>)source;

@end

NS_ASSUME_NONNULL_END
