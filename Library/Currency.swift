import UIKit
import KsApi

public enum Currency: String, Encodable, CaseIterable {
  case EUR
  case AUD
  case CAD
  case CHF
  case DKK
  case GBP
  case HKD
  case JPY
  case MXN
  case NOK
  case NZD
  case SEK
  case SGD
  case USD

  public var descriptionText: String {
    switch self {
    case .EUR:
      return Strings.Currency_EUR()
    case .AUD:
      return Strings.Currency_AUD()
    case .CAD:
      return Strings.Currency_CAD()
    case .CHF:
      return Strings.Currency_CHF()
    case .DKK:
      return Strings.Currency_DKK()
    case .GBP:
      return Strings.Currency_GBP()
    case .HKD:
      return Strings.Currency_HKD()
    case .JPY:
      return Strings.Currency_JPY()
    case .MXN:
      return Strings.Currency_MXN()
    case .NOK:
      return Strings.Currency_NOK()
    case .NZD:
      return Strings.Currency_NZD()
    case .SEK:
      return Strings.Currency_SEK()
    case .SGD:
      return Strings.Currency_SGD()
    case .USD:
      return Strings.Currency_USD()
    }
  }
}
