import KsApi
import PassKit
import Prelude
import UIKit

private let deprecatedProps = [Koala.DeprecatedKey: true]

public final class Koala {
  internal static let DeprecatedKey = "DEPRECATED"

  private let bundle: NSBundleType
  private let dataLakeClient: TrackingClientType
  private let koalaClient: TrackingClientType
  internal private(set) var config: Config?
  private let device: UIDeviceType
  private let distinctId: String
  internal private(set) var loggedInUser: User?
  public var logEventCallback: ((String, [String: Any]) -> Void)?
  private var preferredContentSizeCategory: UIContentSizeCategory?
  private var preferredContentSizeCategoryObserver: Any?
  private let screen: UIScreenType

  private enum DataLakeApprovedEvent: String, CaseIterable {
    case activityFeedViewed = "Activity Feed Viewed"
    case addNewCardButtonClicked = "Add New Card Button Clicked"
    case campaignDetailsButtonClicked = "Campaign Details Button Clicked"
    case campaignDetailsPledgeButtonClicked = "Campaign Details Pledge Button Clicked"
    case creatorDetailsClicked = "Creator Details Clicked"
    case checkoutPaymentPageViewed = "Checkout Payment Page Viewed"
    case collectionViewed = "Collection Viewed"
    case continueWithAppleButtonClicked = "Continue With Apple Button Clicked"
    case editorialCardClicked = "Editorial Card Clicked"
    case explorePageViewed = "Explore Page Viewed"
    case exploreSortClicked = "Explore Sort Clicked"
    case fbLoginOrSignupButtonClicked = "Facebook Log In or Signup Button Clicked"
    case filterClicked = "Filter Clicked"
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
    case pledgeSubmitButtonClicked = "Pledge Submit Button Clicked"
    case projectCardClicked = "Project Card Clicked"
    case projectPagePledgeButtonClicked = "Project Page Pledge Button Clicked"
    case projectPageViewed = "Project Page Viewed"
    case projectSwiped = "Project Swiped"
    case searchPageViewed = "Search Page Viewed"
    case searchResultsLoaded = "Search Results Loaded"
    case selectRewardButtonClicked = "Select Reward Button Clicked"
    case signupButtonClicked = "Signup Button Clicked"
    case signupSubmitButtonClicked = "Signup Submit Button Clicked"
    case tabBarClicked = "Tab Bar Clicked"
    case thanksPageViewed = "Thanks Page Viewed"
    case twoFactorConfirmationViewed = "Two-Factor Confirmation Viewed"
    case watchProjectButtonClicked = "Watch Project Button Clicked"

    static func allApprovedEvents() -> [String] {
      return DataLakeApprovedEvent.allCases.map { $0.rawValue }
    }
  }

  /// Determines the screen from which the event is sent.
  public enum LocationContext: String {
    case activities = "activity_feed_screen" // ActivitiesViewController
    case campaign = "campaign_screen" // ProjectDescriptionViewController
    case discovery = "explore_screen" // DiscoveryViewController
    case editorialProjects = "editorial_collection_screen" // EditorialProjectsViewController
    case forgotPassword = "forgot_password_screen" // ResetPasswordViewController
    case landingPage = "landing_page" // LandingViewController
    case login = "login_screen" // LoginViewController
    case loginTout = "login_or_signup_screen" // LoginToutViewController
    case managePledgeScreen = "manage_pledge_screen" // ManagePledgeViewController
    case onboarding // CategorySelectionViewController, CuratedProjectsViewController
    case pledgeAddNewCard = "pledge_add_new_card_screen" // AddNewCardViewController
    case pledgeScreen = "pledge_screen" // PledgeViewController
    case projectPage = "project_screen" // ProjectPamphletViewController
    case rewards = "rewards_screen" // RewardsViewController
    case search = "search_screen" // SearchViewController
    case settingsAddNewCard = "settings_add_new_card_screen" // AddNewCardViewController
    case signup = "sign_up" // SignupViewController
    case thanks = "thanks_screen" // ThanksViewController
    case twoFactorAuth = "two_factor_auth_verify_screen" // TwoFactorViewController
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

  /**
   Describes a flow of pledging.

   - changeReward: changing your current reward to a different reward
   - manageReward: changing the details of the current reward you are backing (e.g. amount, shipping)
   - newPledge:    pledging to the project without an existing backing
   */
  public enum PledgeContext {
    case fixErroredPledge
    case changeReward
    case manageReward
    case newPledge

    var trackingString: String {
      switch self {
      case .fixErroredPledge: return "fix_errored_pledge"
      case .changeReward: return "change_reward"
      case .manageReward: return "manage_reward"
      case .newPledge: return "new_pledge"
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
    let amount: String
    let checkoutId: Int?
    let estimatedDelivery: TimeInterval?
    let paymentType: String?
    let revenueInUsdCents: Int
    let rewardId: Int
    let rewardTitle: String?
    let shippingEnabled: Bool
    let shippingAmount: Double?
    let userHasStoredApplePayCard: Bool
  }

  public init(
    bundle: NSBundleType = Bundle.main,
    dataLakeClient: TrackingClientType = TrackingClient(.dataLake),
    client: TrackingClientType = TrackingClient(.koala),
    config: Config? = nil,
    device: UIDeviceType = UIDevice.current,
    loggedInUser: User? = nil,
    screen: UIScreenType = UIScreen.main,
    distinctId: String = (UIDevice.current.identifierForVendor ?? UUID()).uuidString
  ) {
    self.bundle = bundle
    self.dataLakeClient = dataLakeClient
    self.koalaClient = client
    self.config = config
    self.device = device
    self.loggedInUser = loggedInUser
    self.screen = screen
    self.distinctId = distinctId

    self.updateAndObservePreferredContentSizeCategory()
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
      event: DataLakeApprovedEvent.activityFeedViewed.rawValue,
      location: .activities,
      properties: ["activities_count": count]
    )
  }

  // MARK: - Application Lifecycle

  /// Call when the app launches or enters foreground.
  public func trackAppOpen() {
    let props: [String: Any] = [
      "badge_count": UIApplication.shared.applicationIconBadgeNumber
    ]

    self.track(event: "App Open", properties: props.withAllValuesFrom(deprecatedProps))
    self.track(event: "Opened App")
  }

  public func trackMemoryWarning() {
    self.track(event: "App Memory Warning")
  }

  public func trackCrashedApp() {
    self.track(event: "Crashed App")
  }

  public func trackNotificationOpened() {
    let props: [String: Any] = [
      "notification_type": "push"
    ]

    self.track(
      event: "Notification Opened",
      properties: props.withAllValuesFrom(deprecatedProps)
    )

    self.track(event: "Opened Notification", properties: props)
  }

  public func trackOpenedAppBanner(_ queryParams: [String: String]) {
    let props: [String: Any] = queryParams

    self.track(
      event: "Smart App Banner Opened",
      properties: props.withAllValuesFrom(deprecatedProps)
    )

    self.track(event: "Opened App Banner", properties: props)
  }

  public func trackUserActivity(_ userActivity: NSUserActivity) {
    let props = properties(userActivity: userActivity)

    self.track(
      event: "Continue User Activity",
      properties: props.withAllValuesFrom(deprecatedProps)
    )

    self.track(event: "Opened Deep Link", properties: props)
  }

  public func trackTabBarClicked(_ tabBarItemLabel: TabBarItemLabel) {
    let properties = contextProperties(pledgeFlowContext: nil, tabBarLabel: tabBarItemLabel)

    self.track(
      event: DataLakeApprovedEvent.tabBarClicked.rawValue,
      properties: properties
    )
  }

  // MARK: - Onboarding Events

  public func trackOnboardingCarouselSwiped(optimizelyProperties: [String: Any] = [:]) {
    self.track(
      event: DataLakeApprovedEvent.onboardingCarouselSwiped.rawValue,
      location: .landingPage,
      properties: optimizelyProperties
    )
  }

  public func trackOnboardingGetStartedButtonClicked(optimizelyProperties: [String: Any] = [:]) {
    self.track(
      event: DataLakeApprovedEvent.onboardingGetStartedButtonClicked.rawValue,
      location: .landingPage,
      properties: optimizelyProperties
    )
  }

  public func trackOnboardingSkipButtonClicked(optimizelyProperties: [String: Any] = [:]) {
    self.track(
      event: DataLakeApprovedEvent.onboardingSkipButtonClicked.rawValue,
      location: .onboarding,
      properties: optimizelyProperties
    )
  }

  public func trackOnboardingContinueButtonClicked(optimizelyProperties: [String: Any] = [:]) {
    self.track(
      event: DataLakeApprovedEvent.onboardingContinueButtonClicked.rawValue,
      location: .onboarding,
      properties: optimizelyProperties
    )
  }

  // MARK: - Discovery Events

  /**
   Call when a discovery page is viewed and the first page is loaded.

   - parameter params: The params used for the discovery search.
   */

  public func trackDiscovery(params: DiscoveryParams,
                             optimizelyProperties: [String: Any] = [:]) {
    let props = discoveryProperties(from: params)
      .withAllValuesFrom(optimizelyProperties)

    self.track(
      event: DataLakeApprovedEvent.explorePageViewed.rawValue,
      location: .discovery,
      properties: props
    )
  }

  /**
   Call when a filter is selected from the Explore modal.

   - parameter params: The params selected from the modal.
   */
  public func trackDiscoveryModalSelectedFilter(params: DiscoveryParams) {
    self.track(
      event: DataLakeApprovedEvent.filterClicked.rawValue,
      location: .discovery,
      properties: discoveryProperties(from: params)
    )
  }

  /**
   Call when the user swipes between sorts or selects a sort.

   - parameter sort: The new sort that was selected.
   */
  public func trackDiscoverySelectedSort(nextSort sort: DiscoveryParams.Sort, params: DiscoveryParams) {
    let props = discoveryProperties(from: params)
      .withAllValuesFrom([
        "discover_sort": sort.rawValue
      ])

    self.track(
      event: DataLakeApprovedEvent.exploreSortClicked.rawValue,
      location: .discovery,
      properties: props
    )
  }

  /**
   Call when the user taps the editorial header at the top of Discovery
   */
  public func trackEditorialHeaderTapped(params: DiscoveryParams,
                                         refTag: RefTag,
                                         optimizelyProperties: [String: Any] = [:]) {
    let props = discoveryProperties(from: params)
      .withAllValuesFrom(optimizelyProperties)

    self.track(
      event: DataLakeApprovedEvent.editorialCardClicked.rawValue,
      location: .discovery,
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
      event: DataLakeApprovedEvent.collectionViewed.rawValue,
      location: .editorialProjects,
      properties: discoveryProperties(from: params)
    )
  }

  /**
   Call when a project card is clicked from a list of projects
   - parameter project: the Project corresponding to the card that was clicked
   - parameter params: the DiscoveryParams associated with the list of projects
   - parameter location: the location context of the event
   */

  public func trackProjectCardClicked(project: Project,
                                      params: DiscoveryParams,
                                      location: LocationContext,
                                      optimizelyProperties: [String: Any] = [:]) {
    let props = discoveryProperties(from: params)
      .withAllValuesFrom(projectProperties(from: project, loggedInUser: self.loggedInUser))
      .withAllValuesFrom(optimizelyProperties)

    self.track(
      event: DataLakeApprovedEvent.projectCardClicked.rawValue,
      location: location,
      properties: props
    )
  }

  // MARK: - Pledge Events

  public func trackPledgeCTAButtonClicked(
    stateType: PledgeStateCTAType,
    project: Project,
    optimizelyProperties: [String: Any] = [:]
  ) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)

    switch stateType {
    case .fix:
      self.track(
        event: DataLakeApprovedEvent.managePledgeButtonClicked.rawValue,
        location: .projectPage,
        properties: props.withAllValuesFrom(contextProperties(pledgeFlowContext: .fixErroredPledge))
      )
    case .pledge, .seeTheRewards, .viewTheRewards:
      let allProps = props
        .withAllValuesFrom(optimizelyProperties)

      self.track(
        event: DataLakeApprovedEvent.projectPagePledgeButtonClicked.rawValue,
        location: .projectPage,
        properties: allProps
      )
    case .manage:
      self.track(event: "Manage Pledge Button Clicked", properties: props)
    case .viewBacking:
      self.track(event: "View Your Pledge Button Clicked", properties: props)
    case .viewRewards:
      self.track(event: "View Rewards Button Clicked", properties: props)
    case .viewYourRewards:
      self.track(event: "View Your Rewards Button Clicked", properties: props)
    }
  }

  public func trackCancelPledgeButtonClicked(project: Project, backingAmount: Double) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(["pledge_total": backingAmount])

    self.track(event: "Cancel Pledge Button Clicked", properties: props)
  }

  public func trackUpdatePaymentMethodButton(project: Project, pledgeAmount: Double) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(["pledge_total": pledgeAmount])

    self.track(event: "Update Payment Method Button Clicked", properties: props)
  }

  public func trackUpdatePledgeButtonClicked(project: Project, pledgeAmount: Double) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(["pledge_total": pledgeAmount])

    self.track(event: "Update Pledge Button Clicked", properties: props)
  }

  public func trackManagePledgeOptionClicked(project: Project, managePledgeMenuCTA: ManagePledgeMenuCTAType) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(["cta": managePledgeMenuCTA.trackingString])

    self.track(event: "Manage Pledge Option Clicked", properties: props)
  }

  public func trackFixPledgeButtonClicked(project: Project) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(contextProperties(pledgeFlowContext: .fixErroredPledge))

    self.track(
      event: DataLakeApprovedEvent.fixPledgeButtonClicked.rawValue,
      location: .managePledgeScreen,
      properties: props
    )
  }

  /* Call when a reward is selected

   parameters:
   - project: the project being pledged to
   - reward: the selected reward
   - context: the PledgeContext from which the event was triggered
   - refTag: the optional RefTag associated with the pledge
   */

  public func trackRewardClicked(
    project: Project,
    reward: Reward,
    context: PledgeContext,
    refTag: RefTag?
  ) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(pledgeProperties(from: reward))
      .withAllValuesFrom(contextProperties(pledgeFlowContext: context))

    self.track(
      event: DataLakeApprovedEvent.selectRewardButtonClicked.rawValue,
      location: .rewards,
      properties: props,
      refTag: refTag?.stringTag
    )
  }

  /* Call when the pledge screen is shown

   parameters:
   - project: the project being pledged to
   - reward: the chosen reward
   - context: the PledgeContext from which the event was triggered
   - refTag: the associated RefTag for the pledge
   - cookieRefTag: The ref tag pulled from cookie storage when this project was shown.

   */

  public func trackCheckoutPaymentPageViewed(
    project: Project,
    reward: Reward,
    context: Koala.PledgeContext,
    refTag: RefTag?,
    cookieRefTag: RefTag?,
    optimizelyProperties: [String: Any] = [:]
  ) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(pledgeProperties(from: reward))
      .withAllValuesFrom(contextProperties(pledgeFlowContext: context))
      .withAllValuesFrom(optimizelyProperties)

    self.track(
      event: DataLakeApprovedEvent.checkoutPaymentPageViewed.rawValue,
      location: .pledgeScreen,
      properties: props,
      refTag: refTag?.stringTag,
      referrerCredit: cookieRefTag?.stringTag
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
      .withAllValuesFrom(pledgeProperties(from: reward))
      .withAllValuesFrom(checkoutProperties(from: checkoutData))
      // the context is always "newPledge" for this event
      .withAllValuesFrom(contextProperties(pledgeFlowContext: .newPledge))

    self.track(
      event: DataLakeApprovedEvent.pledgeSubmitButtonClicked.rawValue,
      location: .pledgeScreen,
      properties: props,
      refTag: refTag?.stringTag
    )
  }

  public func trackPledgeSubmitButtonClicked(
    project: Project,
    reward: Reward,
    context: Koala.PledgeContext,
    refTag: RefTag?
  ) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(pledgeProperties(from: reward))
      .withAllValuesFrom(contextProperties(pledgeFlowContext: context))

    self.track(
      event: DataLakeApprovedEvent.pledgeSubmitButtonClicked.rawValue,
      location: .pledgeScreen,
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
    context: Koala.PledgeContext,
    location: Koala.LocationContext? = nil,
    project: Project,
    refTag: RefTag?,
    reward: Reward
  ) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(pledgeProperties(from: reward))
      .withAllValuesFrom(contextProperties(pledgeFlowContext: context))

    self.track(
      event: DataLakeApprovedEvent.addNewCardButtonClicked.rawValue,
      location: location,
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
      .withAllValuesFrom(contextProperties(pledgeFlowContext: .newPledge))

    if let checkoutData = checkoutData {
      props = props.withAllValuesFrom(checkoutProperties(from: checkoutData))
    }

    self.track(
      event: DataLakeApprovedEvent.thanksPageViewed.rawValue,
      location: .thanks,
      properties: props
    )
  }

  /** Call when the Manage button is tapped on the activity feed to fix an errored pledge.

   - parameter project: the project that was pledged to.
   */
  public func trackActivitiesManagePledgeButtonClicked(project: Project) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(contextProperties(pledgeFlowContext: .fixErroredPledge))
    self.track(
      event: DataLakeApprovedEvent.managePledgeButtonClicked.rawValue,
      location: .activities,
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
      event: DataLakeApprovedEvent.loginOrSignupButtonClicked.rawValue,
      location: .discovery,
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
      event: DataLakeApprovedEvent.loginOrSignupPageViewed.rawValue,
      location: .loginTout,
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
      event: DataLakeApprovedEvent.loginButtonClicked.rawValue,
      location: .loginTout,
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
      event: DataLakeApprovedEvent.fbLoginOrSignupButtonClicked.rawValue,
      location: .loginTout,
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
      event: DataLakeApprovedEvent.continueWithAppleButtonClicked.rawValue,
      location: .loginTout,
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
      event: DataLakeApprovedEvent.signupButtonClicked.rawValue,
      location: .loginTout,
      properties: props
    )
  }

  public func trackSignupSubmitButtonClicked() {
    self.track(event: DataLakeApprovedEvent.signupSubmitButtonClicked.rawValue, location: .signup)
  }

  public func trackLoginSubmitButtonClicked() {
    self.track(event: DataLakeApprovedEvent.loginSubmitButtonClicked.rawValue, location: .login)
  }

  public func trackForgotPasswordViewed() {
    self.track(event: DataLakeApprovedEvent.forgotPasswordViewed.rawValue, location: .forgotPassword)
  }

  public func track2FAViewed() {
    self.track(event: DataLakeApprovedEvent.twoFactorConfirmationViewed.rawValue, location: .twoFactorAuth)
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

  // MARK: - Comments Events

  public func trackLoadNewerComments(project: Project, update: Update?, context: CommentsContext) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(update.map { properties(update: $0) } ?? [:])
      .withAllValuesFrom(["context": context.trackingString])

    // Deprecated events
    switch context {
    case .project:
      self.track(event: "Project Comment Load New", properties: props.withAllValuesFrom(deprecatedProps))
    case .update:
      self.track(event: "Update Comment Load New", properties: props.withAllValuesFrom(deprecatedProps))
    }

    self.track(event: "Loaded Newer Comments", properties: props)
  }

  public func trackLoadOlderComments(
    project: Project,
    update: Update?,
    page: Int,
    context: CommentsContext
  ) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(update.map { properties(update: $0) } ?? [:])
      .withAllValuesFrom(["page_count": page, "context": context.trackingString])

    // Deprecated events
    switch context {
    case .project:
      self.track(event: "Project Comment Load Older", properties: props.withAllValuesFrom(deprecatedProps))
    case .update:
      self.track(event: "Update Comment Load Older", properties: props.withAllValuesFrom(deprecatedProps))
    }

    self.track(event: "Loaded Older Comments", properties: props)
  }

  public func trackOpenedCommentEditor(
    project: Project,
    update: Update?,
    context: CommentDialogContext
  ) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(update.map { properties(update: $0) } ?? [:])
      .withAllValuesFrom(
        [
          "context": context.trackingString,
          "type": update == nil
            ? CommentDialogType.project.trackingString : CommentDialogType.update.trackingString
        ]
      )

    self.track(event: "Opened Comment Editor", properties: props)
  }

  public func trackCanceledCommentEditor(
    project: Project,
    update: Update?,
    context: CommentDialogContext
  ) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(update.map { properties(update: $0) } ?? [:])
      .withAllValuesFrom(
        [
          "context": context.trackingString,
          "type": update == nil
            ? CommentDialogType.project.trackingString : CommentDialogType.update.trackingString
        ]
      )

    self.track(event: "Canceled Comment Editor", properties: props)
  }

  public func trackPostedComment(
    project: Project,
    update: Update?,
    context: CommentDialogContext
  ) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(update.map { properties(update: $0) } ?? [:])
      .withAllValuesFrom(
        [
          "context": context.trackingString,
          "type": update == nil
            ? CommentDialogType.project.trackingString : CommentDialogType.update.trackingString
        ]
      )

    self.track(event: "Posted Comment", properties: props)
  }

  public func trackCommentCreate(comment: Comment, project: Project) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(properties(comment: comment))
      .withAllValuesFrom(deprecatedProps)

    self.track(event: "Project Comment Create", properties: props)
  }

  public func trackCommentCreate(comment: Comment, update: Update, project: Project) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(properties(update: update))
      .withAllValuesFrom(properties(comment: comment))
      .withAllValuesFrom(deprecatedProps)

    self.track(event: "Update Comment Create", properties: props)
  }

  public func trackCommentsView(project: Project, update: Update?, context: CommentsContext) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(update.map { properties(update: $0) } ?? [:])
      .withAllValuesFrom(["context": context.trackingString])

    // Deprecated events
    switch context {
    case .project:
      self.track(event: "Project Comment View", properties: props.withAllValuesFrom(deprecatedProps))
    case .update:
      self.track(event: "Update Comment View", properties: props.withAllValuesFrom(deprecatedProps))
    }

    self.track(event: "Viewed Comments", properties: props)
  }

  /**
   Call when the share sheet is shown.

   - parameter shareContext: The context in which the sharing is happening.
   */
  public func trackShowedShareSheet(shareContext: ShareContext) {
    let props = properties(shareContext: shareContext, loggedInUser: self.loggedInUser)

    self.track(event: "Showed Share Sheet", properties: props)

    // Deprecated event
    let deprecatedEvent = shareContext.isThanksContext ? "Checkout Show Share Sheet"
      : shareContext.update != nil ? "Update Show Share Sheet"
      : "Project Show Share Sheet"
    self.track(event: deprecatedEvent, properties: props.withAllValuesFrom(deprecatedProps))
  }

  /**
   Call when the share sheet is canceled.

   - parameter shareContext: The context in which the sharing is happening.
   */
  public func trackCanceledShareSheet(shareContext: ShareContext) {
    let props = properties(shareContext: shareContext, loggedInUser: self.loggedInUser)

    self.track(
      event: "Canceled Share Sheet",
      properties: props
    )

    // Deprecated event
    let deprecatedEvent = shareContext.isThanksContext ? "Checkout Cancel Share Sheet"
      : shareContext.update != nil ? "Update Cancel Share Sheet"
      : "Project Cancel Share Sheet"
    self.track(event: deprecatedEvent, properties: props.withAllValuesFrom(deprecatedProps))
  }

  /**
   Call when a share dialog is shown. Note that this is showing the actual share dialog, and not
   simply the share sheet.

   - parameter shareContext:      The context in which the sharing is happening.
   - parameter shareActivityType: The type of share that was shown.
   */
  public func trackShowedShare(shareContext: ShareContext, shareActivityType: UIActivity.ActivityType?) {
    let props = properties(
      shareContext: shareContext,
      loggedInUser: self.loggedInUser,
      shareActivityType: shareActivityType
    )
    self.track(event: "Showed Share", properties: props)

    // Deprecated event
    let deprecatedEvent = shareContext.isThanksContext ? "Checkout Show Share"
      : shareContext.update != nil ? "Update Show Share"
      : "Project Show Share"
    self.track(event: deprecatedEvent, properties: props.withAllValuesFrom(deprecatedProps))
  }

  /**
   Call when a share dialog is canceled. Note that this is canceling the actual share dialog, and not
   simply the share sheet.

   - parameter shareContext:      The context in which the sharing is happening.
   - parameter shareActivityType: The type of share that was shown.
   */
  public func trackCanceledShare(shareContext: ShareContext, shareActivityType: UIActivity.ActivityType?) {
    let props = properties(
      shareContext: shareContext,
      loggedInUser: self.loggedInUser,
      shareActivityType: shareActivityType
    )
    self.track(event: "Canceled Share", properties: props)

    // Deprecated event
    let deprecatedEvent = shareContext.isThanksContext ? "Checkout Cancel Share"
      : shareContext.update != nil ? "Update Cancel Share"
      : "Project Cancel Share"
    self.track(event: deprecatedEvent, properties: props.withAllValuesFrom(deprecatedProps))
  }

  /**
   Call when a share is successfully performed.

   - parameter shareContext:      The context in which the sharing is happening.
   - parameter shareActivityType: The type of share that was shown.
   */
  public func trackShared(shareContext: ShareContext, shareActivityType: UIActivity.ActivityType?) {
    let props = properties(
      shareContext: shareContext,
      loggedInUser: self.loggedInUser,
      shareActivityType: shareActivityType
    )
    self.track(event: "Shared", properties: props)

    // Deprecated event
    let deprecatedEvent = shareContext.isThanksContext ? "Checkout Share"
      : shareContext.update != nil ? "Update Share"
      : "Project Share"
    self.track(event: deprecatedEvent, properties: props.withAllValuesFrom(deprecatedProps))
  }

  public func trackCheckoutFinishJumpToDiscovery(project: Project) {
    self.track(
      event: "Checkout Finished Discover More",
      properties: projectProperties(from: project, loggedInUser: self.loggedInUser)
    )
  }

  public func trackTriggeredAppStoreRatingDialog(project: Project) {
    self.track(
      event: "Triggered App Store Rating Dialog",
      properties: projectProperties(from: project, loggedInUser: self.loggedInUser)
    )
  }

  // MARK: - Dashboard

  public func trackDashboardClosedProjectSwitcher(onProject project: Project) {
    self.track(
      event: "Closed Project Switcher",
      properties: projectProperties(from: project, loggedInUser: self.loggedInUser)
    )
  }

  public func trackDashboardSeeAllRewards(project: Project) {
    self.track(
      event: "Showed All Rewards",
      properties: projectProperties(from: project, loggedInUser: self.loggedInUser)
    )
  }

  public func trackDashboardSeeMoreReferrers(project: Project) {
    self.track(
      event: "Showed All Referrers",
      properties: projectProperties(from: project, loggedInUser: self.loggedInUser)
    )
  }

  public func trackDashboardShowProjectSwitcher(onProject project: Project) {
    self.track(
      event: "Showed Project Switcher",
      properties: projectProperties(from: project, loggedInUser: self.loggedInUser)
    )
  }

  public func trackDashboardSwitchProject(_ project: Project) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)

    self.track(event: "Switched Projects", properties: props)

    // deprecated
    self.track(
      event: "Creator Project Navigate",
      properties: props.withAllValuesFrom(deprecatedProps)
    )
  }

  public func trackDashboardView(project: Project) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)

    self.track(event: "Viewed Project Dashboard", properties: props)

    // deprecated
    self.track(
      event: "Dashboard View",
      properties: props.withAllValuesFrom(deprecatedProps)
    )
  }

  // MARK: - Project activity

  public func trackViewedProjectActivity(project: Project) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)

    self.track(event: "Viewed Project Activity", properties: props)
    // deprecated
    self.track(
      event: "Creator Activity View",
      properties: props.withAllValuesFrom(deprecatedProps)
    )
  }

  public func trackLoadedNewerProjectActivity(project: Project) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)

    self.track(event: "Loaded Newer Project Activity", properties: props)
    // deprecated
    self.track(
      event: "Creator Activity View Load Newer",
      properties: props.withAllValuesFrom(deprecatedProps)
    )
  }

  public func trackLoadedOlderProjectActivity(project: Project, page: Int) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(["page_count": page])

    self.track(event: "Loaded Older Project Activity", properties: props)
    // deprecated
    self.track(
      event: "Creator Activity View Load Older",
      properties: props.withAllValuesFrom(deprecatedProps)
    )
  }

  // MARK: - Messages

  public func trackMessageThreadsView(mailbox: Mailbox, project: Project?, refTag: RefTag) {
    let props = (project.flatMap { projectProperties(from: $0, loggedInUser: self.loggedInUser) } ?? [:])
      .withAllValuesFrom(["ref_tag": refTag.stringTag])

    switch mailbox {
    case .inbox:
      self.track(event: "Viewed Message Inbox", properties: props)
    case .sent:
      self.track(event: "Viewed Sent Messages", properties: props)
    }

    // deprecated
    let _deprecatedProps = props.withAllValuesFrom(deprecatedProps)
    self.track(
      event: "Message Threads View",
      properties: _deprecatedProps.withAllValuesFrom(["mailbox": mailbox.rawValue])
    )
    self.track(event: "Message Inbox View", properties: _deprecatedProps)
  }

  public func trackViewedMessageSearch(project: Project?) {
    let props = project.flatMap { projectProperties(from: $0, loggedInUser: self.loggedInUser) } ?? [:]

    self.track(event: "Viewed Message Search", properties: props)
  }

  public func trackViewedMessageSearchResults(term: String, project: Project?, hasResults: Bool) {
    let props = (project.flatMap { projectProperties(from: $0, loggedInUser: self.loggedInUser) } ?? [:])
      .withAllValuesFrom(["term": term])
    let _deprecatedProps = props.withAllValuesFrom(deprecatedProps)

    self.track(event: "Message Threads Search", properties: _deprecatedProps)
    self.track(event: "Message Inbox Search", properties: _deprecatedProps)

    self.track(
      event: "Viewed Message Search Results",
      properties: props.withAllValuesFrom(["has_results": hasResults])
    )
  }

  public func trackClearedMessageSearchTerm(project: Project?) {
    let props = project.flatMap { projectProperties(from: $0, loggedInUser: self.loggedInUser) } ?? [:]

    self.track(
      event: "Cleared Message Search Term",
      properties: props
    )
  }

  public func trackMessageThreadView(project: Project) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)

    self.track(
      event: "Message Thread View",
      properties: props.withAllValuesFrom(deprecatedProps)
    )

    self.track(event: "Viewed Message Thread", properties: props)
  }

  public func trackViewedMessageEditor(project: Project, context: MessageDialogContext) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(["message_type": "single", "context": context.rawValue])

    self.track(event: "Viewed Message Editor", properties: props)
  }

  /**
   Tracks an event for sending a message.

   - parameter project: The project that is the subject of the message.
   - parameter context: The place where the message was sent from.
   */
  public func trackMessageSent(project: Project, context: MessageDialogContext) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(["message_type": "single", "context": context.rawValue])

    self.track(
      event: "Message Sent",
      properties: props.withAllValuesFrom(deprecatedProps)
    )

    self.track(event: "Sent Message", properties: props)
  }

  // MARK: - Search Events

  /// Call once when the search view is initially shown.
  public func trackProjectSearchView() {
    self.track(event: DataLakeApprovedEvent.searchPageViewed.rawValue, location: .search)
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
      event: DataLakeApprovedEvent.searchResultsLoaded.rawValue,
      location: .search,
      properties: props
    )
  }

  // MARK: - Project Page Events

  /**
   Call when a project page is viewed.

   - parameter project:      The project being viewed.
   - parameter refTag:       The ref tag used when opening the project.
   - parameter cookieRefTag: The ref tag pulled from cookie storage when this project was shown.
   */
  public func trackProjectViewed(
    _ project: Project,
    refTag: RefTag? = nil,
    cookieRefTag: RefTag? = nil,
    optimizelyProperties: [String: Any] = [:]
  ) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(optimizelyProperties)

    self.track(
      event: DataLakeApprovedEvent.projectPageViewed.rawValue,
      location: .projectPage,
      properties: props,
      refTag: refTag?.stringTag,
      referrerCredit: cookieRefTag?.stringTag
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
      event: DataLakeApprovedEvent.projectSwiped.rawValue,
      location: .projectPage,
      properties: props, refTag: refTag?.stringTag
    )
  }

  /**
   Call when a project is watched/saved.
   - parameter project: The project being watched
   - parameter location: The location context of where the project is being watched from
   - parameter params: The optional Discover params if the project is being watched from Discover
   */

  public func trackWatchProjectButtonClicked(
    project: Project,
    location: LocationContext,
    params: DiscoveryParams? = nil
  ) {
    var props = projectProperties(from: project, loggedInUser: self.loggedInUser)

    if let discoveryParams = params {
      props = props.withAllValuesFrom(discoveryProperties(from: discoveryParams))
    }

    self.track(
      event: DataLakeApprovedEvent.watchProjectButtonClicked.rawValue,
      location: location,
      properties: props
    )
  }

  public func trackCreatorDetailsClicked(
    project: Project,
    location: LocationContext,
    refTag: RefTag?,
    cookieRefTag: RefTag? = nil,
    optimizelyProperties: [String: Any] = [:]
  ) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(optimizelyProperties)

    self.track(
      event: DataLakeApprovedEvent.creatorDetailsClicked.rawValue,
      location: location,
      properties: props,
      refTag: refTag?.stringTag,
      referrerCredit: cookieRefTag?.stringTag
    )
  }

  public func trackCampaignDetailsButtonClicked(
    project: Project,
    location: LocationContext,
    refTag: RefTag?,
    cookieRefTag: RefTag? = nil,
    optimizelyProperties: [String: Any] = [:]
  ) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(optimizelyProperties)

    self.track(
      event: DataLakeApprovedEvent.campaignDetailsButtonClicked.rawValue,
      location: location,
      properties: props,
      refTag: refTag?.stringTag,
      referrerCredit: cookieRefTag?.stringTag
    )
  }

  public func trackCampaignDetailsPledgeButtonClicked(project: Project,
                                                      location: LocationContext,
                                                      refTag: RefTag?,
                                                      cookieRefTag: RefTag? = nil,
                                                      optimizelyProperties: [String: Any] = [:]) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(optimizelyProperties)

    self.track(
      event: DataLakeApprovedEvent.campaignDetailsPledgeButtonClicked.rawValue,
      location: location,
      properties: props,
      refTag: refTag?.stringTag,
      referrerCredit: cookieRefTag?.stringTag
    )
  }

  public func trackOpenedExternalLink(project: Project, context: ExternalLinkContext) {
    let props = projectProperties(from: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(["context": context.trackingString])

    self.track(event: "Opened External Link", properties: props)
  }

  // MARK: - Profile Events

  public func trackProfileView() {
    // deprecated
    self.track(event: "Profile View My", properties: deprecatedProps)

    self.track(event: "Viewed Profile")
  }

  public func trackViewedProfileTab(projectsType: ProfileProjectsType) {
    self.track(event: "Viewed Profile Tab", properties: ["type": projectsType.trackingString])
  }

  // MARK: - Settings Events

  public func trackAppStoreRatingOpen() {
    // deprecated
    self.track(event: "App Store Rating Open", properties: deprecatedProps)

    self.track(event: "Opened App Store Listing")
  }

  public func trackRecommendationsOptIn() {
    // deprecated
    self.track(event: "Toggled recommendations", properties: deprecatedProps)
  }

  public func trackFollowingOptIn() {
    // deprecated
    self.track(event: "Toggled following", properties: deprecatedProps)
  }

  public func trackCancelLogoutModal() {
    self.track(event: "Canceled Logout", properties: ["context": "modal"])
  }

  public func trackChangeEmailNotification(type: String, on: Bool) {
    self.track(
      event: on ? "Enabled Email Notifications" : "Disabled Email Notifications",
      properties: ["type": type]
    )
  }

  public func trackAccountView() {
    self.track(event: "Viewed Account")
  }

  // MARK: - Create Password Tracking

  public enum CreatePasswordTrackingEvent: String {
    case passwordCreated = "Created Password"
    case viewed = "Viewed Create Password"
  }

  public func trackCreatePassword(event: CreatePasswordTrackingEvent) {
    self.track(event: event.rawValue)
  }

  // MARK: - Change Email Tracking

  public func trackChangeEmailView() {
    self.track(event: "Viewed Change Email")
  }

  public func trackChangeEmail() {
    self.track(event: "Changed Email")
  }

  // MARK: - Change Password Tracking

  public func trackChangePasswordView() {
    self.track(event: "Viewed Change Password")
  }

  public func trackChangePassword() {
    self.track(event: "Changed Password")
  }

  public func trackResentVerificationEmail() {
    self.track(event: "Resent Verification Email")
  }

  public func trackChangedCurrency(_ currency: Currency) {
    let prop = ["currency": currency.descriptionText]
    self.track(event: "Selected Chosen Currency", properties: prop)
  }

  /**
   Tracks an event for toggling a newsletter preference.

   - parameter newsletterType: The newsletter type.
   - parameter sendNewsletter: The boolean determining whether the newsletter should be sent or not.
   - parameter project: The referring project from which a newsletter preference is set (e.g. Thanks screen).
   - parameter context: The context from which the newsletter preference is set.
   */
  public func trackChangeNewsletter(
    newsletterType newsletter: Newsletter,
    sendNewsletter: Bool,
    project: Project?,
    context: NewsletterContext
  ) {
    let props = project.flatMap { projectProperties(from: $0, loggedInUser: self.loggedInUser) } ?? [:]
      .withAllValuesFrom(["context": context.trackingString, "type": newsletter.trackingString])

    self.track(
      event: sendNewsletter ? "Subscribed To Newsletter" : "Unsubscribed From Newsletter",
      properties: props
    )

    // Deprecated events
    switch context {
    case .signup, .facebookSignup:
      self.track(event: "Signup Newsletter Toggle", properties: ["send_newsletters": sendNewsletter])
    case .thanks:
      self.track(event: sendNewsletter ? "Newsletter Subscribe" : "Newsletter Unsubscribe", properties: props)
    case .settings:
      return
    }
  }

  public func trackChangeProjectNotification(_ project: ProjectNotification.Project) {
    let props: [String: Any] = ["name": project.name, "id": project.id]
    self.track(event: "Changed Project Notifications", properties: props)
  }

  public func trackChangePushNotification(type: String, on: Bool) {
    self.track(
      event: on ? "Enabled Push Notifications" : "Disabled Push Notifications",
      properties: ["type": type]
    )
  }

  public func trackPushPermissionOptIn() {
    self.track(event: "Confirmed Push Opt-In")
  }

  public func trackPushPermissionOptOut() {
    self.track(event: "Dismissed Push Opt-In")
  }

  public func trackConfirmLogoutModal() {
    self.track(event: "Confirmed Logout", properties: ["context": "modal"])
  }

  public func trackLogoutModal() {
    self.track(event: "Triggered Logout Modal")
  }

  public func trackSettingsView() {
    // deprecated
    self.track(event: "Settings View", properties: deprecatedProps)

    self.track(event: "Viewed Settings")
  }

  // MARK: - Find Friends Events

  public func trackCloseFacebookConnect(source: FriendsSource) {
    self.track(event: "Close Facebook Connect", properties: ["source": source.trackingString])
  }

  public func trackCloseFindFriends(source: FriendsSource) {
    self.track(event: "Close Find Friends", properties: ["source": source.trackingString])
  }

  public func trackDeclineFriendFollowAll(source: FriendsSource) {
    let props: [String: Any] = ["source": source.trackingString]

    // deprecated
    self.track(
      event: "Facebook Friend Decline Follow All",
      properties: props.withAllValuesFrom(deprecatedProps)
    )

    self.track(event: "Declined Follow All Facebook Friends", properties: props)
  }

  public func trackFacebookConnect(source: FriendsSource) {
    let props: [String: Any] = ["source": source.trackingString]

    // deprecated
    self.track(event: "Facebook Connect", properties: props.withAllValuesFrom(deprecatedProps))

    self.track(event: "Connected Facebook", properties: props)
  }

  public func trackFacebookConnectError(source: FriendsSource) {
    let props: [String: Any] = ["source": source.trackingString]

    // deprecated
    self.track(event: "Facebook Connect Error", properties: props.withAllValuesFrom(deprecatedProps))

    self.track(event: "Errored Facebook Connect", properties: props)
  }

  public func trackFindFriendsView(source: FriendsSource) {
    let props: [String: Any] = ["source": source.trackingString]

    // deprecated
    self.track(event: "Find Friends View", properties: props.withAllValuesFrom(deprecatedProps))

    self.track(event: "Viewed Find Friends", properties: props)
  }

  public func trackFriendFollow(source: FriendsSource) {
    let props: [String: Any] = ["source": source.trackingString]

    // deprecated
    self.track(event: "Facebook Friend Follow", properties: props.withAllValuesFrom(deprecatedProps))

    self.track(event: "Followed Facebook Friend", properties: props)
  }

  public func trackFriendFollowAll(source: FriendsSource) {
    let props: [String: Any] = ["source": source.trackingString]

    // deprecated
    self.track(event: "Facebook Friend Follow All", properties: props.withAllValuesFrom(deprecatedProps))

    self.track(event: "Followed All Facebook Friends", properties: props)
  }

  public func trackFriendUnfollow(source: FriendsSource) {
    let props: [String: Any] = ["source": source.trackingString]

    // deprecated
    self.track(event: "Facebook Friend Unfollow", properties: props.withAllValuesFrom(deprecatedProps))

    self.track(event: "Unfollowed Facebook Friend", properties: props)
  }

  public func loadedMoreFriends(source: FriendsSource, pageCount: Int) {
    self.track(
      event: "Loaded More Friends",
      properties: ["source": source.trackingString, "page_count": pageCount]
    )
  }

  // MARK: - Update Draft Events

  public func trackViewedUpdateDraft(forProject project: Project) {
    self.track(event: "Viewed Draft", properties: self.updateDraftProperties(project: project))
  }

  public func trackClosedUpdateDraft(forProject project: Project) {
    self.track(event: "Closed Draft", properties: self.updateDraftProperties(project: project))
  }

  public func trackEditedUpdateDraftTitle(forProject project: Project) {
    self.track(event: "Edited Title", properties: self.updateDraftProperties(project: project))
  }

  public func trackEditedUpdateDraftBody(forProject project: Project) {
    self.track(event: "Edited Body", properties: self.updateDraftProperties(project: project))
  }

  public func trackStartedAddUpdateDraftAttachment(forProject project: Project) {
    self.track(event: "Started Add Attachment", properties: self.updateDraftProperties(project: project))
  }

  public func trackCompletedAddUpdateDraftAttachment(
    forProject project: Project,
    attachedFrom source: AttachmentSource
  ) {
    var props = self.updateDraftProperties(project: project)
    props["type"] = source.rawValue
    self.track(event: "Completed Add Attachment", properties: props)
  }

  public func trackCanceledAddUpdateDraftAttachment(forProject project: Project) {
    self.track(event: "Canceled Add Attachment", properties: self.updateDraftProperties(project: project))
  }

  public func trackFailedAddUpdateDraftAttachment(forProject project: Project) {
    self.track(event: "Failed Add Attachment", properties: self.updateDraftProperties(project: project))
  }

  public func trackStartedRemoveUpdateDraftAttachment(forProject project: Project) {
    self.track(event: "Started Remove Attachment", properties: self.updateDraftProperties(project: project))
  }

  public func trackCanceledRemoveUpdateDraftAttachment(forProject project: Project) {
    self.track(event: "Canceled Remove Attachment", properties: self.updateDraftProperties(project: project))
  }

  public func trackCompletedRemoveUpdateDraftAttachment(forProject project: Project) {
    self.track(event: "Completed Remove Attachment", properties: self.updateDraftProperties(project: project))
  }

  public func trackFailedRemoveUpdateDraftAttachment(forProject project: Project) {
    self.track(event: "Failed Remove Attachment", properties: self.updateDraftProperties(project: project))
  }

  public func trackChangedUpdateDraftVisibility(forProject project: Project, isPublic: Bool) {
    var props = projectProperties(from: project, loggedInUser: self.loggedInUser)
    props["type"] = isPublic ? "public" : "backers_only"
    self.track(event: "Changed Visibility", properties: props)
  }

  public func trackPreviewedUpdate(forProject project: Project) {
    let props = self.updateDraftProperties(project: project)
    self.track(event: "Previewed Update", properties: props)

    self.track(event: "Update Preview", properties: props.withAllValuesFrom(deprecatedProps))
  }

  public func trackTriggeredPublishConfirmationModal(forProject project: Project) {
    self.track(
      event: "Triggered Publish Confirmation Modal",
      properties: self.updateDraftProperties(project: project)
    )
  }

  public func trackCanceledPublishUpdate(forProject project: Project) {
    self.track(
      event: "Canceled Publish", properties: self.updateDraftProperties(project: project)
        .withAllValuesFrom(["context": "modal"])
    )
  }

  public func trackConfirmedPublishUpdate(forProject project: Project) {
    self.track(
      event: "Confirmed Publish", properties: self.updateDraftProperties(project: project)
        .withAllValuesFrom(["context": "modal"])
    )
  }

  public func trackPublishedUpdate(forProject project: Project, isPublic: Bool) {
    var props = self.updateDraftProperties(project: project)
    props["type"] = isPublic ? "public" : "backers_only"
    self.track(event: "Published Update", properties: props)

    self.track(event: "Update Published", properties: props.withAllValuesFrom(deprecatedProps))
  }

  private func updateDraftProperties(project: Project) -> [String: Any] {
    var props = projectProperties(from: project, loggedInUser: self.loggedInUser)
    props["context"] = "update_draft"
    return props
  }

  // MARK: - Pledge screen events

  public func trackViewedPledge(forProject project: Project) {
    self.track(
      event: "Viewed Pledge Info",
      properties: projectProperties(from: project, loggedInUser: self.loggedInUser)
    )

    // Deprecated event
    self.track(
      event: "Modal Dialog View",
      properties: ["modal_class": "backer_info", Koala.DeprecatedKey: true]
    )
  }

  // MARK: - Help events

  public func trackCanceledContactEmail(context: HelpContext) {
    self.track(event: "Canceled Contact Email", properties: ["context": context.trackingString])
  }

  public func trackCanceledHelpMenu(context: HelpContext) {
    self.track(event: "Canceled Help Menu", properties: ["context": context.trackingString])
  }

  public func trackOpenedContactEmail(context _: HelpContext) {
    // deprecated
    self.track(event: "Contact Email Open", properties: deprecatedProps)
  }

  public func trackSelectedHelpOption(context: HelpContext, type: HelpType) {
    self.track(
      event: "Selected Help Option",
      properties: ["context": context.trackingString, "type": type.trackingString]
    )
  }

  public func trackSentContactEmail(context: HelpContext) {
    self.track(
      event: "Sent Contact Email",
      properties: ["context": context.trackingString]
    )

    // deprecated
    self.track(event: "Contact Email Sent", properties: deprecatedProps)
  }

  public func trackShowedHelpMenu(context: HelpContext) {
    self.track(event: "Showed Help Menu", properties: ["context": context.trackingString])
  }

  // MARK: - Video events

  public func trackVideoCompleted(forProject project: Project) {
    // deprecated
    self.track(event: "Project Video Complete", properties: deprecatedProps)

    self.track(
      event: "Completed Project Video",
      properties: projectProperties(from: project, loggedInUser: self.loggedInUser)
    )
  }

  public func trackVideoPaused(forProject project: Project) {
    // deprecated
    self.track(event: "Project Video Pause", properties: deprecatedProps)

    self.track(
      event: "Paused Project Video",
      properties: projectProperties(from: project, loggedInUser: self.loggedInUser)
    )
  }

  public func trackVideoResume(forProject project: Project) {
    // deprecated
    self.track(event: "Project Video Resume", properties: deprecatedProps)

    self.track(
      event: "Resumed Project Video",
      properties: projectProperties(from: project, loggedInUser: self.loggedInUser)
    )
  }

  public func trackVideoStart(forProject project: Project) {
    // deprecated
    self.track(event: "Project Video Start", properties: deprecatedProps)

    self.track(
      event: "Started Project Video",
      properties: projectProperties(from: project, loggedInUser: self.loggedInUser)
    )
  }

  // MARK: - Empty State Events

  public func trackEmptyStateButtonTapped(type: EmptyState) {
    self.track(
      event: "Tapped Empty State Button",
      properties: ["type": type.rawValue]
    )
  }

  public func trackPerformedShortcutItem(
    _ shortcutItem: ShortcutItem,
    availableShortcutItems: [ShortcutItem]
  ) {
    self.track(
      event: "Performed Shortcut",
      properties: [
        "type": shortcutItem.typeString,
        "context": availableShortcutItems.map { $0.typeString }.joined(separator: ",")
      ]
    )
  }

  public func trackViewedPaymentMethods() {
    self.track(event: "Viewed Payment Methods")
  }

  public func trackViewedAddNewCard() {
    self.track(event: "Viewed Add New Card")
  }

  public func trackDeletedPaymentMethod() {
    self.track(event: "Deleted Payment Method")
  }

  public func trackDeletePaymentMethodError() {
    self.track(event: "Errored Delete Payment Method")
  }

  public func trackSavedPaymentMethod() {
    self.track(event: "Saved Payment Method")
  }

  public func trackFailedPaymentMethodCreation() {
    self.track(event: "Failed Payment Method Creation")
  }

  // Private tracking method that merges in default properties.
  private func track(
    event: String,
    location: Koala.LocationContext? = nil,
    properties: [String: Any] = [:],
    refTag: String? = nil,
    referrerCredit: String? = nil
  ) {
    let props = self.sessionProperties(refTag: refTag, referrerCredit: referrerCredit)
      .withAllValuesFrom(userProperties(for: self.loggedInUser, config: self.config))
      .withAllValuesFrom(contextProperties(location: location))
      .withAllValuesFrom(properties)

    self.logEventCallback?(event, props)

    self.koalaClient.track(
      event: event,
      properties: props
    )

    if DataLakeApprovedEvent.allApprovedEvents().contains(event) {
      self.dataLakeClient.track(
        event: event,
        properties: props
      )
    }
  }

  // MARK: - Session Properties

  private func sessionProperties(
    refTag: String?,
    referrerCredit: String?,
    prefix: String = "session_"
  ) -> [String: Any] {
    var props: [String: Any] = [:]

    let enabledFeatureFlags = self.config?.features
      .filter { key, value in key.starts(with: "ios_") && value }
      .keys
      .sorted()

    props["apple_pay_capable"] = AppEnvironment.current.applePayCapabilities.applePayCapable()
    props["apple_pay_device"] = AppEnvironment.current.applePayCapabilities.applePayDevice()
    props["cellular_connection"] = AppEnvironment.current.coreTelephonyNetworkInfo
      .serviceCurrentRadioAccessTechnology
    props["client_type"] = "native"
    props["current_variants"] = self.config?.abExperimentsArray.sorted()
    props["display_language"] = AppEnvironment.current.language.rawValue

    props["device_format"] = self.device.deviceFormat
    props["device_manufacturer"] = "Apple"
    props["device_model"] = Koala.deviceModel
    props["device_orientation"] = self.deviceOrientation
    props["device_distinct_id"] = self.distinctId

    props["enabled_features"] = enabledFeatureFlags
    props["is_voiceover_running"] = AppEnvironment.current.isVoiceOverRunning()
    props["mp_lib"] = "kickstarter_ios"
    props["os"] = self.device.systemName
    props["os_version"] = self.device.systemVersion
    props["app_build_number"] = self.bundle.infoDictionary?["CFBundleVersion"]
    props["app_release_version"] = self.bundle.infoDictionary?["CFBundleShortVersionString"]
    props["screen_width"] = UInt(self.screen.bounds.width)
    props["user_agent"] = Service.userAgent
    props["user_logged_in"] = self.loggedInUser != nil
    props["wifi_connection"] = Reachability.current == .wifi
    props["client_platform"] = self.clientPlatform

    props["ref_tag"] = refTag
    props["referrer_credit"] = referrerCredit

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
  props["subcategory_id"] = project.category.id
  props["country"] = project.country.countryCode
  props["comments_count"] = project.stats.commentsCount ?? 0
  props["currency"] = project.country.currencyCode
  props["creator_uid"] = project.creator.id
  props["deadline"] = project.dates.deadline
  props["goal"] = project.stats.goal
  props["launched_at"] = project.dates.launchedAt
  props["location"] = project.location.name
  props["name"] = project.name
  props["pid"] = project.id
  props["category"] = project.category.parentName
  props["category_id"] = project.category.parentId
  props["percent_raised"] = project.stats.fundingProgress
  props["state"] = project.state.rawValue
  props["static_usd_rate"] = project.stats.staticUsdRate
  props["current_pledge_amount"] = project.stats.pledged
  props["current_pledge_amount_usd"] = project.stats.pledgedUsd
  props["goal_usd"] = project.stats.goalUsd
  props["has_video"] = project.video != nil
  props["prelaunch_activated"] = project.prelaunchActivated
  props["rewards_count"] = project.rewards.count
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
  result["is_limited_quantity"] = reward.limit != nil
  result["is_limited_time"] = reward.endsAt != nil
  result["minimum"] = reward.minimum
  result["shipping_enabled"] = reward.shipping.enabled
  result["shipping_preference"] = reward.shipping.preference?.trackingString

  return result.prefixedKeys(prefix)
}

// MARK: - Checkout Properties

private func checkoutProperties(from data: Koala.CheckoutPropertiesData, prefix: String = "checkout_")
  -> [String: Any] {
  var result: [String: Any] = [:]

  result["amount"] = data.amount
  result["id"] = data.checkoutId
  result["payment_type"] = data.paymentType
  result["reward_id"] = data.rewardId
  result["reward_title"] = data.rewardTitle
  result["shipping_amount"] = data.shippingAmount
  result["revenue_in_usd_cents"] = data.revenueInUsdCents
  result["reward_estimated_delivery_on"] = data.estimatedDelivery
  result["reward_shipping_enabled"] = data.shippingEnabled
  result["user_has_eligible_stored_apple_pay_card"] = data.userHasStoredApplePayCard

  return result.prefixedKeys(prefix)
}

// MARK: - Discovery Properties

private func discoveryProperties(
  from params: DiscoveryParams,
  prefix: String = "discover_"
) -> [String: Any] {
  var result: [String: Any] = [:]

  // NB: All filters should be added here since `result["everything"]` is derived from this.
  result["recommended"] = params.recommended
  result["social"] = params.social
  result["pwl"] = params.staffPicks
  result["watched"] = params.starred
  result["tag"] = params.tagId?.rawValue
  let categoryProps = params.category.map { properties(category: $0, prefix: "subcategory_") }
  let parentCategoryProps = params.category?.parent.map { properties(category: $0) }

  result = result
    .withAllValuesFrom(categoryProps ?? [:])
    .withAllValuesFrom(parentCategoryProps ?? [:])

  result["everything"] = result.isEmpty
  result["sort"] = params.sort?.rawValue
  result["ref_tag"] = RefTag.fromParams(params).stringTag
  result["search_term"] = params.query

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
  pledgeFlowContext: Koala.PledgeContext? = nil,
  tabBarLabel: Koala.TabBarItemLabel? = nil,
  location: Koala.LocationContext? = nil,
  prefix: String = "context_"
) -> [String: Any] {
  var result: [String: Any] = [:]

  result["location"] = location?.rawValue
  result["pledge_flow"] = pledgeFlowContext?.trackingString
  result["timestamp"] = AppEnvironment.current.dateType.init().timeIntervalSince1970
  result["tab_bar_label"] = tabBarLabel?.trackingString

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

private func userProperties(for user: User?, config: Config?, _ prefix: String = "user_") -> [String: Any] {
  var props: [String: Any] = [:]

  props["country"] = user?.location?.country ?? config?.countryCode
  props["uid"] = user?.id

  return props.prefixedKeys(prefix)
}

extension Koala {
  public enum lens {
    public static let loggedInUser = Lens<Koala, User?>(
      view: { $0.loggedInUser },
      set: { $1.loggedInUser = $0; return $1 }
    )

    public static let config = Lens<Koala, Config?>(
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
