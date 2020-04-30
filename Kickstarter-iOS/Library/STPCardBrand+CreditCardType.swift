import KsApi
import Stripe

extension STPCardBrand {
  public var creditCardType: CreditCardType {
    switch self {
    case .amex: return .amex
    case .dinersClub: return .diners
    case .discover: return .discover
    case .JCB: return .jcb
    case .masterCard: return .mastercard
    case .unionPay: return .unionPay
    case .unknown: return .generic
    case .visa: return .visa
    @unknown default:
      return .generic
    }
  }
}
