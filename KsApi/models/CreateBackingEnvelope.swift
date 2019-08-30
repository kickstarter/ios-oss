import Foundation

public struct CreateBackingEnvelope: Decodable {
  public struct CreateBacking {
    public var checkoutState: Checkout.CheckoutState
  }
}

public struct Checkout: Decodable {
  public var checkoutState: CheckoutState

  public enum CheckoutState: String, Decodable, CaseIterable {
    case authorizing = "AUTHORIZING"
    case verifying = "VERIFYING"
    case successful = "SUCCESSFUL"
    case failed = "FAILED"
  }
}

extension CreateBackingEnvelope.CreateBacking {
  enum CodingKeys: String, CodingKey {
    case createBacking
    case checkout
    case checkoutState
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.checkoutState = try values.nestedContainer(keyedBy: CodingKeys.self, forKey: .createBacking)
      .nestedContainer(keyedBy: CodingKeys.self, forKey: .checkout)
      .decode(Checkout.CheckoutState.self, forKey: .checkoutState)
  }
}
