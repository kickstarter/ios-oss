import Foundation

public struct RewardAddOnSelectionViewEnvelope: Swift.Decodable {
  public var project: Project

  public struct Project: Swift.Decodable {
    public var actions: Actions
    public var addOns: AddOns?
    public var pid: Int
    public var fxRate: Double

    public struct Actions: Swift.Decodable {
      public let displayConvertAmount: Bool
    }

    public struct AddOns: Swift.Decodable {
      public var nodes: [Reward]
    }

    public struct Reward: Swift.Decodable {
      public var amount: Money
      public var backersCount: Int
      public var convertedAmount: Money
      public var description: String
      public var displayName: String
      public var endsAt: TimeInterval?
      public var estimatedDeliveryOn: String?
      public var id: String
      public var isMaxPledge: Bool
      public var items: Items?
      public var limit: Int?
      public var limitPerBacker: Int?
      public var name: String
      public var remainingQuantity: Int?
      public var shippingPreference: ShippingPreference?
      public var startsAt: TimeInterval?

      public struct Items: Swift.Decodable {
        public let nodes: [Item]
      }

      public struct Item: Swift.Decodable {
        public var id: String
        public var name: String
      }

      public enum ShippingPreference: String, Swift.Decodable {
        case noShipping = "none"
        case restricted
        case unrestricted
      }
    }
  }
}
