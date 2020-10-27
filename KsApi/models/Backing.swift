import Curry
import Runes

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
  public let shippingAmount: Int?
  public let status: Status

  public struct PaymentSource {
    public var expirationDate: String?
    public var id: String?
    public var lastFour: String?
    public var paymentType: PaymentType
    public var state: String
    public var type: CreditCardType?
  }

  public enum Status: String, CaseIterable, Swift.Decodable {
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

extension Backing: Swift.Decodable {
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
    self.addOns = try values.decodeIfPresent([Reward].self, forKey: .reward)
    self.amount = try values.decode(Double.self, forKey: .amount)
    self.backer = try values.decodeIfPresent(User.self, forKey: .backer)
    self.backerId = try values.decode(Int.self, forKey: .backerId)
    self.backerCompleted = try values.decodeIfPresent(Bool.self, forKey: .backerCompleted)
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
    self.shippingAmount = try values.decodeIfPresent(Int.self, forKey: .shippingAmount)
    self.status = try values.decode(Status.self, forKey: .status)
  }
}

/*
 extension Backing: Decodable {
 public static func decode(_ json: JSON) -> Decoded<Backing> {
   let tmp1 = curry(Backing.init)
     <^> json <||? "add_ons"
     <*> json <| "amount"
     <*> ((json <|? "backer" >>- tryDecodable) as Decoded<User?>)
     <*> json <| "backer_id"
     <*> json <|? "backer_completed_at"
     <*> (json <| "bonus_amount" <|> .success(0.0))
     <*> json <| "cancelable"
   let tmp2 = tmp1
     <*> json <| "id"
     <*> json <|? "location_id"
     <*> json <|? "location_name"
     <*> (json <|? "payment_source" >>- tryDecodePaymentSource)
     <*> json <| "pledged_at"
     <*> json <| "project_country"
   return tmp2
     <*> json <| "project_id"
     <*> json <|? "reward"
     <*> json <|? "reward_id"
     <*> json <| "sequence"
     <*> json <|? "shipping_amount"
     <*> json <| "status"
 }
 }
 */
#warning("Function tryDecodePaymentSource(_:) should be deleted once the data is being returned normally.")
/*
 Since staging is not returning all the values for Payment Source, the Backing deserialization is failing
 on that environment. This is a workaround to allow us to test on Staging and should be deleted once the
 data is being returned normally.
 */
private func tryDecodePaymentSource(_ json: JSON?) -> Decoded<Backing.PaymentSource?> {
  guard let json = json else {
    return .success(nil)
  }

  let value = Backing.PaymentSource.decode(json)

  switch value {
  case let .success(value):
    return .success(value)
  case .failure:
    return .success(nil)
  }
}

extension Backing: EncodableType {
  public func encode() -> [String: Any] {
    var result: [String: Any] = [:]
    result["backer_completed_at"] = self.backerCompleted
    return result
  }
}

extension Backing.PaymentSource: Swift.Decodable {
  private enum CodingKeys: String, CodingKey {
    case expirationDate = "expiration_date"
    case id
    case lastFour = "last_four"
    case paymentType = "payment_type"
    case state
    case type
  }
}

extension Backing.PaymentSource: Decodable {
  public static func decode(_ json: JSON) -> Decoded<Backing.PaymentSource?> {
    return curry(Backing.PaymentSource.init)
      <^> json <|? "expiration_date"
      <*> json <|? "id"
      <*> json <|? "last_four"
      <*> json <| "payment_type"
      <*> json <| "state"
      <*> json <|? "type"
  }
}

extension Backing.Status: Decodable {}

extension Backing.PaymentSource: Equatable {}
public func == (lhs: Backing.PaymentSource, rhs: Backing.PaymentSource) -> Bool {
  return lhs.id == rhs.id
}

extension Backing: GraphIDBridging {
  public static var modelName: String {
    return "Backing"
  }
}
