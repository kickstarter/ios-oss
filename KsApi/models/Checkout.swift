import Foundation

public struct Checkout: Decodable {
  public var backing: Backing
  public var id: String
  public var state: State

  public enum State: String, Decodable, CaseIterable {
    case authorizing = "AUTHORIZING"
    case failed = "FAILED"
    case successful = "SUCCESSFUL"
    case verifying = "VERIFYING"
  }

  public struct Backing: Decodable {
    public let clientSecret: String?
    public let requiresAction: Bool
  }
}
