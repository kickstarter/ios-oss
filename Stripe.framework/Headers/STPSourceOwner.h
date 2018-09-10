//
//  STPSourceOwner.h
//  Stripe
//
//  Created by Ben Guo on 1/25/17.
//  Copyright © 2017 Stripe, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STPAPIResponseDecodable.h"

NS_ASSUME_NONNULL_BEGIN

@class STPAddress;

/**
 Information about a source's owner.
 */
@interface STPSourceOwner : NSObject<STPAPIResponseDecodable>

/**
 You cannot directly instantiate an `STPSourceOwner`. You should only use one 
 that is part of an existing `STPSource` object.
 */
- (instancetype)init __attribute__((unavailable("You cannot directly instantiate an STPSourceOwner. You should only use one that is part of an existing STPSource object.")));

/**
 Owner's address.
 */
@property (nonatomic, nullable, readonly) STPAddress *address;

/**
 Owner's email address.
 */
@property (nonatomic, nullable, readonly) NSString *email;

/**
 Owner's full name.
 */
@property (nonatomic, nullable, readonly) NSString *name;

/**
 Owner's phone number.
 */
@property (nonatomic, nullable, readonly) NSString *phone;

/**
 Verified owner's address.
 */
@property (nonatomic, nullable, readonly) STPAddress *verifiedAddress;

/**
 Verified owner's email address.
 */
@property (nonatomic, nullable, readonly) NSString *verifiedEmail;

/**
 Verified owner's full name.
 */
@property (nonatomic, nullable, readonly) NSString *verifiedName;

/**
 Verified owner's phone number.
 */
@property (nonatomic, nullable, readonly) NSString *verifiedPhone;

@end

NS_ASSUME_NONNULL_END
