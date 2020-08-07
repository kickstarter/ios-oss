import Foundation
import Prelude

struct GraphBacking: Swift.Decodable {
  public var addOns: AddOns?
  public var amount: Money
  public var backer: Backer?
  public var backerCompleted: Bool
  public var bankAccount: BankAccount?
  public var bonusAmount: Money
  public var cancelable: Bool
  public var creditCard: CreditCard?
  public var errorReason: String?
  public var id: String
  public var location: GraphLocation?
  public var pledgedOn: TimeInterval?
  public var project: GraphProject?
  public var reward: GraphReward?
  public var sequence: Int?
  public var shippingAmount: Money?
  public var status: BackingState

  public struct AddOns: Swift.Decodable {
    public var nodes: [GraphReward]
  }

  public struct Backer: Swift.Decodable {
    public var uid: Int
    public var name: String
  }

  public struct BankAccount: Swift.Decodable {
    public var bankName: String
    public var id: String
    public var lastFour: String
  }

  public struct CreditCard: Swift.Decodable {
    public var expirationDate: String
    public var id: String
    public var lastFour: String
    public var paymentType: PaymentType
    public var state: String
    public var type: CreditCardType
  }
}

extension GraphBacking.Backer {
  private enum CodingKeys: CodingKey {
    case uid
    case name
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    guard let uid = Int(try values.decode(String.self, forKey: .uid)) else {
      throw DecodingError.dataCorruptedError(
        forKey: .uid, in: values, debugDescription: "Not a valid integer"
      )
    }

    self.uid = uid
    self.name = try values.decode(String.self, forKey: .name)
  }
}

extension GraphBacking {
  /// All properties required to instantiate a `Backing` via a `GraphBacking`
  static var baseQueryProperties: NonEmptySet<Query.Backing> {
    return Query.Backing.id +| [
      .addOns([], NonEmptySet(.nodes(GraphReward.baseQueryProperties))),
      .amount(Money.baseQueryProperties),
      .bonusAmount(Money.baseQueryProperties),
      .backerCompleted,
      .backer(.uid +| [.name]),
      .project(GraphProject.baseQueryProperties),
      .status,
      .cancelable,
      .location(GraphLocation.baseQueryProperties),
      .creditCard(
        .id +| [
          .expirationDate,
          .lastFour,
          .paymentType,
          .type
        ]
      ),
      .pledgedOn,
      .reward(GraphReward.baseQueryProperties),
      .sequence,
      .shippingAmount(Money.baseQueryProperties)
    ]
  }
}
