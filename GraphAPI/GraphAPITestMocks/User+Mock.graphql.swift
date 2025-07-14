// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class User: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.User
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<User>>

  public struct MockFields {
    @Field<Int>("backingActionCount") public var backingActionCount
    @Field<UserBackingsConnection>("backings") public var backings
    @Field<Int>("backingsCount") public var backingsCount
    @Field<String>("chosenCurrency") public var chosenCurrency
    @Field<UserCreatedProjectsConnection>("createdProjects") public var createdProjects
    @Field<String>("email") public var email
    @Field<[GraphQLEnum<GraphAPI.Feature>]>("enabledFeatures") public var enabledFeatures
    @Field<Bool>("hasPassword") public var hasPassword
    @Field<Bool>("hasUnreadMessages") public var hasUnreadMessages
    @Field<Bool>("hasUnseenActivity") public var hasUnseenActivity
    @Field<GraphAPI.ID>("id") public var id
    @Field<String>("imageUrl") public var imageUrl
    @Field<Bool>("isAppleConnected") public var isAppleConnected
    @Field<Bool>("isBlocked") public var isBlocked
    @Field<Bool>("isCreator") public var isCreator
    @Field<Bool>("isDeliverable") public var isDeliverable
    @Field<Bool>("isEmailVerified") public var isEmailVerified
    @Field<Bool>("isFacebookConnected") public var isFacebookConnected
    @Field<Bool>("isFollowing") public var isFollowing
    @Field<Bool>("isKsrAdmin") public var isKsrAdmin
    @Field<Bool>("isSocializing") public var isSocializing
    @Field<Location>("location") public var location
    @Field<String>("name") public var name
    @Field<Bool>("needsFreshFacebookToken") public var needsFreshFacebookToken
    @Field<NewsletterSubscriptions>("newsletterSubscriptions") public var newsletterSubscriptions
    @Field<[Notification]>("notifications") public var notifications
    @Field<Bool>("optedOutOfRecommendations") public var optedOutOfRecommendations
    @Field<Bool>("ppoHasAction") public var ppoHasAction
    @Field<UserSavedProjectsConnection>("savedProjects") public var savedProjects
    @Field<Bool>("showPublicProfile") public var showPublicProfile
    @Field<UserCreditCardTypeConnection>("storedCards") public var storedCards
    @Field<SurveyResponsesConnection>("surveyResponses") public var surveyResponses
    @Field<String>("uid") public var uid
  }
}

public extension Mock where O == User {
  convenience init(
    backingActionCount: Int? = nil,
    backings: Mock<UserBackingsConnection>? = nil,
    backingsCount: Int? = nil,
    chosenCurrency: String? = nil,
    createdProjects: Mock<UserCreatedProjectsConnection>? = nil,
    email: String? = nil,
    enabledFeatures: [GraphQLEnum<GraphAPI.Feature>]? = nil,
    hasPassword: Bool? = nil,
    hasUnreadMessages: Bool? = nil,
    hasUnseenActivity: Bool? = nil,
    id: GraphAPI.ID? = nil,
    imageUrl: String? = nil,
    isAppleConnected: Bool? = nil,
    isBlocked: Bool? = nil,
    isCreator: Bool? = nil,
    isDeliverable: Bool? = nil,
    isEmailVerified: Bool? = nil,
    isFacebookConnected: Bool? = nil,
    isFollowing: Bool? = nil,
    isKsrAdmin: Bool? = nil,
    isSocializing: Bool? = nil,
    location: Mock<Location>? = nil,
    name: String? = nil,
    needsFreshFacebookToken: Bool? = nil,
    newsletterSubscriptions: Mock<NewsletterSubscriptions>? = nil,
    notifications: [Mock<Notification>]? = nil,
    optedOutOfRecommendations: Bool? = nil,
    ppoHasAction: Bool? = nil,
    savedProjects: Mock<UserSavedProjectsConnection>? = nil,
    showPublicProfile: Bool? = nil,
    storedCards: Mock<UserCreditCardTypeConnection>? = nil,
    surveyResponses: Mock<SurveyResponsesConnection>? = nil,
    uid: String? = nil
  ) {
    self.init()
    _setScalar(backingActionCount, for: \.backingActionCount)
    _setEntity(backings, for: \.backings)
    _setScalar(backingsCount, for: \.backingsCount)
    _setScalar(chosenCurrency, for: \.chosenCurrency)
    _setEntity(createdProjects, for: \.createdProjects)
    _setScalar(email, for: \.email)
    _setScalarList(enabledFeatures, for: \.enabledFeatures)
    _setScalar(hasPassword, for: \.hasPassword)
    _setScalar(hasUnreadMessages, for: \.hasUnreadMessages)
    _setScalar(hasUnseenActivity, for: \.hasUnseenActivity)
    _setScalar(id, for: \.id)
    _setScalar(imageUrl, for: \.imageUrl)
    _setScalar(isAppleConnected, for: \.isAppleConnected)
    _setScalar(isBlocked, for: \.isBlocked)
    _setScalar(isCreator, for: \.isCreator)
    _setScalar(isDeliverable, for: \.isDeliverable)
    _setScalar(isEmailVerified, for: \.isEmailVerified)
    _setScalar(isFacebookConnected, for: \.isFacebookConnected)
    _setScalar(isFollowing, for: \.isFollowing)
    _setScalar(isKsrAdmin, for: \.isKsrAdmin)
    _setScalar(isSocializing, for: \.isSocializing)
    _setEntity(location, for: \.location)
    _setScalar(name, for: \.name)
    _setScalar(needsFreshFacebookToken, for: \.needsFreshFacebookToken)
    _setEntity(newsletterSubscriptions, for: \.newsletterSubscriptions)
    _setList(notifications, for: \.notifications)
    _setScalar(optedOutOfRecommendations, for: \.optedOutOfRecommendations)
    _setScalar(ppoHasAction, for: \.ppoHasAction)
    _setEntity(savedProjects, for: \.savedProjects)
    _setScalar(showPublicProfile, for: \.showPublicProfile)
    _setEntity(storedCards, for: \.storedCards)
    _setEntity(surveyResponses, for: \.surveyResponses)
    _setScalar(uid, for: \.uid)
  }
}
