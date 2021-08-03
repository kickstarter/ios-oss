import Foundation

public struct Backing {
  public let addOns: [Reward]?
  public let amount: Double
  public let backer: User?
  public let backerId: Int
  public let backerCompleted: Bool?
  public let bonusAmount: Double
  public let cancelable: Bool
  public let id: Int
  public let locationId: Int?
  public let locationName: String?
  public let paymentSource: PaymentSource?
  public let pledgedAt: TimeInterval
  public let projectCountry: String
  public let projectId: Int
  public let reward: Reward?
  public let rewardId: Int?
  public let sequence: Int
  public let shippingAmount: Double?
  public let status: Status

  public struct PaymentSource {
    public var expirationDate: String?
    public var id: String?
    public var lastFour: String?
    public var paymentType: PaymentType
    public var state: String
    public var type: CreditCardType?
  }

  public enum Status: String, CaseIterable, Decodable {
    case canceled
    case collected
    case dropped
    case errored
    case pledged
    case preauth
  }
}

extension Backing: Equatable {}

public func == (lhs: Backing, rhs: Backing) -> Bool {
  return lhs.id == rhs.id
}

extension Backing: Decodable {
  private enum CodingKeys: String, CodingKey {
    case addOns = "add_ons"
    case amount
    case backer
    case backerId = "backer_id"
    case backerCompleted = "backer_completed_at"
    case bonusAmount = "bonus_amount"
    case cancelable
    case id
    case locationId = "location_id"
    case locationName = "location_name"
    case paymentSource = "payment_source"
    case pledgedAt = "pledged_at"
    case projectCountry = "project_country"
    case projectId = "project_id"
    case reward
    case rewardId = "reward_id"
    case sequence
    case shippingAmount = "shipping_amount"
    case status
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.addOns = try values.decodeIfPresent([Reward].self, forKey: .addOns)
    self.amount = try values.decode(Double.self, forKey: .amount)
    self.backer = try values.decodeIfPresent(User.self, forKey: .backer)
    self.backerId = try values.decode(Int.self, forKey: .backerId)
    self.backerCompleted = try values.decodeIfPresent(Int.self, forKey: .backerCompleted) != nil
    self.bonusAmount = try values.decodeIfPresent(Double.self, forKey: .bonusAmount) ?? 0.0
    self.cancelable = try values.decode(Bool.self, forKey: .cancelable)
    self.id = try values.decode(Int.self, forKey: .id)
    self.locationId = try values.decodeIfPresent(Int.self, forKey: .locationId)
    self.locationName = try values.decodeIfPresent(String.self, forKey: .locationName)
    self.paymentSource = try? values.decodeIfPresent(PaymentSource.self, forKey: .paymentSource)
    self.pledgedAt = try values.decode(TimeInterval.self, forKey: .pledgedAt)
    self.projectCountry = try values.decode(String.self, forKey: .projectCountry)
    self.projectId = try values.decode(Int.self, forKey: .projectId)
    self.reward = try values.decodeIfPresent(Reward.self, forKey: .reward)
    self.rewardId = try values.decodeIfPresent(Int.self, forKey: .rewardId)
    self.sequence = try values.decode(Int.self, forKey: .sequence)
    self.shippingAmount = try values.decodeIfPresent(Double.self, forKey: .shippingAmount)
    self.status = try values.decode(Status.self, forKey: .status)
  }
}

extension Backing: EncodableType {
  public func encode() -> [String: Any] {
    var result: [String: Any] = [:]
    result["backer_completed_at"] = self.backerCompleted
    return result
  }
}

extension Backing.PaymentSource: Decodable {
  private enum CodingKeys: String, CodingKey {
    case expirationDate = "expiration_date"
    case id
    case lastFour = "last_four"
    case paymentType = "payment_type"
    case state
    case type
  }
}

extension Backing.PaymentSource: Equatable {}
public func == (lhs: Backing.PaymentSource, rhs: Backing.PaymentSource) -> Bool {
  return lhs.id == rhs.id
}

extension Backing: GraphIDBridging {
  public static var modelName: String {
    return "Backing"
  }
}
