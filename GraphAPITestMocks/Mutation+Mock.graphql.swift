// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class Mutation: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.Mutation
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Mutation>>

  public struct MockFields {
    @Field<AddUserToSecretRewardGroupPayload>("addUserToSecretRewardGroup") public var addUserToSecretRewardGroup
    @Field<BlockUserPayload>("blockUser") public var blockUser
    @Field<CancelBackingPayload>("cancelBacking") public var cancelBacking
    @Field<ClearUserUnseenActivityPayload>("clearUserUnseenActivity") public var clearUserUnseenActivity
    @Field<CompleteOnSessionCheckoutPayload>("completeOnSessionCheckout") public var completeOnSessionCheckout
    @Field<CreateAttributionEventPayload>("createAttributionEvent") public var createAttributionEvent
    @Field<CreateBackingPayload>("createBacking") public var createBacking
    @Field<CreateCheckoutPayload>("createCheckout") public var createCheckout
    @Field<PostCommentPayload>("createComment") public var createComment
    @Field<CreateFlaggingPayload>("createFlagging") public var createFlagging
    @Field<CreateOrUpdateBackingAddressPayload>("createOrUpdateBackingAddress") public var createOrUpdateBackingAddress
    @Field<CreatePaymentIntentPayload>("createPaymentIntent") public var createPaymentIntent
    @Field<CreatePaymentSourcePayload>("createPaymentSource") public var createPaymentSource
    @Field<CreateSetupIntentPayload>("createSetupIntent") public var createSetupIntent
    @Field<PaymentSourceDeletePayload>("paymentSourceDelete") public var paymentSourceDelete
    @Field<SignInWithApplePayload>("signInWithApple") public var signInWithApple
    @Field<TriggerThirdPartyEventPayload>("triggerThirdPartyEvent") public var triggerThirdPartyEvent
    @Field<UpdateBackingPayload>("updateBacking") public var updateBacking
    @Field<UpdateUserAccountPayload>("updateUserAccount") public var updateUserAccount
    @Field<UpdateUserProfilePayload>("updateUserProfile") public var updateUserProfile
    @Field<UserSendEmailVerificationPayload>("userSendEmailVerification") public var userSendEmailVerification
    @Field<WatchProjectPayload>("watchProject") public var watchProject
  }
}

public extension Mock where O == Mutation {
  convenience init(
    addUserToSecretRewardGroup: Mock<AddUserToSecretRewardGroupPayload>? = nil,
    blockUser: Mock<BlockUserPayload>? = nil,
    cancelBacking: Mock<CancelBackingPayload>? = nil,
    clearUserUnseenActivity: Mock<ClearUserUnseenActivityPayload>? = nil,
    completeOnSessionCheckout: Mock<CompleteOnSessionCheckoutPayload>? = nil,
    createAttributionEvent: Mock<CreateAttributionEventPayload>? = nil,
    createBacking: Mock<CreateBackingPayload>? = nil,
    createCheckout: Mock<CreateCheckoutPayload>? = nil,
    createComment: Mock<PostCommentPayload>? = nil,
    createFlagging: Mock<CreateFlaggingPayload>? = nil,
    createOrUpdateBackingAddress: Mock<CreateOrUpdateBackingAddressPayload>? = nil,
    createPaymentIntent: Mock<CreatePaymentIntentPayload>? = nil,
    createPaymentSource: Mock<CreatePaymentSourcePayload>? = nil,
    createSetupIntent: Mock<CreateSetupIntentPayload>? = nil,
    paymentSourceDelete: Mock<PaymentSourceDeletePayload>? = nil,
    signInWithApple: Mock<SignInWithApplePayload>? = nil,
    triggerThirdPartyEvent: Mock<TriggerThirdPartyEventPayload>? = nil,
    updateBacking: Mock<UpdateBackingPayload>? = nil,
    updateUserAccount: Mock<UpdateUserAccountPayload>? = nil,
    updateUserProfile: Mock<UpdateUserProfilePayload>? = nil,
    userSendEmailVerification: Mock<UserSendEmailVerificationPayload>? = nil,
    watchProject: Mock<WatchProjectPayload>? = nil
  ) {
    self.init()
    _setEntity(addUserToSecretRewardGroup, for: \.addUserToSecretRewardGroup)
    _setEntity(blockUser, for: \.blockUser)
    _setEntity(cancelBacking, for: \.cancelBacking)
    _setEntity(clearUserUnseenActivity, for: \.clearUserUnseenActivity)
    _setEntity(completeOnSessionCheckout, for: \.completeOnSessionCheckout)
    _setEntity(createAttributionEvent, for: \.createAttributionEvent)
    _setEntity(createBacking, for: \.createBacking)
    _setEntity(createCheckout, for: \.createCheckout)
    _setEntity(createComment, for: \.createComment)
    _setEntity(createFlagging, for: \.createFlagging)
    _setEntity(createOrUpdateBackingAddress, for: \.createOrUpdateBackingAddress)
    _setEntity(createPaymentIntent, for: \.createPaymentIntent)
    _setEntity(createPaymentSource, for: \.createPaymentSource)
    _setEntity(createSetupIntent, for: \.createSetupIntent)
    _setEntity(paymentSourceDelete, for: \.paymentSourceDelete)
    _setEntity(signInWithApple, for: \.signInWithApple)
    _setEntity(triggerThirdPartyEvent, for: \.triggerThirdPartyEvent)
    _setEntity(updateBacking, for: \.updateBacking)
    _setEntity(updateUserAccount, for: \.updateUserAccount)
    _setEntity(updateUserProfile, for: \.updateUserProfile)
    _setEntity(userSendEmailVerification, for: \.userSendEmailVerification)
    _setEntity(watchProject, for: \.watchProject)
  }
}
