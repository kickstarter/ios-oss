import Foundation
import GraphAPI
import KsApi

#if targetEnvironment(simulator)
  extension PPOProjectCardModel {
    // Minimal set of representative templates to keep previews lightweight.
    public static let previewTemplates: [PPOProjectCardModel] = [
      noRewardPledgeCollected,
      awaitingShippableRewardTemplate,
      digitalRewardReceivedTemplate,
      managePledgeTemplate,
      confirmAddressTemplate,
      addressLockTemplate,
      fixPaymentTemplate,
      authenticateCardTemplate,
      completeSurveyTemplate
    ]

    // Minimal set of funded project templates that makes sure each tier type
    // and each reward type is represented at least once (instead of containing
    // every possible combination of tier type and reward type).
    public static let fundedProjectTemplates: [PPOProjectCardModel] = [
      noRewardPledgeCollected,
      surveySubmittedTemplate,
      addressConfirmedTemplate,
      digitalRewardReceivedTemplate,
      awaitingShippableRewardTemplate
    ]

    // MARK: Funded projects

    internal static let noRewardPledgeCollected = PPOProjectCardModel(
      isUnread: true,
      alerts: [
        .init(type: .info, icon: nil, message: "Pledge collected")
      ],
      image: .network(URL(string: "https:///")!),
      projectName: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
      projectId: 12_345,
      pledge: "$50.00",
      creatorName: "rokaplay",
      address: .hidden,
      rewardReceivedToggleState: .hidden,
      action: nil,
      tierType: .pledgeCollected,
      backingDetailsUrl: "fakeBackingDetailsUrl",
      backingId: 47,
      backingGraphId: "backing-fake-id",
      projectAnalytics: Self.projectAnalyticsFragmentTemplate
    )

    internal static let surveySubmittedTemplate = PPOProjectCardModel(
      isUnread: true,
      alerts: [
        .init(type: .info, icon: nil, message: "Survey submitted")
      ],
      image: .network(URL(string: "https:///")!),
      projectName: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
      projectId: 12_345,
      pledge: "$50.00",
      creatorName: "rokaplay truncate if longer than this extra long string",
      address: .editable(address: """
        Firsty Lasty
        123 First Street, Apt #5678
        Los Angeles, CA 90025-1234
        United States
      """),
      rewardReceivedToggleState: .hidden,
      action: nil,
      tierType: .surveySubmitted,
      backingDetailsUrl: "fakeBackingDetailsUrl",
      backingId: 47,
      backingGraphId: "backing-fake-id",
      projectAnalytics: Self.projectAnalyticsFragmentTemplate
    )

    internal static let addressConfirmedTemplate = PPOProjectCardModel(
      isUnread: true,
      alerts: [
        .init(type: .warning, icon: .time, message: "Address locks in 8 hours")
      ],
      image: .network(URL(string: "https:///")!),
      projectName: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
      projectId: 12_345,
      pledge: "$50.00",
      creatorName: "rokaplay truncate if longer than this extra long string",
      address: .editable(address: """
        Firsty Lasty
        123 First Street, Apt #5678
        Los Angeles, CA 90025-1234
        United States
      """),
      rewardReceivedToggleState: .hidden,
      action: nil,
      tierType: .addressConfirmed,
      backingDetailsUrl: "fakeBackingDetailsUrl",
      backingId: 47,
      backingGraphId: "backing-fake-id",
      projectAnalytics: Self.projectAnalyticsFragmentTemplate
    )

    internal static let digitalRewardReceivedTemplate = PPOProjectCardModel(
      isUnread: true,
      alerts: [
        .init(type: .info, icon: nil, message: "Reward received")
      ],
      image: .network(URL(string: "https:///")!),
      projectName: "Sugardew Island",
      projectId: 12_345,
      pledge: "$50.00",
      creatorName: "rokaplay",
      address: .hidden,
      rewardReceivedToggleState: .rewardReceived,
      action: nil,
      tierType: .rewardReceived,
      backingDetailsUrl: "fakeBackingDetailsUrl",
      backingId: 47,
      backingGraphId: "backing-fake-id",
      projectAnalytics: Self.projectAnalyticsFragmentTemplate
    )

    internal static let awaitingShippableRewardTemplate = PPOProjectCardModel(
      isUnread: true,
      alerts: [
        .init(type: .info, icon: nil, message: "In fulfillment")
      ],
      image: .network(URL(string: "https:///")!),
      projectName: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
      projectId: 12_345,
      pledge: "$50.00",
      creatorName: "rokaplay truncate if longer than this extra long string",
      address: .locked(address: """
        Firsty Lasty
        123 First Street, Apt #5678
        Los Angeles, CA 90025-1234
        United States
      """),
      rewardReceivedToggleState: .notReceived,
      action: nil,
      tierType: .awaitingReward,
      backingDetailsUrl: "fakeBackingDetailsUrl",
      backingId: 47,
      backingGraphId: "backing-fake-id",
      projectAnalytics: Self.projectAnalyticsFragmentTemplate
    )

    // MARK: Project alerts

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
      address: .editable(address: """
        Firsty Lasty
        123 First Street, Apt #5678
        Los Angeles, CA 90025-1234
        United States
      """),
      rewardReceivedToggleState: .hidden,
      action: .confirmAddress(
        address: """
          123 First Street, Apt #5678
          Los Angeles, CA 90025-1234
          United States
        """,
        addressId: "fake-address-id"
      ),
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
      address: .hidden,
      rewardReceivedToggleState: .hidden,
      action: .completeSurvey,
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
      address: .hidden,
      rewardReceivedToggleState: .hidden,
      action: .fixPayment,
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
      address: .hidden,
      rewardReceivedToggleState: .hidden,
      action: .authenticateCard(clientSecret: "seti_asdqwe_secret_x"),
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
      address: .hidden,
      rewardReceivedToggleState: .hidden,
      action: .completeSurvey,
      tierType: .openSurvey,
      backingDetailsUrl: "fakeBackingDetailsUrl",
      backingId: 47,
      backingGraphId: "backing-fake-id",
      projectAnalytics: Self.projectAnalyticsFragmentTemplate
    )

    internal static let managePledgeTemplate = PPOProjectCardModel(
      isUnread: true,
      alerts: [
        .init(type: .warning, icon: .alert, message: "Finalize your pledge")
      ],
      image: .network(URL(string: "https:///")!),
      projectName: "Sugardew Island - Your cozy farm shop let’s pretend this is a way way way longer title",
      projectId: 12_345,
      pledge: "$50.00",
      creatorName: "rokaplay truncate if longer than this extra long string",
      address: .hidden,
      rewardReceivedToggleState: .hidden,
      action: .managePledge,
      tierType: .pledgeManagement,
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
      country: .init(code: GraphQLEnum.case(.us)),
      creator: nil,
      currency: GraphQLEnum.case(.usd),
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
      state: GraphQLEnum.case(.successful),
      video: nil,
      pledged: .init(amount: nil),
      fxRate: 4,
      usdExchangeRate: nil,
      posts: ProjectAnalyticsFragment.Posts(totalCount: 0),
      goal: nil
    )

    // MARK: UI edge cases

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
      address: .hidden,
      rewardReceivedToggleState: .hidden,
      action: .completeSurvey,
      tierType: .openSurvey,
      backingDetailsUrl: "fakeBackingDetailsUrl",
      backingId: 47,
      backingGraphId: "backing-fake-id",
      projectAnalytics: Self.projectAnalyticsFragmentTemplate
    )

    internal static let lotsOfFlagsTemplate = PPOProjectCardModel(
      isUnread: true,
      alerts: [
        .init(
          type: .warning,
          icon: .time,
          message: "This is a very very very very very very very very very very long flag"
        ),
        .init(
          type: .alert,
          icon: .alert,
          message: "Also long"
        ),
        .init(
          type: .alert,
          icon: .alert,
          message: "And still very long"
        )
      ],
      image: .network(URL(string: "https:///")!),
      projectName: "Project",
      projectId: 12_345,
      pledge: "$50.00",
      creatorName: "Bob",
      address: .hidden,
      rewardReceivedToggleState: .hidden,
      action: .completeSurvey,
      tierType: .openSurvey,
      backingDetailsUrl: "fakeBackingDetailsUrl",
      backingId: 47,
      backingGraphId: "backing-fake-id",
      projectAnalytics: Self.projectAnalyticsFragmentTemplate
    )
  }
#endif
