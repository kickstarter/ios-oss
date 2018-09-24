import KsApi
import UIKit

public enum SettingsAccountSectionType: Int {

  case emailPassword
  case privacy
  case payment

  public static var sectionHeaderHeight: CGFloat {
    return Styles.grid(5)
  }

  public static var allCases: [SettingsAccountSectionType] = [.emailPassword,
                                                              .privacy,
                                                              .payment]

  public var cellRowsForSection: [SettingsAccountCellType] {
    switch self {
    case .emailPassword:
      return [.changeEmail, .changePassword]
    case .privacy:
      return [.privacy]
    case .payment:
      return [.paymentMethods, .currency]
    }
  }
}

public enum SettingsAccountCellType: SettingsCellTypeProtocol {

  case changeEmail
  case changePassword
  case privacy
  case paymentMethods
  case currency

  public static var allCases: [SettingsAccountCellType] = [.changeEmail,
                                                           .changePassword,
                                                           .privacy,
                                                           .paymentMethods,
                                                           .currency]

  public var showArrowImageView: Bool {
    switch self {
    case .currency:
      return false
    default:
      return true
    }
  }

  public var textColor: UIColor {
    return .ksr_text_dark_grey_500
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
    case .currency: return "$ Dollar (USD)"
    default: return nil
    }
  }
}
