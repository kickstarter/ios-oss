//
//  STPSourceRedirect.h
//  Stripe
//
//  Created by Ben Guo on 1/25/17.
//  Copyright © 2017 Stripe, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STPAPIResponseDecodable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Redirect status types for a Source.
 */
typedef NS_ENUM(NSInteger, STPSourceRedirectStatus) {

    /**
     The redirect is pending.
     */
    STPSourceRedirectStatusPending,

    /**
     The redirect has succeeded.
     */
    STPSourceRedirectStatusSucceeded,

    /**
     The redirect has failed.
     */
    STPSourceRedirectStatusFailed,

    /**
     The state of the redirect is unknown.
     */
    STPSourceRedirectStatusUnknown
};

/**
 Information related to a source's redirect flow.
 */
@interface STPSourceRedirect : NSObject<STPAPIResponseDecodable>

/**
 You cannot directly instantiate an `STPSourceRedirect`. You should only use 
 one that is part of an existing `STPSource` object.
 */
- (instancetype)init __attribute__((unavailable("You cannot directly instantiate an STPSourceRedirect. You should only use one that is part of an existing STPSource object.")));

/**
 The URL you provide to redirect the customer to after they authenticated their payment.
 */
@property (nonatomic, nullable, readonly) NSURL *returnURL;

/**
 The status of the redirect.
 */
@property (nonatomic, readonly) STPSourceRedirectStatus status;

/**
 The URL provided to you to redirect a customer to as part of a redirect authentication flow.
 */
@property (nonatomic, nullable, readonly) NSURL *url;

@end

NS_ASSUME_NONNULL_END
