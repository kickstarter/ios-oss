import UIKit


public enum Currency: Int, CaseIterable {
  case euro
  case australianDollar
  case canadianDollar
  case swissFranc
  case danishKrone
  case poundSterling
  case hongKongDollar
  case yen
  case mexicanPeso
  case norwegianKrone
  case newZealandDollar
  case swedishKrona
  case singaporeDollar
  case usDollar

  public static var rowHeight: CGFloat {
    return Styles.grid(7)
  }

  public var descriptionText: String {
    switch self {
    case .euro:
      return Strings.Currency_EUR()
    case .australianDollar:
      return Strings.Currency_AUD()
    case .canadianDollar:
      return Strings.Currency_CAD()
    case .swissFranc:
      return Strings.Currency_CHF()
    case .danishKrone:
      return Strings.Currency_DKK()
    case .poundSterling:
      return Strings.Currency_GBP()
    case .hongKongDollar:
      return Strings.Currency_HKD()
    case .yen:
      return Strings.Currency_JPY()
    case .mexicanPeso:
      return Strings.Currency_MXN()
    case .norwegianKrone:
      return Strings.Currency_NOK()
    case .newZealandDollar:
      return Strings.Currency_NZD()
    case .swedishKrona:
      return Strings.Currency_SEK()
    case .singaporeDollar:
      return Strings.Currency_SGD()
    case .usDollar:
      return Strings.Currency_USD()
    }
  }
}
