//
//  STPShippingAddressViewController.h
//  Stripe
//
//  Created by Ben Guo on 8/29/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PassKit/PassKit.h>

#import "STPCoreTableViewController.h"
#import "STPPaymentContext.h"

NS_ASSUME_NONNULL_BEGIN

@protocol STPShippingAddressViewControllerDelegate;

/** This view controller contains a shipping address collection form. It renders a right bar button item that submits the form, so it must be shown inside a `UINavigationController`. Depending on your configuration's shippingType, the view controller may present a shipping method selection form after the user enters an address.
 */
@interface STPShippingAddressViewController : STPCoreTableViewController

/**
 A convenience initializer; equivalent to calling `initWithConfiguration:[STPPaymentConfiguration sharedConfiguration] theme:[STPTheme defaultTheme] currency:nil shippingAddress:nil selectedShippingMethod:nil prefilledInformation:nil`.
 */
- (instancetype)init;

/**
 Initializes a new `STPShippingAddressViewController` with the given payment context and sets the payment context as its delegate.

 @param paymentContext The payment context to use.
 */
- (instancetype)initWithPaymentContext:(STPPaymentContext *)paymentContext;

/**
 Initializes a new `STPShippingAddressCardViewController` with the provided parameters.

 @param configuration             The configuration to use (this determines the required shipping address fields and shipping type). @see STPPaymentConfiguration
 @param theme                     The theme to use to inform the view controller's visual appearance. @see STPTheme
 @param currency                  The currency to use when displaying amounts for shipping methods. The default is USD.
 @param shippingAddress           If set, the shipping address view controller will be pre-filled with this address. @see STPAddress
 @param selectedShippingMethod    If set, the shipping methods view controller will use this method as the selected shipping method. If `selectedShippingMethod` is nil, the first shipping method in the array of methods returned by your delegate will be selected.
 @param prefilledInformation      If set, the shipping address view controller will be pre-filled with this information. @see STPUserInformation
 */
- (instancetype)initWithConfiguration:(STPPaymentConfiguration *)configuration
                                theme:(STPTheme *)theme
                             currency:(nullable NSString *)currency
                      shippingAddress:(nullable STPAddress *)shippingAddress
               selectedShippingMethod:(nullable PKShippingMethod *)selectedShippingMethod
                 prefilledInformation:(nullable STPUserInformation *)prefilledInformation;

/**
 The view controller's delegate. This must be set before showing the view controller in order for it to work properly. @see STPShippingAddressViewControllerDelegate
 */
@property (nonatomic, weak) id<STPShippingAddressViewControllerDelegate> delegate;

/**
 If you're pushing `STPShippingAddressViewController` onto an existing `UINavigationController`'s stack, you should use this method to dismiss it, since it may have pushed an additional shipping method view controller onto the navigation controller's stack.

 @param completion The callback to run after the view controller is dismissed. You may specify nil for this parameter.
 */
- (void)dismissWithCompletion:(nullable STPVoidBlock)completion;

/**
 Use one of the initializers declared in this interface.
 */
- (instancetype)initWithTheme:(STPTheme *)theme NS_UNAVAILABLE;

/**
 Use one of the initializers declared in this interface.
 */
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

/**
 Use one of the initializers declared in this interface.
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

@end

/**
 An `STPShippingAddressViewControllerDelegate` is notified when an `STPShippingAddressViewController` receives an address, completes with an address, or is cancelled.
 */
@protocol STPShippingAddressViewControllerDelegate <NSObject>

/**
 Called when the user cancels entering a shipping address. You should dismiss (or pop) the view controller at this point.

 @param addressViewController the view controller that has been cancelled
 */
- (void)shippingAddressViewControllerDidCancel:(STPShippingAddressViewController *)addressViewController;

/**
 This is called when the user enters a shipping address and taps next. You
 should validate the address and determine what shipping methods are available,
 and call the `completion` block when finished. If an error occurrs, call
 the `completion` block with the error. Otherwise, call the `completion`
 block with a nil error and an array of available shipping methods. If you don't
 need to collect a shipping method, you may pass an empty array or nil.

 @param addressViewController the view controller where the address was entered
 @param address               the address that was entered. @see STPAddress
 @param completion            call this callback when you're done validating the address and determining available shipping methods.
 */
- (void)shippingAddressViewController:(STPShippingAddressViewController *)addressViewController
                      didEnterAddress:(STPAddress *)address
                           completion:(STPShippingMethodsCompletionBlock)completion;

/**
 This is called when the user selects a shipping method. If no shipping methods are given, or if the shipping type doesn't require a shipping method, this will be called after the user has a shipping address and your validation has succeeded. After updating your app with the user's shipping info, you should dismiss (or pop) the view controller. Note that if `shippingMethod` is non-nil, there will be an additional shipping methods view controller on the navigation controller's stack.

 @param addressViewController the view controller where the address was entered
 @param address               the address that was entered. @see STPAddress
 @param method        the shipping method that was selected.
 */
- (void)shippingAddressViewController:(STPShippingAddressViewController *)addressViewController
                 didFinishWithAddress:(STPAddress *)address
                       shippingMethod:(nullable PKShippingMethod *)method;

@end

NS_ASSUME_NONNULL_END
