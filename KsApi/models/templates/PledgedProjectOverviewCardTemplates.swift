import Foundation

extension PledgedProjectOverviewCard {
  #if targetEnvironment(simulator)
    public static let previewTemplates: [PledgedProjectOverviewCard] = [
      confirmAddressTemplate,
      addressLockTemplate,
      fixPaymentTemplate,
      authenticateCardTemplate,
      completeSurveyTemplate
    ]
  #endif

  internal static let confirmAddressTemplate = PledgedProjectOverviewCard(
    isUnread: true,
    alerts: [
      .init(type: .time, icon: .warning, message: "Address locks in 8 hours")
    ],
    imageURL: URL(string: "http://localhost/")!,
    title: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
    pledge: .init(amount: "50.00", currency: .usd, symbol: "$"),
    creatorName: "rokaplay truncate if longer than",
    address: """
      Firsty Lasty
      123 First Street, Apt #5678
      Los Angeles, CA 90025-1234
      United States
    """,
    actions: (.confirmAddress, .editAddress),
    tierType: .confirmAddress,
    projectAnalytics: Self.projectAnalyticsFragmentTemplate
  )

  internal static let addressLockTemplate = PledgedProjectOverviewCard(
    isUnread: true,
    alerts: [
      .init(type: .alert, icon: .warning, message: "Survey available"),
      .init(type: .time, icon: .warning, message: "Address locks in 48 hours")
    ],
    imageURL: URL(string: "http://localhost/")!,
    title: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
    pledge: .init(amount: "50.00", currency: .usd, symbol: "$"),
    creatorName: "rokaplay truncate if longer than",
    address: nil,
    actions: (.completeSurvey, nil),
    tierType: .openSurvey,
    projectAnalytics: Self.projectAnalyticsFragmentTemplate
  )

  internal static let fixPaymentTemplate = PledgedProjectOverviewCard(
    isUnread: true,
    alerts: [
      .init(type: .alert, icon: .alert, message: "Payment failed"),
      .init(
        type: .time,
        icon: .alert,
        message: "Pledge will be dropped in 6 days"
      )
    ],
    imageURL: URL(string: "http://localhost/")!,
    title: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
    pledge: .init(amount: "50.00", currency: .usd, symbol: "$"),
    creatorName: "rokaplay truncate if longer than",
    address: nil,
    actions: (.fixPayment, nil),
    tierType: .fixPayment,
    projectAnalytics: Self.projectAnalyticsFragmentTemplate
  )

  internal static let authenticateCardTemplate = PledgedProjectOverviewCard(
    isUnread: true,
    alerts: [
      .init(type: .alert, icon: .alert, message: "Card needs authentication"),
      .init(
        type: .time,
        icon: .alert,
        message: "Pledge will be dropped in 6 days"
      )
    ],
    imageURL: URL(string: "http://localhost/")!,
    title: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
    pledge: .init(amount: "50.00", currency: .usd, symbol: "$"),
    creatorName: "rokaplay truncate if longer than",
    address: nil,
    actions: (.authenticateCard, nil),
    tierType: .authenticateCard,
    projectAnalytics: Self.projectAnalyticsFragmentTemplate
  )

  internal static let completeSurveyTemplate = PledgedProjectOverviewCard(
    isUnread: true,
    alerts: [
      .init(type: .alert, icon: .warning, message: "Survey available")
    ],
    imageURL: URL(string: "http://localhost/")!,
    title: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
    pledge: .init(amount: "50.00", currency: .usd, symbol: "$"),
    creatorName: "rokaplay truncate if longer than",
    address: nil,
    actions: (.completeSurvey, nil),
    tierType: .openSurvey,
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
