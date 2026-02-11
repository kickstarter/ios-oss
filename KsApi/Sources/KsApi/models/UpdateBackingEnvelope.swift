import Foundation

public struct UpdateBackingEnvelope: Decodable {
  public var updateBacking: UpdateBacking

  public struct UpdateBacking: Decodable {
    public var checkout: Checkout
  }
}
