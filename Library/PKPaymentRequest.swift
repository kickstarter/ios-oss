import Argo
import Runes
import Curry
import Foundation
import KsApi
import PassKit

extension PKPaymentNetwork: Decodable {}

extension PKPaymentSummaryItem: Decodable {

  public static func decode(_ json: JSON) -> Decoded<PKPaymentSummaryItem> {
    return curry(PKPaymentSummaryItem.init(label:amount:type:))
      <^> json <| "label"
      <*> json <| "amount"
      <*> (json <| "type" <|> .success(.final))
  }
}

extension PKPaymentRequest: Decodable {

  fileprivate convenience init(countryCode: String, currencyCode: String,
                               merchantCapabilities: PKMerchantCapability,
                               merchantIdentifier: String,
                               paymentSummaryItems: [PKPaymentSummaryItem],
                               shippingType: PKShippingType,
                               supportedNetworks: [PKPaymentNetwork]) {

    self.init()
    self.countryCode = countryCode
    self.currencyCode = currencyCode
    self.merchantCapabilities = merchantCapabilities
    self.merchantIdentifier = merchantIdentifier
    self.paymentSummaryItems = paymentSummaryItems
    self.shippingType = shippingType
    self.supportedNetworks = supportedNetworks
  }

  public static func decode(_ json: JSON) -> Decoded<PKPaymentRequest> {
    let create = curry(PKPaymentRequest.init)
    let snakeCase = create
      <^> json <|  "country_code"
      <*> json <|  "currency_code"
      <*> (json <| "merchant_capabilities" <|> .success(.capability3DS))
      <*> json <|  "merchant_identifier"
      <*> json <|| "payment_summary_items"
      <*> (json <|  "shipping_type" <|> .success(.shipping))
      <*> json <|| "supported_networks"

    let camelCase = {
      create
        <^> json <|  "countryCode"
        <*> json <|  "currencyCode"
        <*> (json <| "merchantCapabilities" <|> .success(.capability3DS))
        <*> json <|  "merchantIdentifier"
        <*> json <|| "paymentSummaryItems"
        <*> (json <|  "shippingType" <|> .success(.shipping))
        <*> json <|| "supportedNetworks"
    }

    return snakeCase <|> camelCase()
  }
}

extension NSDecimalNumber: Decodable {
  public static func decode(_ json: JSON) -> Decoded<NSDecimalNumber> {
    switch json {
    case let .string(string):
      return .success(NSDecimalNumber(string: string))
    case let .number(number):
      return .success(NSDecimalNumber(decimal: number.decimalValue))
    default:
      return .failure(.typeMismatch(expected: "String or Number", actual: json.description))
    }
  }
}

extension PKPaymentRequest: EncodableType {
  public func encode() -> [String : Any] {
    var result: [String:Any] = [:]
    result["countryCode"] = self.countryCode
    result["currencyCode"] = self.currencyCode
    result["merchantCapabilities"] = self.merchantCapabilities.rawValue.bitComponents()
    result["merchantIdentifier"] = self.merchantIdentifier
    result["supportedNetworks"] = self.supportedNetworks
    result["shippingType"] = self.shippingType.rawValue
    result["paymentSummaryItems"] = self.paymentSummaryItems.map { $0.encode() }
    return result
  }
}

extension PKPaymentSummaryItem: EncodableType {
  public func encode() -> [String : Any] {
    var result: [String:Any] = [:]
    result["label"] = self.label
    result["amount"] = self.amount
    result["type"] = self.type.rawValue
    return result
  }
}

// swiftlint:disable cyclomatic_complexity
extension PKMerchantCapability: Decodable {
  public static func decode(_ json: JSON) -> Decoded<PKMerchantCapability> {
    switch json {
    case let .string(string):
      switch string {
      case "Capability3DS":     return .success(.capability3DS)
      case "CapabilityEMV":     return .success(.capabilityEMV)
      case "CapabilityCredit":  return .success(.capabilityCredit)
      case "CapabilityDebit":   return .success(.capabilityDebit)
      default:                  return .failure(.custom("Unrecognized merchant capability: \(string)"))
      }

    case let .number(number):
      switch number.uintValue {
      case PKMerchantCapability.capability3DS.rawValue:
        return .success(.capability3DS)
      case PKMerchantCapability.capabilityEMV.rawValue:
        return .success(.capabilityEMV)
      case PKMerchantCapability.capabilityCredit.rawValue:
        return .success(.capabilityCredit)
      case PKMerchantCapability.capabilityDebit.rawValue:
        return .success(.capabilityDebit)
      default:
        return .failure(.custom("Unrecognized merchant capability: \(number)"))
      }

    case let .array(array):
      return .success(
        array
          .flatMap { PKMerchantCapability.decode($0).value }
          .reduce([]) { $0.union($1) }
      )

    default:
      return .failure(
        .typeMismatch(expected: "String, Integer or Array of Strings/Integers", actual: json.description)
      )
    }
  }
}

extension PKShippingType: Decodable {
  public static func decode(_ json: JSON) -> Decoded<PKShippingType> {
    switch json {
    case let .string(string):
      switch string {
      case "Shipping":
        return .success(.shipping)
      case "Delivery":
        return .success(.delivery)
      case "StorePickup":
        return .success(.storePickup)
      case "ServicePickup":
        return .success(.servicePickup)
      default:
        return .failure(.custom("Unrecognized shipping: \(string)"))
      }

    case let .number(number):
      switch number.uintValue {
      case PKShippingType.shipping.rawValue:
        return .success(.shipping)
      case PKShippingType.delivery.rawValue:
        return .success(.delivery)
      case PKShippingType.storePickup.rawValue:
        return .success(.storePickup)
      case PKShippingType.servicePickup.rawValue:
        return .success(.servicePickup)
      default:
        return .failure(.custom("Unrecognized shipping: \(number)"))
      }

    default:
      return .failure(.typeMismatch(expected: "String or Integer", actual: json.description))
    }
  }
}

extension PKPaymentSummaryItemType: Decodable {
  public static func decode(_ json: JSON) -> Decoded<PKPaymentSummaryItemType> {
    switch json {
    case let .string(string):
      switch string {
      case "Final":
        return .success(.final)
      case "Pending":
        return .success(.pending)
      default:
        return .failure(.custom("Unrecognized payment summary item type: \(string)"))
      }

    case let .number(number):
      switch number.uintValue {
      case PKPaymentSummaryItemType.final.rawValue:
        return .success(.final)
      case PKPaymentSummaryItemType.pending.rawValue:
        return .success(.pending)
      default:
        return .failure(.custom("Unrecognized payment summary item type: \(number)"))
      }

    default:
      return .failure(.typeMismatch(expected: "String or Integer", actual: json.description))
    }
  }
}
// swiftlint:enable cyclomatic_complexity

extension UInt {
  /**
   - returns: An array of bitmask values for an integer.
   */
  fileprivate func bitComponents() -> [UInt] {
    let range: CountableRange<UInt> = 0 ..< UInt(8 * MemoryLayout<UInt>.size)
    return range
      .map { 1 << $0 }
      .filter { self & $0 != 0 }
  }
}
