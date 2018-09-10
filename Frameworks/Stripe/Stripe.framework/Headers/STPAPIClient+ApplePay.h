//
//  STPAPIClient+ApplePay.h
//  Stripe
//
//  Created by Jack Flintermann on 12/19/14.
//

#import <Foundation/Foundation.h>
#import <PassKit/PassKit.h>

#import "STPAPIClient.h"

/**
 STPAPIClient extensions to create Stripe tokens from Apple Pay PKPayment objects.
 */
@interface STPAPIClient (ApplePay)

/**
 Converts a PKPayment object into a Stripe token using the Stripe API.

 @param payment     The user's encrypted payment information as returned from a PKPaymentAuthorizationViewController. Cannot be nil.
 @param completion  The callback to run with the returned Stripe token (and any errors that may have occurred).
 */
- (void)createTokenWithPayment:(nonnull PKPayment *)payment
                    completion:(nonnull STPTokenCompletionBlock)completion;

/**
 Converts a PKPayment object into a Stripe source using the Stripe API.

 @param payment     The user's encrypted payment information as returned from a PKPaymentAuthorizationViewController. Cannot be nil.
 @param completion  The callback to run with the returned Stripe source (and any errors that may have occurred).
 */
- (void)createSourceWithPayment:(nonnull PKPayment *)payment
                     completion:(nonnull STPSourceCompletionBlock)completion;

@end

/**
 This function should not be called directly.
 
 It is used by the SDK when it is built as a static library to force the
 compiler to link in category methods regardless of the integrating
 app's compiler flags.
 */
void linkSTPAPIClientApplePayCategory(void);
