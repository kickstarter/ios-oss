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
    case confirmAddress(address: String, addressId: Int)
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

extension PPOProjectCardModel {
  #if targetEnvironment(simulator)
    public static let previewTemplates: [PPOProjectCardModel] = [
      confirmAddressTemplate,
      addressLockTemplate,
      fixPaymentTemplate,
      authenticateCardTemplate,
      completeSurveyTemplate
    ]
  #endif

  internal static let confirmAddressTemplate = PPOProjectCardModel(
    isUnread: true,
    alerts: [
      .init(type: .warning, icon: .time, message: "Address locks in 8 hours")
    ],
    image: .network(URL(string: "https:///")!),
    projectName: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
    projectId: 12_345,
    pledge: "$50.00",
    creatorName: "rokaplay truncate if longer than",
    address: """
      Firsty Lasty
      123 First Street, Apt #5678
      Los Angeles, CA 90025-1234
      United States
    """,
    actions: (.confirmAddress(
      address: """
        123 First Street, Apt #5678
        Los Angeles, CA 90025-1234
        United States
      """,
      addressId: 98
    ), .editAddress),
    tierType: .confirmAddress,
    backingDetailsUrl: "fakeBackingDetailsUrl",
    backingId: 47,
    projectAnalytics: Self.projectAnalyticsFragmentTemplate
  )

  internal static let addressLockTemplate = PPOProjectCardModel(
    isUnread: true,
    alerts: [
      .init(type: .warning, icon: .alert, message: "Survey available"),
      .init(type: .warning, icon: .time, message: "Address locks in 48 hours")
    ],
    image: .network(URL(string: "https:///")!),
    projectName: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
    projectId: 12_345,
    pledge: "$50.00",
    creatorName: "rokaplay truncate if longer than",
    address: nil,
    actions: (.completeSurvey, nil),
    tierType: .openSurvey,
    backingDetailsUrl: "fakeBackingDetailsUrl",
    backingId: 47,
    projectAnalytics: Self.projectAnalyticsFragmentTemplate
  )

  internal static let fixPaymentTemplate = PPOProjectCardModel(
    isUnread: true,
    alerts: [
      .init(type: .alert, icon: .alert, message: "Payment failed"),
      .init(
        type: .alert,
        icon: .time,
        message: "Pledge will be dropped in 6 days"
      )
    ],
    image: .network(URL(string: "https:///")!),
    projectName: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
    projectId: 12_345,
    pledge: "$50.00",
    creatorName: "rokaplay truncate if longer than",
    address: nil,
    actions: (.fixPayment, nil),
    tierType: .fixPayment,
    backingDetailsUrl: "fakeBackingDetailsUrl",
    backingId: 47,
    projectAnalytics: Self.projectAnalyticsFragmentTemplate
  )

  internal static let authenticateCardTemplate = PPOProjectCardModel(
    isUnread: true,
    alerts: [
      .init(type: .alert, icon: .alert, message: "Card needs authentication"),
      .init(
        type: .alert,
        icon: .time,
        message: "Pledge will be dropped in 6 days"
      )
    ],
    image: .network(URL(string: "https:///")!),
    projectName: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
    projectId: 12_345,
    pledge: "$50.00",
    creatorName: "rokaplay truncate if longer than",
    address: nil,
    actions: (.authenticateCard(clientSecret: ""), nil),
    tierType: .authenticateCard,
    backingDetailsUrl: "fakeBackingDetailsUrl",
    backingId: 47,
    projectAnalytics: Self.projectAnalyticsFragmentTemplate
  )

  internal static let completeSurveyTemplate = PPOProjectCardModel(
    isUnread: true,
    alerts: [
      .init(type: .warning, icon: .alert, message: "Survey available")
    ],
    image: .network(URL(string: "https:///")!),
    projectName: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
    projectId: 12_345,
    pledge: "$50.00",
    creatorName: "rokaplay truncate if longer than",
    address: nil,
    actions: (.completeSurvey, nil),
    tierType: .openSurvey,
    backingDetailsUrl: "fakeBackingDetailsUrl",
    backingId: 47,
    projectAnalytics: Self.projectAnalyticsFragmentTemplate
  )

  internal static let projectAnalyticsFragmentTemplate = GraphAPI.ProjectAnalyticsFragment(
    addOns: nil,
    backersCount: 42,
    backing: nil,
    category: nil,
    commentsCount: 42,
    country: .init(code: .us),
    creator: nil,
    currency: .usd,
    deadlineAt: nil,
    launchedAt: nil,
    pid: 42,
    name: "Test",
    isInPostCampaignPledgingPhase: true,
    isWatched: true,
    percentFunded: 100,
    isPrelaunchActivated: false,
    projectTags: [],
    postCampaignPledgingEnabled: false,
    rewards: nil,
    state: .successful,
    video: nil,
    pledged: .init(amount: nil),
    fxRate: 4,
    usdExchangeRate: nil,
    posts: nil,
    goal: nil
  )
}

private enum PPOProjectCardModelConstants {
  static let paymentFailed = "Tier1PaymentFailed"
  static let confirmAddress = "Tier1AddressLockingSoon"
  static let completeSurvey = "Tier1OpenSurvey"
  static let authenticationRequired = "Tier1PaymentAuthenticationRequired"
}

extension PPOProjectCardModel {
  init?(node: GraphAPI.FetchPledgedProjectsQuery.Data.PledgeProjectsOverview.Pledge.Edge.Node) {
    let card = node.fragments.ppoCardFragment
    let backing = card.backing?.fragments.ppoBackingFragment
    let ppoProject = backing?.project?.fragments.ppoProjectFragment

    let image = ppoProject?.image?.url
      .flatMap { URL(string: $0) }
      .map { Kingfisher.Source.network($0) }

    let projectName = ppoProject?.name
    let projectId = ppoProject?.pid
    let pledgeFragment = backing?.amount.fragments.moneyFragment
    let formattedPledge = pledgeFragment.flatMap { Format.currency($0) }
    let creatorName = ppoProject?.creator?.name

    let addressId: Int? = backing?.deliveryAddress.flatMap { decompose(id: $0.id) }
    let address: String? = backing?.deliveryAddress.flatMap { deliveryAddress in
      let cityRegionFields: [String?] = [
        deliveryAddress.city,
        deliveryAddress.region.flatMap { ", \($0)" },
        deliveryAddress.postalCode.flatMap { " \($0)" }
      ]
      let fields: [String?] = [
        deliveryAddress.recipientName,
        deliveryAddress.addressLine1,
        deliveryAddress.addressLine2,
        cityRegionFields.compactMap { $0 }.joined(),
        deliveryAddress.countryCode.rawValue,
        deliveryAddress.phoneNumber
      ]
      return fields.compactMap { $0 }.joined(separator: "\n")
    }

    let alerts: [PPOProjectCardModel.Alert] = card.flags?
      .compactMap { PPOProjectCardModel.Alert(flag: $0) } ?? []

    let primaryAction: PPOProjectCardModel.Action
    let secondaryAction: PPOProjectCardModel.Action?
    let tierType: PPOProjectCardModel.TierType
    // For v1 of PPO we're just using the same url for surveys and the backing details page.
    // This specifically links to the survey tab.
    let backingDetailsUrl = backing?.backingDetailsPageRoute
    let backingId = backing.flatMap { decompose(id: $0.id) }

    switch (card.tierType, backing?.clientSecret, address, addressId) {
    case (PPOProjectCardModelConstants.paymentFailed, _, _, _):
      primaryAction = .fixPayment
      secondaryAction = nil
      tierType = .fixPayment
    case let (PPOProjectCardModelConstants.confirmAddress, _, .some(address), .some(addressId)):
      primaryAction = .confirmAddress(address: address, addressId: addressId)
      secondaryAction = .editAddress
      tierType = .confirmAddress
    case (PPOProjectCardModelConstants.confirmAddress, _, _, _):
      // Return nil instead of a card if there's no address to confirm.
      return nil
    case (PPOProjectCardModelConstants.completeSurvey, _, _, _):
      primaryAction = .completeSurvey
      secondaryAction = nil
      tierType = .openSurvey
    case let (PPOProjectCardModelConstants.authenticationRequired, .some(clientSecret), _, _):
      primaryAction = .authenticateCard(clientSecret: clientSecret)
      secondaryAction = nil
      tierType = .authenticateCard
    case (PPOProjectCardModelConstants.authenticationRequired, .none, _, _),
         _:
      return nil
    }

    let projectAnalyticsFragment = backing?.project?.fragments.projectAnalyticsFragment

    if let image, let projectName, let projectId, let formattedPledge, let creatorName,
       let projectAnalyticsFragment, let backingDetailsUrl, let backingId {
      self.init(
        isUnread: true,
        alerts: alerts,
        image: image,
        projectName: projectName,
        projectId: projectId,
        pledge: formattedPledge,
        creatorName: creatorName,
        address: address,
        actions: (primaryAction, secondaryAction),
        tierType: tierType,
        backingDetailsUrl: backingDetailsUrl,
        backingId: backingId,
        projectAnalytics: projectAnalyticsFragment
      )
    } else {
      return nil
    }
  }
}
