//
//  STPSourceProtocol.h
//  Stripe
//
//  Created by Jack Flintermann on 1/15/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Objects conforming to this protocol can be attached to a Stripe Customer object
 as a payment source.
 
 @see https://stripe.com/docs/api#customer_object-sources
 */
@protocol STPSourceProtocol <NSObject>

/**
 The Stripe ID of the source.
 */
@property (nonatomic, readonly) NSString *stripeID;

@end

NS_ASSUME_NONNULL_END
