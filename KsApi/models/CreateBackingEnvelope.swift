import Foundation

public struct CreateBackingEnvelope: Swift.Decodable {
  public var createBacking: CreateBacking

  public struct CreateBacking: Swift.Decodable {
    public var checkout: Checkout
  }
}
