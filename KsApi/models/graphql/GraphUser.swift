import Foundation
import Prelude

// TODO: Remove public access
public struct GraphUser: Decodable, Equatable {
  public var chosenCurrency: String?
  public var email: String?
  public var hasPassword: Bool?
  public var id: String
  public var imageUrl: String
  public var isAppleConnected: Bool?
  public var isEmailVerified: Bool?
  public var isDeliverable: Bool?
  public var name: String
  public var uid: String
}

extension GraphUser {
  /// All properties required to instantiate a `User` via a `GraphUser`
  static var baseQueryProperties: NonEmptySet<Query.User> {
    return Query.User.id +| [
      .imageUrl(alias: "imageUrl", blur: false, width: Constants.imageWidth),
      .id,
      .uid,
      .name
    ]
  }
}
