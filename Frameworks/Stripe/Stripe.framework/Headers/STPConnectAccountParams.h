//
//  STPConnectAccountParams.h
//  Stripe
//
//  Created by Daniel Jackson on 1/4/18.
//  Copyright © 2018 Stripe, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STPFormEncodable.h"

@class STPLegalEntityParams;

NS_ASSUME_NONNULL_BEGIN

/**
 Parameters for creating a Connect Account token.
 */
@interface STPConnectAccountParams : NSObject<STPFormEncodable>

/**
 Optional boolean indicating that the Terms Of Service were shown to the user &
 the user accepted them.
 */
@property (nonatomic, nullable, readonly) NSNumber *tosShownAndAccepted;

/**
 Required property with information about the legal entity for this account.

 At least one field in the legalEntity must have a value, otherwise the create token
 call will fail.
 */
@property (nonatomic, readonly) STPLegalEntityParams *legalEntity;

/**
 `STPConnectAccountParams` cannot be directly instantiated, use `initWithTosShownAndAccepted:legalEntity:`
 or `initWithLegalEntity:`
 */
- (instancetype)init __attribute__((unavailable("Cannot be directly instantiated")));

/**
 Initialize `STPConnectAccountParams` with tosShownAndAccepted = YES

 This method cannot be called with `wasAccepted == NO`, guarded by a `NSParameterAssert()`.

 Use this init method if you want to set the `tosShownAndAccepted` parameter. If you
 don't, use the `initWithLegalEntity:` version instead.

 @param wasAccepted Must be YES, but only if the user was shown & accepted the ToS
 @param legalEntity data about the legal entity
 */
- (instancetype)initWithTosShownAndAccepted:(BOOL)wasAccepted
                                legalEntity:(STPLegalEntityParams *)legalEntity;

/**
 Initialize `STPConnectAccountParams` with the `STPLegalEntityParams` provided.

 This init method cannot change the `tosShownAndAccepted` parameter. Use
 `initWithTosShownAndAccepted:legalEntity:` instead if you need to do that.

 These two init methods exist to avoid the (slightly awkward) NSNumber box that would
 be needed around `tosShownAndAccepted` if it was optional/nullable, and to enforce
 that it is either nil or YES.

 @param legalEntity data to send to Stripe about the legal entity
 */
- (instancetype)initWithLegalEntity:(STPLegalEntityParams *)legalEntity;

@end

NS_ASSUME_NONNULL_END
