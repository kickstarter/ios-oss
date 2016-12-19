import Argo
import Runes
import Curry
import Foundation
import KsApi
import PassKit

extension PKPaymentSummaryItem: Decodable {

  public static func decode(_ json: JSON) -> Decoded<PKPaymentSummaryItem> {
    return curry(PKPaymentSummaryItem.init(label:amount:type:))
      <^> json <| "label"
      <*> json <| "amount"
      <*> json <| "type" <|> .Success(.Final)
  }
}

extension PKPaymentRequest: Decodable {

  fileprivate convenience init(countryCode: String, currencyCode: String,
                          merchantCapabilities: PKMerchantCapability,
                          merchantIdentifier: String, paymentSummaryItems: [PKPaymentSummaryItem],
                          shippingType: PKShippingType, supportedNetworks: [String]) {

    self.init()
    self.countryCode = countryCode
    self.currencyCode = currencyCode
    self.merchantCapabilities = merchantCapabilities
    self.merchantIdentifier = merchantIdentifier
    self.paymentSummaryItems = paymentSummaryItems
    self.shippingType = shippingType
    self.supportedNetworks = supportedNetworks as! [PKPaymentNetwork]
  }

  public static func decode(_ json: JSON) -> Decoded<PKPaymentRequest> {
    let create = curry(PKPaymentRequest.init)
    let snakeCase = create
      <^> json <|  "country_code"
      <*> json <|  "currency_code"
      <*> (json <| "merchant_capabilities" <|> .Success(.Capability3DS))
      <*> json <|  "merchant_identifier"
      <*> json <|| "payment_summary_items"
      <*> json <|  "shipping_type" <|> .Success(.Shipping)
      <*> json <|| "supported_networks"

    let camelCase = {
      create
        <^> json <|  "countryCode"
        <*> json <|  "currencyCode"
        <*> (json <| "merchantCapabilities" <|> .Success(.Capability3DS))
        <*> json <|  "merchantIdentifier"
        <*> json <|| "paymentSummaryItems"
        <*> json <|  "shippingType" <|> .Success(.Shipping)
        <*> json <|| "supportedNetworks"
    }

    return snakeCase <|> camelCase()
  }
}

extension NSDecimalNumber: Decodable {
  public static func decode(_ json: JSON) -> Decoded<NSDecimalNumber> {
    switch json {
    case let .String(string):
      return .Success(NSDecimalNumber(string: string))
    case let .Number(number):
      return .Success(NSDecimalNumber(decimal: number.decimalValue))
    default:
      return .Failure(.TypeMismatch(expected: "String or Number", actual: json.description))
    }
  }
}

extension PKPaymentRequest: EncodableType {
  public func encode() -> [String : AnyObject] {
    var result: [String:AnyObject] = [:]
    result["countryCode"] = self.countryCode as AnyObject?
    result["currencyCode"] = self.currencyCode as AnyObject?
    result["merchantCapabilities"] = self.merchantCapabilities.rawValue.bitComponents() as AnyObject?
    result["merchantIdentifier"] = self.merchantIdentifier as AnyObject?
    result["supportedNetworks"] = self.supportedNetworks as AnyObject?
    result["shippingType"] = self.shippingType.rawValue as AnyObject?
    result["paymentSummaryItems"] = self.paymentSummaryItems.map { $0.encode() }
    return result
  }
}

extension PKPaymentSummaryItem: EncodableType {
  public func encode() -> [String : AnyObject] {
    var result: [String:AnyObject] = [:]
    result["label"] = self.label as AnyObject?
    result["amount"] = self.amount
    result["type"] = self.type.rawValue as AnyObject?
    return result
  }
}

// swiftlint:disable cyclomatic_complexity
extension PKMerchantCapability: Decodable {
  public static func decode(_ json: JSON) -> Decoded<PKMerchantCapability> {
    switch json {
    case let .String(string):
      switch string {
      case "Capability3DS":     return .Success(.Capability3DS)
      case "CapabilityEMV":     return .Success(.CapabilityEMV)
      case "CapabilityCredit":  return .Success(.CapabilityCredit)
      case "CapabilityDebit":   return .Success(.CapabilityDebit)
      default:                  return .Failure(.Custom("Unrecognized merchant capability: \(string)"))
      }

    case let .Number(number):
      switch number.unsignedIntegerValue {
      case PKMerchantCapability.Capability3DS.rawValue:
        return .Success(.Capability3DS)
      case PKMerchantCapability.CapabilityEMV.rawValue:
        return .Success(.CapabilityEMV)
      case PKMerchantCapability.CapabilityCredit.rawValue:
        return .Success(.CapabilityCredit)
      case PKMerchantCapability.CapabilityDebit.rawValue:
        return .Success(.CapabilityDebit)
      default:
        return .Failure(.Custom("Unrecognized merchant capability: \(number)"))
      }

    case let .Array(array):
      return .Success(
        array
          .flatMap { PKMerchantCapability.decode($0).value }
          .reduce([]) { $0.union($1) }
      )

    default:
      return .Failure(
        .TypeMismatch(expected: "String, Integer or Array of Strings/Integers", actual: json.description)
      )
    }
  }
}

extension PKShippingType: Decodable {
  public static func decode(_ json: JSON) -> Decoded<PKShippingType> {
    switch json {
    case let .String(string):
      switch string {
      case "Shipping":
        return .Success(.Shipping)
      case "Delivery":
        return .Success(.Delivery)
      case "StorePickup":
        return .Success(.StorePickup)
      case "ServicePickup":
        return .Success(.ServicePickup)
      default:
        return .Failure(.Custom("Unrecognized shipping: \(string)"))
      }

    case let .Number(number):
      switch number.unsignedIntegerValue {
      case PKShippingType.Shipping.rawValue:
        return .Success(.Shipping)
      case PKShippingType.Delivery.rawValue:
        return .Success(.Delivery)
      case PKShippingType.StorePickup.rawValue:
        return .Success(.StorePickup)
      case PKShippingType.ServicePickup.rawValue:
        return .Success(.ServicePickup)
      default:
        return .Failure(.Custom("Unrecognized shipping: \(number)"))
      }

    default:
      return .Failure(.TypeMismatch(expected: "String or Integer", actual: json.description))
    }
  }
}

extension PKPaymentSummaryItemType: Decodable {
  public static func decode(_ json: JSON) -> Decoded<PKPaymentSummaryItemType> {
    switch json {
    case let .String(string):
      switch string {
      case "Final":
        return .Success(.Final)
      case "Pending":
        return .Success(.Pending)
      default:
        return .Failure(.Custom("Unrecognized payment summary item type: \(string)"))
      }

    case let .Number(number):
      switch number.unsignedIntegerValue {
      case PKPaymentSummaryItemType.Final.rawValue:
        return .Success(.Final)
      case PKPaymentSummaryItemType.Pending.rawValue:
        return .Success(.Pending)
      default:
        return .Failure(.Custom("Unrecognized payment summary item type: \(number)"))
      }

    default:
      return .Failure(.TypeMismatch(expected: "String or Integer", actual: json.description))
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
