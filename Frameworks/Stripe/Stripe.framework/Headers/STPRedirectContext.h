//
//  STPRedirectContext.h
//  Stripe
//
//  Created by Brian Dorfman on 3/29/17.
//  Copyright © 2017 Stripe, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STPBlocks.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Possible states for the redirect context to be in
 */
typedef NS_ENUM(NSUInteger, STPRedirectContextState) {
    /**
     Initialized, but redirect not started.
     */
    STPRedirectContextStateNotStarted,

    /**
      Redirect is in progress.
     */
    STPRedirectContextStateInProgress,

    /**
     Redirect has been cancelled programmatically before completing.
     */
    STPRedirectContextStateCancelled,

    /**
     Redirect has completed.
     */
    STPRedirectContextStateCompleted
};

/**
 A callback that is executed when the context believes the redirect action has been completed.

 @param sourceID The stripe id of the source.
 @param clientSecret The client secret of the source.
 @param error An error if one occured. Note that a lack of an error does not 
 mean that the action was completed successfully, the presence of one confirms 
 that it was not. Currently the only possible error the context can know about 
 is if SFSafariViewController fails its initial load (e.g. the user has no
 internet connection, or servers are down).
 */
typedef void (^STPRedirectContextSourceCompletionBlock)(NSString *sourceID, NSString * __nullable clientSecret, NSError * __nullable error);

/**
 A callback that is executed when the context believes the redirect action has been completed.

 This type has been renamed to `STPRedirectContextSourceCompletionBlock` and deprecated.
 */
__attribute__((deprecated("STPRedirectContextCompletionBlock has been renamed to STPRedirectContextSourceCompletionBlock", "STPRedirectContextSourceCompletionBlock")))
typedef STPRedirectContextSourceCompletionBlock STPRedirectContextCompletionBlock;


/**
 A callback that is executed when the context believes the redirect action has been completed.

 @param clientSecret The client secret of the PaymentIntent
 @param error An error if one occured. Note that a lack of an error does not
 mean that the action was completed successfully, the presence of one confirms
 that it was not. Currently the only possible error the context can know about
 is if SFSafariViewController fails its initial load (e.g. the user has no
 internet connection, or servers are down).
 */
typedef void(^STPRedirectContextPaymentIntentCompletionBlock)(NSString *clientSecret, NSError * __nullable error);

/**
 This is a helper class for handling redirects associated with STPSource and
 STPPaymentIntents.

 Init and retain an instance with the Source or PaymentIntent you want to handle,
 then choose a redirect method. The context will fire the completion handler
 when the redirect completes.

 Due to the nature of iOS, very little concrete information can be gained
 during this process, as all actions take place in either the Safari app
 or the sandboxed SFSafariViewController class. The context attempts to 
 detect when the user has completed the necessary redirect action by listening
 for both app foregrounds and url callbacks received in the app delegate.
 However, it is possible the when the redirect is "completed", the user may
 have not actually completed the necessary actions to authorize the charge.

 You should not use either this class, nor `STPAPIClient`, as a way
 to determine when you should charge the Source or to determine if the redirect
 was successful. Use Stripe webhooks on your backend server to listen for Source
 state changes and to make the charge.
 
 See https://stripe.com/docs/sources/best-practices
 */
NS_EXTENSION_UNAVAILABLE("STPRedirectContext is not available in extensions")
@interface STPRedirectContext : NSObject

/**
 The current state of the context.
 */
@property (nonatomic, readonly) STPRedirectContextState state;

/**
 Initializer for context from an `STPSource`.

 @note You must ensure that the returnURL set up in the created source
 correctly goes to your app so that users can be returned once
 they complete the redirect in the web broswer.

 @param source The source that needs user redirect action to be taken.
 @param completion A block to fire when the action is believed to have 
 been completed.

 @return nil if the specified source is not a redirect-flow source. Otherwise
 a new context object.

 @note Execution of the completion block does not necessarily mean the user
 successfully performed the redirect action. You should listen for source status
 change webhooks on your backend to determine the result of a redirect.
 */
- (nullable instancetype)initWithSource:(STPSource *)source
                             completion:(STPRedirectContextSourceCompletionBlock)completion;

/**
 Initializer for context from an `STPPaymentIntent`.

 This should be used when the `status` is `STPPaymentIntentStatusRequiresSourceAction`.
 If the next action involves a redirect, this init method will return a non-nil object.

 @param paymentIntent The STPPaymentIntent that needs a redirect.
 @param completion A block to fire when the action is believed to have
 been completed.

 @return nil if the provided PaymentIntent does not need a redirect. Otherwise
 a new context object.

 @note Execution of the completion block does not necessarily mean the user
 successfully performed the redirect action.
 */
- (nullable instancetype)initWithPaymentIntent:(STPPaymentIntent *)paymentIntent
                                    completion:(STPRedirectContextPaymentIntentCompletionBlock)completion;

/**
 Use `initWithSource:completion:`
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 Starts a redirect flow.

 You must ensure that your app delegate listens for  the `returnURL` that you
 set on the Stripe object, and forwards it to the Stripe SDK so that the
 context can be notified when the redirect is completed and dismiss the
 view controller. See `[Stripe handleStripeURLCallbackWithURL:]`

 The context will listen for both received URLs and app open notifications
 and fire its completion block when either the URL is received, or the next
 time the app is foregrounded.

 The context will initiate the flow by presenting a SFSafariViewController
 instance from the passsed in view controller. If you want more manual control
 over the redirect method, you can use `startSafariViewControllerRedirectFlowFromViewController` 
 or `startSafariAppRedirectFlow`
 
 If the redirect supports a native app, and that app is is installed on the user's
 device, this call will do a direct app-to-app redirect instead of showing
 a web url. 

 @note This method does nothing if the context is not in the 
 `STPRedirectContextStateNotStarted` state.

 @param presentingViewController The view controller to present the Safari
 view controller from.
 */
- (void)startRedirectFlowFromViewController:(UIViewController *)presentingViewController;

/**
 Starts a redirect flow by presenting an SFSafariViewController in your app
 from the passed in view controller.

 You must ensure that your app delegate listens for  the `returnURL` that you
 set on the Stripe object, and forwards it to the Stripe SDK so that the
 context can be notified when the redirect is completed and dismiss the
 view controller. See `[Stripe handleStripeURLCallbackWithURL:]`

 The context will listen for both received URLs and app open notifications 
 and fire its completion block when either the URL is received, or the next
 time the app is foregrounded.

 @note This method does nothing if the context is not in the 
 `STPRedirectContextStateNotStarted` state.

 @param presentingViewController The view controller to present the Safari 
 view controller from.
 */
- (void)startSafariViewControllerRedirectFlowFromViewController:(UIViewController *)presentingViewController;

/**
 Starts a redirect flow by calling `openURL` to bounce the user out to
 the Safari app.

 The context will listen for app open notifications and fire its completion
 block the next time the user re-opens the app (either manually or via url)

 @note This method does nothing if the context is not in the 
  `STPRedirectContextStateNotStarted` state.
 */
- (void)startSafariAppRedirectFlow;

/**
 Dismisses any presented views and stops listening for any
 app opens or callbacks. The completion block will not be fired.
 */
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
