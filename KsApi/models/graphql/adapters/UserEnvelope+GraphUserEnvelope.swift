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
   Returns a `UserEnvelope<GraphUser>` from a `FetchUserEmailQuery.Data` object.
   */
  static func userEnvelope(from data: GraphAPI.FetchUserEmailQuery.Data) -> UserEnvelope<GraphUserEmail>? {
    guard let userFragment = data.me?.fragments.userEmailFragment else { return nil }

    let graphUser = GraphUserEmail(
      email: userFragment.email
    )

    return UserEnvelope<GraphUserEmail>(me: graphUser)
  }

  /**
   Returns a `UserEnvelope<GraphUserMemberStatus>` from a `FetchUserMemberStatusQuery.Data` object.
   */
  static func userEnvelope(from data: GraphAPI.FetchUserMemberStatusQuery
    .Data) -> UserEnvelope<GraphUserMemberStatus>? {
    guard let userMemberStatusFragment = data.me?.fragments.userMemberStatusFragment else { return nil }

    let graphUserMemberStatus = GraphUserMemberStatus(
      creatorProjectsTotalCount: userMemberStatusFragment.createdProjects?.totalCount ?? 0,
      memberProjectsTotalCount: userMemberStatusFragment.membershipProjects?.totalCount ?? 0
    )

    return UserEnvelope<GraphUserMemberStatus>(me: graphUserMemberStatus)
  }
}
