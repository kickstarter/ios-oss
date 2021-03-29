import KsApi
import PassKit
import Prelude
import Segment
import UIKit

public final class KSRAnalytics {
  private let bundle: NSBundleType
  private let dataLakeClient: TrackingClientType
  internal private(set) var config: Config?
  private let device: UIDeviceType
  private let distinctId: String
  internal private(set) var loggedInUser: User? {
    didSet {
      self.identify(self.loggedInUser)
    }
  }

  public var logEventCallback: ((String, [String: Any]) -> Void)?
  private var preferredContentSizeCategory: UIContentSizeCategory?
  private var preferredContentSizeCategoryObserver: Any?
  private let screen: UIScreenType
  private let segmentClient: TrackingClientType & IdentifyingTrackingClient

  private enum ApprovedEvent: String, CaseIterable {
    case activityFeedViewed = "Activity Feed Viewed"
    case addNewCardButtonClicked = "Add New Card Button Clicked"
    case addOnsPageViewed = "Add-Ons Page Viewed"
    case collectionViewed = "Collection Viewed"
    case continueWithAppleButtonClicked = "Continue With Apple Button Clicked"
    case fbLoginOrSignupButtonClicked = "Facebook Log In or Signup Button Clicked"
    case fixPledgeButtonClicked = "Fix Pledge Button Clicked"
    case forgotPasswordViewed = "Forgot Password Viewed"
    case loginButtonClicked = "Log In Button Clicked"
    case loginOrSignupButtonClicked = "Log In or Signup Button Clicked"
    case loginOrSignupPageViewed = "Log In or Signup Page Viewed"
    case loginSubmitButtonClicked = "Log In Submit Button Clicked"
    case managePledgeButtonClicked = "Manage Pledge Button Clicked"
    case onboardingCarouselSwiped = "Onboarding Carousel Swiped"
    case onboardingContinueButtonClicked = "Onboarding Continue Button Clicked"
    case onboardingGetStartedButtonClicked = "Onboarding Get Started Button Clicked"
    case onboardingSkipButtonClicked = "Onboarding Skip Button Clicked"
    case projectPagePledgeButtonClicked = "Project Page Pledge Button Clicked"
    case projectSwiped = "Project Swiped"
    case searchResultsLoaded = "Search Results Loaded"
    case signupButtonClicked = "Signup Button Clicked"
    case signupSubmitButtonClicked = "Signup Submit Button Clicked"
    case skipVerificationButtonClicked = "Skip Verification Button Clicked"
    case tabBarClicked = "Tab Bar Clicked"
    case twoFactorConfirmationViewed = "Two-Factor Confirmation Viewed"
    case verificationScreenViewed = "Verification Screen Viewed"
  }

  private enum NewApprovedEvent: String, CaseIterable {
    case cardClicked = "Card Clicked"
    case ctaClicked = "CTA Clicked"
    case pageViewed = "Page Viewed"
    case videoPlaybackStarted = "Video Playback Started"
  }

  /// Determines the screen from which the event is sent.
  public enum PageContext: String {
    case activities = "activity_feed" // ActivitiesViewController
    case addOnsSelection = "add_ons" // RewardAddOnSelectionViewController
    case campaign // ProjectDescriptionViewController
    case changePayment = "change_payment" // PledgeViewController
    case checkout // // PledgeViewController
    case discovery = "discover" // DiscoveryViewController
    case editorialProjects = "editorial_collection" // EditorialProjectsViewController
    case emailVerification = "email_verification" // EmailVerificationViewController
    case forgotPassword = "forgot_password" // ResetPasswordViewController
    case landingPage = "landing_page" // LandingViewController
    case login = "log_in" // LoginViewController
    case loginTout = "log_in_sign_up" // LoginToutViewController
    case managePledgeScreen = "manage_pledge" // ManagePledgeViewController
    case onboarding // CategorySelectionViewController, CuratedProjectsViewController
    case pledgeAddNewCard = "pledge_add_new_card" // AddNewCardViewController
    case pledgeScreen = "pledge" // PledgeViewController
    case projectPage = "project" // ProjectPamphletViewController
    case profile // BackerDashboardProjectsViewController
    case rewards // RewardsViewController
    case search // SearchViewController
    case settingsAddNewCard = "settings_add_new_card" // AddNewCardViewController
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
   - projectDescription: The project description page.
   - projectUpdates: The project updates page.

   **/
  public enum ExternalLinkContext {
    case projectCreator
    case projectDescription
    case projectUpdate
    case projectUpdates

    var trackingString: String {
      switch self {
      case .projectCreator:
        return "project_creator"
      case .projectDescription:
        return "project_description"
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
   Determines the type of comment in which the dialog was presented for.

   - project: A project comment.
   - update: An update comment.
   */
  public enum CommentDialogType {
    case project
    case update

    var trackingString: String {
      switch self {
      case .project: return "project"
      case .update: return "update"
      }
    }
  }

  /**
   Determines the place from which the comments were presented.

   - project: The comments for a project.
   - update: The comments for an update.
   */
  public enum CommentsContext {
    case project
    case update

    var trackingString: String {
      switch self {
      case .project: return "project"
      case .update: return "update"
      }
    }
  }

  /**
   Indicates which button or link the user has clicked or tapped; describes CTA Clicked events.
   */
  public enum CTAContext {
    case addOnsContinue
    case campaignDetails
    case creatorDetails
    case discover
    case discoverFilter
    case discoverSort
    case forgotPassword
    case logInInitiate
    case logInOrSignUp
    case logInSubmit
    case pledgeInitiate
    case pledgeSubmit
    case rewardContinue
    case search
    case signUpInitiate
    case signUpSubmit
    case watchProject

    var trackingString: String {
      switch self {
      case .addOnsContinue: return "add_ons_continue"
      case .campaignDetails: return "campaign_details"
      case .creatorDetails: return "creator_details"
      case .discover: return "discover"
      case .discoverFilter: return "discover_filter"
      case .discoverSort: return "discover_sort"
      case .forgotPassword: return "forgot_password"
      case .pledgeInitiate: return "pledge_initiate"
      case .pledgeSubmit: return "pledge_submit"
      case .logInInitiate: return "log_in_initiate"
      case .logInOrSignUp: return "log_in_or_sign_up"
      case .logInSubmit: return "log_in_submit"
      case .rewardContinue: return "reward_continue"
      case .search: return "search"
      case .signUpInitiate: return "sign_up_initiate"
      case .signUpSubmit: return "sign_up_submit"
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
    case cancelPledge
    case changePaymentMethod
    case chooseAnotherReward
    case contactCreator
    case updatePledge
    case viewRewards

    var trackingString: String {
      switch self {
      case .cancelPledge: return "cancel_pledge"
      case .changePaymentMethod: return "change_payment_method"
      case .chooseAnotherReward: return "choose_another_reward"
      case .contactCreator: return "contact_creator"
      case .updatePledge: return "update_pledge"
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
   - campaign: Details when user clicks "Read more"
   - overview: Project overview landing screen
   - updates: Section of project overview screen.
   - watched:Section of BackerDashboardProjectViewController for saved Projects
   */
  public enum SectionContext {
    case backed
    case campaign
    case comments
    case overview
    case updates
    case watched

    var trackingString: String {
      switch self {
      case .backed: return "backed"
      case .campaign: return "campaign"
      case .comments: return "comments"
      case .overview: return "overview"
      case .updates: return "updates"
      case .watched: return "watched"
      }
    }
  }

  /**
   Contextual details about an event that was fired that aren't captured in other context properties
   */
  public enum TypeContext {
    case allProjects
    case amountGoal
    case amountPledged
    case apple
    case applePay
    case backed
    case categoryName
    case creditCard
    case discovery(DiscoverySortContext)
    case facebook
    case location
    case percentRaised
    case pledge(PledgeContext)
    case project
    case projectState
    case pwl
    case recommended
    case searchTerm
    case social
    case subcategoryName
    case subscriptionFalse
    case subscriptionTrue
    case tag
    case unwatch
    case watch
    case watched

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
      case .categoryName: return "category_name"
      case .creditCard: return "credit_card"
      case let .discovery(discoveryContext): return discoveryContext.trackingString
      case .facebook: return "facebook"
      case .location: return "location"
      case .percentRaised: return "percent_raised"
      case let .pledge(pledgeContext): return pledgeContext.trackingString
      case .project: return "project"
      case .projectState: return "project_state"
      case .pwl: return "pwl"
      case .recommended: return "recommended"
      case .searchTerm: return "search_term"
      case .social: return "social"
      case .subcategoryName: return "subcategory_name"
      case .subscriptionFalse: return "subscription_false"
      case .subscriptionTrue: return "subscription_true"
      case .tag: return "tag"
      case .unwatch: return "unwatch"
      case .watch: return "watch"
      case .watched: return "watched"
      }
    }
  }

  /**
   A context providing additional details about the location the event occurs.
   */
  public enum LocationContext {
    case accountMenu
    case discoverAdvanced
    case discoverOverlay
    case globalNav
    case recommendations

    var trackingString: String {
      switch self {
      case .accountMenu: return "account_menu"
      case .discoverAdvanced: return "discover_advanced"
      case .discoverOverlay: return "discover_overlay"
      case .globalNav: return "global_nav"
      case .recommendations: return "recommendations"
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
    let addOnsMinimumUsd: String?
    let bonusAmountInUsd: String
    let checkoutId: Int?
    let estimatedDelivery: TimeInterval?
    let paymentType: String?
    let revenueInUsd: Double
    let rewardId: Int
    let rewardMinimumUsd: String
    let rewardTitle: String?
    let shippingEnabled: Bool
    let shippingAmountUsd: String?
    let userHasStoredApplePayCard: Bool
  }

  public init(
    bundle: NSBundleType = Bundle.main,
    dataLakeClient: TrackingClientType = TrackingClient(.dataLake),
    config: Config? = nil,
    device: UIDeviceType = UIDevice.current,
    loggedInUser: User? = nil,
    screen: UIScreenType = UIScreen.main,
    segmentClient: TrackingClientType & IdentifyingTrackingClient = Analytics
      .configuredClient(),
    distinctId: String = (UIDevice.current.identifierForVendor ?? UUID()).uuidString
  ) {
    self.bundle = bundle
    self.dataLakeClient = dataLakeClient
    self.config = config
    self.device = device
    self.loggedInUser = loggedInUser
    self.screen = screen
    self.segmentClient = segmentClient
    self.distinctId = distinctId

    self.updateAndObservePreferredContentSizeCategory()
  }

  /// Configure Tracking Client's supporting user identity
  private func identify(_ user: User?) {
    guard let user = user else {
      return self.segmentClient.resetIdentity()
    }

    self.segmentClient.identify(
      userId: "\(user.id)",
      traits: [
        "name": user.name,
        "is_creator": user.isCreator,
        "backed_projects_count": user.stats.backedProjectsCount ?? 0,
        "created_projects_count": user.stats.createdProjectsCount ?? 0
      ]
    )
  }

  private func updateAndObservePreferredContentSizeCategory() {
    let update = { [weak self] in
      self?.preferredContentSizeCategory = UIApplication.shared.preferredContentSizeCategory
    }

    self.preferredContentSizeCategoryObserver = NotificationCenter.default.addObserver(
      forName: UIContentSizeCategory.didChangeNotification,
      object: nil,
      queue: OperationQueue.main
    ) { _ in update() }

    if Thread.isMainThread {
      update()
    } else {
      DispatchQueue.main.async {
        update()
      }
    }
  }

  deinit {
    self.preferredContentSizeCategoryObserver.doIfSome(NotificationCenter.default.removeObserver)
  }

  // MARK: - Activity

  /// Call when the activities screen is shown.
  public func trackActivities(count: Int) {
    self.track(
      event: ApprovedEvent.activityFeedViewed.rawValue,
      page: .activities,
      properties: ["activities_count": count]
    )
  }

  /// Call when the user is logged out, on the `Activity` tab and taps the `Explore Projects`button.
  public func trackExploreButtonClicked() {
    let properties = contextProperties(ctaContext: .discover, locationContext: .globalNav)
    self.track(
      event: NewApprovedEvent.ctaClicked.rawValue,
      properties: properties
    )
  }

  // MARK: - Application Lifecycle

  public func trackTabBarClicked(_ tabBarItemLabel: TabBarItemLabel) {
    switch tabBarItemLabel {
    case .search:
      let properties = contextProperties(
        ctaContext: .search,
        locationContext: .globalNav
      )
      self.track(
        event: NewApprovedEvent.ctaClicked.rawValue,
        page: .search,
        properties: properties
      )
    default:
      let properties = contextProperties(tabBarLabel: tabBarItemLabel)
      self.track(
        event: ApprovedEvent.tabBarClicked.rawValue,
        properties: properties
      )
    }
  }

  // MARK: - Onboarding Events

  public func trackOnboardingCarouselSwiped(optimizelyProperties: [String: Any] = [:]) {
    self.track(
      event: ApprovedEvent.onboardingCarouselSwiped.rawValue,
      page: .landingPage,
      properties: optimizelyProperties
    )
  }

  public func trackOnboardingGetStartedButtonClicked(optimizelyProperties: [String: Any] = [:]) {
    self.track(
      event: ApprovedEvent.onboardingGetStartedButtonClicked.rawValue,
      page: .landingPage,
      properties: optimizelyProperties
    )
  }

  public func trackOnboardingSkipButtonClicked(optimizelyProperties: [String: Any] = [:]) {
    self.track(
      event: ApprovedEvent.onboardingSkipButtonClicked.rawValue,
      page: .onboarding,
      properties: optimizelyProperties
    )
  }

  public func trackOnboardingContinueButtonClicked(optimizelyProperties: [String: Any] = [:]) {
    self.track(
      event: ApprovedEvent.onboardingContinueButtonClicked.rawValue,
      page: .onboarding,
      properties: optimizelyProperties
    )
  }

  // MARK: - Discovery Events

  /**
   Call when a discovery page is viewed and the first page is loaded.

   - parameter params: The params used for the discovery search.
   */

  public func trackDiscovery(params: DiscoveryParams) {
    let props = discoveryProperties(from: params)

    self.track(
      event: NewApprovedEvent.pageViewed.rawValue,
      page: .discovery,
      properties: props
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
      event: NewApprovedEvent.ctaClicked.rawValue,
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
      event: NewApprovedEvent.ctaClicked.rawValue,
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
          typeContext: .discovery(discoverySortContext),
          locationContext: .discoverAdvanced
        )
      )

    self.track(
      event: NewApprovedEvent.ctaClicked.rawValue,
      page: .discovery,
      properties: props
    )
  }

  /**
   Call when the user taps the editorial header at the top of Discovery
   */
  public func trackEditorialHeaderTapped(params: DiscoveryParams,
                                         refTag: RefTag) {
    let props = contextProperties(
      page: .discovery,
      typeContext: .project,
      locationContext: .discoverAdvanced
    )
    .withAllValuesFrom(discoveryProperties(from: params))

    self.track(
      event: NewApprovedEvent.cardClicked.rawValue,
      properties: props,
      refTag: refTag.stringTag
    )
  }

  /**
   Call when a collection is viewed

   - parameter params: The DiscoveryParams associated with the collection
   */
  public func trackCollectionViewed(params: DiscoveryParams) {
    self.track(
      event: ApprovedEvent.collectionViewed.rawValue,
      page: .editorialProjects,
      properties: discoveryProperties(from: params)
    )
  }

  /**
   Call when a project card is clicked from a list of projects
   - parameter page: The `PageContext` representing the specific area the UI is interacted in
   - parameter checkoutData: The `CheckoutPropertiesData` associated with this specific checkout instance
   - parameter project: The `Project` corresponding to the card that was clicked
   - parameter location: The optional `LocationContext` representing additional details of the UI interaction
   - parameter params: The optional `DiscoveryParams  ` associated with the list of projects
   - parameter reward: The optional `Reward  ` for the selected `Project`
   - parameter section: The optional `SectionContext  ` representing the grouping of content
   */

  public func trackProjectCardClicked(page: PageContext,
                                      project: Project,
                                      checkoutData: CheckoutPropertiesData? = nil,
                                      location: LocationContext? = nil,
                                      params: DiscoveryParams? = nil,
                                      reward: Reward? = nil,
                                      section: SectionContext? = nil) {
    var props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(contextProperties(
        sectionContext: section,
        typeContext: .project,
        locationContext: location
      ))

    if let checkoutProps = checkoutData {
      props = props.withAllValuesFrom(checkoutProperties(from: checkoutProps, and: reward))
    }

    if let discoveryParams = params {
      props = props.withAllValuesFrom(discoveryProperties(from: discoveryParams))
    }

    self.track(
      event: NewApprovedEvent.cardClicked.rawValue,
      page: page,
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
    project: Project,
    videoLength: Int,
    videoPosition: Int
  ) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(videoProperties(videoLength: videoLength, videoPosition: videoPosition))

    self.track(
      event: NewApprovedEvent.videoPlaybackStarted.rawValue,
      page: .projectPage,
      properties: props
    )
  }

  // MARK: - Pledge Events

  public func trackAddOnsContinueButtonClicked(
    project: Project,
    reward: Reward,
    checkoutData: CheckoutPropertiesData,
    refTag: RefTag?
  ) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(contextProperties(ctaContext: .addOnsContinue))
      .withAllValuesFrom(checkoutProperties(from: checkoutData, and: reward))
    self.track(
      event: NewApprovedEvent.ctaClicked.rawValue,
      properties: props,
      refTag: refTag?.stringTag
    )
  }

  public func trackAddOnsPageViewed(
    project: Project,
    reward: Reward,
    checkoutData: CheckoutPropertiesData,
    refTag: RefTag?
  ) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(checkoutProperties(from: checkoutData, and: reward))

    self.track(
      event: NewApprovedEvent.pageViewed.rawValue,
      page: .addOnsSelection,
      properties: props,
      refTag: refTag?.stringTag
    )
  }

  public func trackPledgeCTAButtonClicked(
    stateType: PledgeStateCTAType,
    project: Project,
    optimizelyProperties _: [String: Any] = [:]
  ) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)

    switch stateType {
    case .fix:
      self.track(
        event: ApprovedEvent.managePledgeButtonClicked.rawValue,
        page: .projectPage,
        properties: props.withAllValuesFrom(contextProperties()) // .fixErroredPledge
      )
    case .pledge:
      let allProps = props
        .withAllValuesFrom(optimizelyProperties() ?? [:])
        .withAllValuesFrom(contextProperties(ctaContext: .pledgeInitiate))

      self.track(
        event: NewApprovedEvent.ctaClicked.rawValue,
        page: .projectPage,
        properties: allProps
      )
    case .manage:
      self.track(
        event: ApprovedEvent.managePledgeButtonClicked.rawValue,
        page: .projectPage,
        properties: props.withAllValuesFrom(contextProperties()) // .manageReward
      )
    default:
      return
    }
  }

  public func trackFixPledgeButtonClicked(project: Project) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(contextProperties())

    self.track(
      event: ApprovedEvent.fixPledgeButtonClicked.rawValue,
      page: .managePledgeScreen,
      properties: props
    )
  }

  public func trackManagePledgePageViewed(
    project: Project,
    reward: Reward,
    checkoutData: CheckoutPropertiesData
  ) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(checkoutProperties(from: checkoutData, and: reward))

    self.track(
      event: NewApprovedEvent.pageViewed.rawValue,
      page: .managePledgeScreen,
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
    project: Project,
    reward: Reward,
    checkoutPropertiesData: KSRAnalytics.CheckoutPropertiesData,
    refTag: RefTag?
  ) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(contextProperties(ctaContext: .rewardContinue))
      .withAllValuesFrom(checkoutProperties(from: checkoutPropertiesData, and: reward))

    self.track(
      event: NewApprovedEvent.ctaClicked.rawValue,
      page: .rewards,
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
    project: Project,
    checkoutPropertiesData: KSRAnalytics.CheckoutPropertiesData,
    refTag: RefTag?
  ) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(checkoutProperties(from: checkoutPropertiesData))

    self.track(
      event: NewApprovedEvent.pageViewed.rawValue,
      page: .rewards,
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
    project: Project,
    reward: Reward,
    pledgeViewContext: PledgeViewContext,
    checkoutData: CheckoutPropertiesData,
    refTag: RefTag?
  ) {
    var props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(checkoutProperties(from: checkoutData, and: reward))

    switch pledgeViewContext {
    case .pledge:
      props = props.withAllValuesFrom(contextProperties(page: .checkout))
    case .changePaymentMethod:
      props = props.withAllValuesFrom(contextProperties(page: .changePayment))
    case .update, .updateReward:
      props = props.withAllValuesFrom(contextProperties(page: .updatePledge))
    default:
      return
    }

    self.track(
      event: NewApprovedEvent.pageViewed.rawValue,
      properties: props,
      refTag: refTag?.stringTag
    )
  }

  /* Call when the Pledge button is clicked

   parameters:
   - project: the project being pledged to
   - reward: the chosen reward
   - checkoutData: all the checkout data associated with the pledge
   - refTag: the associated RefTag for the pledge

   */

  public func trackPledgeSubmitButtonClicked(
    project: Project,
    reward: Reward,
    checkoutData: CheckoutPropertiesData,
    refTag: RefTag?
  ) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(checkoutProperties(from: checkoutData, and: reward))
      // the context is always "newPledge" for this event
      .withAllValuesFrom(contextProperties(ctaContext: .pledgeSubmit, typeContext: .creditCard))

    self.track(
      event: NewApprovedEvent.ctaClicked.rawValue,
      page: .pledgeScreen,
      properties: props,
      refTag: refTag?.stringTag
    )
  }

  /* Call when the Add New Card button is clicked from the pledge screen

   parameters:
   - project: the project that is being pledged to
   - reward: the reward that was chosen for the pledge
   - context: the PledgeContext from which the event was triggered
   */

  public func trackAddNewCardButtonClicked(
    location: KSRAnalytics.PageContext? = nil,
    project: Project,
    refTag: RefTag?,
    reward: Reward
  ) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(pledgeProperties(from: reward))
      .withAllValuesFrom(contextProperties())

    self.track(
      event: ApprovedEvent.addNewCardButtonClicked.rawValue,
      page: location,
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
    project: Project,
    reward: Reward,
    checkoutData: CheckoutPropertiesData?
  ) {
    var props = projectProperties(from: project)
      .withAllValuesFrom(pledgeProperties(from: reward))
      // the context is always "newPledge" for this event
      .withAllValuesFrom(contextProperties(typeContext: TypeContext.pledge(.newPledge)))

    if let checkoutData = checkoutData {
      props = props.withAllValuesFrom(checkoutProperties(from: checkoutData, and: reward))
    }

    self.track(
      event: NewApprovedEvent.pageViewed.rawValue,
      page: .thanks,
      properties: props
    )
  }

  /** Call when the Manage button is tapped on the activity feed to fix an errored pledge.

   - parameter project: the project that was pledged to.
   */
  public func trackActivitiesManagePledgeButtonClicked(project: Project) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      // the context is always "fixErroredPledge" for this event
      .withAllValuesFrom(contextProperties())
    self.track(
      event: ApprovedEvent.managePledgeButtonClicked.rawValue,
      page: .activities,
      properties: props
    )
  }

  // MARK: - Login/Signup Events

  /* Call when the Login or Signup button entry-point is tapped

   parameters:
   - intent: the LoginIntent associated with the login/signup attempt
   - project: if the login attempt is made from the checkout flow, the associated project
   - reward: if the login attempt is made from the checkout flow, the associated selected reward
   */

  public func trackLoginOrSignupButtonClicked(
    intent: LoginIntent,
    project: Project? = nil,
    reward: Reward? = nil
  ) {
    let props = self.loginEventProperties(for: intent, project: project, reward: reward)

    self.track(
      event: ApprovedEvent.loginOrSignupButtonClicked.rawValue,
      page: .discovery,
      properties: props
    )
  }

  /* Call when the Login/Signup page is viewed

   parameters:
   - intent: the LoginIntent associated with the login/signup attempt
   - project: if the login attempt is made from the checkout flow, the associated project
   - reward: if the login attempt is made from the checkout flow, the associated selected reward
   */
  public func trackLoginOrSignupPageViewed(
    intent: LoginIntent,
    project: Project? = nil,
    reward: Reward? = nil
  ) {
    let props = self.loginEventProperties(for: intent, project: project, reward: reward)

    self.track(
      event: ApprovedEvent.loginOrSignupPageViewed.rawValue,
      page: .loginTout,
      properties: props
    )
  }

  /* Call when the Log In button is tapped on the Login/Signup Page

   parameters:
   - intent: the LoginIntent associated with the login/signup attempt
   - project: if the login attempt is made from the checkout flow, the associated project
   - reward: if the login attempt is made from the checkout flow, the associated selected reward
   */

  public func trackLoginButtonClicked(
    intent: LoginIntent,
    project: Project? = nil,
    reward: Reward? = nil
  ) {
    let props = self.loginEventProperties(for: intent, project: project, reward: reward)

    self.track(
      event: ApprovedEvent.loginButtonClicked.rawValue,
      page: .loginTout,
      properties: props
    )
  }

  /* Call when the "Log in with Facebook" button is tapped on the Login/Signup Page

   parameters:
   - intent: the LoginIntent associated with the login/signup attempt
   - project: if the login attempt is made from the checkout flow, the associated project
   - reward: if the login attempt is made from the checkout flow, the associated selected reward
   */

  public func trackFacebookLoginOrSignupButtonClicked(
    intent: LoginIntent,
    project: Project? = nil,
    reward: Reward? = nil
  ) {
    let props = self.loginEventProperties(for: intent, project: project, reward: reward)

    self.track(
      event: ApprovedEvent.fbLoginOrSignupButtonClicked.rawValue,
      page: .loginTout,
      properties: props
    )
  }

  /* Call when the "Continue with Apple" button is tapped on the Login/Signup Page

   parameters:
   - intent: the LoginIntent associated with the login/signup attempt
   - project: if the login attempt is made from the checkout flow, the associated project
   - reward: if the login attempt is made from the checkout flow, the associated selected reward
   */

  public func trackContinueWithAppleButtonClicked(
    intent: LoginIntent,
    project: Project? = nil,
    reward: Reward? = nil
  ) {
    let props = self.loginEventProperties(for: intent, project: project, reward: reward)

    self.track(
      event: ApprovedEvent.continueWithAppleButtonClicked.rawValue,
      page: .loginTout,
      properties: props
    )
  }

  /* Call when the "Sign up" button is tapped on the Login/Signup Page

   parameters:
   - intent: the LoginIntent associated with the login/signup attempt
   - project: if the login attempt is made from the checkout flow, the associated project
   - reward: if the login attempt is made from the checkout flow, the associated selected reward
   */

  public func trackSignupButtonClicked(
    intent: LoginIntent,
    project: Project? = nil,
    reward: Reward? = nil
  ) {
    let props = self.loginEventProperties(for: intent, project: project, reward: reward)

    self.track(
      event: ApprovedEvent.signupButtonClicked.rawValue,
      page: .loginTout,
      properties: props
    )
  }

  public func trackSignupSubmitButtonClicked() {
    self.track(event: ApprovedEvent.signupSubmitButtonClicked.rawValue, page: .signup)
  }

  public func trackLoginSubmitButtonClicked() {
    self.track(event: ApprovedEvent.loginSubmitButtonClicked.rawValue, page: .login)
  }

  public func trackForgotPasswordViewed() {
    self.track(event: ApprovedEvent.forgotPasswordViewed.rawValue, page: .forgotPassword)
  }

  public func track2FAViewed() {
    self.track(event: ApprovedEvent.twoFactorConfirmationViewed.rawValue, page: .twoFactorAuth)
  }

  private func loginEventProperties(for intent: LoginIntent, project: Project?, reward: Reward?)
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

    self.track(
      event: NewApprovedEvent.pageViewed.rawValue,
      page: .search,
      properties: props
    )
  }

  // Call when projects have been obtained from a search.
  public func trackSearchResults(
    query: String,
    params: DiscoveryParams,
    refTag: RefTag,
    hasResults: Bool
  ) {
    let props = discoveryProperties(from: params)
      .withAllValuesFrom([
        "discover_ref_tag": refTag.stringTag,
        "search_term": query,
        "has_results": hasResults
      ])

    self.track(
      event: ApprovedEvent.searchResultsLoaded.rawValue,
      page: .search,
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
    _ project: Project,
    refTag: RefTag? = nil,
    sectionContext: KSRAnalytics.SectionContext
  ) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(contextProperties(sectionContext: sectionContext))

    self.track(
      event: NewApprovedEvent.pageViewed.rawValue,
      page: .projectPage,
      properties: props,
      refTag: refTag?.stringTag
    )
  }

  /**
   Call when a project page is swiped to the next project.
   - parameter project:      The next project being viewed.
   - parameter refTag:       The ref tag used when swiping to the project.
   */
  public func trackSwipedProject(_ project: Project, refTag: RefTag?) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)

    self.track(
      event: ApprovedEvent.projectSwiped.rawValue,
      page: .projectPage,
      properties: props, refTag: refTag?.stringTag
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
    project: Project,
    location: PageContext,
    params: DiscoveryParams? = nil,
    typeContext: TypeContext
  ) {
    var props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(contextProperties(
        ctaContext: .watchProject,
        typeContext: typeContext
      ))

    if let discoveryParams = params {
      props = props.withAllValuesFrom(discoveryProperties(from: discoveryParams))
    }

    self.track(
      event: NewApprovedEvent.ctaClicked.rawValue,
      page: location,
      properties: props
    )
  }

  /**
   Call when a user clicks creator's name on a project.

   - parameter project: The project the creator's name is clicked from.
   */

  public func trackGotoCreatorDetailsClicked(project: Project) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(contextProperties(ctaContext: .creatorDetails, page: .projectPage))

    self.track(
      event: NewApprovedEvent.ctaClicked.rawValue,
      properties: props
    )
  }

  // MARK: - Email Verification

  public func trackEmailVerificationScreenViewed() {
    self.track(
      event: ApprovedEvent.verificationScreenViewed.rawValue,
      page: .emailVerification
    )
  }

  public func trackSkipEmailVerificationButtonClicked() {
    self.track(
      event: ApprovedEvent.skipVerificationButtonClicked.rawValue,
      page: .emailVerification
    )
  }

  // MARK: - Empty State Events

  // Private tracking method that merges in default properties.
  private func track(
    event: String,
    page: KSRAnalytics.PageContext? = nil,
    properties: [String: Any] = [:],
    refTag: String? = nil
  ) {
    let props = self.sessionProperties(refTag: refTag)
      .withAllValuesFrom(userProperties(for: self.loggedInUser, config: self.config))
      .withAllValuesFrom(contextProperties(page: page))
      .withAllValuesFrom(properties)

    self.logEventCallback?(event, props)

    self.dataLakeClient.track(
      event: event,
      properties: props
    )

    // Currently events approved for the Data Lake are good for Segment.
    self.segmentClient.track(
      event: event,
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
    props["current_variants"] = self.config?.abExperimentsArray.sorted()
    props["display_language"] = AppEnvironment.current.language.rawValue

    props["device_type"] = self.device.deviceType
    props["device_manufacturer"] = "Apple"
    props["device_model"] = KSRAnalytics.deviceModel
    props["device_orientation"] = self.deviceOrientation
    props["device_distinct_id"] = self.distinctId

    props["app_build_number"] = self.bundle.infoDictionary?["CFBundleVersion"]
    props["app_release_version"] = self.bundle.infoDictionary?["CFBundleShortVersionString"]
    props["is_voiceover_running"] = AppEnvironment.current.isVoiceOverRunning()
    props["os"] = self.device.systemName
    props["os_version"] = self.device.systemVersion
    props["platform"] = self.clientPlatform
    props["screen_width"] = UInt(self.screen.bounds.width)
    props["user_agent"] = Service.userAgent
    props["user_logged_in"] = self.loggedInUser != nil

    props["ref_tag"] = refTag

    return props.prefixedKeys(prefix)
  }

  private static let deviceModel: String? = {
    var size: Int = 0
    sysctlbyname("hw.machine", nil, &size, nil, 0)
    var machine = [CChar](repeating: 0, count: Int(size))
    sysctlbyname("hw.machine", &machine, &size, nil, 0)
    return String(cString: machine)
  }()

  private var deviceOrientation: String {
    switch self.device.orientation {
    case .faceDown:
      return "Face Down"
    case .faceUp:
      return "Face Up"
    case .landscapeLeft:
      return "Landscape Left"
    case .landscapeRight:
      return "Landscape Right"
    case .portrait:
      return "Portrait"
    case .portraitUpsideDown:
      return "Portrait Upside Down"
    case .unknown:
      return "Unknown"
    @unknown default:
      fatalError()
    }
  }

  private var clientPlatform: String {
    switch self.device.userInterfaceIdiom {
    case .phone, .pad: return "ios"
    case .tv: return "tvos"
    default: return "unspecified"
    }
  }
}

// MARK: - Project Properties

private func projectProperties(
  from project: Project,
  loggedInUser: User? = nil,
  dateType: DateProtocol.Type = AppEnvironment.current.dateType,
  calendar: Calendar = AppEnvironment.current.calendar,
  prefix: String = "project_"
) -> [String: Any] {
  var props: [String: Any] = [:]

  props["backers_count"] = project.stats.backersCount
  props["subcategory"] = project.category.name
  props["country"] = project.country.countryCode
  props["comments_count"] = project.stats.commentsCount ?? 0
  props["currency"] = project.country.currencyCode
  props["creator_uid"] = project.creator.id
  props["deadline"] = ISO8601DateFormatter().string(from: Date(timeIntervalSince1970: project.dates.deadline))
  props["has_add_ons"] = project.hasAddOns
  props["launched_at"] = project.dates.launchedAt
  props["name"] = project.name
  props["pid"] = project.id
  props["category"] = project.category.parentName
  props["category_id"] = project.category.parentId
  props["percent_raised"] = project.stats.fundingProgress
  props["state"] = project.state.rawValue
  props["current_pledge_amount"] = project.stats.pledged
  props["current_amount_pledged_usd"] = project.stats.pledgedUsd
  props["goal_usd"] = project.stats.goalUsd
  props["has_video"] = project.video != nil
  props["prelaunch_activated"] = project.prelaunchActivated
  props["rewards_count"] = project.rewards.count
  props["tags"] = project.tags?.joined(separator: ", ")
  props["updates_count"] = project.stats.updatesCount

  let now = dateType.init().date
  props["hours_remaining"] = project.dates.hoursRemaining(from: now, using: calendar)
  props["duration"] = project.dates.duration(using: calendar)

  var userProperties: [String: Any] = [:]
  userProperties["has_watched"] = project.personalization.isStarred
  userProperties["is_backer"] = project.personalization.isBacking
  userProperties["is_project_creator"] = project.creator.id == loggedInUser?.id

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

private func properties(comment: Comment, prefix: String = "comment_") -> [String: Any] {
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

private func checkoutProperties(from data: KSRAnalytics.CheckoutPropertiesData, and reward: Reward? = nil,
                                prefix: String = "checkout_")
  -> [String: Any] {
  var result: [String: Any] = [:]

  result["amount_total_usd"] = data.revenueInUsd
  result["add_ons_count_total"] = data.addOnsCountTotal
  result["add_ons_count_unique"] = data.addOnsCountUnique
  result["add_ons_minimum_usd"] = data.addOnsMinimumUsd
  result["bonus_amount_usd"] = data.bonusAmountInUsd
  result["id"] = data.checkoutId
  result["payment_type"] = data.paymentType
  result["reward_estimated_delivery_on"] = data.estimatedDelivery
  result["reward_id"] = data.rewardId
  result["reward_is_limited_quantity"] = reward?.isLimitedQuantity
  result["reward_is_limited_time"] = reward?.isLimitedTime
  result["reward_minimum_usd"] = data.rewardMinimumUsd
  result["reward_shipping_enabled"] = data.shippingEnabled
  result["reward_shipping_preference"] = reward?.shipping.preference?.trackingString
  result["reward_title"] = data.rewardTitle
  result["shipping_amount_usd"] = data.shippingAmountUsd
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
  result["category_name"] = params.category?.name
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
  result["name"] = category.name

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
  result["page"] = page?.rawValue
  result["section"] = sectionContext?.trackingString
  result["tab_bar_label"] = tabBarLabel?.trackingString
  result["type"] = typeContext?.trackingString

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
  case let .creatorDashboard(project):
    result = result.withAllValuesFrom(projectProperties(from: project, loggedInUser: loggedInUser))
    result["context"] = "creator_dashboard"
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

// MARK: - User Properties

private func userProperties(for user: User?, config _: Config?, _ prefix: String = "user_") -> [String: Any] {
  var props: [String: Any] = [:]

  props["backed_projects_count"] = user?.stats.backedProjectsCount
  props["created_projects_count"] = user?.stats.createdProjectsCount
  props["is_admin"] = user?.isAdmin
  props["launched_projects_count"] = user?.stats.memberProjectsCount
  props["uid"] = user?.id
  props["watched_projects_count"] = user?.stats.starredProjectsCount

  return props.prefixedKeys(prefix)
}

// MARK: - Video Properties

private func videoProperties(videoLength: Int, videoPosition: Int,
                             prefix: String = "video_") -> [String: Any] {
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
  }
}

extension Reward.Shipping.Preference {
  fileprivate var trackingString: String {
    switch self {
    case .none: return "none"
    case .restricted: return "restricted"
    case .unrestricted: return "unrestricted"
    }
  }
}
