import Foundation

extension UserEnvelope {
  /**
   Returns a `UserEnvelope<GraphUser>` from a `FetchUserQuery.Data` object.
   */
  static func userEnvelope(from data: GraphAPI.FetchUserQuery.Data) -> UserEnvelope<GraphUser>? {
    guard let userFragment = data.me?.fragments.userFragment else { return nil }

    let allStoredCards = UserCreditCards.userCreditCards(from: userFragment)

    let userCreditCards = UserCreditCards(storedCards: allStoredCards.storedCards)

    let graphUser = GraphUser(
      chosenCurrency: userFragment.chosenCurrency,
      email: userFragment.email,
      hasPassword: userFragment.hasPassword,
      id: userFragment.id,
      isBlocked: userFragment.isBlocked,
      isCreator: userFragment.isCreator,
      imageUrl: userFragment.imageUrl,
      isAppleConnected: userFragment.isAppleConnected,
      isEmailVerified: userFragment.isEmailVerified,
      isDeliverable: userFragment.isDeliverable,
      name: userFragment.name,
      storedCards: userCreditCards,
      uid: userFragment.uid
    )

    return UserEnvelope<GraphUser>(me: graphUser)
  }

  /**
   Returns a `User` from a `FetchUserQuery.Data` object if possible.
   */
  static func user(from data: GraphAPI.FetchUserQuery.Data) -> UserEnvelope<User>? {
    guard let userFragment = data.me?.fragments.userFragment,
          let user = User.user(from: userFragment) else { return nil }

    return UserEnvelope<User>(me: user)
  }

  /**
   Returns a `UserEnvelope<GraphUserEmail>` from a `FetchUserEmailQuery.Data` object.
   */
  static func userEnvelope(from data: GraphAPI.FetchUserEmailQuery.Data) -> UserEnvelope<GraphUserEmail>? {
    guard let userFragment = data.me?.fragments.userEmailFragment else { return nil }

    let graphUser = GraphUserEmail(
      email: userFragment.email
    )

    return UserEnvelope<GraphUserEmail>(me: graphUser)
  }

  /**
   Returns a `UserEnvelope<GraphUserSetup>` from a `FetchUserSetupQuery.Data` object.
   */
  static func userEnvelope(from data: GraphAPI.FetchUserSetupQuery.Data) -> UserEnvelope<GraphUserSetup>? {
    guard
      let userFragment = data.me?.fragments.userEmailFragment,
      let featuresFragment = data.me?.fragments.userFeaturesFragment,
      let ppoUserFragment = data.me?.fragments.ppoUserSetupFragment
    else { return nil }

    let graphUser = GraphUserSetup(
      email: userFragment.email,
      enabledFeatures: Set(featuresFragment.enabledFeatures),
      ppoHasAction: ppoUserFragment.ppoHasAction,
      backingActionCount: ppoUserFragment.backingActionCount
    )

    return UserEnvelope<GraphUserSetup>(me: graphUser)
  }
}
