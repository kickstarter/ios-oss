import KsApi
import UIKit

public enum SettingsAccountSectionType: Int {

  case emailPassword
  case payment
  case privacy

  public static var sectionHeaderHeight: CGFloat {
    return 30.0
  }

  public static var allCases: [SettingsAccountSectionType] = [.emailPassword,
                                                              .payment,
                                                              .privacy]

  public var cellRowsForSection: [SettingsAccountCellType] {
    switch self {
    case .emailPassword:
      return [.changeEmail, .changePassword]
    case .payment:
      return [.paymentMethods, .currency]
    case .privacy:
      return [.privacy]
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
      return Strings.Email() // TODO: Add string
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
}
