import Foundation

public struct GraphUser: Swift.Decodable {
  public var chosenCurrency: String?
  public var email: String
  public var hasPassword: Bool?
  public var isAppleConnected: Bool?
  public var isEmailVerified: Bool?
  public var isDeliverable: Bool?
}

extension GraphUser: Equatable {}
