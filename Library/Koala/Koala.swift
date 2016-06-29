// swiftlint:disable file_length
// swiftlint:disable type_body_length
import Foundation
import UIKit
import KsApi
import Prelude

public final class Koala {
  internal static let DeprecatedKey = "DEPRECATED"

  private let bundle: NSBundleType
  private let client: TrackingClientType
  private let config: Config?
  private let device: UIDeviceType
  private let loggedInUser: User?
  private let screen: UIScreenType

  /**
   Determines the place from which the message dialog was presented.

   - backerModel:     The backing view, usually seen by pressing "View pledge" on the project page.
   - creatorActivity: The creator's activity feed.
   - messages:        The messages inbox.
   - projectMessages: The messages inbox for a particular project of a creator's.
   - projectPage:     The project page.
   */
  public enum MessageDialogContext: String {
    case backerModel = "backer_modal"
    case creatorActivity = "creator_activity"
    case messages = "messages"
    case projectMessages = "project_messages"
    case projectPage = "project_page"
  }

  public init(bundle: NSBundleType = NSBundle.mainBundle(),
              client: TrackingClientType,
              config: Config? = nil,
              device: UIDeviceType = UIDevice.currentDevice(),
              loggedInUser: User? = nil,
              screen: UIScreenType = UIScreen.mainScreen()) {
    self.bundle = bundle
    self.client = client
    self.config = config
    self.device = device
    self.loggedInUser = loggedInUser
    self.screen = screen
  }

  /// Call when the activities screen is shown.
  public func trackActivities() {
    self.track(event: "Activities")
  }

  /// Call when the app launches or enters foreground.
  public func trackAppOpen() {
    self.track(event: "App Open")
  }

  /// Call when the app enters the background.
  public func trackAppClose() {
    self.track(event: "App Close")
  }

  public func trackAttemptingOnePasswordLogin() {
    self.track(event: "Attempting 1password Login")
  }

  /**
   Call when a discovery search is made, including pagination.

   - parameter params: The params used for the discovery search.
   - parameter page: The number of pages that have been loaded.
   */
  public func trackDiscovery(params params: DiscoveryParams, page: Int) {
    self.track(event: "Discover List View",
               properties: properties(params: params).withAllValuesFrom(["page": page]))
  }

  /// Call when the discovery filters appear
  public func trackDiscoveryModal() {
    self.track(event: "Discover Switch Modal", properties: ["modal_type": "filters"])
  }

  /**
   Call when a filter is selected from the discovery modal.

   - parameter params: The params selected from the modal.
   */
  public func trackDiscoveryModalSelectedFilter(params params: DiscoveryParams) {
    self.track(event: "Discover Modal Selected Filter", properties: properties(params: params))
  }

  /**
   Call when the user swipes between sorts.

   - parameter sort: The new sort that was swiped to.
   */
  public func trackDiscoverySortsSwiped(nextSort sort: DiscoveryParams.Sort) {
    self.track(event: "Discover Swiped Sorts", properties: ["discover_sort": sort.rawValue])
  }

  /**
   Call when the user swipes between sorts.

   - parameter sort: The new sort that was selected.
   */
  public func trackDiscoveryPagerSelectedSort(nextSort sort: DiscoveryParams.Sort) {
    self.track(event: "Discover Pager Selected Sort", properties: ["discover_sort": sort.rawValue])
  }

  // MARK: Login Events
  public func trackLoginTout(intent intent: LoginIntent) {

    let intentTrackingString: String
    switch intent {
    case .activity:             intentTrackingString = "activity"
    case .backProject:          intentTrackingString = "pledge"
    case .discoveryOnboarding:  intentTrackingString = "discovery_onboarding"
    case .favoriteCategory:     intentTrackingString = "favorite_category"
    case .generic:              intentTrackingString = "generic"
    case .loginTab:             intentTrackingString = "login_tab"
    case .messageCreator:       intentTrackingString = "new_message"
    case .starProject:          intentTrackingString = "star"
    }

    self.track(event: "Application Login or Signup",
               properties: ["intent": intentTrackingString, "context": intentTrackingString])
  }

  public func trackLoginFormView(onePasswordIsAvailable onePasswordIsAvailable: Bool) {
    self.track(event: "User Login",
               properties: [
                "1password_extension_available": onePasswordIsAvailable,
                Koala.DeprecatedKey: true
      ]
    )
    self.track(event: "Viewed Login",
               properties: ["1password_extension_available": onePasswordIsAvailable])
  }

  public func trackLoginSuccess() {
    self.track(event: "Login")
  }

  public func trackLoginError() {
    self.track(event: "Errored User Login")
  }

  public func trackResetPassword() {
    self.track(event: "Forgot Password View")
  }

  public func trackResetPasswordSuccess() {
    self.track(event: "Forgot Password Requested")
  }

  public func trackResetPasswordError() {
    self.track(event: "Forgot Password Errored")
  }

  public func trackFacebookConfirmation() {
    self.track(event: "Facebook Confirm")
  }

  public func trackFacebookLoginSuccess() {
    self.track(event: "Facebook Login")
  }

  public func trackFacebookLoginError() {
    self.track(event: "Errored Facebook Login")
  }

  public func trackTfa() {
    self.track(event: "Two-factor Authentication Confirm View")
  }

  public func trackTfaResendCode() {
    self.track(event: "Two-factor Authentication Resend Code")
  }

  // MARK: Signup

  // Call when an error is returned after attempting to signup.
  public func trackSignupError() {
    self.track(event: "Errored User Signup")
  }

  // Call when the user toggles the signup form's newsletter toggle.
  public func trackSignupNewsletterToggle(sendNewsletters: Bool) {
    self.track(event: "Signup Newsletter Toggle", properties: ["send_newsletters": sendNewsletters])
  }

  // Call when the user has successfully signed up for a new account.
  public func trackSignupSuccess() {
    self.track(event: "New User")
  }

  // Call once when the signup view loads.
  public func trackSignupView() {
    self.track(event: "User Signup")
  }

  // MARK: Comments Events
  public func trackLoadNewerComments(project project: Project) {
    self.track(event: "Project Comment Load New",
               properties: properties(project: project, loggedInUser: self.loggedInUser))
  }

  public func trackLoadNewerComments(update update: Update, project: Project) {
    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(properties(update: update))

    self.track(event: "Update Comment Load New", properties: props)
  }

  public func trackLoadOlderComments(project project: Project, page: Int) {
    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(["page_count": page])

    self.track(event: "Project Comment Load Older", properties: props)
  }

  public func trackLoadOlderComments(update update: Update, project: Project, page: Int) {
    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(properties(update: update))
      .withAllValuesFrom(["page_count": page])

    self.track(event: "Update Comment Load Older", properties: props)
  }

  public func trackCommentCreate(comment comment: Comment, project: Project) {
    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(properties(comment: comment))

    self.track(event: "Project Comment Create", properties: props)
  }

  public func trackCommentCreate(comment comment: Comment, update: Update, project: Project) {
    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(properties(update: update))
      .withAllValuesFrom(properties(comment: comment))

    self.track(event: "Update Comment Create", properties: props)
  }

  public func trackCommentsView(project project: Project) {
    self.track(event: "Project Comment View",
               properties: properties(project: project, loggedInUser: self.loggedInUser))
  }

  public func trackCommentsView(update update: Update, project: Project) {
    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(properties(update: update))

    self.track(event: "Update Comment View", properties: props)
  }

  /**
   Call when the share sheet is shown.

   - parameter shareContext: The context in which the sharing is happening.
   */
  public func trackShowedShareSheet(shareContext shareContext: ShareContext) {
    let props = properties(shareContext: shareContext, loggedInUser: self.loggedInUser)

    self.track(event: "Showed Share Sheet", properties: props)

    // Deprecated event
    let deprecatedEvent = shareContext.isThanksContext ? "Checkout Show Share Sheet"
      : shareContext.update != nil ? "Update Show Share Sheet"
      : "Project Show Share Sheet"
    self.track(event: deprecatedEvent, properties: props.withAllValuesFrom([Koala.DeprecatedKey: true]))
  }

  /**
   Call when the share sheet is canceled.

   - parameter shareContext: The context in which the sharing is happening.
   */
  public func trackCanceledShareSheet(shareContext shareContext: ShareContext) {
    let props = properties(shareContext: shareContext, loggedInUser: self.loggedInUser)

    self.track(event: "Canceled Share Sheet",
               properties: props)

    // Deprecated event
    let deprecatedEvent = shareContext.isThanksContext ? "Checkout Cancel Share Sheet"
      : shareContext.update != nil ? "Update Cancel Share Sheet"
      : "Project Cancel Share Sheet"
    self.track(event: deprecatedEvent, properties: props.withAllValuesFrom([Koala.DeprecatedKey: true]))
  }

  /**
   Call when a share dialog is shown. Note that this is showing the actual share dialog, and not
   simply the share sheet.

   - parameter shareContext:      The context in which the sharing is happening.
   - parameter shareActivityType: The type of share that was shown.
   */
  public func trackShowedShare(shareContext shareContext: ShareContext, shareActivityType: String?) {
    let props = properties(shareContext: shareContext,
                                loggedInUser: self.loggedInUser,
                                shareActivityType: shareActivityType)
    self.track(event: "Showed Share", properties: props)

    // Deprecated event
    let deprecatedEvent = shareContext.isThanksContext ? "Checkout Show Share"
      : shareContext.update != nil ? "Update Show Share"
      : "Project Show Share"
    self.track(event: deprecatedEvent, properties: props.withAllValuesFrom([Koala.DeprecatedKey: true]))
  }

  /**
   Call when a share dialog is canceled. Note that this is canceling the actual share dialog, and not
   simply the share sheet.

   - parameter shareContext:      The context in which the sharing is happening.
   - parameter shareActivityType: The type of share that was shown.
   */
  public func trackCanceledShare(shareContext shareContext: ShareContext, shareActivityType: String?) {
    let props = properties(shareContext: shareContext,
                           loggedInUser: self.loggedInUser,
                           shareActivityType: shareActivityType)
    self.track(event: "Canceled Share", properties: props)

    // Deprecated event
    let deprecatedEvent = shareContext.isThanksContext ? "Checkout Cancel Share"
      : shareContext.update != nil ? "Update Cancel Share"
      : "Project Cancel Share"
    self.track(event: deprecatedEvent, properties: props.withAllValuesFrom([Koala.DeprecatedKey: true]))
  }

  /**
   Call when a share is successfully performed.

   - parameter shareContext:      The context in which the sharing is happening.
   - parameter shareActivityType: The type of share that was shown.
   */
  public func trackShared(shareContext shareContext: ShareContext, shareActivityType: String?) {
    let props = properties(shareContext: shareContext,
                           loggedInUser: self.loggedInUser,
                           shareActivityType: shareActivityType)
    self.track(event: "Shared", properties: props)

    // Deprecated event
    let deprecatedEvent = shareContext.isThanksContext ? "Checkout Share"
      : shareContext.update != nil ? "Update Share"
      : "Project Share"
    self.track(event: deprecatedEvent, properties: props.withAllValuesFrom([Koala.DeprecatedKey: true]))
  }

  public func trackCheckoutFinishJumpToDiscovery(project project: Project) {
    self.track(event: "Checkout Finished Discover More",
               properties: properties(project: project, loggedInUser: self.loggedInUser))
  }

  public func trackCheckoutFinishJumpToProject(project project: Project) {
    self.track(event: "Checkout Finished Discover Open Project",
               properties: properties(project: project, loggedInUser: self.loggedInUser))
  }

  public func trackCheckoutFinishAppStoreRatingAlertRateNow(project project: Project) {
    self.track(event: "Checkout Finished Alert App Store Rating Rate Now",
               properties: properties(project: project, loggedInUser: self.loggedInUser))
  }

  public func trackCheckoutFinishAppStoreRatingAlertRemindLater(project project: Project) {
    self.track(event: "Checkout Finished Alert App Store Rating Remind Later",
               properties: properties(project: project, loggedInUser: self.loggedInUser))
  }

  public func trackCheckoutFinishAppStoreRatingAlertNoThanks(project project: Project) {
    self.track(event: "Checkout Finished Alert App Store Rating No Thanks",
               properties: properties(project: project, loggedInUser: self.loggedInUser))
  }

  /**
   Tracks an event for toggling a newsletter preference.

   - parameter sendNewsletter: The boolean determining whether the newsletter should be sent or not.
   - parameter project: The referring project from which a newsletter preference is set (e.g. Thanks screen).
   */
  public func trackNewsletterToggle(sendNewsletter: Bool, project: Project?) {
    let props = project.flatMap { properties(project: $0, loggedInUser: self.loggedInUser) } ?? [:]
    self.track(event: sendNewsletter ? "Newsletter Subscribe" : "Newsletter Unsubscribe",
               properties: props)
  }

  // MARK: Messages

  public func trackMessageThreadsView(mailbox mailbox: Mailbox, project: Project?) {
    let props = project.flatMap { properties(project: $0, loggedInUser: self.loggedInUser) } ?? [:]

    self.track(event: "Message Threads View",
               properties: props.withAllValuesFrom(["mailbox": mailbox.rawValue]))
    // deprecated
    self.track(event: "Message Inbox View",
               properties: props.withAllValuesFrom([Koala.DeprecatedKey: true]))
  }

  public func trackMessageThreadsSearch(term term: String, project: Project?) {
    let props = project.flatMap { properties(project: $0, loggedInUser: self.loggedInUser) } ?? [:]

    self.track(event: "Message Threads Search",
               properties: props.withAllValuesFrom(["term": term]))
    self.track(event: "Message Inbox Search",
               properties: props.withAllValuesFrom(["term": term, Koala.DeprecatedKey: true]))
  }

  public func trackMessageThreadView(project project: Project) {
    self.track(event: "Message Thread View",
               properties: properties(project: project, loggedInUser: self.loggedInUser))
  }

  /**
   Tracks an event for sending a message.

   - parameter project: The project that is the subject of the message.
   - parameter context: The place where the message was sent from.
   */
  public func trackMessageSent(project project: Project, context: MessageDialogContext) {
    let props = properties(project: project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(["message_type": "single", "context": context.rawValue])

    self.track(event: "Message Sent", properties: props)
  }

  // MARK: Search Events
  /// Call once when the search view is initially shown.
  public func trackProjectSearchView() {
    self.track(event: "Discover Search")
  }

  // Call when projects have been obtained from a search.
  public func trackSearchResults(query query: String, pageCount: Int) {
    let properties: [String:AnyObject] = ["search_term": query, "page_count": pageCount]

    if pageCount == 1 {
      self.track(event: "Discover Search Results", properties: properties)
    } else {
      self.track(event: "Discover Search Results Load More", properties: properties)
    }
  }

  // MARK: Project Events
  /**
   Call when a project page is viewed.

   - parameter project:      The project being viewed.
   - parameter refTag:       The ref tag used when opening the project.
   - parameter cookieRefTag: The ref tag pulled from cookie storage when this project was shown.
   */
  public func trackProjectShow(project: Project,
                               refTag: RefTag? = nil,
                               cookieRefTag: RefTag? = nil) {

    var props = properties(project: project, loggedInUser: self.loggedInUser)
    props["ref_tag"] = refTag?.stringTag
    props["referrer_credit"] = cookieRefTag?.stringTag

    self.track(event: "Project Page", properties: props)
  }

  public func trackProjectStar(project: Project) {
    guard let isStarred = project.personalization.isStarred else { return }

    let event = isStarred ? "Project Star" : "Project Unstar"
    self.track(event: event, properties: properties(project: project, loggedInUser: self.loggedInUser))
  }

  // MARK: Profile Events
  public func trackProfileView() {
    self.track(event: "Profile View My")
  }

  // MARK: Settings Events
  public func trackAppStoreRatingOpen() {
    self.track(event: "App Store Rating Open")
  }

  public func trackContactEmailOpen() {
    self.track(event: "Contact Email Open")
  }

  public func trackContactEmailSent() {
    self.track(event: "Contact Email Sent")
  }

  public func trackSettingsView() {
    self.track(event: "Settings View")
  }

  // MARK: Find Friends Events
  public func trackCloseFacebookConnect(source source: FriendsSource) {
    self.track(event: "Close Facebook Connect", properties: ["source": source.trackingString])
  }

  public func trackCloseFindFriends(source source: FriendsSource) {
    self.track(event: "Close Find Friends", properties: ["source": source.trackingString])
  }

  public func trackDeclineFriendFollowAll(source source: FriendsSource) {
    self.track(event: "Facebook Friend Decline Follow All", properties: ["source": source.trackingString])
  }

  public func trackFacebookConnect(source source: FriendsSource) {
    self.track(event: "Facebook Connect", properties: ["source": source.trackingString])
  }

  public func trackFacebookConnectError(source source: FriendsSource) {
    self.track(event: "Facebook Connect Error", properties: ["source": source.trackingString])
  }

  public func trackFindFriendsView(source source: FriendsSource) {
    self.track(event: "Find Friends View", properties: ["source": source.trackingString])
  }

  public func trackFriendFollow(source source: FriendsSource) {
    self.track(event: "Facebook Friend Follow", properties: ["source": source.trackingString])
  }

  public func trackFriendFollowAll(source source: FriendsSource) {
    self.track(event: "Facebook Friend Follow All", properties: ["source": source.trackingString])
  }

  public func trackFriendUnfollow(source source: FriendsSource) {
    self.track(event: "Facebook Friend Unfollow", properties: ["source": source.trackingString])
  }

  // MARK: Update Draft Events

  public enum AttachmentOrigin: String {
    case camera = "camera"
    case cameraRoll = "camera_roll"
  }

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
                                                           attachedFrom origin: AttachmentOrigin) {
    var props = updateDraftProperties(project: project)
    props["type"] = origin.rawValue
    self.track(event: "Completed Add Attachment", properties: props)
  }

  public func trackCanceledAddUpdateDraftAttachment(forProject project: Project) {
    self.track(event: "Canceled Add Attachment", properties: updateDraftProperties(project: project))
  }

  public func trackChangedUpdateDraftVisibility(forProject project: Project, isPublic: Bool) {
    var props = properties(project: project, loggedInUser: self.loggedInUser)
    props["type"] = isPublic ? "public" : "backers_only"
    self.track(event: "Changed Visibility", properties: props)
  }

  public func trackPreviewedUpdate(forProject project: Project) {
    var props = updateDraftProperties(project: project)
    self.track(event: "Previewed Update", properties: props)

    props[Koala.DeprecatedKey] = true
    self.track(event: "Update Preview", properties: props)
  }

  public func trackPublishedUpdate(forProject project: Project, isPublic: Bool) {
    var props = updateDraftProperties(project: project)
    props["type"] = isPublic ? "public" : "backers_only"
    self.track(event: "Published Update", properties: props)

    props[Koala.DeprecatedKey] = true
    self.track(event: "Update Published", properties: props)
  }

  private func updateDraftProperties(project project: Project) -> [String: AnyObject] {
    var props = properties(project: project, loggedInUser: self.loggedInUser)
    props["context"] = "update_draft"
    return props
  }

  // Private tracking method that merges in default properties.
  private func track(event event: String, properties: [String:AnyObject] = [:]) {
    self.client.track(
      event: event,
      properties: self.defaultProperties().withAllValuesFrom(properties)
    )
  }

  private func defaultProperties() -> [String: AnyObject] {
    var props: [String:AnyObject] = [:]

    props["manufacturer"] = "Apple"
    props["app_version"] = self.bundle.infoDictionary?["CFBundleVersion"]
    props["app_release"] = self.bundle.infoDictionary?["CFBundleShortVersionString"]
    props["model"] = Koala.deviceModel
    props["os"] = self.device.systemName
    props["os_version"] = self.device.systemVersion
    props["screen_width"] = UInt(self.screen.bounds.width)
    props["screen_height"] = UInt(self.screen.bounds.height)

    props["koala_lib"] = "iphone"

    props["client_type"] = "native"
    props["device_format"] = self.deviceFormat
    props["client_platform"] = self.clientPlatform

    if let loggedInUser = self.loggedInUser {
      properties(user: loggedInUser).forEach { props[$0] = $1 }
    }
    props["user_logged_in"] = loggedInUser != nil
    props["user_country"] = self.loggedInUser?.location?.country ?? self.config?.countryCode

    return props
  }

  private static let deviceModel: String? = {
    var size: Int = 0
    sysctlbyname("hw.machine", nil, &size, nil, 0)
    var machine = [CChar](count: Int(size), repeatedValue: 0)
    sysctlbyname("hw.machine", &machine, &size, nil, 0)
    return String.fromCString(machine)
  }()

  private var deviceFormat: String {
    switch self.device.userInterfaceIdiom {
    case .Phone: return "phone"
    case .Pad:   return "tablet"
    case .TV:    return "tv"
    default:     return "unspecified"
    }
  }

  private var clientPlatform: String {
    switch self.device.userInterfaceIdiom {
    case .Phone, .Pad: return "ios"
    case .TV:          return "tvos"
    default:           return "unspecified"
    }
  }
}

private func properties(project project: Project,
                                loggedInUser: User?,
                                prefix: String = "project_") -> [String:AnyObject] {

  var props = [String:AnyObject]()

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

  let now = NSDate().timeIntervalSince1970
  props["hours_remaining"] = Int(ceil(max(0.0, (project.dates.deadline - now) / 3_600.0)))
  props["duration"] = Int(round(project.dates.deadline - project.dates.launchedAt))

  props["category"] = project.category.name
  props["parent_category"] = project.category.parent?.name

  props["location"] = project.location.name

  var loggedInUserProperties: [String:AnyObject] = [:]
  if let user = loggedInUser {
    loggedInUserProperties["user_is_project_creator"] = project.creator.id == user.id
    loggedInUserProperties["user_is_backer"] = project.personalization.isBacking
    loggedInUserProperties["user_has_starred"] = project.personalization.isStarred
  }

  return props.prefixedKeys(prefix)
    .withAllValuesFrom(properties(user: project.creator, prefix: "creator_"))
    .withAllValuesFrom(loggedInUserProperties)
}

private func properties(update update: Update, prefix: String = "update_") -> [String:AnyObject] {

  var properties: [String:AnyObject] = [:]

  properties["comments_count"] = update.commentsCount
  properties["user_has_liked"] = update.hasLiked
  properties["likes_count"] = update.likesCount
  properties["published_at"] = update.publishedAt
  properties["sequence"] = update.sequence

  return properties.prefixedKeys(prefix)
}

private func properties(comment comment: Comment, prefix: String = "comment_") -> [String:AnyObject] {

  var properties: [String:AnyObject] = [:]

  properties["body_length"] = comment.body.characters.count

  return properties.prefixedKeys(prefix)
}

private func properties(user user: User, prefix: String = "user_") -> [String:AnyObject] {

  var properties = [String:AnyObject]()

  properties["uid"] = user.id
  properties["backed_projects_count"] = user.stats.backedProjectsCount
  properties["created_projects_count"] = user.stats.createdProjectsCount
  properties["starred_projects_count"] = user.stats.starredProjectsCount

  return properties.prefixedKeys(prefix)
}

private func properties(params params: DiscoveryParams, prefix: String = "discover_") -> [String:AnyObject] {
  var result: [String:AnyObject] = [:]

  result["staff_picks"] = params.staffPicks
  result["starred"] = params.starred
  result["everything"] = nil
  result["social"] = params.social
  result["sort"] = params.sort?.rawValue
  result["term"] = params.query
  result["page"] = params.page

  return result
    .withAllValuesFrom(params.category.map(properties(category:)) ?? [:])
    .prefixedKeys("discover_")
}

private func properties(category category: KsApi.Category) -> [String:AnyObject] {

  var result: [String:AnyObject] = [:]

  result["category_id"] = category.id
  result["category_name"] = category.name
  result["category_projects_count"] = category.projectsCount

  result["category_is_root"] = category.isRoot
  result["category_root_id"] = category.rootId
  result["category_root_name"] = category.isRoot

  let parentProperties = category.parent.map(properties(category:)) ?? [:]

  return result
    .withAllValuesFrom(parentProperties.prefixedKeys("parent_"))
}

private func properties(shareContext shareContext: ShareContext,
                                     loggedInUser: User?,
                                     shareActivityType: String? = nil) -> [String:AnyObject] {

  var result: [String:AnyObject] = [:]

  result["share_activity_type"] = shareActivityType
  result["share_type"] = shareTypeProperty(shareActivityType)

  switch shareContext {
  case let .creatorDashboard(project):
    result = result.withAllValuesFrom(properties(project: project, loggedInUser: loggedInUser))
    result["context"] = "creator_dashboard"
  case let .project(project):
    result = result.withAllValuesFrom(properties(project: project, loggedInUser: loggedInUser))
    result["context"] = "project"
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

private func shareTypeProperty(shareType: String?) -> String {
  #if os(iOS)
  guard let shareType = shareType else { return "" }

  if shareType == UIActivityTypePostToFacebook {
    return "facebook"
  } else if shareType == UIActivityTypeMessage {
    return "message"
  } else if shareType == UIActivityTypeMail {
    return "email"
  } else if shareType == UIActivityTypeCopyToPasteboard {
    return "copy link"
  } else if shareType == UIActivityTypePostToTwitter {
    return "twitter"
  } else if shareType == "com.apple.mobilenotes.SharingExtension" {
    return "notes"
  } else if shareType == SafariActivityType {
    return "safari"
  } else {
    return shareType
  }
  #else
  return ""
  #endif
}

// swiftlint:disable type_name
extension Koala {
  public enum lens {
    public static let loggedInUser = Lens<Koala, User?>(
      view: { $0.loggedInUser },
      set: { Koala(bundle: $1.bundle, client: $1.client, config: $1.config, device: $1.device,
        loggedInUser: $0, screen: $1.screen) }
    )

    public static let config = Lens<Koala, Config?>(
      view: { $0.config },
      set: { Koala(bundle: $1.bundle, client: $1.client, config: $0, device: $1.device,
        loggedInUser: $1.loggedInUser, screen: $1.screen) }
    )
  }
}
// swiftlint:enable type_name
