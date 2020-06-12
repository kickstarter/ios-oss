import Argo
import Curry
import Runes

public struct Backing {
  public let amount: Double
  public let backer: User?
  public let backerId: Int
  public let backerCompleted: Bool?
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

  public enum Status: String, CaseIterable {
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
      <*> json <| "cancelable"
      <*> json <| "id"
    let tmp2 = tmp1
      <*> json <|? "location_id"
      <*> json <|? "location_name"
      <*> (json <|? "payment_source" >>- tryDecodePaymentSource)
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

extension Backing.PaymentSource: Argo.Decodable {
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

extension Backing.Status: Argo.Decodable {}

extension Backing.PaymentSource: Equatable {}
public func == (lhs: Backing.PaymentSource, rhs: Backing.PaymentSource) -> Bool {
  return lhs.id == rhs.id
}

extension Backing: GraphIDBridging {
  public static var modelName: String {
    return "Backing"
  }
}
