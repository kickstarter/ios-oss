//
//  STPSourceEnums.h
//  Stripe
//
//  Created by Brian Dorfman on 8/4/17.
//  Copyright © 2017 Stripe, Inc. All rights reserved.
//

/**
 Authentication flows for a Source
 */
typedef NS_ENUM(NSInteger, STPSourceFlow) {
    /**
     No action is required from your customer.
     */
    STPSourceFlowNone,

    /**
     Your customer must be redirected to their online banking service (either a website or mobile banking app) to approve the payment.
     */
    STPSourceFlowRedirect,

    /**
     Your customer must verify ownership of their account by providing a code that you post to the Stripe API for authentication.
     */
    STPSourceFlowCodeVerification,

    /**
     Your customer must push funds to the account information provided.
     */
    STPSourceFlowReceiver,

    /**
     The source's flow is unknown.
     */
    STPSourceFlowUnknown
};

/**
 Usage types for a Source
 */
typedef NS_ENUM(NSInteger, STPSourceUsage) {
    /**
     The source can be reused.
     */
    STPSourceUsageReusable,

    /**
     The source can only be used once.
     */
    STPSourceUsageSingleUse,

    /**
     The source's usage is unknown.
     */
    STPSourceUsageUnknown
};

/**
 Status types for a Source
 */
typedef NS_ENUM(NSInteger, STPSourceStatus) {
    /**
     The source has been created and is awaiting customer action.
     */
    STPSourceStatusPending,

    /**
     The source is ready to use. The customer action has been completed or the
     payment method requires no customer action.
     */
    STPSourceStatusChargeable,

    /**
     The source has been used. This status only applies to single-use sources.
     */
    STPSourceStatusConsumed,

    /**
     The source, which was chargeable, has expired because it was not used to
     make a charge request within a specified amount of time.
     */
    STPSourceStatusCanceled,

    /**
     Your customer has not taken the required action or revoked your access
     (e.g., did not authorize the payment with their bank or canceled their
     mandate acceptance for SEPA direct debits).
     */
    STPSourceStatusFailed,

    /**
     The source status is unknown.
     */
    STPSourceStatusUnknown,
};

/**
 Types for a Source
 
 @see https://stripe.com/docs/sources
 */
typedef NS_ENUM(NSInteger, STPSourceType) {
    /**
     A Bancontact source. @see https://stripe.com/docs/sources/bancontact
     */
    STPSourceTypeBancontact,

    /**
     A card source. @see https://stripe.com/docs/sources/cards
     */
    STPSourceTypeCard,

    /**
     A Giropay source. @see https://stripe.com/docs/sources/giropay
     */
    STPSourceTypeGiropay,

    /**
     An iDEAL source. @see https://stripe.com/docs/sources/ideal
     */
    STPSourceTypeIDEAL,

    /**
     A SEPA Direct Debit source. @see https://stripe.com/docs/sources/sepa-debit
     */
    STPSourceTypeSEPADebit,

    /**
     A SOFORT source. @see https://stripe.com/docs/sources/sofort
     */
    STPSourceTypeSofort,

    /**
     A 3DS card source. @see https://stripe.com/docs/sources/three-d-secure
     */
    STPSourceTypeThreeDSecure,

    /**
     An Alipay source. @see https://stripe.com/docs/sources/alipay
     */
    STPSourceTypeAlipay,

    /**
     A P24 source. @see https://stripe.com/docs/sources/p24
     */
    STPSourceTypeP24,

    /**
     An EPS source. @see https://stripe.com/docs/sources/eps
     */
    STPSourceTypeEPS,

    /**
     A Multibanco source. @see https://stripe.com/docs/sources/multibanco
     */
    STPSourceTypeMultibanco,

    /**
     An unknown type of source.
     */
    STPSourceTypeUnknown,
};
