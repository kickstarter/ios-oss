import Foundation

public struct ManagePledgeViewBackingEnvelope: Swift.Decodable {
  public var project: Project
  public var backing: Backing?

  public struct Project: Swift.Decodable {
    public var id: String
    public var name: String
    public var state: ProjectState
  }

  public struct Backing: Swift.Decodable {
    public var amount: Money
    public var backer: Backer?
    public var bankAccount: BankAccount?
    public var creditCard: CreditCard?
    public var errorReason: String?
    public var id: String
    public var pledgedOn: TimeInterval?
    public var reward: Reward?
    public var shippingAmount: Money?
    public var status: BackingState

    public struct Backer: Swift.Decodable {
      public var id: String
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
      public var type: CreditCardType
    }

    public struct Reward: Swift.Decodable {
      public var amount: Money
      public var backersCount: Int?
      public var description: String
      public var estimatedDeliveryOn: String?
      public var items: [Item]?
      public var name: String?

      public struct Item: Swift.Decodable {
        public var id: String
        public var name: String?
      }
    }
  }
}

public extension ManagePledgeViewBackingEnvelope {
  private enum CodingKeys: CodingKey {
    case backing
    case project
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    self.project = try values.decode(Project.self, forKey: .project)
    self.backing = try values.nestedContainer(keyedBy: CodingKeys.self, forKey: .project)
      .decode(Backing?.self, forKey: .backing)
  }
}

public extension ManagePledgeViewBackingEnvelope.Backing.Reward {
  private enum CodingKeys: CodingKey {
    case amount
    case backersCount
    case description
    case estimatedDeliveryOn
    case items
    case name
    case nodes
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    self.amount = try values.decode(Money.self, forKey: .amount)
    self.backersCount = try values.decode(Int?.self, forKey: .backersCount)
    self.description = try values.decode(String.self, forKey: .description)
    self.estimatedDeliveryOn = try values.decode(String?.self, forKey: .estimatedDeliveryOn)
    self.items = try? values.nestedContainer(keyedBy: CodingKeys.self, forKey: .items)
      .decode([Item].self, forKey: .nodes)
    self.name = try values.decode(String?.self, forKey: .name)
  }
}
