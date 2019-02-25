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
      return [.paymentMethods]
    }
  }
}

public enum SettingsAccountCellType: SettingsCellTypeProtocol, Equatable {
  case changeEmail
  case changePassword
  case privacy
  case paymentMethods
  case currency(Currency?)

  public var accessibilityTraits: UIAccessibilityTraits {
    return .button
  }

  public var showArrowImageView: Bool {
    return true
  }

  public var textColor: UIColor {
    return .ksr_soft_black
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
