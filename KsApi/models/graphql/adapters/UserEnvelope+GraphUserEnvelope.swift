import Foundation

extension UserEnvelope {
  /**
   Returns a `UserEnvelope<GraphUser>` from a `FetchUserQuery.Data` object.
   */
  static func userEnvelope(from data: GraphAPI.FetchUserQuery.Data) -> UserEnvelope<GraphUser>? {
    guard let userFragment = data.me?.fragments.userFragment,
      let storedCards = GraphUserCreditCard.graphUserCreditCard(from: userFragment) else { return nil }

    let graphUser = GraphUser(
      chosenCurrency: userFragment.chosenCurrency,
      email: userFragment.email,
      hasPassword: userFragment.hasPassword,
      id: userFragment.id,
      isCreator: userFragment.isCreator,
      imageUrl: userFragment.imageUrl,
      isAppleConnected: userFragment.isAppleConnected,
      isEmailVerified: userFragment.isEmailVerified,
      isDeliverable: userFragment.isDeliverable,
      name: userFragment.name,
      storedCards: storedCards,
      uid: userFragment.uid
    )

    return UserEnvelope<GraphUser>(me: graphUser)
  }
}
