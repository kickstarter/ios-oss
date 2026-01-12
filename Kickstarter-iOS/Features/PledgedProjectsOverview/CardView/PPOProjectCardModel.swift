import Foundation
import GraphAPI
import Kingfisher
import KsApi
import Library

public enum PPORewardToggleState: Equatable {
  case hidden
  case rewardReceived
  case notReceived
}

public struct PPOProjectCardModel: Identifiable, Equatable, Hashable {
  public let isUnread: Bool
  public let alerts: [Alert]
  public let image: Kingfisher.Source
  public let projectName: String
  public let projectId: Int
  public let pledge: String
  public let creatorName: String
  public let address: DisplayAddress
  public let rewardReceivedToggleState: PPORewardToggleState
  public let action: ButtonAction?
  public let tierType: PPOTierType
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
    hasher.combine(self.action)
    hasher.combine(self.tierType)
  }

  // MARK: - Identifiable

  // Create the card's id from the project id, tier type, and actions.
  // If any other fields change, the card should be considered the same card, just modified.
  public var id: String {
    "\(self.projectId)-\(self.tierType)-\(self.action?.id ?? "")"
  }

  public enum DisplayAddress: Equatable, Hashable {
    case hidden
    case locked(address: String)
    case editable(address: String)

    public var rawAddress: String? {
      switch self {
      case .hidden: return nil
      case let .locked(address): return address
      case let .editable(address): return address
      }
    }
  }

  public enum ButtonAction: Identifiable, Equatable, Hashable {
    case confirmAddress(address: String, addressId: String)
    case completeSurvey
    case managePledge
    case fixPayment
    case authenticateCard(clientSecret: String)

    public var label: String {
      switch self {
      case .confirmAddress:
        Strings.Confirm()
      case .completeSurvey:
        Strings.Take_survey()
      case .managePledge:
        Strings.Finalize_pledge()
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
      case .completeSurvey:
        .green
      case .managePledge:
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
    public let icon: AlertIcon?
    public let message: String

    public init(type: AlertType, icon: AlertIcon?, message: String) {
      self.type = type
      self.icon = icon
      self.message = message
    }

    public var id: String {
      "\(self.type)-\(self.icon?.id ?? "noIcon")-\(self.message)"
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
      case info

      public var id: String {
        switch self {
        case .warning:
          "warning"
        case .alert:
          "alert"
        case .info:
          "info"
        }
      }
    }
  }
}

extension PPOProjectCardModel.Alert {
  init?(flag: GraphAPI.PPOCardFragment.Flag) {
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
    case "info":
      .info
    default:
      nil
    }
    let message = flag.message

    guard let alertType, let message else {
      return nil
    }

    self = .init(type: alertType, icon: alertIcon, message: message)
  }
}

extension GraphAPI.MoneyFragment: Equatable {
  public static func == (lhs: GraphAPI.MoneyFragment, rhs: GraphAPI.MoneyFragment) -> Bool {
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
