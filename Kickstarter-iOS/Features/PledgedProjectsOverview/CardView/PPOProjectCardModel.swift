import Foundation
import Kingfisher
import KsApi
import Library

public struct PPOProjectCardModel: Identifiable, Equatable, Hashable {
  public let isUnread: Bool
  public let alerts: [Alert]
  public let image: Kingfisher.Source
  public let projectName: String
  public let projectId: Int
  public let pledge: String
  public let creatorName: String
  public let address: String?
  public let actions: (Action, Action?)
  public let tierType: TierType
  public let backingDetailsUrl: String
  public let backingId: Int
  public let backingGraphId: String
  public let projectAnalytics: GraphAPI.ProjectAnalyticsFragment

  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.isUnread)
    hasher.combine(self.alerts)
    hasher.combine(self.image)
    hasher.combine(self.projectName)
    hasher.combine(self.projectId)
    hasher.combine(self.pledge)
    hasher.combine(self.creatorName)
    hasher.combine(self.address)
    hasher.combine(self.actions.0)
    hasher.combine(self.actions.1)
    hasher.combine(self.tierType)
  }

  // MARK: - Identifiable

  public let id = UUID()

  // MARK: - Equatable

  // For some reason this isn't generated because of the `actions` tuple
  // If that ever is fixed, this can be removed in favor of a synthesized Equatable implementation
  public static func == (lhs: PPOProjectCardModel, rhs: PPOProjectCardModel) -> Bool {
    lhs.isUnread == rhs.isUnread &&
      lhs.alerts == rhs.alerts &&
      lhs.image == rhs.image &&
      lhs.projectName == rhs.projectName &&
      lhs.projectId == rhs.projectId &&
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

  public enum Action: Identifiable, Equatable, Hashable {
    case confirmAddress(address: String, addressId: String)
    case editAddress
    case completeSurvey
    case fixPayment
    case authenticateCard(clientSecret: String)

    public var label: String {
      switch self {
      case .confirmAddress:
        Strings.Confirm()
      case .editAddress:
        Strings.Edit()
      case .completeSurvey:
        Strings.Take_survey()
      case .fixPayment:
        Strings.Fix_payment()
      case .authenticateCard:
        Strings.Authenticate_card()
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

  public struct Alert: Identifiable, Equatable, Hashable {
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

    public enum AlertIcon: Identifiable, Equatable {
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

    public enum AlertType: Identifiable, Equatable {
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

extension PPOProjectCardModel.Alert {
  init?(flag: GraphAPI.PpoCardFragment.Flag) {
    let alertIcon: PPOProjectCardModel.Alert.AlertIcon? = switch flag.icon {
    case "alert":
      .alert
    case "time":
      .time
    default:
      nil
    }

    let alertType: PPOProjectCardModel.Alert.AlertType? = switch flag.type {
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

extension GraphAPI.MoneyFragment: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.amount)
    hasher.combine(self.currency)
    hasher.combine(self.symbol)
  }
}
