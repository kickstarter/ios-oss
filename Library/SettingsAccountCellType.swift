import KsApi
import UIKit

public enum SettingsAccountSectionType: Int, CaseIterable, Equatable {
  case emailPassword
  case privacy
  case payment

  public static var sectionHeaderHeight: CGFloat {
    return Styles.grid(5)
  }

  public var cellRowsForSection: [SettingsAccountCellType] {
    switch self {
    case .emailPassword:
      return [.changePassword]
    case .privacy:
      return [.privacy]
    case .payment:
      #if DEBUG
        return [.paymentMethods]
      #else
        return []
      #endif
    }
  }
}

public enum SettingsAccountCellType: SettingsCellTypeProtocol, CaseIterable, Equatable {
  case changeEmail
  case changePassword
  case privacy
  case paymentMethods
  case currency(Currency?)

  public static var allCases: [SettingsAccountCellType] {
    return [.changeEmail, changePassword, privacy, paymentMethods]
      + Currency.allCases.map(SettingsAccountCellType.currency)
  }

  public var showArrowImageView: Bool {
    return true
  }

  public var textColor: UIColor {
    return .ksr_soft_black
  }

  public var detailTextColor: UIColor {
    switch self {
    default:
      return .ksr_text_dark_grey_400
    }
  }

  public var hideDescriptionLabel: Bool {
    switch self {
    case .currency:
      return false
    default:
      return true
    }
  }

  public var title: String {
    switch self {
    case .changeEmail:
      return Strings.Change_email()
    case .changePassword:
      return Strings.Change_password()
    case .privacy:
      return Strings.Privacy()
    case .paymentMethods:
      return Strings.Payment_methods()
    case .currency:
      return Strings.Currency()
    }
  }

  public var description: String? {
    switch self {
    case let .currency(currency): return currency?.descriptionText
    default: return nil
    }
  }
}
