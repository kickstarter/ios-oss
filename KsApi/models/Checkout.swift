import Foundation

// This model is used in multiple queries, if modified update UpdateBacking and CreateBacking mutations.
public struct Checkout: Decodable {
  public var id: String
  public var state: State
  public var backing: Backing

  public enum State: String, Decodable, CaseIterable {
    case authorizing = "AUTHORIZING"
    case verifying = "VERIFYING"
    case successful = "SUCCESSFUL"
    case failed = "FAILED"
  }

  public struct Backing: Decodable {
    public let clientSecret: String?
    public let requiresAction: Bool
  }
}
