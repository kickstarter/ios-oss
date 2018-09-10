//
//  STPPaymentIntentEnums.h
//  Stripe
//
//  Created by Daniel Jackson on 6/27/18.
//  Copyright © 2018 Stripe, Inc. All rights reserved.
//

/**
 Status types for an STPPaymentIntent
 */
typedef NS_ENUM(NSInteger, STPPaymentIntentStatus) {
    /**
     Unknown status
     */
    STPPaymentIntentStatusUnknown,

    /**
     This PaymentIntent requires a Source
     */
    STPPaymentIntentStatusRequiresSource,

    /**
     This PaymentIntent needs to be confirmed
     */
    STPPaymentIntentStatusRequiresConfirmation,

    /**
     The selected Source requires additional authentication steps.
     Additional actions found via `next_source_action`
     */
    STPPaymentIntentStatusRequiresSourceAction,

    /**
     Stripe is processing this PaymentIntent
     */
    STPPaymentIntentStatusProcessing,

    /**
     The payment has succeeded
     */
    STPPaymentIntentStatusSucceeded,

    /**
     Indicates the payment must be captured, for STPPaymentIntentCaptureMethodManual
     */
    STPPaymentIntentStatusRequiresCapture,

    /**
     This PaymentIntent was canceled and cannot be changed.
     */
    STPPaymentIntentStatusCanceled,
};

/**
 Capture methods for a STPPaymentIntent
 */
typedef NS_ENUM(NSInteger, STPPaymentIntentCaptureMethod) {
    /**
     Unknown capture method
     */
    STPPaymentIntentCaptureMethodUnknown,

    /**
     The PaymentIntent will be automatically captured
     */
    STPPaymentIntentCaptureMethodAutomatic,

    /**
     The PaymentIntent must be manually captured once it has the status
     `STPPaymentIntentStatusRequiresCapture`
     */
    STPPaymentIntentCaptureMethodManual,
};

/**
 Confirmation methods for a STPPaymentIntent
 */
typedef NS_ENUM(NSInteger, STPPaymentIntentConfirmationMethod) {
    /**
     Unknown confirmation method
     */
    STPPaymentIntentConfirmationMethodUnknown,

    /**
     Confirmed via publishable key
     */
    STPPaymentIntentConfirmationMethodPublishable,

    /**
     Confirmed via secret key
     */
    STPPaymentIntentConfirmationMethodSecret,
};
