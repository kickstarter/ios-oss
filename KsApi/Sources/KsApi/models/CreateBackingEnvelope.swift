import Foundation

public struct CreateBackingEnvelope: Decodable {
  public var createBacking: CreateBacking

  public struct CreateBacking: Decodable {
    public var checkout: Checkout
  }
}
