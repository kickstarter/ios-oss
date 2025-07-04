import AppboySegment
import KsApi
import PassKit
import Prelude
import UIKit

public final class KSRAnalytics {
  private let bundle: NSBundleType
  internal private(set) var config: Config?
  private let device: UIDeviceType
  private(set) var loggedInUser: User?
  private var appTrackingTransparency: AppTrackingTransparencyType?
  public var logEventCallback: ((String, [String: Any]) -> Void)?
  private let screen: UIScreenType
  private var segmentClient: (TrackingClientType & IdentifyingTrackingClient)?

  /// Configures `KSRAnalytics` with a Segment tracking client. Call is idempotent and will only set once.
  public func configureSegmentClient(_ segmentClient: TrackingClientType & IdentifyingTrackingClient) {
    guard self.segmentClient == nil else { return }
    self.segmentClient = segmentClient
  }

  private enum SegmentEvent: String, CaseIterable {
    case cardClicked = "Card Clicked"
    case ctaClicked = "CTA Clicked"
    case pageViewed = "Page Viewed"
    case videoPlaybackStarted = "Video Playback Started"
  }

  /// Determines the screen from which the event is sent.
  public enum PageContext: String {
    case activities = "activity_feed" // ActivitiesViewController
    case addOnsSelection = "add_ons" // RewardAddOnSelectionViewController
    case changePayment = "change_payment" // PledgeViewController
    case checkout // // PledgeViewController
    case creatorDashboard = "creator_dashboard" // DashboardViewController
    case discovery = "discover" // DiscoveryViewController
    case forgotPassword = "forgot_password" // ResetPasswordViewController
    case login = "log_in" // LoginViewController
    case loginTout = "log_in_sign_up" // LoginToutViewController
    case managePledgeScreen = "manage_pledge" // ManagePledgeViewController
    case messages // MessagesViewController
    case onboarding // CategorySelectionViewController, CuratedProjectsViewController
    case pledgeAddNewCard = "pledge_add_new_card"
    case pledgeScreen = "pledge" // PledgeViewController
    case project // ProjectPageViewController
    case projectAlerts = "project_alerts" // PPOView
    case profile // BackerDashboardProjectsViewController
    case rewards // RewardsViewController
    case search // SearchViewController
    case settingsAddNewCard = "settings_add_new_card"
    case signup = "sign_up" // SignupViewController
    case thanks // ThanksViewController
    case twoFactorAuth = "two_factor_auth" // TwoFactorViewController
    case updatePledge = "update_pledge" // PledgeViewController
  }

  /// Determines the authentication type for login or signup events.
  public enum AuthType {
    case email
    case facebook

    var trackingString: String {
      switch self {
      case .email: return "Email"
      case .facebook: return "Facebook"
      }
    }
  }

  /**
   Determines the place from which the external link was presented.

   - projectCreator: The creator profile, usually seen by pressing the creator's name on the project page.
   - projectUpdate: The page for a specific project update.
   - projectUpdates: The project updates page.

   **/
  public enum ExternalLinkContext {
    case projectCreator
    case projectUpdate
    case projectUpdates

    var trackingString: String {
      switch self {
      case .projectCreator:
        return "project_creator"
      case .projectUpdate:
        return "project_update"
      case .projectUpdates:
        return "project_updates"
      }
    }
  }

  /**
   Determines the place from which the message dialog was presented.

   - backerModal:     The backing view, usually seen by pressing "View pledge" on the project page.
   - creatorActivity: The creator's activity feed.
   - messages:        The messages inbox.
   - projectMessages: The messages inbox for a particular project of a creator's.
   - projectPage:     The project page.
   */
  public enum MessageDialogContext: String, Equatable {
    case backerModal = "backer_modal"
    case creatorActivity = "creator_activity"
    case messages
    case projectMessages = "project_messages"
    case projectPage = "project_page"
  }

  /**
   Determines the place from which the comments dialog was presented.

   - projectActivity: The creator's project activity screen.
   - projectComments: The comments screen for a project.
   - updateComments:  The comments screen for an update.
   */
  public enum CommentDialogContext {
    case projectActivity
    case projectComments
    case updateComments

    var trackingString: String {
      switch self {
      case .projectActivity: return "project_activity"
      case .projectComments: return "project_comments"
      case .updateComments: return "update_comments"
      }
    }
  }

  /**
   Indicates which button or link the user has clicked or tapped; describes CTA Clicked events.
   */
  public enum CTAContext {
    case addOnsContinue
    case blockUser
    case confirmInitiate
    case confirmSubmit
    case creatorDashboard
    case creatorDetails
    case discover
    case discoverFilter
    case discoverSort
    case edit
    case finalizePledgeInitiate
    case fixPledgeInitiate
    case forgotPassword
    case logInInitiate
    case logInOrSignUp
    case logInSubmit
    case messageCreatorInitiate
    case pledgeConfirm
    case pledgeInitiate
    case pledgeSubmit
    case project
    case projectSelect
    case projectUpdateCreateDraft
    case rewardContinue
    case search
    case signUpInitiate
    case signUpSubmit
    case surveyResponseInitiate
    case watchProject

    var trackingString: String {
      switch self {
      case .addOnsContinue: return "add_ons_continue"
      case .blockUser: return "block_user"
      case .confirmInitiate: return "confirm_initiate"
      case .confirmSubmit: return "confirm_submit"
      case .creatorDashboard: return "creator_dashboard"
      case .creatorDetails: return "creator_details"
      case .discover: return "discover"
      case .discoverFilter: return "discover_filter"
      case .discoverSort: return "discover_sort"
      case .edit: return "edit"
      case .finalizePledgeInitiate: return "finalize_pledge_initiate"
      case .fixPledgeInitiate: return "fix_pledge_initiate"
      case .forgotPassword: return "forgot_password"
      case .messageCreatorInitiate: return "message_creator_initiate"
      case .pledgeInitiate: return "pledge_initiate"
      case .pledgeConfirm: return "pledge_confirm"
      case .pledgeSubmit: return "pledge_submit"
      case .project: return "project"
      case .projectSelect: return "creator_project_select"
      case .projectUpdateCreateDraft: return "creator_project_update_create_draft"
      case .logInInitiate: return "log_in_initiate"
      case .logInOrSignUp: return "log_in_or_sign_up"
      case .logInSubmit: return "log_in_submit"
      case .rewardContinue: return "reward_continue"
      case .search: return "search"
      case .signUpInitiate: return "sign_up_initiate"
      case .signUpSubmit: return "sign_up_submit"
      case .surveyResponseInitiate: return "survey_response_initiate"
      case .watchProject: return "watch_project"
      }
    }
  }

  /// Determines which gesture was used.
  public enum GestureType: String {
    case swipe
    case tap

    fileprivate var trackingString: String {
      switch self {
      case .swipe: return "swipe"
      case .tap: return "tap"
      }
    }
  }

  /**
   Determines the place from which the newsletter toggle was presented.

   - facebook: The Facebook confirmation signup screen.
   - settings: The settings screen.
   - signup: The signup screen.
   - thanks: The thanks page games modal.
   */
  public enum NewsletterContext {
    case facebookSignup
    case settings
    case signup
    case thanks

    var trackingString: String {
      switch self {
      case .facebookSignup: return "facebook_signup"
      case .settings: return "settings"
      case .signup: return "signup"
      case .thanks: return "thanks"
      }
    }
  }

  public enum ManagePledgeMenuCTAType {
    case editPledgeOverTimePledge
    case cancelPledge
    case changePaymentMethod
    case chooseAnotherReward
    case contactCreator
    case viewRewards

    var trackingString: String {
      switch self {
      case .editPledgeOverTimePledge: return "edit_pledge_over_time_pledge"
      case .cancelPledge: return "cancel_pledge"
      case .changePaymentMethod: return "change_payment_method"
      case .chooseAnotherReward: return "choose_another_reward"
      case .contactCreator: return "contact_creator"
      case .viewRewards: return "view_rewards"
      }
    }
  }

  public enum CheckoutPageContext {
    case paymentsPage
    case projectPage
    case rewardSelection

    fileprivate var trackingString: String {
      switch self {
      case .paymentsPage: return "Payments Page"
      case .projectPage: return "Project Page"
      case .rewardSelection: return "Reward Selection"
      }
    }
  }

  /**
   A tab or section within a grouping of content.
   - backed: Section of BackerDashboardProjectViewController for backed Projects
   - comments: Section of Project overview screen
   - overview: Project overview landing screen
   - updates: Section of project overview screen.
   - watched:Section of BackerDashboardProjectViewController for saved Projects
   - tabSelected: Navigation tab of ProjectPageViewController.
   */
  public enum SectionContext {
    case backed
    case backerSurvey
    case comments
    case dashboard
    case overview
    case updates
    case watched
    case tabSelected(TabContext)

    var trackingString: String {
      switch self {
      case .backed: return "backed"
      case .backerSurvey: return "backer_survey"
      case .comments: return "comments"
      case .dashboard: return "dashboard"
      case .overview: return "overview"
      case .updates: return "updates"
      case .watched: return "watched"
      case let .tabSelected(tabContext): return tabContext.trackingString
      }
    }

    public enum TabContext {
      case overview
      case risks
      case campaign
      case useOfAI
      case faqs
      case environmentalCommitments

      var trackingString: String {
        switch self {
        case .overview: return "overview"
        case .risks: return "risks"
        case .campaign: return "campaign"
        case .useOfAI: return "use_of_ai"
        case .faqs: return "faq"
        case .environmentalCommitments: return "environment"
        }
      }
    }
  }

  /**
   Contextual details about an event that was fired that aren't captured in other context properties
   */
  public enum TypeContext {
    case address
    case allProjects
    case amountGoal
    case amountPledged
    case apple
    case applePay
    case backed
    case categoryName
    case cancel
    case creditCard
    case confirm
    case discovery(DiscoverySortContext)
    case facebook
    case initiate
    case location
    case percentRaised
    case pledge(PledgeContext)
    case projectState
    case pwl
    case recommended
    case results
    case searchTerm
    case social
    case subcategoryName
    case subscriptionFalse
    case subscriptionTrue
    case tag
    case unwatch
    case watch
    case watched

    /**
     Initialize a `TypeContext` value with `DiscoveryParams` for use with discovery filters..

     - parameter params: a `DiscoveryParams` object
     */
    init(params: DiscoveryParams) {
      if let recommended = params.recommended, recommended {
        self = .recommended
      } else if let starred = params.starred, starred {
        self = .watched
      } else if let social = params.social, social {
        self = .social
      } else {
        self = .results
      }
    }

    public enum DiscoverySortContext {
      case endingSoon
      case magic
      case newest
      case popular

      var trackingString: String {
        switch self {
        case .endingSoon: return "ending_soon"
        case .magic: return "magic"
        case .newest: return "newest"
        case .popular: return "popular"
        }
      }
    }

    public enum PledgeContext {
      case fixErroredPledge
      case newPledge
      case managePledge

      var trackingString: String {
        switch self {
        case .fixErroredPledge: return "fix_errored_pledge"
        case .newPledge: return "new_pledge"
        case .managePledge: return "manage_pledge"
        }
      }
    }

    var trackingString: String {
      switch self {
      case .allProjects: return "all"
      case .amountGoal: return "amount_goal"
      case .amountPledged: return "amount_pledged"
      case .apple: return "apple"
      case .applePay: return "apple_pay"
      case .backed: return "backed"
      case .cancel: return "cancel"
      case .categoryName: return "category_name"
      case .confirm: return "confirm"
      case .creditCard: return "credit_card"
      case let .discovery(discoveryContext): return discoveryContext.trackingString
      case .facebook: return "facebook"
      case .initiate: return "initiate"
      case .location: return "location"
      case .percentRaised: return "percent_raised"
      case let .pledge(pledgeContext): return pledgeContext.trackingString
      case .projectState: return "project_state"
      case .pwl: return "pwl"
      case .recommended: return "recommended"
      case .results: return "results"
      case .searchTerm: return "search_term"
      case .social: return "social"
      case .subcategoryName: return "subcategory_name"
      case .subscriptionFalse: return "subscription_false"
      case .subscriptionTrue: return "subscription_true"
      case .tag: return "tag"
      case .unwatch: return "unwatch"
      case .watch: return "watch"
      case .watched: return "watched"
      case .address: return "address"
      }
    }
  }

  /**
   A context providing additional details about the location the event occurs.
   */
  public enum LocationContext {
    case accountMenu
    case curated
    case creatorDetailsMenu
    case discoverAdvanced
    case discoverOverlay
    case globalNav
    case recommendations
    case searchResults

    var trackingString: String {
      switch self {
      case .accountMenu: return "account_menu"
      case .curated: return "curated"
      case .creatorDetailsMenu: return "creator_details_menu"
      case .discoverAdvanced: return "discover_advanced"
      case .discoverOverlay: return "discover_overlay"
      case .globalNav: return "global_nav"
      case .recommendations: return "recommendations"
      case .searchResults: return "search_results"
      }
    }
  }

  /**
   Determines the place from which the update was presented.

   - activity:        The activity feed.
   - activitySample:  The activity sample in Discovery.
   - creatorActivity: The creator's activity feed.
   - deepLink:        A deep link, including push notification.
   - draftPreview:    The update draft editor.
   - updates:         The updates index.
   */
  public enum UpdateContext {
    case activity
    case activitySample
    case creatorActivity
    case deepLink
    case draftPreview
    case updates

    fileprivate var trackingString: String {
      switch self {
      case .activity: return "activity"
      case .activitySample: return "activity_sample"
      case .creatorActivity: return "creator_activity"
      case .deepLink: return "deep_link"
      case .draftPreview: return "draft_preview"
      case .updates: return "updates"
      }
    }
  }

  public enum TabBarItemLabel: String {
    case discovery
    case activity
    case search
    case dashboard
    case profile

    var trackingString: String {
      return self.rawValue
    }
  }

  public struct CheckoutPropertiesData: Equatable {
    let addOnsCountTotal: Int?
    let addOnsCountUnique: Int?
    let addOnsMinimumUsd: Double
    let bonusAmountInUsd: Decimal?
    let checkoutId: String?
    let estimatedDelivery: TimeInterval?
    let paymentType: String?
    let revenueInUsd: Decimal
    let rewardId: String
    let rewardMinimumUsd: Decimal
    let rewardTitle: String?
    let shippingEnabled: Bool
    let shippingAmountUsd: Double?
    let userHasStoredApplePayCard: Bool
  }

  public struct PledgedProjectOverviewProperties {
    let addressLocksSoonCount: Int
    let surveyAvailableCount: Int
    let pledgeManagementCount: Int
    let paymentFailedCount: Int
    let cardAuthRequiredCount: Int
    let total: Int?
    let page: Int?

    public init(
      addressLocksSoonCount: Int,
      surveyAvailableCount: Int,
      pledgeManagementCount: Int,
      paymentFailedCount: Int,
      cardAuthRequiredCount: Int,
      total: Int?,
      page: Int?
    ) {
      self.addressLocksSoonCount = addressLocksSoonCount
      self.surveyAvailableCount = surveyAvailableCount
      self.pledgeManagementCount = pledgeManagementCount
      self.paymentFailedCount = paymentFailedCount
      self.cardAuthRequiredCount = cardAuthRequiredCount
      self.total = total
      self.page = page
    }
  }

  public init(
    bundle: NSBundleType = Bundle.main,
    config: Config? = nil,
    device: UIDeviceType = UIDevice.current,
    loggedInUser: User? = nil,
    screen: UIScreenType = UIScreen.main,
    segmentClient: (TrackingClientType & IdentifyingTrackingClient)? = nil,
    appTrackingTransparency: AppTrackingTransparencyType? = nil
  ) {
    self.bundle = bundle
    self.config = config
    self.device = device
    self.loggedInUser = loggedInUser
    self.screen = screen
    self.segmentClient = segmentClient
    self.appTrackingTransparency = appTrackingTransparency
  }

  /// Configure Tracking Client's supporting user identity
  public func identify(newUser: User?) {
    guard let newUser = newUser else {
      self.segmentClient?.reset()
      return
    }

    let newData = KSRAnalyticsIdentityData(newUser)
    self.segmentClient?.identify(
      "\(newData.userId)",
      traits: newData.allTraits
    )
  }

  // MARK: - Activity

  /// Call when the user is logged out, on the `Activity` tab and taps the `Explore Projects`button.
  public func trackExploreButtonClicked() {
    let properties = contextProperties(ctaContext: .discover, page: .activities)
    self.track(
      event: SegmentEvent.ctaClicked.rawValue,
      properties: properties
    )
  }

  // MARK: - Pledged Project Overview Events

  public func trackPPODashboardOpens(properties: PledgedProjectOverviewProperties) {
    let properties = contextProperties(page: .projectAlerts)
      .withAllValuesFrom(pledgedProjectOverviewProperties(from: properties))
    self.track(
      event: SegmentEvent.pageViewed.rawValue,
      properties: properties
    )
  }

  public func trackPPOMessagingCreator(
    from project: any ProjectAnalyticsProperties,
    properties: PledgedProjectOverviewProperties
  ) {
    let properties = contextProperties(ctaContext: .messageCreatorInitiate, page: .projectAlerts)
      .withAllValuesFrom(projectProperties(from: project))
      .withAllValuesFrom(pledgedProjectOverviewProperties(from: properties))
      .withAllValuesFrom(["interaction_target_uid": project.creatorId ?? ""])
    self.track(
      event: SegmentEvent.ctaClicked.rawValue,
      properties: properties
    )
  }

  public func trackPPOFixingPaymentFailure(
    project: any ProjectAnalyticsProperties,
    properties: PledgedProjectOverviewProperties
  ) {
    let props = contextProperties(ctaContext: .fixPledgeInitiate, page: .projectAlerts)
      .withAllValuesFrom(projectProperties(from: project))
      .withAllValuesFrom(pledgedProjectOverviewProperties(from: properties))

    self.track(
      event: SegmentEvent.ctaClicked.rawValue,
      properties: props
    )
  }

  public func trackPPOOpeningSurvey(
    project: any ProjectAnalyticsProperties,
    properties: PledgedProjectOverviewProperties
  ) {
    let props = contextProperties(
      ctaContext: .surveyResponseInitiate,
      page: .projectAlerts
    )
    .withAllValuesFrom(projectProperties(from: project))
    .withAllValuesFrom(pledgedProjectOverviewProperties(from: properties))

    self.track(
      event: SegmentEvent.ctaClicked.rawValue,
      properties: props
    )
  }

  public func trackPPOManagePledge(
    project: any ProjectAnalyticsProperties,
    properties: PledgedProjectOverviewProperties
  ) {
    let props = contextProperties(
      ctaContext: .finalizePledgeInitiate,
      page: .projectAlerts
    )
    .withAllValuesFrom(projectProperties(from: project))
    .withAllValuesFrom(pledgedProjectOverviewProperties(from: properties))

    self.track(
      event: SegmentEvent.ctaClicked.rawValue,
      properties: props
    )
  }

  public func trackPPOInitiateConfirmingAddress(
    project: any ProjectAnalyticsProperties,
    properties: PledgedProjectOverviewProperties
  ) {
    let props = contextProperties(
      ctaContext: .confirmInitiate,
      page: .projectAlerts,
      typeContext: .address
    )
    .withAllValuesFrom(projectProperties(from: project))
    .withAllValuesFrom(pledgedProjectOverviewProperties(from: properties))

    self.track(
      event: SegmentEvent.ctaClicked.rawValue,
      properties: props
    )
  }

  public func trackPPOSubmitAddressConfirmation(
    project: any ProjectAnalyticsProperties,
    properties: PledgedProjectOverviewProperties
  ) {
    let props = contextProperties(
      ctaContext: .confirmSubmit,
      page: .projectAlerts,
      typeContext: .address
    )
    .withAllValuesFrom(projectProperties(from: project))
    .withAllValuesFrom(pledgedProjectOverviewProperties(from: properties))

    self.track(
      event: SegmentEvent.ctaClicked.rawValue,
      properties: props
    )
  }

  public func trackPPOEditAddress(
    project: any ProjectAnalyticsProperties,
    properties: PledgedProjectOverviewProperties
  ) {
    let props = contextProperties(
      ctaContext: .edit,
      page: .projectAlerts,
      typeContext: .address
    )
    .withAllValuesFrom(projectProperties(from: project))
    .withAllValuesFrom(pledgedProjectOverviewProperties(from: properties))

    self.track(
      event: SegmentEvent.ctaClicked.rawValue,
      properties: props
    )
  }

  // MARK: - Application Lifecycle

  /**
   Called when the user selected a tab bar item.

   - parameter tabBarItemLabel: The tab the user is navigating to.
   - parameter previousTabBarItemLabel: The tab the user is navigating from.
   */
  public func trackTabBarClicked(
    tabBarItemLabel: TabBarItemLabel,
    previousTabBarItemLabel: TabBarItemLabel
  ) {
    let page = pageContext(from: previousTabBarItemLabel)
    switch tabBarItemLabel {
    case .discovery:
      let properties = contextProperties(
        ctaContext: .discover,
        page: page,
        locationContext: .globalNav
      )
      self.track(
        event: SegmentEvent.ctaClicked.rawValue,
        properties: properties
      )
    default:
      return
    }
  }

  /**
   Called when the user specifically taps on the Search TabBarItem

   - parameter prevTabBarItemLabel: The tab the user was on before clicking search.
   */

  public func trackSearchTabBarClicked(prevTabBarItemLabel: TabBarItemLabel) {
    let page = pageContext(from: prevTabBarItemLabel)
    let properties = contextProperties(
      ctaContext: .search,
      page: page,
      locationContext: .globalNav
    )
    self.track(
      event: SegmentEvent.ctaClicked.rawValue,
      properties: properties
    )
  }

  // MARK: - Block User Events

  /**
   Call when a user attempts to block a user and when blocking succeeds

   - parameter project: The project being viewed.
   - parameter page: The `PageContext` representing the specific area the UI is interacted in
   - parameter sectionContext: The optional `SectionContext` representing the grouping of content
   - parameter locationContext: The optional `LocationContext` representing additional details of the UI interaction
   - parameter typeContext: Additional information about where in the flow the event emitted.
   - parameter targetUserId: The uid of the user who is potentially being blocked.
   */

  public func trackBlockedUser(
    _ project: any ProjectAnalyticsProperties,
    page: KSRAnalytics.PageContext,
    sectionContext: KSRAnalytics.SectionContext? = nil,
    locationContext: KSRAnalytics.LocationContext? = nil,
    typeContext: KSRAnalytics.TypeContext,
    targetUserId: String
  ) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(contextProperties(
        ctaContext: .blockUser,
        page: page,
        sectionContext: sectionContext,
        typeContext: typeContext,
        locationContext: locationContext
      ))
      .withAllValuesFrom(interactionProperties(targetUserId: targetUserId))

    self.track(
      event: SegmentEvent.ctaClicked.rawValue,
      properties: props
    )
  }

  // MARK: - Discovery Events

  /**
   Call when a discovery page is viewed and the first page is loaded.

   - parameter params: The params used for the discovery search.
   */

  public func trackDiscovery(params: DiscoveryParams) {
    let properties = contextProperties(page: .discovery)
      .withAllValuesFrom(discoveryProperties(from: params))

    self.track(
      event: SegmentEvent.pageViewed.rawValue,
      properties: properties
    )
  }

  /**
   Call when a filter is selected from the Explore modal.

   - parameter params: The params selected from the modal.
   - parameter typeContext: The context of the selected filter.
   - parameter locationContext: Represents additional details of the UI interaction
   */
  public func trackDiscoveryModalSelectedFilter(
    params: DiscoveryParams,
    typeContext: TypeContext,
    locationContext: LocationContext
  ) {
    let props = discoveryProperties(from: params)
      .withAllValuesFrom(
        contextProperties(
          ctaContext: .discoverFilter,
          page: .discovery,
          typeContext: typeContext,
          locationContext: locationContext
        )
      )
    self.track(
      event: SegmentEvent.ctaClicked.rawValue,
      properties: props
    )
  }

  /**
   Called when saved is selected from profile.

   - parameter params: The params selected from the modal.
   */
  public func trackProfilePageFilterSelected(
    params: DiscoveryParams
  ) {
    let props = discoveryProperties(from: params)
      .withAllValuesFrom(
        contextProperties(
          ctaContext: .discoverFilter,
          page: .discovery,
          typeContext: .watched,
          locationContext: .accountMenu
        )
      )
    self.track(
      event: SegmentEvent.ctaClicked.rawValue,
      properties: props
    )
  }

  /**
   Call when the user swipes between sorts or selects a sort.

   if a user is on Discover Advanced and has results sorted by magic, but then clicks the button to sort by popularity,
   that would be discover_sort = magic, context_cta = discover_sort, context_type = popular, context_location = discover_advanced, context_page = discover.

   - parameter prevSort: The last sort selected before the new sort.
   - parameter params: additional parameters associated with the current selected sort.
   - parameter discoverySortContext: the context of the selected sort
   */
  public func trackDiscoverySelectedSort(
    prevSort: DiscoveryParams.Sort,
    params: DiscoveryParams,
    discoverySortContext: TypeContext.DiscoverySortContext
  ) {
    let props = discoveryProperties(from: params)
      .withAllValuesFrom([
        "discover_sort": prevSort.trackingString
      ])
      .withAllValuesFrom(
        contextProperties(
          ctaContext: .discoverSort,
          page: .discovery,
          typeContext: .discovery(discoverySortContext),
          locationContext: .discoverAdvanced
        )
      )

    self.track(
      event: SegmentEvent.ctaClicked.rawValue,
      properties: props
    )
  }

  /**
   Call when a project card is clicked from a list of projects
   - parameter page: The `PageContext` representing the specific area the UI is interacted in
   - parameter checkoutData: The `CheckoutPropertiesData` associated with this specific checkout instance
   - parameter project: The `Project` corresponding to the card that was clicked
   - parameter typeContext: Additional information about an event that was not captured in other context properties for the `Project` tapped.
   - parameter location: The optional `LocationContext` representing additional details of the UI interaction
   - parameter params: The optional `DiscoveryParams  ` associated with the list of projects
   - parameter reward: The optional `Reward  ` for the selected `Project`
   - parameter section: The optional `SectionContext  ` representing the grouping of content
   */

  public func trackProjectCardClicked(
    page: PageContext,
    project: any ProjectAnalyticsProperties,
    checkoutData: CheckoutPropertiesData? = nil,
    typeContext: TypeContext? = nil,
    location: LocationContext? = nil,
    params: DiscoveryParams? = nil,
    reward: Reward? = nil,
    section: SectionContext? = nil
  ) {
    var props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(contextProperties(
        ctaContext: .project,
        page: page,
        sectionContext: section,
        typeContext: typeContext,
        locationContext: location
      ))

    if let checkoutProps = checkoutData {
      props = props.withAllValuesFrom(checkoutProperties(from: checkoutProps, and: reward))
    }

    if let discoveryParams = params {
      props = props.withAllValuesFrom(discoveryProperties(from: discoveryParams))
    }

    self.track(
      event: SegmentEvent.ctaClicked.rawValue,
      properties: props
    )
  }

  /**
   Call when a video starts playing on a project

   - parameter project: The `Project` corresponding to the video that started playing.
   - parameter videoLength: The length of video in seconds
   - parameter videoPosition: The index position of the playhead, in seconds
   */

  public func trackProjectVideoPlaybackStarted(
    project: any HasProjectAnalyticsProperties,
    videoLength: Int,
    videoPosition: Int
  ) {
    let props = projectProperties(from: project.projectAnalyticsProperties, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(videoProperties(videoLength: videoLength, videoPosition: videoPosition))
      .withAllValuesFrom(contextProperties(page: .project))

    self.track(
      event: SegmentEvent.videoPlaybackStarted.rawValue,
      properties: props
    )
  }

  // MARK: - Pledge Events

  public func trackAddOnsContinueButtonClicked(
    project: any ProjectAnalyticsProperties,
    reward: Reward,
    checkoutData: CheckoutPropertiesData,
    refTag: RefTag?
  ) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(contextProperties(ctaContext: .addOnsContinue, page: .addOnsSelection))
      .withAllValuesFrom(checkoutProperties(from: checkoutData, and: reward))
    self.track(
      event: SegmentEvent.ctaClicked.rawValue,
      properties: props,
      refTag: refTag?.stringTag
    )
  }

  public func trackAddOnsPageViewed(
    project: any ProjectAnalyticsProperties,
    reward: Reward,
    checkoutData: CheckoutPropertiesData,
    refTag: RefTag?
  ) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(checkoutProperties(from: checkoutData, and: reward))
      .withAllValuesFrom(contextProperties(page: .addOnsSelection))

    self.track(
      event: SegmentEvent.pageViewed.rawValue,
      properties: props,
      refTag: refTag?.stringTag
    )
  }

  public func trackPledgeCTAButtonClicked(
    stateType: PledgeStateCTAType,
    project: any ProjectAnalyticsProperties
  ) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(contextProperties(page: .project))

    switch stateType {
    case .pledge:
      let allProps = props
        .withAllValuesFrom([:])
        .withAllValuesFrom(contextProperties(ctaContext: .pledgeInitiate))
        .withAllValuesFrom(props)

      self.track(
        event: SegmentEvent.ctaClicked.rawValue,
        properties: allProps
      )
    default:
      return
    }
  }

  public func trackManagePledgePageViewed(
    project: any ProjectAnalyticsProperties,
    reward: Reward,
    checkoutData: CheckoutPropertiesData
  ) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(checkoutProperties(from: checkoutData, and: reward))
      .withAllValuesFrom(contextProperties(page: .managePledgeScreen))

    self.track(
      event: SegmentEvent.pageViewed.rawValue,
      properties: props
    )
  }

  /* Call when a reward is selected

   parameters:
   - project: the project being pledged to
   - reward: the selected reward
   - checkoutPropertiesData: the `CheckoutPropertiesData` associated with the given project and reward
   - refTag: the optional RefTag associated with the pledge
   */

  public func trackRewardClicked(
    project: any ProjectAnalyticsProperties,
    reward: Reward,
    checkoutPropertiesData: KSRAnalytics.CheckoutPropertiesData,
    refTag: RefTag?
  ) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(contextProperties(ctaContext: .rewardContinue, page: .rewards))
      .withAllValuesFrom(checkoutProperties(from: checkoutPropertiesData, and: reward))

    self.track(
      event: SegmentEvent.ctaClicked.rawValue,
      properties: props,
      refTag: refTag?.stringTag
    )
  }

  /* Call when the rewards carousel is viewed

   parameters:
   - project: the project being pledged to
   - checkoutPropertiesData: the `CheckoutPropertiesData` associated with the given project and reward
   - refTag: the optional RefTag associated with the pledge
   */

  public func trackRewardsViewed(
    project: any ProjectAnalyticsProperties,
    checkoutPropertiesData: KSRAnalytics.CheckoutPropertiesData,
    refTag: RefTag?
  ) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(checkoutProperties(from: checkoutPropertiesData))
      .withAllValuesFrom(contextProperties(page: .rewards))

    self.track(
      event: SegmentEvent.pageViewed.rawValue,
      properties: props,
      refTag: refTag?.stringTag
    )
  }

  /* Call when the PledgeViewController is shown.

   parameters:
   - project: the project being pledged to
   - reward: the chosen reward
   - pledgeViewContext: The specific context applicable to the PledgeViewModel
   - checkoutData: the `CheckoutPropertiesData` associated with the given project and reward
   - refTag: the associated RefTag for the pledge

   */

  public func trackCheckoutPaymentPageViewed(
    project: any ProjectAnalyticsProperties,
    reward: Reward,
    pledgeViewContext: PledgeViewContext,
    checkoutData: CheckoutPropertiesData,
    refTag: RefTag?
  ) {
    var props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(checkoutProperties(from: checkoutData, and: reward))

    switch pledgeViewContext {
    case .pledge, .latePledge:
      props = props.withAllValuesFrom(contextProperties(page: .checkout))
    case .changePaymentMethod:
      props = props.withAllValuesFrom(contextProperties(page: .changePayment))
    case .update, .updateReward:
      props = props.withAllValuesFrom(contextProperties(page: .updatePledge))
    default:
      return
    }

    self.track(
      event: SegmentEvent.pageViewed.rawValue,
      properties: props,
      refTag: refTag?.stringTag
    )
  }

  /* Call when the Pledge button or Apple Pay button is clicked

   parameters:
   - project: the project being pledged to
   - reward: the chosen reward
   - typeContext: The context of the pledge submit button for a project.
   - checkoutData: all the checkout data associated with the pledge
   - refTag: the associated RefTag for the pledge

   */

  public func trackPledgeSubmitButtonClicked(
    project: any ProjectAnalyticsProperties,
    reward: Reward,
    typeContext: TypeContext,
    checkoutData: CheckoutPropertiesData,
    refTag: RefTag?
  ) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(checkoutProperties(from: checkoutData, and: reward))
      // the context is always "newPledge" for this event
      .withAllValuesFrom(contextProperties(
        ctaContext: .pledgeSubmit,
        page: .checkout,
        typeContext: typeContext
      ))

    self.track(
      event: SegmentEvent.ctaClicked.rawValue,
      properties: props,
      refTag: refTag?.stringTag
    )
  }

  /* Call when the Thanks page is viewed

   parameters:
   - project: the project that was pledged to
   - reward: the reward that was chosen
   - checkoutData: all the checkout data associated with the pledge
   */

  public func trackThanksPageViewed(
    project: any ProjectAnalyticsProperties,
    reward: Reward,
    checkoutData: CheckoutPropertiesData?
  ) {
    var props = projectProperties(from: project, isBacker: true)
      .withAllValuesFrom(pledgeProperties(from: reward))
      // the context is always "newPledge" for this event
      .withAllValuesFrom(contextProperties(page: .thanks, typeContext: TypeContext.pledge(.newPledge)))

    if let checkoutData = checkoutData {
      props = props.withAllValuesFrom(checkoutProperties(from: checkoutData, and: reward))
    }

    self.track(
      event: SegmentEvent.pageViewed.rawValue,
      properties: props
    )
  }

  // MARK: - Login/Signup Events

  /**
   Call when the Login page is viewed
   */
  public func trackLoginPageViewed() {
    let props = contextProperties(page: .login)
    self.track(event: SegmentEvent.pageViewed.rawValue, properties: props)
  }

  public func trackLoginSubmitButtonClicked() {
    let props = contextProperties(ctaContext: .logInSubmit, page: .login)
    self.track(
      event: SegmentEvent.ctaClicked.rawValue,
      properties: props
    )
  }

  private func loginEventProperties(
    for intent: LoginIntent,
    project: (any ProjectAnalyticsProperties)?,
    reward: Reward?
  )
    -> [String: Any] {
    var props: [String: Any] = [:]

    if let project = project {
      props = props.withAllValuesFrom(projectProperties(from: project))
    }

    if let reward = reward {
      props = props.withAllValuesFrom(pledgeProperties(from: reward))
    }

    return props.withAllValuesFrom(["login_intent": intent.trackingString])
  }

  // MARK: - Search Events

  /// Call whenever the search view is shown.
  public func trackProjectSearchView(
    params: DiscoveryParams,
    results: Int? = nil
  ) {
    let props = discoveryProperties(from: params, results: results)
      .withAllValuesFrom(contextProperties(page: .search))

    self.track(
      event: SegmentEvent.pageViewed.rawValue,
      properties: props
    )
  }

  // MARK: - Project Page Events

  /**
   Call when a project page is viewed.

   - parameter project: The project being viewed.
   - parameter refTag: The ref tag used when opening the project.
   - parameter sectionContext: The context referring to the section of the screen being interacted with.
   */
  public func trackProjectViewed(
    _ project: any ProjectAnalyticsProperties,
    refTag: RefTag? = nil,
    sectionContext: KSRAnalytics.SectionContext
  ) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(contextProperties(page: .project, sectionContext: sectionContext))

    self.track(
      event: SegmentEvent.pageViewed.rawValue,
      properties: props,
      refTag: refTag?.stringTag
    )
  }

  /**
   Call when a project is watched/saved.
   - parameter project: The project being watched
   - parameter location: The location context of where the project is being watched from
   - parameter params: The optional Discover params if the project is being watched from Discover
   - parameter typeContext: The context of the watch/saved project
   */

  public func trackWatchProjectButtonClicked(
    project: any ProjectAnalyticsProperties,
    page: PageContext,
    params: DiscoveryParams? = nil,
    typeContext: TypeContext
  ) {
    var props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(contextProperties(
        ctaContext: .watchProject,
        page: page,
        typeContext: typeContext
      ))

    if let discoveryParams = params {
      props = props.withAllValuesFrom(discoveryProperties(from: discoveryParams))
    }

    self.track(
      event: SegmentEvent.ctaClicked.rawValue,
      properties: props
    )
  }

  /**
   Call when a user clicks creator's name on a project.

   - parameter project: The project the creator's name is clicked from.
   */

  public func trackGotoCreatorDetailsClicked(project: any HasProjectAnalyticsProperties) {
    let props = projectProperties(from: project.projectAnalyticsProperties, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(contextProperties(ctaContext: .creatorDetails, page: .project))

    self.track(
      event: SegmentEvent.ctaClicked.rawValue,
      properties: props
    )
  }

  // MARK: - Empty State Events

  // Private tracking method that merges in default properties.
  private func track(
    event: String,
    properties: [String: Any] = [:],
    refTag: String? = nil
  ) {
    guard let appTrackingTransparency = self.appTrackingTransparency else { return }

    self.appTrackingTransparency?.updateAdvertisingIdentifier()

    guard let _ = appTrackingTransparency.advertisingIdentifier else { return }

    let props = self.sessionProperties(refTag: refTag)
      .withAllValuesFrom(userProperties(for: self.loggedInUser))
      .withAllValuesFrom(properties)

    self.logEventCallback?(event, props)

    self.segmentClient?.track(
      event,
      properties: props
    )
  }

  // MARK: - Session Properties

  private func sessionProperties(
    refTag: String?,
    prefix: String = "session_"
  ) -> [String: Any] {
    var props: [String: Any] = [:]

    props["apple_pay_capable"] = AppEnvironment.current.applePayCapabilities.applePayCapable()
    props["client"] = "native"
    props["country"] = self.config?.countryCode
    props["display_language"] = AppEnvironment.current.language.rawValue
    props["device_type"] = self.device.deviceType
    props["device_orientation"] = self.deviceOrientation

    if let appBuildNumber = self.bundle.infoDictionary?["CFBundleVersion"] as? String {
      props["app_build_number"] = Int(appBuildNumber)
    }

    props["app_release_version"] = self.bundle.infoDictionary?["CFBundleShortVersionString"]
    props["is_voiceover_running"] = AppEnvironment.current.isVoiceOverRunning()
    props["os"] = "ios"
    props["platform"] = self.clientPlatform
    props["user_is_logged_in"] = self.loggedInUser != nil
    props["ref_tag"] = refTag

    return props.prefixedKeys(prefix)
  }

  private var deviceOrientation: String {
    switch self.device.orientation {
    case .faceDown:
      return "face_down"
    case .faceUp:
      return "face_up"
    case .landscapeLeft:
      return "landscape_left"
    case .landscapeRight:
      return "landscape_right"
    case .portrait:
      return "portrait"
    case .portraitUpsideDown:
      return "portrait_upside_down"
    case .unknown:
      return "unknown"
    @unknown default:
      fatalError()
    }
  }

  private var clientPlatform: String {
    switch self.device.userInterfaceIdiom {
    case .phone, .pad: return "native_ios"
    case .tv: return "tvos"
    default: return "unspecified"
    }
  }
}

// MARK: - Project Properties

private func projectProperties(
  from project: any ProjectAnalyticsProperties,
  loggedInUser: User? = nil,
  dateType: DateProtocol.Type = AppEnvironment.current.dateType,
  isBacker: Bool = false,
  calendar: Calendar = AppEnvironment.current.calendar,
  prefix: String = "project_"
) -> [String: Any] {
  var props: [String: Any] = [:]

  props["backers_count"] = project.statsBackerCount
  props["subcategory"] = project.categoryAnalyticsName
  props["country"] = project.countryCode
  props["comments_count"] = project.statsCommentsCount ?? 0
  props["currency"] = project.statsCurrency
  props["creator_uid"] = project.creatorId
  props["deadline"] = project.datesDeadline?.toISO8601DateTimeString()
  props["has_add_ons"] = project.hasAddOns
  props["launched_at"] = project.datesLaunchedAt?.toISO8601DateTimeString()
  props["name"] = project.name
  props["pid"] = String(project.id)
  props["category"] = project.categoryParentAnalyticsName
  props["category_id"] = project.categoryParentId
  props["percent_raised"] = project.statsPercentFunded
  props["current_pledge_amount"] = project.statsPledged
  props["current_amount_pledged_usd"] = rounded(project.statsTotalAmountPledgedUsdCurrency ?? 0, places: 2)
  props["goal_usd"] = rounded(project.statsGoalUsdCurrency ?? 0, places: 2)
  props["has_video"] = project.hasVideo
  props["prelaunch_activated"] = project.prelaunchActivated
  props["rewards_count"] = project.rewardsCount
  props["tags"] = project.tags?.joined(separator: ", ")
  props["updates_count"] = project.statsUpdatesCount
  props["is_repeat_creator"] = project.creatorIsRepeatCreator ?? false

  if featurePostCampaignPledgeEnabled() {
    props["late_pledge_enabled"] = project.postCampaignPledgingEnabled
    props["state"] = project.isInPostCampaignPledgingPhase
      ? "post_campaign"
      : project.stateValue
  } else {
    props["state"] = project.stateValue
  }

  let now = dateType.init().date
  props["hours_remaining"] = project.datesHoursRemaining(from: now, using: calendar)
  props["duration"] = project.datesDuration(using: calendar)

  var userProperties: [String: Any] = [:]
  userProperties["has_watched"] = project.personalizationIsStarred

  // is_backer should be false in all situations except on a new pledge on the thanks page and when a user is viewing an existing pledge
  userProperties["is_backer"] = (project.personalizationIsBacking ?? false) || isBacker

  // Only send this property if the user is logged in
  if let loggedInUser = loggedInUser {
    userProperties["is_project_creator"] = project.creatorId == String(loggedInUser.id)
  }

  let userProps = userProperties.prefixedKeys("user_")

  return props
    .withAllValuesFrom(userProps)
    .prefixedKeys(prefix)
}

private func properties(update: Update, prefix: String = "update_") -> [String: Any] {
  var properties: [String: Any] = [:]

  properties["comments_count"] = update.commentsCount
  properties["user_has_liked"] = update.hasLiked
  properties["likes_count"] = update.likesCount
  properties["published_at"] = update.publishedAt
  properties["sequence"] = update.sequence

  return properties.prefixedKeys(prefix)
}

private func properties(comment: ActivityComment, prefix: String = "comment_") -> [String: Any] {
  var properties: [String: Any] = [:]

  properties["body_length"] = comment.body.count

  return properties.prefixedKeys(prefix)
}

private func properties(userActivity: NSUserActivity) -> [String: Any] {
  var props: [String: Any] = [:]

  props["user_activity_type"] = userActivity.activityType
  props["user_activity_title"] = userActivity.title
  props["user_activity_webpage_url"] = userActivity.webpageURL?.absoluteString
  props["user_activity_keywords"] = Array(userActivity.keywords)

  return props
}

// MARK: - Pledged Project Overview Properties

private func pledgedProjectOverviewProperties(
  from properties: KSRAnalytics
    .PledgedProjectOverviewProperties
) -> [String: Any] {
  var result: [String: Any] = [:]

  result["notification_count_address_locks_soon"] = properties.addressLocksSoonCount
  result["notification_count_survey_available"] = properties.surveyAvailableCount
  result["notification_count_pledge_management"] = properties.pledgeManagementCount
  result["notification_count_payment_failed"] = properties.paymentFailedCount
  result["notification_count_card_auth_required"] = properties.cardAuthRequiredCount

  if let total = properties.total {
    result["notification_count_total"] = total
  }

  if let page = properties.page {
    result["context_page_number"] = page
  }

  return result
}

// MARK: - Pledge Properties

private func pledgeProperties(from reward: Reward, prefix: String = "pledge_backer_reward_")
  -> [String: Any] {
  var result: [String: Any] = [:]

  result["has_items"] = !reward.rewardsItems.isEmpty
  result["id"] = reward.id
  result["minimum"] = reward.minimum

  return result.prefixedKeys(prefix)
}

// MARK: - Checkout Properties

private func checkoutProperties(
  from data: KSRAnalytics.CheckoutPropertiesData,
  and reward: Reward? = nil,
  prefix: String = "checkout_"
) -> [String: Any] {
  var result: [String: Any] = [:]

  result["amount_total_usd"] = data.revenueInUsd
  result["add_ons_count_total"] = data.addOnsCountTotal
  result["add_ons_count_unique"] = data.addOnsCountUnique
  result["add_ons_minimum_usd"] = rounded(data.addOnsMinimumUsd, places: 2)
  result["bonus_amount_usd"] = data.bonusAmountInUsd
  result["id"] = data.checkoutId
  result["payment_type"] = data.paymentType
  result["reward_estimated_delivery_on"] = data.estimatedDelivery?.toISO8601DateTimeString()
  result["reward_id"] = data.rewardId
  result["reward_is_limited_quantity"] = reward?.isLimitedQuantity
  result["reward_is_limited_time"] = reward?.isLimitedTime
  result["reward_minimum_usd"] = data.rewardMinimumUsd
  result["reward_shipping_enabled"] = data.shippingEnabled
  result["reward_shipping_preference"] = reward?.shipping.preference?.trackingString
  result["reward_title"] = data.rewardTitle
  result["shipping_amount_usd"] = rounded(data.shippingAmountUsd ?? 0, places: 2)
  result["user_has_eligible_stored_apple_pay_card"] = data.userHasStoredApplePayCard

  return result.prefixedKeys(prefix)
}

// MARK: - Discovery Properties

private func discoveryProperties(
  from params: DiscoveryParams,
  results: Int? = nil,
  prefix: String = "discover_"
) -> [String: Any] {
  var result: [String: Any] = [:]

  // NB: All filters should be added here since `result["everything"]` is derived from this.

  // If a `Category`'s `parent` field is nil, use the `Category`'s name.
  result["category_name"] = params.category?.parent?.analyticsName ?? params.category?.analyticsName
  result["recommended"] = params.recommended
  result["social"] = params.social
  result["pwl"] = params.staffPicks
  result["watched"] = params.starred
  let categoryProps = params.category.map { properties(category: $0, prefix: "subcategory_") }
  let parentCategoryProps = params.category?.parent.map { properties(category: $0) }

  result = result
    .withAllValuesFrom(categoryProps ?? [:])
    .withAllValuesFrom(parentCategoryProps ?? [:])

  result["everything"] = result.isEmpty
  result["sort"] = params.sort?.trackingString
  result["ref_tag"] = RefTag.fromParams(params).stringTag
  result["search_term"] = params.query
  result["search_results_count"] = results

  return result.prefixedKeys(prefix)
}

private func properties(category: KsApi.Category, prefix: String = "category_") -> [String: Any] {
  var result: [String: Any] = [:]

  result["id"] = category.intID
  result["name"] = category.analyticsName

  return result.prefixedKeys(prefix)
}

// MARK: - Context Properties

private func contextProperties(
  ctaContext: KSRAnalytics.CTAContext? = nil,
  tabBarLabel: KSRAnalytics.TabBarItemLabel? = nil,
  page: KSRAnalytics.PageContext? = nil,
  sectionContext: KSRAnalytics.SectionContext? = nil,
  typeContext: KSRAnalytics.TypeContext? = nil,
  locationContext: KSRAnalytics.LocationContext? = nil,
  prefix: String = "context_"
) -> [String: Any] {
  var result: [String: Any] = [:]

  result["cta"] = ctaContext?.trackingString
  result["location"] = locationContext?.trackingString
  result["page"] = page?
    .rawValue ??
    "other" // Product/Insight want some event with no `context_page` to be defaulted as `other` until a context_page is defined for them.
  result["section"] = sectionContext?.trackingString
  result["tab_bar_label"] = tabBarLabel?.trackingString
  result["type"] = typeContext?.trackingString

  return result.prefixedKeys(prefix)
}

// MARK: - Interaction Properties

private func interactionProperties(
  targetUserId: String,
  prefix: String = "interaction_"
) -> [String: Any] {
  var result: [String: Any] = [:]

  result["target_uid"] = targetUserId

  return result.prefixedKeys(prefix)
}

private func properties(
  shareContext: ShareContext,
  loggedInUser: User?,
  shareActivityType: UIActivity.ActivityType? = nil
) -> [String: Any] {
  var result: [String: Any] = [:]

  result["share_activity_type"] = shareActivityType?.rawValue
  result["share_type"] = shareActivityType.flatMap(shareTypeProperty)

  switch shareContext {
  case let .discovery(project):
    result = result.withAllValuesFrom(projectProperties(from: project, loggedInUser: loggedInUser))
    result["context"] = "discovery"
  case let .project(project):
    result = result.withAllValuesFrom(projectProperties(from: project, loggedInUser: loggedInUser))
    result["context"] = "project"
  case let .thanks(project):
    result = result.withAllValuesFrom(projectProperties(from: project, loggedInUser: loggedInUser))
    result["context"] = "thanks"
  case let .update(project, update):
    result = result.withAllValuesFrom(projectProperties(from: project, loggedInUser: loggedInUser))
    result = result.withAllValuesFrom(properties(update: update))
    result["context"] = "update"
  }

  return result
}

private func shareTypeProperty(_ shareType: UIActivity.ActivityType?) -> String? {
  guard let shareType = shareType else { return nil }

  if shareType == .postToFacebook {
    return "facebook"
  } else if shareType == .message {
    return "message"
  } else if shareType == .mail {
    return "email"
  } else if shareType == .copyToPasteboard {
    return "copy link"
  } else if shareType == .postToTwitter {
    return "twitter"
  } else if shareType == UIActivity.ActivityType("com.apple.mobilenotes.SharingExtension") {
    return "notes"
  } else if shareType == SafariActivityType {
    return "safari"
  } else {
    return shareType.rawValue
  }
}

/**
 Call to get a `PageContext` value from a `TabBarItemLabel`

 - parameter from: The `TabBarItemLabel` that is being converted.

 - returns: A `PageContext` value used for analytics.
 */
private func pageContext(from tabBarItemLabel: KSRAnalytics.TabBarItemLabel) -> KSRAnalytics.PageContext? {
  switch tabBarItemLabel {
  case .activity:
    return .activities
  case .discovery:
    return .discovery
  case .profile:
    return .profile
  case .search:
    return .search
  default:
    return nil
  }
}

// MARK: - User Properties

private func userProperties(for user: User?, _ prefix: String = "user_") -> [String: Any] {
  guard let user = user else { return [:] }
  var props: [String: Any] = [:]

  props["backed_projects_count"] = user.stats.backedProjectsCount
  // the product/insights team definition of created_projects_count is the sum of createdProjectsCount and draftProjectsCount
  props["created_projects_count"] = (user.stats.createdProjectsCount ?? 0) +
    (user.stats.draftProjectsCount ?? 0)
  props["is_admin"] = user.isAdmin
  props["launched_projects_count"] = user.stats
    .createdProjectsCount // product and insights defines launched_projects_count as only the createdProjectsCount
  props["uid"] = "\(user.id)"
  props["watched_projects_count"] = user.stats.starredProjectsCount
  props["facebook_connected"] = user.facebookConnected

  return props.prefixedKeys(prefix)
}

// MARK: - Video Properties

private func videoProperties(
  videoLength: Int,
  videoPosition: Int,
  prefix: String = "video_"
) -> [String: Any] {
  var props: [String: Any] = [:]

  props["length"] = videoLength
  props["position"] = videoPosition

  return props.prefixedKeys(prefix)
}

extension KSRAnalytics {
  public enum lens {
    public static let loggedInUser = Lens<KSRAnalytics, User?>(
      view: { $0.loggedInUser },
      set: { $1.loggedInUser = $0; return $1 }
    )

    public static let config = Lens<KSRAnalytics, Config?>(
      view: { $0.config },
      set: { $1.config = $0; return $1 }
    )

    public static let appTrackingTransparency = Lens<KSRAnalytics, AppTrackingTransparencyType?>(
      view: { $0.appTrackingTransparency },
      set: { $1.appTrackingTransparency = $0; return $1 }
    )
  }
}

extension Reward.Shipping.Preference {
  fileprivate var trackingString: String {
    switch self {
    case .local: return "local"
    case .none: return "none"
    case .restricted: return "restricted"
    case .unrestricted: return "unrestricted"
    }
  }
}
