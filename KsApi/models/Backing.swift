import Argo
import Curry
import Runes

public struct Backing {
  public let amount: Double
  public let backer: User?
  public let backerId: Int
  public let backerCompleted: Bool?
  public let id: Int
  public let locationId: Int?
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
    public let expirationDate: String
    public let id: Int
    public let lastFour: String
    public let paymentType: String
    public let state: String
    public let type: String
  }

  public enum Status: String {
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

extension Backing: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<Backing> {
    let tmp1 = curry(Backing.init)
      <^> json <| "amount"
      <*> json <|? "backer"
      <*> json <| "backer_id"
      <*> json <|? "backer_completed_at"
      <*> json <| "id"
    let tmp2 = tmp1
      <*> json <|? "payment_source"
      <*> json <|? "location_id"
      <*> json <| "pledged_at"
      <*> json <| "project_country"
      <*> json <| "project_id"
    return tmp2
      <*> json <|? "reward"
      <*> json <|? "reward_id"
      <*> json <| "sequence"
      <*> json <|? "shipping_amount"
      <*> json <| "status"
  }
}

extension Backing.PaymentSource: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<Backing.PaymentSource> {
    return curry(Backing.PaymentSource.init)
      <^> json <| "expiration_date"
      <*> json <| "id"
      <*> json <| "last_four"
      <*> json <| "payment_type"
      <*> json <| "state"
      <*> json <| "type"
  }
}


extension Backing: EncodableType {
  public func encode() -> [String: Any] {
    var result: [String: Any] = [:]
    result["backer_completed_at"] = self.backerCompleted
    return result
  }
}

extension Backing.Status: Argo.Decodable {}
