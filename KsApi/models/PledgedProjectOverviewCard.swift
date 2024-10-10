import Foundation

public struct PledgedProjectOverviewCard: Identifiable, Equatable {
  public let isUnread: Bool
  public let alerts: [Alert]
  public let imageURL: URL
  public let title: String
  public let pledge: GraphAPI.MoneyFragment
  public let creatorName: String
  public let address: String?
  public let actions: (Action, Action?)
  public let tierType: TierType
  public let projectAnalytics: GraphAPI.ProjectAnalyticsFragment

  // MARK: - Identifiable

  public let id = UUID()

  // MARK: - Equatable

  // For some reason this isn't generated because of the `actions` tuple
  // If that ever is fixed, this can be removed in favor of a synthesized Equatable implementation
  public static func == (lhs: PledgedProjectOverviewCard, rhs: PledgedProjectOverviewCard) -> Bool {
    lhs.isUnread == rhs.isUnread &&
      lhs.alerts == rhs.alerts &&
      lhs.imageURL == rhs.imageURL &&
      lhs.title == rhs.title &&
      lhs.pledge == rhs.pledge &&
      lhs.creatorName == rhs.creatorName &&
      lhs.address == rhs.address &&
      lhs.actions == rhs.actions
  }

  public enum TierType: Equatable {
    case fixPayment
    case authenticateCard
    case openSurvey
    case confirmAddress
  }

  public enum Action: Identifiable, Equatable {
    case confirmAddress
    case editAddress
    case completeSurvey
    case fixPayment
    case authenticateCard

    // TODO: Localize
    public var label: String {
      switch self {
      case .confirmAddress:
        "Confirm"
      case .editAddress:
        "Edit"
      case .completeSurvey:
        "Complete survey"
      case .fixPayment:
        "Fix payment"
      case .authenticateCard:
        "Authenticate card"
      }
    }

    public var style: Style {
      switch self {
      case .confirmAddress:
        .green
      case .editAddress:
        .black
      case .completeSurvey:
        .green
      case .fixPayment:
        .red
      case .authenticateCard:
        .red
      }
    }

    public enum Style: Identifiable, Equatable {
      case green
      case red
      case black

      public var id: String {
        switch self {
        case .green: "green"
        case .red: "red"
        case .black: "black"
        }
      }
    }

    public var id: String {
      "\(self.label) \(self.style.id)"
    }
  }

  public struct Alert: Identifiable, Equatable {
    public let type: AlertType
    public let icon: AlertIcon
    public let message: String

    public init(type: AlertType, icon: AlertIcon, message: String) {
      self.type = type
      self.icon = icon
      self.message = message
    }

    public var id: String {
      "\(self.type)-\(self.icon)-\(self.message)"
    }

    public enum AlertType: Identifiable, Equatable {
      case time
      case alert

      public var id: String {
        switch self {
        case .time:
          "time"
        case .alert:
          "alert"
        }
      }
    }

    public enum AlertIcon: Identifiable, Equatable {
      case warning
      case alert

      public var id: String {
        switch self {
        case .warning:
          "warning"
        case .alert:
          "alert"
        }
      }
    }
  }
}

extension PledgedProjectOverviewCard.Alert {
  init?(flag: GraphAPI.PpoCardFragment.Flag) {
    let alertType: PledgedProjectOverviewCard.Alert.AlertType? = switch flag.type {
    case "alert":
      .alert
    case "time":
      .time
    default:
      nil
    }

    let alertIcon: PledgedProjectOverviewCard.Alert.AlertIcon? = switch flag.icon {
    case "alert":
      .alert
    case "warning":
      .warning
    default:
      nil
    }
    let message = flag.message

    guard let alertType, let alertIcon, let message else {
      return nil
    }

    self = .init(type: alertType, icon: alertIcon, message: message)
  }
}

extension GraphAPI.MoneyFragment: Equatable {
  public static func == (lhs: KsApi.GraphAPI.MoneyFragment, rhs: KsApi.GraphAPI.MoneyFragment) -> Bool {
    return lhs.amount == rhs.amount &&
      lhs.currency == rhs.currency &&
      lhs.symbol == rhs.symbol
  }
}
