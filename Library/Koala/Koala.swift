// swiftlint:disable file_length
import Foundation
import UIKit
import KsApi
import Prelude

public final class Koala {
  private let client: TrackingClientType
  private let loggedInUser: User?
  private let bundle: NSBundleType
  private let device: UIDeviceType
  private let screen: UIScreenType

  // swiftlint:disable type_name
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
  // swiftlint:enable type_name

  public init(client: TrackingClientType,
              loggedInUser: User? = nil,
              bundle: NSBundleType = NSBundle.mainBundle(),
              device: UIDeviceType = UIDevice.currentDevice(),
              screen: UIScreenType = UIScreen.mainScreen()) {
    self.client = client
    self.loggedInUser = loggedInUser
    self.bundle = bundle
    self.device = device
    self.screen = screen
  }

  public func withLoggedInUser(loggedInUser: User?) -> Koala {
    return Koala(
      client: self.client,
      loggedInUser: loggedInUser,
      bundle: self.bundle,
      device: self.device,
      screen: self.screen
    )
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

  /// Call when a discovery search is made, including pagination.
  public func trackDiscovery() {
    self.track(event: "Discovery List View")
  }

  // MARK: Login Events
  public func trackLoginTout(intent: String) {
    self.track(event: "Application Login or Signup", properties: ["intent": intent])
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
               properties: projectProperties(project, loggedInUser: self.loggedInUser))
  }

  public func trackLoadNewerComments(update update: Update, project: Project) {
    let properties = projectProperties(project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(updateProperties(update))

    self.track(event: "Update Comment Load New", properties: properties)
  }

  public func trackLoadOlderComments(project project: Project, page: Int) {
    let properties = projectProperties(project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(["page_count": page])

    self.track(event: "Project Comment Load Older", properties: properties)
  }

  public func trackLoadOlderComments(update update: Update, project: Project, page: Int) {
    let properties = projectProperties(project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(updateProperties(update))
      .withAllValuesFrom(["page_count": page])

    self.track(event: "Update Comment Load Older", properties: properties)
  }

  public func trackCommentCreate(comment comment: Comment, project: Project) {
    let properties = projectProperties(project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(commentProperties(comment))

    self.track(event: "Project Comment Create", properties: properties)
  }

  public func trackCommentCreate(comment comment: Comment, update: Update, project: Project) {
    let properties = projectProperties(project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(updateProperties(update))
      .withAllValuesFrom(commentProperties(comment))

    self.track(event: "Update Comment Create", properties: properties)
  }

  public func trackCommentsView(project project: Project) {
    self.track(event: "Project Comment View",
               properties: projectProperties(project, loggedInUser: self.loggedInUser))
  }

  public func trackCommentsView(update update: Update, project: Project) {
    let properties = projectProperties(project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(updateProperties(update))

    self.track(event: "Update Comment View", properties: properties)
  }

  // MARK: Checkout Events
  public func trackCheckoutNext() {
    self.track(event: "Checkout Next")
  }

  public func trackCheckoutCancel() {
    self.track(event: "Checkout Cancel")
  }

  public func trackCheckoutLoadFailed() {
    self.track(event: "Checkout Page Failed")
  }

  public func trackCheckoutShowShareSheet(project project: Project) {
    self.track(event: "Checkout Show Share Sheet",
               properties: projectProperties(project, loggedInUser: self.loggedInUser))
  }

  public func trackCheckoutCancelShareSheet(project project: Project) {
    self.track(event: "Checkout Cancel Share Sheet",
               properties: projectProperties(project, loggedInUser: self.loggedInUser))
  }

  public func trackCheckoutCancelShare(project project: Project, shareType: String?) {
    let properties = projectProperties(project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(["share_type": shareTypeProperty(shareType)])

    self.track(event: "Checkout Cancel Share", properties: properties)
  }

  public func trackCheckoutShowShare(project project: Project, shareType: String?) {
    let properties = projectProperties(project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(["share_type": shareTypeProperty(shareType)])

    self.track(event: "Checkout Show Share", properties: properties)
  }

  // cancel share event

  public func trackCheckoutShare(project project: Project, shareType: String?) {
    let properties = projectProperties(project, loggedInUser: self.loggedInUser)
      .withAllValuesFrom(["share_type": shareTypeProperty(shareType)])

    self.track(event: "Checkout Share", properties: properties)
  }

  public func trackCheckoutFinishJumpToDiscovery(project project: Project) {
    self.track(event: "Checkout Finished Discover More",
               properties: projectProperties(project, loggedInUser: self.loggedInUser))
  }

  public func trackCheckoutFinishJumpToProject(project project: Project) {
    self.track(event: "Checkout Finished Discover Open Project",
               properties: projectProperties(project, loggedInUser: self.loggedInUser))
  }

  public func trackCheckoutFinishAppStoreRatingAlertRateNow(project project: Project) {
    self.track(event: "Checkout Finished Alert App Store Rating Rate Now",
               properties: projectProperties(project, loggedInUser: self.loggedInUser))
  }

  public func trackCheckoutFinishAppStoreRatingAlertRemindLater(project project: Project) {
    self.track(event: "Checkout Finished Alert App Store Rating Remind Later",
               properties: projectProperties(project, loggedInUser: self.loggedInUser))
  }

  public func trackCheckoutFinishAppStoreRatingAlertNoThanks(project project: Project) {
    self.track(event: "Checkout Finished Alert App Store Rating No Thanks",
               properties: projectProperties(project, loggedInUser: self.loggedInUser))
  }

  /**
   Tracks an event for toggling a newsletter preference.

   - parameter sendNewsletter: The boolean determining whether the newsletter should be sent or not.
   - parameter project: The referring project from which a newsletter preference is set (e.g. Thanks screen).
   */
  public func trackNewsletterToggle(sendNewsletter: Bool, project: Project?) {
    let properties = project.flatMap { projectProperties($0, loggedInUser: self.loggedInUser) } ?? [:]
    if sendNewsletter {
      self.track(event: "Newsletter Subscribe", properties: properties)
    } else {
      self.track(event: "Newsletter Unsubscribe", properties: properties)
    }
  }

  // MARK: Messages

  public func trackMessageThreadsView(mailbox mailbox: Mailbox, project: Project?) {
    let properties = project.flatMap { projectProperties($0, loggedInUser: self.loggedInUser) } ?? [:]

    self.track(event: "Message Threads View",
               properties: properties.withAllValuesFrom(["mailbox": mailbox.rawValue]))
    // deprecated
    self.track(event: "Message Inbox View",
               properties: properties.withAllValuesFrom(["DEPRECATED": true]))
  }

  public func trackMessageThreadsSearch(term term: String, project: Project?) {
    let properties = project.flatMap { projectProperties($0, loggedInUser: self.loggedInUser) } ?? [:]

    self.track(event: "Message Threads Search",
               properties: properties.withAllValuesFrom(["term": term]))
    self.track(event: "Message Inbox Search",
               properties: properties.withAllValuesFrom(["term": term, "DEPRECATED": true]))
  }

  public func trackMessageThreadView(project project: Project) {
    self.track(event: "Message Thread View",
               properties: projectProperties(project, loggedInUser: self.loggedInUser))
  }

  /**
   Tracks an event for sending a message.

   - parameter project: The project that is the subject of the message.
   - parameter context: The place where the message was sent from.
   */
  public func trackMessageSent(project project: Project, context: MessageDialogContext) {
    let props = projectProperties(project, loggedInUser: self.loggedInUser)
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

    var properties = projectProperties(project, loggedInUser: self.loggedInUser)
    properties["ref_tag"] = refTag?.stringTag
    properties["referrer_credit"] = cookieRefTag?.stringTag

    self.track(event: "Project Page", properties: properties)
  }

  public func trackProjectStar(project: Project) {
    guard let isStarred = project.personalization.isStarred else { return }

    let event = isStarred ? "Project Star" : "Project Unstar"
    self.track(event: event, properties: projectProperties(project, loggedInUser: self.loggedInUser))
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
    props["model"] = self.deviceModel
    props["os"] = self.device.systemName
    props["os_version"] = self.device.systemVersion
    props["screen_width"] = UInt(self.screen.bounds.width)
    props["screen_height"] = UInt(self.screen.bounds.height)

    props["koala_lib"] = "iphone"

    props["client_type"] = "native"
    props["device_format"] = self.deviceFormat
    props["client_platform"] = self.clientPlatform

    if let loggedInUser = self.loggedInUser {
      userProperties(loggedInUser).forEach { props[$0] = $1 }
    }
    props["user_logged_in"] = loggedInUser != nil

    return props
  }

  private lazy var deviceModel: String? = {
    var size: Int = 0
    sysctlbyname("hw.machine", nil, &size, nil, 0)
    var machine = [CChar](count: Int(size), repeatedValue: 0)
    sysctlbyname("hw.machine", &machine, &size, nil, 0)
    return String.fromCString(machine)
  }()

  private lazy var deviceFormat: String = {
    switch self.device.userInterfaceIdiom {
    case .Phone: return "phone"
    case .Pad:   return "tablet"
    case .TV:    return "tv"
    default:     return "unspecified"
    }
  }()

  private lazy var clientPlatform: String = {
    switch self.device.userInterfaceIdiom {
    case .Phone, .Pad: return "ios"
    case .TV:          return "tvos"
    default:           return "unspecified"
    }
  }()
}

private func projectProperties(project: Project,
                               loggedInUser: User?,
                               prefix: String = "project_") -> [String:AnyObject] {

  var properties = [String:AnyObject]()

  properties["backers_count"] = project.stats.backersCount
  properties["country"] = project.country.countryCode
  properties["currency"] = project.country.currencyCode
  properties["goal"] = project.stats.goal
  properties["pid"] = project.id
  properties["name"] = project.name
  properties["pledged"] = project.stats.pledged
  properties["percent_raised"] = project.stats.fundingProgress
  properties["has_video"] = project.video != nil
  properties["state"] = project.state.rawValue
  properties["update_count"] = project.stats.updatesCount
  properties["comments_count"] = project.stats.commentsCount

  let now = NSDate().timeIntervalSince1970
  properties["hours_remaining"] = Int(ceil(max(0.0, (project.dates.deadline - now) / 3_600.0)))
  properties["duration"] = Int(round(project.dates.deadline - project.dates.launchedAt))

  properties["category"] = project.category.name
  properties["parent_category"] = project.category.parent?.name

  properties["location"] = project.location.name

  var loggedInUserProperties: [String:AnyObject] = [:]
  if let user = loggedInUser {
    loggedInUserProperties["user_is_project_creator"] = project.creator.id == user.id
    loggedInUserProperties["user_is_backer"] = project.personalization.isBacking
    loggedInUserProperties["user_has_starred"] = project.personalization.isStarred
  }

  return properties.prefixedKeys(prefix)
    .withAllValuesFrom(userProperties(project.creator, prefix: "creator_"))
    .withAllValuesFrom(loggedInUserProperties)
}

private func updateProperties(update: Update, prefix: String = "update_") -> [String:AnyObject] {

  var properties: [String:AnyObject] = [:]

  properties["comments_count"] = update.commentsCount
  properties["user_has_liked"] = update.hasLiked
  properties["likes_count"] = update.likesCount
  properties["published_at"] = update.publishedAt
  properties["sequence"] = update.sequence

  return properties.prefixedKeys(prefix)
}

private func commentProperties(comment: Comment, prefix: String = "comment_") -> [String:AnyObject] {

  var properties: [String:AnyObject] = [:]

  properties["body_length"] = comment.body.characters.count

  return properties.prefixedKeys(prefix)
}

private func userProperties(user: User, prefix: String = "user_") -> [String:AnyObject] {

  var properties = [String:AnyObject]()

  properties["uid"] = user.id
  properties["backed_projects_count"] = user.stats.backedProjectsCount
  properties["created_projects_count"] = user.stats.createdProjectsCount
  properties["starred_projects_count"] = user.stats.starredProjectsCount

  return properties.prefixedKeys(prefix)
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
  } else {
    return shareType
  }
  #else
    return ""
  #endif
}
