import Apollo
import Foundation
import ReactiveSwift

extension Project {
  static func projectFriendsProducer(
    from data: GraphAPI.FetchProjectFriendsByIdQuery.Data
  ) -> SignalProducer<[User], ErrorEnvelope> {
    let projectFriends = Project.projectFriends(from: data)

    return SignalProducer(value: projectFriends)
  }

  static func projectFriendsProducer(
    from data: GraphAPI.FetchProjectFriendsBySlugQuery.Data
  ) -> SignalProducer<[User], ErrorEnvelope> {
    let projectFriends = Project.projectFriends(from: data)

    return SignalProducer(value: projectFriends)
  }

  static func projectFriends(from data: GraphAPI.FetchProjectFriendsByIdQuery.Data) -> [User] {
    let projectFriends = data.project?.friends?.nodes?
      .compactMap { $0?.fragments.userFragment }
      .compactMap { User.user(from: $0) } ?? []

    return projectFriends
  }

  static func projectFriends(from data: GraphAPI.FetchProjectFriendsBySlugQuery.Data) -> [User] {
    let projectFriends = data.project?.friends?.nodes?
      .compactMap { $0?.fragments.userFragment }
      .compactMap { User.user(from: $0) } ?? []

    return projectFriends
  }
}
