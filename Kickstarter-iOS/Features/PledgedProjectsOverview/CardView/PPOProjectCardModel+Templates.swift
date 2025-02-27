import Foundation
import KsApi

#if targetEnvironment(simulator)
  extension PPOProjectCardModel {
    public static let previewTemplates: [PPOProjectCardModel] = [
      confirmAddressTemplate,
      addressLockTemplate,
      fixPaymentTemplate,
      authenticateCardTemplate,
      completeSurveyTemplate
    ]

    internal static let confirmAddressTemplate = PPOProjectCardModel(
      isUnread: true,
      alerts: [
        .init(type: .warning, icon: .time, message: "Address locks in 8 hours")
      ],
      image: .network(URL(string: "https:///")!),
      projectName: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
      projectId: 12_345,
      pledge: "$50.00",
      creatorName: "rokaplay truncate if longer than this extra long string",
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
        addressId: "fake-address-id"
      ), .editAddress),
      tierType: .confirmAddress,
      backingDetailsUrl: "fakeBackingDetailsUrl",
      backingId: 47,
      backingGraphId: "backing-fake-id",
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
      creatorName: "rokaplay truncate if longer than this extra long string",
      address: nil,
      actions: (.completeSurvey, nil),
      tierType: .openSurvey,
      backingDetailsUrl: "fakeBackingDetailsUrl",
      backingId: 47,
      backingGraphId: "backing-fake-id",
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
      creatorName: "rokaplay truncate if longer than this extra long string",
      address: nil,
      actions: (.fixPayment, nil),
      tierType: .fixPayment,
      backingDetailsUrl: "fakeBackingDetailsUrl",
      backingId: 47,
      backingGraphId: "backing-fake-id",
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
      creatorName: "rokaplay truncate if longer than this extra long string",
      address: nil,
      actions: (.authenticateCard(clientSecret: "seti_asdqwe_secret_x"), nil),
      tierType: .authenticateCard,
      backingDetailsUrl: "fakeBackingDetailsUrl",
      backingId: 47,
      backingGraphId: "backing-fake-id",
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
      creatorName: "rokaplay truncate if longer than this extra long string",
      address: nil,
      actions: (.completeSurvey, nil),
      tierType: .openSurvey,
      backingDetailsUrl: "fakeBackingDetailsUrl",
      backingId: 47,
      backingGraphId: "backing-fake-id",
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

    internal static let shortTextTemplate = PPOProjectCardModel(
      isUnread: true,
      alerts: [
        .init(type: .warning, icon: .time, message: "Wait"),
        .init(
          type: .alert,
          icon: .alert,
          message: "Bad"
        )
      ],
      image: .network(URL(string: "https:///")!),
      projectName: "Project",
      projectId: 12_345,
      pledge: "$50.00",
      creatorName: "Bob",
      address: nil,
      actions: (.completeSurvey, nil),
      tierType: .openSurvey,
      backingDetailsUrl: "fakeBackingDetailsUrl",
      backingId: 47,
      backingGraphId: "backing-fake-id",
      projectAnalytics: Self.projectAnalyticsFragmentTemplate
    )
  }
#endif
