import CoreTelephony
import KsApi
import LiveStream
import PassKit
import Prelude
import UIKit

private let deprecatedProps = [Koala.DeprecatedKey: true]

public final class Koala {
  internal static let DeprecatedKey = "DEPRECATED"

  fileprivate let bundle: NSBundleType
  fileprivate let client: TrackingClientType
  fileprivate let config: Config?
  fileprivate let device: UIDeviceType
  internal let loggedInUser: User?
  fileprivate let screen: UIScreenType
  fileprivate let distinctId: String

  /// Determines the authentication type for login or signup events.
  public enum AuthType {
    case email
    case facebook

    var trackingString: String {
      switch self {
      case .email:      return "Email"
      case .facebook:   return "Facebook"
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
    case messages = "messages"
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
      case .projectActivity:  return "project_activity"
      case .projectComments:  return "project_comments"
      case .updateComments:   return "update_comments"
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
      case .project:  return "project"
      case .update:   return "update"
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
      case .project:  return "project"
      case .update:   return "update"
      }
    }
  }

  /// Determines which gesture was used.
  public enum GestureType: String {
    case swipe
    case tap

    fileprivate var trackingString: String {
      switch self {
      case .swipe:  return "swipe"
      case .tap:    return "tap"
      }
    }
  }

  /// Determines which swipe was used.
  public enum SwipeType: String {
    case next
    case previous

    fileprivate var trackingString: String {
      switch self {
      case .next:     return "next"
      case .previous: return "previous"
      }
    }
  }

  /// Determines the place from which the project was saved.
  public enum SaveContext: String {
    case discovery
    case project

    fileprivate var trackingString: String {
      switch self {
      case .discovery:  return "discovery"
      case .project:    return "project"
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
      case .facebookSignup:   return "facebook_signup"
      case .settings:         return "settings"
      case .signup:           return "signup"
      case .thanks:           return "thanks"
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
    case changeReward
    case manageReward
    case newPledge

    var trackingString: String {
      switch self {
      case .changeReward: return "change_reward"
      case .manageReward: return "manage_reward"
      case .newPledge:    return "new_pledge"
      }
    }
  }

  /**
   Describes the buttons the user can click on in the reward pledge screen.

   - applePay:            The user clicked the apple pay button.
   - cancel:              The user clicked the cancel pledge button.
   - changePaymentMethod: The user clicked the change payment method button.
   - paymentMethods:      The user clicked the payment methods button.
   - updatePledge:        The user clicked the update pledge button.
   */
  public enum ClickedRewardPledgeButtonType {
    case applePay
    case cancel
    case changePaymentMethod
    case paymentMethods
    case updatePledge

    fileprivate var trackingString: String {
      switch self {
      case .applePay:             return "apple_pay"
      case .cancel:               return "cancel"
      case .changePaymentMethod:  return "change_payment_method"
      case .paymentMethods:       return "payment_methods"
      case .updatePledge:         return "update_pledge"
      }
    }
  }

  /**
   Describes the types of errors that can occur when trying to click a reward pledge button.

   - maximumAmount: A pledge amount was entered that is greater than what the project can handle.
   - minimumAmount: A pledge amount was entered that is less than the minimum the project requires.
   */
  public enum ErroredRewardPledgeButtonClickType {
    case maximumAmount
    case minimumAmount

    fileprivate var trackingString: String {
      switch self {
      case .maximumAmount:  return "MAXIMUM_AMOUNT"
      case .minimumAmount:  return "MINIMUM_AMOUNT"
      }
    }
  }

  /**
   Describes the types of payment methods that can be used.
   */
  public enum PaymentMethod {
    case applePay

    fileprivate var trackingString: String {
      switch self {
      case .applePay: return "apple_pay"
      }
    }
  }

  /**
   Describes the pages where checkout events can occur.
   */
  public enum CheckoutPageContext {
    case paymentsPage
    case projectPage
    case rewardSelection

    fileprivate var trackingString: String {
      switch self {
      case .paymentsPage:     return "Payments Page"
      case .projectPage:      return "Project Page"
      case .rewardSelection:  return "Reward Selection"
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
      case .activity:         return "activity"
      case .activitySample:   return "activity_sample"
      case .creatorActivity:  return "creator_activity"
      case .deepLink:         return "deep_link"
      case .draftPreview:     return "draft_preview"
      case .updates:          return "updates"
      }
    }
  }

  public init(bundle: NSBundleType = Bundle.main,
              client: TrackingClientType,
              config: Config? = nil,
              device: UIDeviceType = UIDevice.current,
              loggedInUser: User? = nil,
              screen: UIScreenType = UIScreen.main,
              distinctId: String = (UIDevice.current.identifierForVendor ?? UUID()).uuidString) {
    self.bundle = bundle
    self.client = client
    self.config = config
    self.device = device
    self.loggedInUser = loggedInUser
    self.screen = screen
    self.distinctId = distinctId
  }

  /// Call when the activities screen is shown.
  public func trackActivities() {
    self.track(event: "Activities", properties: deprecatedProps)
    self.track(event: "Viewed Activity")
  }

  /// Call when the activities are refreshed.
  public func trackLoadedNewerActivity() {
    self.track(event: "Loaded Newer Activity")
  }

  /// Call when the activities are paginated.
  ///
  /// - parameter page: The number of pages that have been loaded.
  public func trackLoadedOlderActivity(page: Int) {
    self.track(event: "Loaded Older Activity", properties: ["page": page])
  }

  /// Call when the app launches or enters foreground.
  public func trackAppOpen() {
    self.track(event: "App Open", properties: deprecatedProps)
    self.track(event: "Opened App")
  }

  /// Call when the app enters the background.
  public func trackAppClose() {
    self.track(event: "App Close", properties: deprecatedProps)
    self.track(event: "Closed App")
  }

  public func trackMemoryWarning() {
    self.track(event: "App Memory Warning")
  }

  public func trackCrashedApp() {
    self.track(event: "Crashed App")
  }

  public func trackNotificationOpened() {
    let props: [String:Any] = [
      "notification_type": "push",
    ]

    self.track(event: "Notification Opened",
               properties: props.withAllValuesFrom(deprecatedProps))

    self.track(event: "Opened Notification", properties: props)
  }

  public func trackOpenedAppBanner(_ queryParams: [String: String]) {
    let props: [String:Any] = queryParams

    self.track(event: "Smart App Banner Opened",
               properties: props.withAllValuesFrom(deprecatedProps))

    self.track(event: "Opened App Banner", properties: props)
  }

  public func trackUserActivity(_ userActivity: NSUserActivity) {
    let props = properties(userActivity: userActivity)

    self.track(event: "Continue User Activity",
               properties: props.withAllValuesFrom(deprecatedProps))

    self.track(event: "Opened Deep Link", properties: props)
  }

  public func trackAttemptingOnePasswordLogin() {
    // Deprecated event
    self.track(event: "Attempting 1password Login", properties: deprecatedProps)

    self.track(event: "Triggered 1Password")
  }

  // MARK: Discovery Events

  /**
   Call when a discovery search is made, including pagination.

   - parameter params: The params used for the discovery search.
   - parameter page: The number of pages that have been loaded.
   */
  public func trackDiscovery(params: DiscoveryParams, page: Int) {
    let props = properties(params: params).withAllValuesFrom(["page": page])

    self.track(event: "Loaded Discovery Results", properties: props)

    // Deprecated event
    self.track(event: "Discover List View",
               properties: props.withAllValuesFrom(deprecatedProps))
  }

  public func trackDiscoveryViewed(params: DiscoveryParams) {
    self.track(event: "Viewed Discovery", properties: properties(params: params))
  }

  public func trackDiscoveryFavoritedCategory(params: DiscoveryParams, isFavorited: Bool) {
    let props = params.category.map(properties) ?? [:]
    let deprecatedProps = props.withAllValuesFrom(
      ["toggle_to": isFavorited, Koala.DeprecatedKey: true]
    )

    self.track(event: isFavorited ? "Added Favorite Category" : "Removed Favorite Category",
               properties: props)

    // Deprecated event
    self.track(event: "Discover Category Favorite",
               properties: deprecatedProps)
  }

  /// Call when the discovery filters appear
  public func trackDiscoveryModal() {
    let props: [String:Any] = ["modal_type": "filters"]

    self.track(event: "Viewed Discovery Filters", properties: props)

    // Deprecated event
    self.track(event: "Discover Switch Modal",
               properties: props.withAllValuesFrom(deprecatedProps))
  }

  /**
   Call when a filter is selected from the discovery modal.

   - parameter params: The params selected from the modal.
   - parameter isFavorite: Whether the filter is a favorite category or not.
   */
  public func trackDiscoveryModalSelectedFilter(params: DiscoveryParams, isFavorite: Bool = false) {
    self.track(event: "Selected Discovery Filter",
               properties: properties(params: params).withAllValuesFrom([
                "is_favorite": isFavorite ? "1" : "0"
               ]))

    // Deprecated event
    self.track(event: "Discover Modal Selected Filter",
               properties: properties(params: params).withAllValuesFrom(deprecatedProps))
  }

  /**
   Call when closing filter modal without selecting a new filter.

   - parameter params: The params selected from the modal.
  **/
  public func trackDiscoveryModalClosedFilter(params: DiscoveryParams) {
    self.track(event: "Closed Discovery Filter", properties: properties(params: params))
  }

  /**
   Call when expanding filter on a parent category tap.

   - parameter params: The params selected from the modal.
  **/
  public func trackDiscoveryModalExpandedFilter(params: DiscoveryParams) {
    self.track(event: "Expanded Discovery Filter", properties: properties(params: params))
  }

  /**
   Call when the user swipes between sorts or selects a sort.

   - parameter sort: The new sort that was selected.
   - parameter gesture: The gesture that was used.
   */
  public func trackDiscoverySelectedSort(nextSort sort: DiscoveryParams.Sort, gesture: GestureType) {
    self.track(event: "Selected Discovery Sort", properties: [
      "discover_sort": sort.rawValue,
      "gesture_type": gesture.trackingString
      ])
  }

  public func trackSaveProject(context: SaveContext) {
    self.track(event: "Star", properties: [
      "context": context.trackingString
      ])
  }

  // MARK: Checkout Events
  public func trackCheckoutCancel(project: Project,
                                  reward: Reward,
                                  pledgeContext: PledgeContext) {

    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(properties(reward: reward))
      .withAllValuesFrom(["pledge_context": pledgeContext.trackingString])

    self.track(event: "Checkout Cancel", properties: props.withAllValuesFrom(deprecatedProps))
    self.track(event: "Canceled Checkout", properties: props)
  }

  public func trackClickedRewardPledgeButton(project: Project,
                                             reward: Reward,
                                             buttonType: ClickedRewardPledgeButtonType,
                                             pageContext: CheckoutPageContext,
                                             pledgeContext: PledgeContext) {

    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(properties(reward: reward))
      .withAllValuesFrom([
        "pledge_context": pledgeContext.trackingString,
        "type": buttonType.trackingString,
        "context": pageContext.trackingString
        ])

    self.track(event: "Clicked Reward Pledge Button", properties: props)
  }

  public func trackClickedRewardPledgeButton(project: Project,
                                             reward: Reward,
                                             errorText: String,
                                             errorType: ErroredRewardPledgeButtonClickType,
                                             paymentMethod: PaymentMethod?,
                                             pageContext: CheckoutPageContext,
                                             pledgeContext: PledgeContext) {

    var extraProps = [
      "error_text": errorText,
      "type": errorType.trackingString,
      "pledge_context": pledgeContext.trackingString,
      "context": pageContext.trackingString
    ]
    extraProps["payment_method"] = paymentMethod?.trackingString

    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(properties(reward: reward))
      .withAllValuesFrom(extraProps)

    self.track(event: "Errored Reward Pledge Button Click", properties: props)
  }

  public func trackChangedPledgeAmount(_ project: Project, reward: Reward, pledgeContext: PledgeContext) {
    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(properties(reward: reward))
      .withAllValuesFrom(["pledge_context": pledgeContext.trackingString])

    self.track(event: "Checkout Amount Changed", properties: props.withAllValuesFrom(deprecatedProps))

    self.track(event: "Changed Pledge Amount", properties: props)
  }

  public func trackSelectedShippingDestination(_ project: Project,
                                               reward: Reward,
                                               pledgeContext: PledgeContext) {

    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(properties(reward: reward))
      .withAllValuesFrom(["pledge_context": pledgeContext.trackingString])

    self.track(event: "Checkout Location Changed", properties: props.withAllValuesFrom(deprecatedProps))

    self.track(event: "Selected Shipping Destination", properties: props)
  }

  public func trackSelectedReward(project: Project, reward: Reward, pledgeContext: PledgeContext) {

    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(properties(reward: reward))
      .withAllValuesFrom(["pledge_context": pledgeContext.trackingString])

    self.track(event: "Reward Checkout", properties: props.withAllValuesFrom(deprecatedProps))

    self.track(event: "Selected Reward", properties: props)
  }

  public func trackClosedReward(project: Project, reward: Reward, pledgeContext: PledgeContext) {

    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(properties(reward: reward))
      .withAllValuesFrom(["pledge_context": pledgeContext.trackingString])

    self.track(event: "Closed Reward", properties: props)
  }

  // MARK: Login Events
  public func trackLoginTout(intent: LoginIntent) {
    // Deprecated event
    self.track(event: "Application Login or Signup",
               properties: [
                "intent": intent.trackingString,
                "context": intent.trackingString,
                Koala.DeprecatedKey: true
      ]
    )

    self.track(event: "Viewed Login Signup",
               properties: ["intent": intent.trackingString, "context": intent.trackingString])
  }

  public func trackLoginFormView(onePasswordIsAvailable: Bool) {
    self.track(event: "User Login",
               properties: [
                "1password_extension_available": onePasswordIsAvailable,
                Koala.DeprecatedKey: true
      ]
    )
    self.track(event: "Viewed Login",
               properties: ["one_password_extension_available": onePasswordIsAvailable])
  }

  public func trackLoginSuccess(authType: AuthType) {
    // Deprecated event
    self.track(event: "Login", properties: deprecatedProps)

    self.track(event: "Logged In", properties: ["auth_type": authType.trackingString])
  }

  public func trackLoginError(authType: AuthType) {
    // Deprecated event
    self.track(event: "Errored User Login", properties: deprecatedProps)

    self.track(event: "Errored Login", properties: ["auth_type": authType.trackingString])
  }

  public func trackResetPassword() {
    // Deprecated event
    self.track(event: "Forgot Password View", properties: deprecatedProps)

    self.track(event: "Viewed Forgot Password")
  }

  public func trackResetPasswordSuccess() {
    // Deprecated event
    self.track(event: "Forgot Password Requested", properties: deprecatedProps)

    self.track(event: "Requested Password Reset")
  }

  public func trackResetPasswordError() {
    // Deprecated event
    self.track(event: "Forgot Password Errored", properties: deprecatedProps)

    self.track(event: "Errored Forgot Password")
  }

  public func trackFacebookConfirmation() {
    // Deprecated event
    self.track(event: "Facebook Confirm", properties: deprecatedProps)

    self.track(event: "Viewed Facebook Signup")
  }

  public func trackTfa() {
    // Deprecated event
    self.track(event: "Two-factor Authentication Confirm View", properties: deprecatedProps)

    self.track(event: "Viewed Two-Factor Confirmation")
  }

  public func trackTfaResendCode() {
    // Deprecated event
    self.track(event: "Two-factor Authentication Resend Code", properties: deprecatedProps)

    self.track(event: "Resent Two-Factor Code")
  }

  // MARK: Signup

  // Call when an error is returned after attempting to signup.
  public func trackSignupError(authType: AuthType) {
    // Deprecated event
    self.track(event: "Errored User Signup", properties: deprecatedProps)

    self.track(event: "Errored Signup", properties: ["auth_type": authType.trackingString])
  }

  // Call when the user has successfully signed up for a new account.
  public func trackSignupSuccess(authType: AuthType) {
    // Deprecated event
    self.track(event: "New User", properties: deprecatedProps)

    self.track(event: "Signed Up", properties: ["auth_type": authType.trackingString])
  }

  // Call once when the signup view loads.
  public func trackSignupView() {
    // Deprecated event
    self.track(event: "User Signup", properties: deprecatedProps)

    self.track(event: "Viewed Signup")
  }

  // MARK: Comments Events
  public func trackLoadNewerComments(project: Project, update: Update?, context: CommentsContext) {
    let props = properties(project: project, loggedInUser: self.loggedInUser)
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

  public func trackLoadOlderComments(project: Project,
                                     update: Update?,
                                     page: Int,
                                     context: CommentsContext) {

    let props = properties(project: project, loggedInUser: self.loggedInUser)
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

  public func trackOpenedCommentEditor(project: Project,
                                       update: Update?,
                                       context: CommentDialogContext) {

    let props = properties(project: project, loggedInUser: self.loggedInUser)
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

  public func trackCanceledCommentEditor(project: Project,
                                         update: Update?,
                                         context: CommentDialogContext) {

    let props = properties(project: project, loggedInUser: self.loggedInUser)
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

  public func trackPostedComment(project: Project,
                                 update: Update?,
                                 context: CommentDialogContext) {
    let props = properties(project: project, loggedInUser: self.loggedInUser)
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
    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(properties(comment: comment))
      .withAllValuesFrom(deprecatedProps)

    self.track(event: "Project Comment Create", properties: props)
  }

  public func trackCommentCreate(comment: Comment, update: Update, project: Project) {
    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(properties(update: update))
      .withAllValuesFrom(properties(comment: comment))
      .withAllValuesFrom(deprecatedProps)

    self.track(event: "Update Comment Create", properties: props)
  }

  public func trackCommentsView(project: Project, update: Update?, context: CommentsContext) {
    let props = properties(project: project, loggedInUser: self.loggedInUser)
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

    guard shareContext.isLiveStreamContext != true else { return }

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

    self.track(event: "Canceled Share Sheet",
               properties: props)

    guard shareContext.isLiveStreamContext != true else { return }

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
  public func trackShowedShare(shareContext: ShareContext, shareActivityType: UIActivityType?) {
    let props = properties(shareContext: shareContext,
                           loggedInUser: self.loggedInUser,
                           shareActivityType: shareActivityType)
    self.track(event: "Showed Share", properties: props)

    guard shareContext.isLiveStreamContext != true else { return }

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
  public func trackCanceledShare(shareContext: ShareContext, shareActivityType: UIActivityType?) {
    let props = properties(shareContext: shareContext,
                           loggedInUser: self.loggedInUser,
                           shareActivityType: shareActivityType)
    self.track(event: "Canceled Share", properties: props)

    guard shareContext.isLiveStreamContext != true else { return }

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
  public func trackShared(shareContext: ShareContext, shareActivityType: UIActivityType?) {
    let props = properties(shareContext: shareContext,
                           loggedInUser: self.loggedInUser,
                           shareActivityType: shareActivityType)
    self.track(event: "Shared", properties: props)

    guard shareContext.isLiveStreamContext != true else { return }

    // Deprecated event
    let deprecatedEvent = shareContext.isThanksContext ? "Checkout Share"
      : shareContext.update != nil ? "Update Share"
      : "Project Share"
    self.track(event: deprecatedEvent, properties: props.withAllValuesFrom(deprecatedProps))
  }

  public func trackCheckoutFinishJumpToDiscovery(project: Project) {
    self.track(event: "Checkout Finished Discover More",
               properties: properties(project: project, loggedInUser: self.loggedInUser))
  }

  public func trackCheckoutFinishJumpToProject(project: Project) {
    self.track(event: "Checkout Finished Discover Open Project",
               properties: properties(project: project, loggedInUser: self.loggedInUser))
  }

  public func trackCheckoutFinishAppStoreRatingAlertRateNow(project: Project) {
    let props = properties(project: project, loggedInUser: self.loggedInUser)

    self.track(event: "Accepted App Store Rating Dialog", properties: props)

    // Deprecated event
    self.track(event: "Checkout Finished Alert App Store Rating Rate Now",
               properties: props.withAllValuesFrom(deprecatedProps))
  }

  public func trackCheckoutFinishAppStoreRatingAlertRemindLater(project: Project) {
    let props = properties(project: project, loggedInUser: self.loggedInUser)

    self.track(event: "Delayed App Store Rating Dialog", properties: props)

    // Deprecated event
    self.track(event: "Checkout Finished Alert App Store Rating Remind Later",
               properties: props.withAllValuesFrom(deprecatedProps))
  }

  public func trackCheckoutFinishAppStoreRatingAlertNoThanks(project: Project) {
    let props = properties(project: project, loggedInUser: self.loggedInUser)

    self.track(event: "Dismissed App Store Rating Dialog", properties: props)

    // Deprecated event
    self.track(event: "Checkout Finished Alert App Store Rating No Thanks",
               properties: props.withAllValuesFrom(deprecatedProps))
  }

  public func trackTriggeredAppStoreRatingDialog(project: Project) {
    self.track(event: "Triggered App Store Rating Dialog",
               properties: properties(project: project, loggedInUser: self.loggedInUser))
  }

  // MARK: Dashboard
  public func trackDashboardClosedProjectSwitcher(onProject project: Project) {
    self.track(event: "Closed Project Switcher",
               properties: properties(project: project, loggedInUser: self.loggedInUser))
  }

  public func trackDashboardSeeAllRewards(project: Project) {
    self.track(event: "Showed All Rewards",
               properties: properties(project: project, loggedInUser: self.loggedInUser))
  }

  public func trackDashboardSeeMoreReferrers(project: Project) {
    self.track(event: "Showed All Referrers",
               properties: properties(project: project, loggedInUser: self.loggedInUser))
  }

  public func trackDashboardShowProjectSwitcher(onProject project: Project) {
    self.track(event: "Showed Project Switcher",
               properties: properties(project: project, loggedInUser: self.loggedInUser))
  }

  public func trackDashboardSwitchProject(_ project: Project) {
    let props = properties(project: project, loggedInUser: self.loggedInUser)

    self.track(event: "Switched Projects", properties: props)

    // deprecated
    self.track(event: "Creator Project Navigate",
               properties: props.withAllValuesFrom(deprecatedProps))
  }

  public func trackDashboardView(project: Project) {
    let props = properties(project: project, loggedInUser: self.loggedInUser)

    self.track(event: "Viewed Project Dashboard", properties: props)

    // deprecated
    self.track(event: "Dashboard View",
               properties: props.withAllValuesFrom(deprecatedProps))
  }

  // MARK: Project activity
  public func trackViewedProjectActivity(project: Project) {
    let props = properties(project: project, loggedInUser: self.loggedInUser)

    self.track(event: "Viewed Project Activity", properties: props)
    // deprecated
    self.track(event: "Creator Activity View",
               properties: props.withAllValuesFrom(deprecatedProps))
  }

  public func trackLoadedNewerProjectActivity(project: Project) {
    let props = properties(project: project, loggedInUser: self.loggedInUser)

    self.track(event: "Loaded Newer Project Activity", properties: props)
    // deprecated
    self.track(event: "Creator Activity View Load Newer",
               properties: props.withAllValuesFrom(deprecatedProps))
  }

  public func trackLoadedOlderProjectActivity(project: Project, page: Int) {
    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(["page_count": page])

    self.track(event: "Loaded Older Project Activity", properties: props)
    // deprecated
    self.track(event: "Creator Activity View Load Older",
               properties: props.withAllValuesFrom(deprecatedProps))
  }

  // MARK: Messages

  public func trackMessageThreadsView(mailbox: Mailbox, project: Project?) {
    let props = project.flatMap { properties(project: $0, loggedInUser: self.loggedInUser) } ?? [:]

    switch mailbox {
    case .inbox:
      self.track(event: "Viewed Message Inbox", properties: props)
    case .sent:
      self.track(event: "Viewed Sent Messages", properties: props)
    }

    // deprecated
    let _deprecatedProps = props.withAllValuesFrom(deprecatedProps)
    self.track(event: "Message Threads View",
               properties: _deprecatedProps.withAllValuesFrom(["mailbox": mailbox.rawValue]))
    self.track(event: "Message Inbox View", properties: _deprecatedProps)
  }

  public func trackViewedMessageSearch(project: Project?) {
    let props = project.flatMap { properties(project: $0, loggedInUser: self.loggedInUser) } ?? [:]

    self.track(event: "Viewed Message Search", properties: props)
  }

  public func trackViewedMessageSearchResults(term: String, project: Project?, hasResults: Bool) {
    let props = (project.flatMap { properties(project: $0, loggedInUser: self.loggedInUser) } ?? [:])
      .withAllValuesFrom(["term": term])
    let _deprecatedProps = props.withAllValuesFrom(deprecatedProps)

    self.track(event: "Message Threads Search", properties: _deprecatedProps)
    self.track(event: "Message Inbox Search", properties: _deprecatedProps)

    self.track(event: "Viewed Message Search Results",
               properties: props.withAllValuesFrom(["has_results": hasResults]))
  }

  public func trackClearedMessageSearchTerm(project: Project?) {
    let props = project.flatMap { properties(project: $0, loggedInUser: self.loggedInUser) } ?? [:]

    self.track(event: "Cleared Message Search Term",
               properties: props)
  }

  public func trackMessageThreadView(project: Project) {
    let props = properties(project: project, loggedInUser: self.loggedInUser)

    self.track(event: "Message Thread View",
               properties: props.withAllValuesFrom(deprecatedProps))

    self.track(event: "Viewed Message Thread", properties: props)
  }

  public func trackViewedMessageEditor(project: Project, context: MessageDialogContext) {
    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(["message_type": "single", "context": context.rawValue])

    self.track(event: "Viewed Message Editor", properties: props)
  }

  /**
   Tracks an event for sending a message.

   - parameter project: The project that is the subject of the message.
   - parameter context: The place where the message was sent from.
   */
  public func trackMessageSent(project: Project, context: MessageDialogContext) {
    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(["message_type": "single", "context": context.rawValue])

    self.track(event: "Message Sent",
               properties: props.withAllValuesFrom(deprecatedProps))

    self.track(event: "Sent Message", properties: props)
  }

  // MARK: Search Events
  /// Call once when the search view is initially shown.
  public func trackProjectSearchView() {
    self.track(event: "Discover Search", properties: deprecatedProps)

    self.track(event: "Viewed Search")
  }

  // Call when projects have been obtained from a search.
  public func trackSearchResults(query: String, page: Int, hasResults: Bool) {
    let sharedProps: [String:Any] = ["search_term": query]

    let deprecatedProps = sharedProps.withAllValuesFrom(["page_count": page, Koala.DeprecatedKey: true])
    let props = sharedProps.withAllValuesFrom(["page": page, "has_results": hasResults])

    if page == 1 {
      self.track(event: "Discover Search Results", properties: deprecatedProps)

      self.track(event: "Loaded Search Results", properties: props)
    } else {
      self.track(event: "Discover Search Results Load More", properties: deprecatedProps)

      self.track(event: "Loaded More Search Results", properties: props)
    }
  }

  public func trackClearedSearchTerm() {
    self.track(event: "Cleared Search Term")
  }

  // MARK: Project Events
  /**
   Call when a project page is viewed.

   - parameter project:      The project being viewed.
   - parameter refTag:       The ref tag used when opening the project.
   - parameter cookieRefTag: The ref tag pulled from cookie storage when this project was shown.
   */
  public func trackProjectShow(_ project: Project,
                               liveStreamEvents: [LiveStreamEvent]?,
                               refTag: RefTag? = nil,
                               cookieRefTag: RefTag? = nil) {

    var props = properties(project: project, loggedInUser: self.loggedInUser)
    props["ref_tag"] = refTag?.stringTag
    props["referrer_credit"] = cookieRefTag?.stringTag
    props["live_stream_type"] = prioritizedLiveStreamState(
      fromLiveStreamEvents: liveStreamEvents)?.trackingString

    // Deprecated event
    self.track(event: "Project Page", properties: props.withAllValuesFrom(deprecatedProps))

    self.track(event: "Viewed Project Page", properties: props)
  }

  public func trackSwipedProject(_ project: Project, refTag: RefTag?, type: SwipeType) {

    var props = properties(project: project, loggedInUser: self.loggedInUser)
    props["ref_tag"] = refTag?.stringTag
    props["type"] = type.trackingString

    self.track(event: "Swiped Project", properties: props)
    self.track(event: "Project Navigate", properties: props)
  }

  public func trackClosedProjectPage(_ project: Project, refTag: RefTag?, gestureType: GestureType) {
    var props = properties(project: project, loggedInUser: self.loggedInUser)
    props["gesture_type"] = gestureType.trackingString
    props["ref_tag"] = refTag?.stringTag

    self.track(event: "Closed Project Page", properties: props)
  }

  public func trackProjectStar(_ project: Project, context: SaveContext) {
    guard let isStarred = project.personalization.isStarred else { return }

    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(["context": context.trackingString])

    // Deprecated event
    self.track(event: isStarred ? "Project Star" : "Project Unstar",
               properties: props.withAllValuesFrom(deprecatedProps))

    self.track(event: isStarred ? "Starred Project" : "Unstarred Project",
               properties: props)
  }

  public func trackOpenedExternalLink(project: Project, context: ExternalLinkContext ) {
    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(["context": context.trackingString])

    self.track(event: "Opened External Link", properties: props)
  }

  // MARK: Profile Events
  public func trackProfileView() {
    // deprecated
    self.track(event: "Profile View My", properties: deprecatedProps)

    self.track(event: "Viewed Profile")
  }

  public func trackViewedProfileTab(projectsType: ProfileProjectsType) {
    self.track(event: "Viewed Profile Tab", properties: ["type": projectsType.trackingString])
  }

  // MARK: Settings Events
  public func trackAppStoreRatingOpen() {
    // deprecated
    self.track(event: "App Store Rating Open", properties: deprecatedProps)

    self.track(event: "Opened App Store Listing")
  }

  public func trackCancelLogoutModal() {
    self.track(event: "Canceled Logout", properties: ["context": "modal"])
  }

  public func trackChangeEmailNotification(type: String, on: Bool) {
    self.track(event: on ? "Enabled Email Notifications" : "Disabled Email Notifications",
               properties: ["type": type])
  }

  /**
   Tracks an event for toggling a newsletter preference.

   - parameter newsletterType: The newsletter type.
   - parameter sendNewsletter: The boolean determining whether the newsletter should be sent or not.
   - parameter project: The referring project from which a newsletter preference is set (e.g. Thanks screen).
   - parameter context: The context from which the newsletter preference is set.
   */
  public func trackChangeNewsletter(newsletterType newsletter: Newsletter,
                                    sendNewsletter: Bool,
                                    project: Project?,
                                    context: NewsletterContext) {

    let props = project.flatMap { properties(project: $0, loggedInUser: self.loggedInUser) } ?? [:]
      .withAllValuesFrom(["context": context.trackingString, "type": newsletter.trackingString])

    self.track(event: sendNewsletter ? "Subscribed To Newsletter" : "Unsubscribed From Newsletter",
               properties: props)

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
    let props: [String:Any] = ["name": project.name, "id": project.id]
    self.track(event: "Changed Project Notifications", properties: props)
  }

  public func trackChangePushNotification(type: String, on: Bool) {
    self.track(event: on ? "Enabled Push Notifications" : "Disabled Push Notifications",
               properties: ["type": type])
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

  // MARK: Find Friends Events
  public func trackCloseFacebookConnect(source: FriendsSource) {
    self.track(event: "Close Facebook Connect", properties: ["source": source.trackingString])
  }

  public func trackCloseFindFriends(source: FriendsSource) {
    self.track(event: "Close Find Friends", properties: ["source": source.trackingString])
  }

  public func trackDeclineFriendFollowAll(source: FriendsSource) {
    self.track(event: "Facebook Friend Decline Follow All", properties: ["source": source.trackingString])
  }

  public func trackFacebookConnect(source: FriendsSource) {
    self.track(event: "Facebook Connect", properties: ["source": source.trackingString])
  }

  public func trackFacebookConnectError(source: FriendsSource) {
    self.track(event: "Facebook Connect Error", properties: ["source": source.trackingString])
  }

  public func trackFindFriendsView(source: FriendsSource) {
    self.track(event: "Find Friends View", properties: ["source": source.trackingString])
  }

  public func trackFriendFollow(source: FriendsSource) {
    self.track(event: "Facebook Friend Follow", properties: ["source": source.trackingString])
  }

  public func trackFriendFollowAll(source: FriendsSource) {
    self.track(event: "Facebook Friend Follow All", properties: ["source": source.trackingString])
  }

  public func trackFriendUnfollow(source: FriendsSource) {
    self.track(event: "Facebook Friend Unfollow", properties: ["source": source.trackingString])
  }

  // MARK: Update Draft Events

  public func trackViewedUpdateDraft(forProject project: Project) {
    self.track(event: "Viewed Draft", properties: updateDraftProperties(project: project))
  }

  public func trackClosedUpdateDraft(forProject project: Project) {
    self.track(event: "Closed Draft", properties: updateDraftProperties(project: project))
  }

  public func trackEditedUpdateDraftTitle(forProject project: Project) {
    self.track(event: "Edited Title", properties: updateDraftProperties(project: project))
  }

  public func trackEditedUpdateDraftBody(forProject project: Project) {
    self.track(event: "Edited Body", properties: updateDraftProperties(project: project))
  }

  public func trackStartedAddUpdateDraftAttachment(forProject project: Project) {
    self.track(event: "Started Add Attachment", properties: updateDraftProperties(project: project))
  }

  public func trackCompletedAddUpdateDraftAttachment(forProject project: Project,
                                                     attachedFrom source: AttachmentSource) {
    var props = updateDraftProperties(project: project)
    props["type"] = source.rawValue
    self.track(event: "Completed Add Attachment", properties: props)
  }

  public func trackCanceledAddUpdateDraftAttachment(forProject project: Project) {
    self.track(event: "Canceled Add Attachment", properties: updateDraftProperties(project: project))
  }

  public func trackFailedAddUpdateDraftAttachment(forProject project: Project) {
    self.track(event: "Failed Add Attachment", properties: updateDraftProperties(project: project))
  }

  public func trackStartedRemoveUpdateDraftAttachment(forProject project: Project) {
    self.track(event: "Started Remove Attachment", properties: updateDraftProperties(project: project))
  }

  public func trackCanceledRemoveUpdateDraftAttachment(forProject project: Project) {
    self.track(event: "Canceled Remove Attachment", properties: updateDraftProperties(project: project))
  }

  public func trackCompletedRemoveUpdateDraftAttachment(forProject project: Project) {
    self.track(event: "Completed Remove Attachment", properties: updateDraftProperties(project: project))
  }

  public func trackFailedRemoveUpdateDraftAttachment(forProject project: Project) {
    self.track(event: "Failed Remove Attachment", properties: updateDraftProperties(project: project))
  }

  public func trackChangedUpdateDraftVisibility(forProject project: Project, isPublic: Bool) {
    var props = properties(project: project, loggedInUser: self.loggedInUser)
    props["type"] = isPublic ? "public" : "backers_only"
    self.track(event: "Changed Visibility", properties: props)
  }

  public func trackPreviewedUpdate(forProject project: Project) {
    let props = updateDraftProperties(project: project)
    self.track(event: "Previewed Update", properties: props)

    self.track(event: "Update Preview", properties: props.withAllValuesFrom(deprecatedProps))
  }

  public func trackTriggeredPublishConfirmationModal(forProject project: Project) {
    self.track(event: "Triggered Publish Confirmation Modal",
               properties: updateDraftProperties(project: project))
  }

  public func trackCanceledPublishUpdate(forProject project: Project) {
    self.track(event: "Canceled Publish", properties: updateDraftProperties(project: project)
      .withAllValuesFrom(["context": "modal"]))
  }

  public func trackConfirmedPublishUpdate(forProject project: Project) {
    self.track(event: "Confirmed Publish", properties: updateDraftProperties(project: project)
      .withAllValuesFrom(["context": "modal"]))
  }

  public func trackPublishedUpdate(forProject project: Project, isPublic: Bool) {
    var props = updateDraftProperties(project: project)
    props["type"] = isPublic ? "public" : "backers_only"
    self.track(event: "Published Update", properties: props)

    self.track(event: "Update Published", properties: props.withAllValuesFrom(deprecatedProps))
  }

  private func updateDraftProperties(project: Project) -> [String:Any] {
    var props = properties(project: project, loggedInUser: self.loggedInUser)
    props["context"] = "update_draft"
    return props
  }

  // MARK: Pledge screen events
  public func trackViewedPledge(forProject project: Project) {
    self.track(event: "Viewed Pledge Info",
               properties: properties(project: project, loggedInUser: self.loggedInUser))

    // Deprecated event
    self.track(event: "Modal Dialog View",
               properties: ["modal_class": "backer_info", Koala.DeprecatedKey: true])
  }

  // MARK: Help events
  public func trackCanceledContactEmail(context: HelpContext) {
    self.track(event: "Canceled Contact Email", properties: ["context": context.trackingString])
  }

  public func trackCanceledHelpMenu(context: HelpContext) {
    self.track(event: "Canceled Help Menu", properties: ["context": context.trackingString])
  }

  public func trackOpenedContactEmail(context: HelpContext) {
    // deprecated
    self.track(event: "Contact Email Open", properties: deprecatedProps)
  }

  public func trackSelectedHelpOption(context: HelpContext, type: HelpType) {
    self.track(event: "Selected Help Option",
               properties: ["context": context.trackingString, "type": type.trackingString]
    )
  }

  public func trackSentContactEmail(context: HelpContext) {
    self.track(event: "Sent Contact Email",
               properties: ["context": context.trackingString])

    // deprecated
    self.track(event: "Contact Email Sent", properties: deprecatedProps)
  }

  public func trackShowedHelpMenu(context: HelpContext) {
    self.track(event: "Showed Help Menu", properties: ["context": context.trackingString])
  }

  // MARK: Video events
  public func trackVideoCompleted(forProject project: Project) {
    // deprecated
    self.track(event: "Project Video Complete", properties: deprecatedProps)

    self.track(event: "Completed Project Video",
               properties: properties(project: project, loggedInUser: self.loggedInUser))
  }

  public func trackVideoPaused(forProject project: Project) {
    // deprecated
    self.track(event: "Project Video Pause", properties: deprecatedProps)

    self.track(event: "Paused Project Video",
               properties: properties(project: project, loggedInUser: self.loggedInUser))
  }

  public func trackVideoResume(forProject project: Project) {
    // deprecated
    self.track(event: "Project Video Resume", properties: deprecatedProps)

    self.track(event: "Resumed Project Video",
               properties: properties(project: project, loggedInUser: self.loggedInUser))
  }

  public func trackVideoStart(forProject project: Project) {
    // deprecated
    self.track(event: "Project Video Start", properties: deprecatedProps)

    self.track(event: "Started Project Video",
               properties: properties(project: project, loggedInUser: self.loggedInUser))
  }

  // MARK: Apple Pay events

  public func trackShowApplePaySheet(project: Project,
                                     reward: Reward,
                                     pledgeContext: PledgeContext) {

    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(properties(reward: reward))
      .withAllValuesFrom(["pledge_context": pledgeContext.trackingString])

    // deprecated
    self.track(event: "Apple Pay Show Sheet",
               properties: props.withAllValuesFrom(deprecatedProps))

    self.track(event: "Showed Apple Pay Sheet", properties: props)
  }

  public func trackApplePayAuthorizedPayment(project: Project,
                                             reward: Reward,
                                             pledgeContext: PledgeContext) {

    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(properties(reward: reward))
      .withAllValuesFrom(["pledge_context": pledgeContext.trackingString])

    // deprecated
    self.track(event: "Apple Pay Authorized", properties: props.withAllValuesFrom(deprecatedProps))

    self.track(event: "Authorized Apple Pay", properties: props)
  }

  public func trackStripeTokenCreatedForApplePay(project: Project,
                                                 reward: Reward,
                                                 pledgeContext: PledgeContext) {

    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(properties(reward: reward))
      .withAllValuesFrom(["pledge_context": pledgeContext.trackingString])

    self.track(event: "Apple Pay Stripe Token Created", properties: props.withAllValuesFrom(deprecatedProps))

    self.track(event: "Created Apple Pay Stripe Token", properties: props)
  }

  public func trackStripeTokenErroredForApplePay(project: Project,
                                                 reward: Reward,
                                                 pledgeContext: PledgeContext) {

    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(properties(reward: reward))
      .withAllValuesFrom(["pledge_context": pledgeContext.trackingString])

    self.track(event: "Apple Pay Stripe Token Errored", properties: props.withAllValuesFrom(deprecatedProps))

    self.track(event: "Errored Apple Pay Stripe Token", properties: props)
  }

  public func trackApplePayFinished(project: Project,
                                    reward: Reward,
                                    pledgeContext: PledgeContext) {

    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(properties(reward: reward))
      .withAllValuesFrom(["pledge_context": pledgeContext.trackingString])

    self.track(event: "Apple Pay Finished", properties: props.withAllValuesFrom(deprecatedProps))
  }

  public func trackApplePaySheetCanceled(project: Project,
                                         reward: Reward,
                                         pledgeContext: PledgeContext) {

    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(properties(reward: reward))
      .withAllValuesFrom(["pledge_context": pledgeContext.trackingString])
    self.track(event: "Apple Pay Canceled", properties: props.withAllValuesFrom(deprecatedProps))

    self.track(event: "Canceled Apple Pay", properties: props)
  }

  // MARK: Empty State Events
  public func trackEmptyStateViewed(type: EmptyState) {
    self.track(event: "Viewed Empty State",
               properties: ["type": type.rawValue])
  }

  public func trackEmptyStateButtonTapped(type: EmptyState) {
    self.track(event: "Tapped Empty State Button",
               properties: ["type": type.rawValue])
  }

  public func trackExpandedRewardDescription(_ reward: Reward,
                                             project: Project,
                                             pledgeContext: PledgeContext) {

    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(properties(reward: reward))
      .withAllValuesFrom(["pledge_context": pledgeContext.trackingString])

    self.track(event: "Expanded Reward Description", properties: props)
  }

  public func trackExpandedUnavailableReward(_ reward: Reward,
                                             project: Project,
                                             pledgeContext: PledgeContext) {

    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(properties(reward: reward))
      .withAllValuesFrom(["pledge_context": pledgeContext.trackingString])

    self.track(event: "Expanded Unavailable Reward", properties: props)
  }

  public func trackPerformedShortcutItem(_ shortcutItem: ShortcutItem,
                                         availableShortcutItems: [ShortcutItem]) {
    self.track(
      event: "Performed Shortcut",
      properties: [
        "type": shortcutItem.typeString,
        "context": availableShortcutItems.map { $0.typeString }.joined(separator: ",")
      ]
    )
  }

  // MARK: Live streams
  public func trackChangedLiveStreamOrientation(project: Project,
                                                liveStreamEvent: LiveStreamEvent,
                                                toOrientation: UIInterfaceOrientation) {
    let orientationString = toOrientation.isLandscape ? "landscape" : "portrait"

    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(properties(liveStreamEvent: liveStreamEvent))
      .withAllValuesFrom(
        [
          "context": stateContext(forLiveStreamEvent: liveStreamEvent).trackingString,
          "type": orientationString
        ]
    )

    self.track(event: "Changed Live Stream Orientation", properties: props)
  }

  public func trackClosedLiveStream(project: Project,
                                    liveStreamEvent: LiveStreamEvent,
                                    startTime: TimeInterval,
                                    endTime: TimeInterval,
                                    refTag: RefTag) {
    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(properties(liveStreamEvent: liveStreamEvent))
      .withAllValuesFrom([
        "ref_tag": refTag.stringTag,
        "type": stateContext(forLiveStreamEvent: liveStreamEvent).trackingString,
        "duration": max(0, endTime - startTime)
      ])

    self.track(event: "Closed Live Stream", properties: props)
  }

  public func trackLiveStreamChatSentMessage(project: Project,
                                             liveStreamEvent: LiveStreamEvent) {
    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(properties(liveStreamEvent: liveStreamEvent))

    self.track(event: "Sent Live Stream Message", properties: props)
  }

  public func trackLiveStreamToggleSubscription(project: Project,
                                                liveStreamEvent: LiveStreamEvent,
                                                subscribed: Bool) {
    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(properties(liveStreamEvent: liveStreamEvent))
      .withAllValuesFrom(
        [
          "context": stateContext(forLiveStreamEvent: liveStreamEvent).trackingString
        ]
    )

    self.track(
      event: subscribed ? "Confirmed KSR Live Subscribe Button" : "Confirmed KSR Live Unsubscribe Button",
      properties: props
    )
  }

  public func trackLiveStreamDiscovery() {
    self.track(event: "Viewed Live Stream Discovery")
  }

  public func trackViewedLiveStreamCountdown(project: Project,
                                             liveStreamEvent: LiveStreamEvent,
                                             refTag: RefTag) {
    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(properties(liveStreamEvent: liveStreamEvent))
      .withAllValuesFrom(["ref_tag": refTag.stringTag])

    self.track(event: "Viewed Live Stream Countdown", properties: props)
  }

  public func trackViewedLiveStream(project: Project,
                                    liveStreamEvent: LiveStreamEvent,
                                    refTag: RefTag) {
    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(properties(liveStreamEvent: liveStreamEvent))
      .withAllValuesFrom(["ref_tag": refTag.stringTag])

    self.track(event: "Viewed Live Stream", properties: props)
  }

  public func trackWatchedLiveStream(project: Project,
                                     liveStreamEvent: LiveStreamEvent,
                                     refTag: RefTag,
                                     duration: Int) {
    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(properties(liveStreamEvent: liveStreamEvent))
      .withAllValuesFrom(["ref_tag": refTag.stringTag, "duration": duration])

    if liveStreamEvent.liveNow {
      self.track(event: "Watched Live Stream", properties: props)
    } else {
      self.track(event: "Watched Live Stream Replay", properties: props)
    }
  }

  // Private tracking method that merges in default properties.
  private func track(event: String, properties: [String:Any] = [:]) {
    self.client.track(
      event: event,
      properties: self.defaultProperties().withAllValuesFrom(properties)
    )
  }

  private func defaultProperties() -> [String: Any] {
    var props: [String:Any] = [:]

    props["manufacturer"] = "Apple"
    props["app_version"] = self.bundle.infoDictionary?["CFBundleVersion"]
    props["app_release"] = self.bundle.infoDictionary?["CFBundleShortVersionString"]
    props["model"] = Koala.deviceModel
    props["distinct_id"] = self.distinctId
    props["device_fingerprint"] = self.distinctId
    props["iphone_uuid"] = self.distinctId
    props["os"] = self.device.systemName
    props["os_version"] = self.device.systemVersion
    props["screen_width"] = UInt(self.screen.bounds.width)
    props["screen_height"] = UInt(self.screen.bounds.height)
    props["device_orientation"] = Koala.deviceOrientation
    props["preferred_content_size_category"] = UIApplication.shared.preferredContentSizeCategory

    props["mp_lib"] = "kickstarter_ios"
    props["koala_lib"] = "kickstarter_ios"

    props["client_type"] = "native"
    props["device_format"] = self.deviceFormat
    props["client_platform"] = self.clientPlatform
    props["cellular_connection"] = CTTelephonyNetworkInfo().currentRadioAccessTechnology
    props["wifi_connection"] = Reachability.current == .wifi

    if let loggedInUser = self.loggedInUser {
      properties(user: loggedInUser).forEach { props[$0] = $1 }
    }
    props["user_logged_in"] = loggedInUser != nil
    props["user_country"] = self.loggedInUser?.location?.country ?? self.config?.countryCode

    props["apple_pay_capable"] = PKPaymentAuthorizationViewController.applePayCapable()
    props["apple_pay_device"] = PKPaymentAuthorizationViewController.applePayDevice()

    props["time"] = Date().timeIntervalSince1970

    return props
  }

  private static let deviceModel: String? = {
    var size: Int = 0
    sysctlbyname("hw.machine", nil, &size, nil, 0)
    var machine = [CChar](repeating: 0, count: Int(size))
    sysctlbyname("hw.machine", &machine, &size, nil, 0)
    return String(cString: machine)
  }()

  private static var deviceOrientation: String {
    switch UIDevice.current.orientation {
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
    }
  }

  private var deviceFormat: String {
    switch self.device.userInterfaceIdiom {
    case .phone: return "phone"
    case .pad:   return "tablet"
    case .tv:    return "tv"
    default:     return "unspecified"
    }
  }

  private var clientPlatform: String {
    switch self.device.userInterfaceIdiom {
    case .phone, .pad: return "ios"
    case .tv:          return "tvos"
    default:           return "unspecified"
    }
  }
}

private func properties(project: Project,
                        loggedInUser: User?,
                        prefix: String = "project_") -> [String:Any] {

  var props: [String:Any] = [:]

  props["backers_count"] = project.stats.backersCount
  props["country"] = project.country.countryCode
  props["currency"] = project.country.currencyCode
  props["goal"] = project.stats.goal
  props["pid"] = project.id
  props["name"] = project.name
  props["pledged"] = project.stats.pledged
  props["percent_raised"] = project.stats.fundingProgress
  props["has_video"] = project.video != nil
  props["state"] = project.state.rawValue
  props["update_count"] = project.stats.updatesCount
  props["comments_count"] = project.stats.commentsCount

  let now = MockDate().timeIntervalSince1970
  props["hours_remaining"] = Int(ceil(max(0.0, (project.dates.deadline - now) / 3_600.0)))
  props["duration"] = Int(round(project.dates.deadline - project.dates.launchedAt))

  props["category"] = project.category.name
  props["parent_category"] = project.category.parent?.name

  props["location"] = project.location.name

  var loggedInUserProperties: [String:Any] = [:]
  if let user = loggedInUser {
    loggedInUserProperties["user_is_project_creator"] = project.creator.id == user.id
    loggedInUserProperties["user_is_backer"] = project.personalization.isBacking
    loggedInUserProperties["user_has_starred"] = project.personalization.isStarred
  }

  return props.prefixedKeys(prefix)
    .withAllValuesFrom(properties(user: project.creator, prefix: "creator_"))
    .withAllValuesFrom(loggedInUserProperties)
}

private func properties(update: Update, prefix: String = "update_") -> [String:Any] {

  var properties: [String:Any] = [:]

  properties["comments_count"] = update.commentsCount
  properties["user_has_liked"] = update.hasLiked
  properties["likes_count"] = update.likesCount
  properties["published_at"] = update.publishedAt
  properties["sequence"] = update.sequence

  return properties.prefixedKeys(prefix)
}

private func properties(comment: Comment, prefix: String = "comment_") -> [String:Any] {

  var properties: [String:Any] = [:]

  properties["body_length"] = comment.body.characters.count

  return properties.prefixedKeys(prefix)
}

private func properties(user: User, prefix: String = "user_") -> [String:Any] {
  var properties: [String:Any] = [:]

  properties["uid"] = user.id
  properties["backed_projects_count"] = user.stats.backedProjectsCount
  properties["created_projects_count"] = user.stats.createdProjectsCount
  properties["starred_projects_count"] = user.stats.starredProjectsCount

  return properties.prefixedKeys(prefix)
}

private func properties(userActivity: NSUserActivity) -> [String:Any] {
  var props: [String:Any] = [:]

  props["user_activity_type"] = userActivity.activityType
  props["user_activity_title"] = userActivity.title
  props["user_activity_webpage_url"] = userActivity.webpageURL?.absoluteString
  props["user_activity_keywords"] = Array(userActivity.keywords)

  return props
}

private func properties(params: DiscoveryParams, prefix: String = "discover_") -> [String:Any] {
  var result: [String:Any] = [:]

  // NB: All filters should be added here since `result["everything"]` is derived from this.
  result["recommended"] = params.recommended
  result["social"] = params.social
  result["staff_picks"] = params.staffPicks
  result["starred"] = params.starred
  result["term"] = params.query
  result = result.withAllValuesFrom(params.category.map(properties(category:)) ?? [:])

  result["everything"] = result.isEmpty
  result["page"] = params.page
  result["sort"] = params.sort?.rawValue

  return result.prefixedKeys("discover_")
}

private func properties(category: KsApi.Category) -> [String:Any] {

  var result: [String:Any] = [:]

  result["category_id"] = category.id
  result["category_name"] = category.name
  result["category_projects_count"] = category.projectsCount

  result["category_is_root"] = category.isRoot
  result["category_root_id"] = category.rootId
  result["category_root_name"] = category.root?.name

  let parentProperties = category.parent.map(properties(category:)) ?? [:]

  return result
    .withAllValuesFrom(parentProperties.prefixedKeys("parent_"))
}

private func properties(shareContext: ShareContext,
                        loggedInUser: User?,
                        shareActivityType: UIActivityType? = nil) -> [String:Any] {

  var result: [String:Any] = [:]

  result["share_activity_type"] = shareActivityType?.rawValue
  result["share_type"] = shareActivityType.flatMap(shareTypeProperty)

  switch shareContext {
  case let .creatorDashboard(project):
    result = result.withAllValuesFrom(properties(project: project, loggedInUser: loggedInUser))
    result["context"] = "creator_dashboard"
  case let .discovery(project):
    result = result.withAllValuesFrom(properties(project: project, loggedInUser: loggedInUser))
    result["context"] = "discovery"
  case let .project(project):
    result = result.withAllValuesFrom(properties(project: project, loggedInUser: loggedInUser))
    result["context"] = "project"
  case let .liveStream(project, event):
    result = result.withAllValuesFrom(properties(project: project, loggedInUser: loggedInUser))
    result["context"] = stateContext(forLiveStreamEvent: event).trackingString
  case let .thanks(project):
    result = result.withAllValuesFrom(properties(project: project, loggedInUser: loggedInUser))
    result["context"] = "thanks"
  case let .update(project, update):
    result = result.withAllValuesFrom(properties(project: project, loggedInUser: loggedInUser))
    result = result.withAllValuesFrom(properties(update: update))
    result["context"] = "update"
  }

  return result
}

private func properties(reward: Reward, prefix: String = "backer_reward_") -> [String:Any] {
  guard reward != Reward.noReward else { return [:] }

  var result: [String:Any] = [:]

  result["id"] = reward.id
  result["is_limited_quantity"] = reward.limit == nil
  // result["is_limited_time"] = // implement when reward scheduling is supported
  result["minimum"] = reward.minimum
  result["shipping_enabled"] = reward.shipping.enabled
  result["shipping_preference"] = reward.shipping.preference?.trackingString
  result["has_items"] = !reward.rewardsItems.isEmpty

  return result.prefixedKeys(prefix)
}

private func properties(liveStreamEvent: LiveStreamEvent,
                        prefix: String = "live_stream_") -> [String:Any] {
  var properties: [String:Any] = [:]

  properties["id"] = liveStreamEvent.id
  properties["is_live_now"] = liveStreamEvent.liveNow
  properties["state"] = stateContext(forLiveStreamEvent: liveStreamEvent).trackingString
  properties["name"] = liveStreamEvent.name
  properties["start_date"] = liveStreamEvent.startDate.timeIntervalSince1970

  return properties.prefixedKeys(prefix)
}

private func shareTypeProperty(_ shareType: UIActivityType?) -> String? {
  #if os(iOS)
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
    } else if shareType == UIActivityType("com.apple.mobilenotes.SharingExtension") {
      return "notes"
    } else if shareType == SafariActivityType {
      return "safari"
    } else {
      return shareType.rawValue
    }
  #else
    return nil
  #endif
}

extension Koala {
  public enum lens {
    public static let loggedInUser = Lens<Koala, User?>(
      view: { $0.loggedInUser },
      set: { Koala(bundle: $1.bundle, client: $1.client, config: $1.config, device: $1.device,
        loggedInUser: $0, screen: $1.screen, distinctId: $1.distinctId) }
    )

    public static let config = Lens<Koala, Config?>(
      view: { $0.config },
      set: { Koala(bundle: $1.bundle, client: $1.client, config: $0, device: $1.device,
        loggedInUser: $1.loggedInUser, screen: $1.screen, distinctId: $1.distinctId) }
    )
  }
}
// swiftlint:enable type_name

extension Reward.Shipping.Preference {
  fileprivate var trackingString: String {
    switch self {
    case .none:         return "none"
    case .restricted:   return "restricted"
    case .unrestricted: return "unrestricted"
    }
  }
}

private func stateContext(forLiveStreamEvent liveStreamEvent: LiveStreamEvent) -> LiveStreamStateContext {
  if liveStreamEvent.liveNow {
    return .live
  }

  if AppEnvironment.current.dateType.init().date >= liveStreamEvent.startDate {
    return .replay
  }

  return .countdown
}

private func prioritizedLiveStreamState(fromLiveStreamEvents liveStreamEvents: [LiveStreamEvent]?) ->
  LiveStreamStateContext? {

  guard let liveStreamEvents = liveStreamEvents else { return nil }

  return liveStreamEvents.map(stateContext(forLiveStreamEvent:))
    .sorted()
    .first
}

// Simple enum to map states on LiveStreamEvent
fileprivate enum LiveStreamStateContext: Comparable {
  case countdown
  case live
  case replay

  fileprivate var trackingString: String {
    switch self {
    case .live:      return "live_stream_live"
    case .countdown: return "live_stream_countdown"
    case .replay:    return "live_stream_replay"
    }
  }

  fileprivate static func == (lhs: LiveStreamStateContext, rhs: LiveStreamStateContext) -> Bool {
    switch (lhs, rhs) {
    case (.countdown, .countdown), (.live, .live), (.replay, .replay):
      return true
    default:
      return false
    }
  }

  fileprivate static func < (lhs: LiveStreamStateContext, rhs: LiveStreamStateContext) -> Bool {
    switch (lhs, rhs) {
    case (.live, .countdown), (.live, .replay), (.countdown, .replay):
      return true
    case (.countdown, .live), (.replay, .live), (.replay, .countdown),
         (.live, .live), (.countdown, .countdown), (.replay, .replay):
      return false
    }
  }
}
