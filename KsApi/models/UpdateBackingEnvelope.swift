import Foundation

public struct UpdateBackingEnvelope: Swift.Decodable {
  public var updateBacking: UpdateBacking

  public struct UpdateBacking: Swift.Decodable {
    public var checkout: Checkout
  }
}
