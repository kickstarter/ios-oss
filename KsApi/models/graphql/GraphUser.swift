import Foundation
import Prelude

// TODO: Remove public access
public struct GraphUser: Decodable {
  public var chosenCurrency: String?
  public var email: String?
  public var hasPassword: Bool?
  public var id: String
  public var isCreator: Bool?
  public var imageUrl: String
  public var isAppleConnected: Bool?
  public var isEmailVerified: Bool?
  public var isDeliverable: Bool?
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
