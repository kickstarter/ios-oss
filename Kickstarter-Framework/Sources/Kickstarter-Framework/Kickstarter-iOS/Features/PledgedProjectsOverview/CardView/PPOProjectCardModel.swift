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
  public let backingId: Int
  public let backingGraphId: String
  public let projectAnalytics: GraphAPI.ProjectAnalyticsFragment
  public let projectPageParam: ProjectPageParam?

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

  // Create the card's id from the project id. There will be at most one PPO card per project.
  public var id: String {
    "\(self.projectId)"
  }

  // MARK: - Equatable

  // Consider two card models to be equal if the core properties are equal.
  // The project page param is not `Equatable` and prevents this function from being synthesized.
  public static func == (lhs: PPOProjectCardModel, rhs: PPOProjectCardModel) -> Bool {
    lhs.isUnread == rhs.isUnread &&
      lhs.alerts == rhs.alerts &&
      lhs.image == rhs.image &&
      lhs.projectName == rhs.projectName &&
      lhs.projectId == rhs.projectId &&
      lhs.pledge == rhs.pledge &&
      lhs.creatorName == rhs.creatorName &&
      lhs.address == rhs.address &&
      lhs.rewardReceivedToggleState == rhs.rewardReceivedToggleState &&
      lhs.action == rhs.action &&
      lhs.tierType == rhs.tierType &&
      lhs.backingId == rhs.backingId
  }

  public enum DisplayAddress: Equatable, Hashable {
    case hidden
    case locked(address: String)
    case editable(address: String, editUrl: String)

    public var rawAddress: String? {
      switch self {
      case .hidden: return nil
      case let .locked(address): return address
      case let .editable(address, _): return address
      }
    }
  }

  public enum ButtonAction: Identifiable, Equatable, Hashable {
    case confirmAddress(address: String, addressId: String)
    case completeSurvey(url: String)
    case openPledgeManager(url: String)
    case fixPayment
    case authenticateCard(clientSecret: String)
    case manageLivePledge

    public var label: String {
      switch self {
      case .confirmAddress:
        Strings.Confirm()
      case .completeSurvey:
        Strings.Take_survey()
      case .openPledgeManager:
        Strings.Finalize_pledge()
      case .fixPayment:
        Strings.Fix_payment()
      case .authenticateCard:
        Strings.Authenticate_card()
      case .manageLivePledge:
        Strings.project_manage_button()
      }
    }

    public var style: Style {
      switch self {
      case .confirmAddress:
        .green
      case .completeSurvey:
        .green
      case .openPledgeManager:
        .green
      case .fixPayment:
        .red
      case .authenticateCard:
        .red
      case .manageLivePledge:
        .blue
      }
    }

    public enum Style: Identifiable, Equatable {
      case green
      case red
      case blue

      public var id: String {
        switch self {
        case .green: "green"
        case .red: "red"
        case .blue: "blue"
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
