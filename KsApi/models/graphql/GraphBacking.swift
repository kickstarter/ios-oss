import Foundation
import Prelude

struct GraphBacking: Decodable {
  public var addOns: AddOns?
  public var amount: Money
  public var backer: GraphUser?
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

  public struct AddOns: Decodable {
    public var nodes: [GraphReward]
  }

  public struct BankAccount: Decodable {
    public var bankName: String
    public var id: String
    public var lastFour: String
  }

  public struct CreditCard: Decodable {
    public var expirationDate: String
    public var id: String
    public var lastFour: String
    public var paymentType: PaymentType
    public var state: String
    public var type: CreditCardType
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
      .backer(GraphUser.baseQueryProperties),
      .project(GraphProject.baseQueryProperties),
      .status,
      .cancelable,
      .location(GraphLocation.baseQueryProperties),
      .creditCard(
        .id +| [
          .expirationDate,
          .lastFour,
          .paymentType,
          .state,
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
