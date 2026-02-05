import Foundation
import Prelude

// TODO: Remove public access
public struct GraphUser: Decodable {
  public var chosenCurrency: String? = nil
  public var email: String? = nil
  public var hasPassword: Bool? = nil
  public var id: String
  public var isBlocked: Bool? = nil
  public var isCreator: Bool? = nil
  public var imageUrl: String
  public var isAppleConnected: Bool? = nil
  public var isEmailVerified: Bool? = nil
  public var isDeliverable: Bool? = nil
  public var name: String
  public var storedCards: UserCreditCards
  public var uid: String
}

extension GraphUser: Equatable {
  public static func == (lhs: GraphUser, rhs: GraphUser) -> Bool {
    lhs.chosenCurrency == rhs.chosenCurrency &&
      lhs.email == rhs.email &&
      lhs.hasPassword == rhs.hasPassword &&
      lhs.id == rhs.id &&
      lhs.isBlocked == rhs.isBlocked &&
      lhs.isCreator == rhs.isCreator &&
      lhs.imageUrl == rhs.imageUrl &&
      lhs.isAppleConnected == rhs.isAppleConnected &&
      lhs.isEmailVerified == rhs.isEmailVerified &&
      lhs.isDeliverable == rhs.isDeliverable &&
      lhs.name == rhs.name &&
      lhs.storedCards == rhs.storedCards &&
      lhs.uid == rhs.uid
  }
}
