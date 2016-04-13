import Foundation
import UIKit
import Models
import Prelude

public final class Koala {
  private let client: TrackingClientType
  private let loggedInUser: User?
  private let bundle: NSBundleType
  private let device: UIDeviceType
  private let screen: UIScreenType

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

  public func trackSignupSuccess() {
    self.track(event: "New User")
  }

  public func trackSignupNewsletterToggle(sendNewsletters: Bool) {
    self.track(event: "Signup Newsletter Toggle", properties: ["send_newsletters": sendNewsletters])
  }

  public func trackFacebookConfirmation() {
    self.track(event: "Facebook Confirm")
  }

  public func trackTfa() {
    self.track(event: "Two-factor Authentication Confirm View")
  }

  public func trackTfaResendCode() {
    self.track(event: "Two-factor Authentication Resend Code")
  }

  public func trackLoadNewerProjectComments() {
    self.track(event: "Project Comment Load New")
  }

  public func trackLoadNewerUpdateComments() {
    self.track(event: "Update Comment Load New")
  }

  public func trackLoadOlderProjectComments(page: Int) {
    self.track(event: "Project Comment Load Older", properties: ["page_count": page])
  }

  public func trackLoadOlderUpdateComments(page: Int) {
    self.track(event: "Update Comment Load Older", properties: ["page_count": page])
  }

  public func trackProjectCommentCreate() {
    self.track(event: "Project Comment Create")
  }

  public func trackUpdateCommentCreate() {
    self.track(event: "Update Comment Create")
  }

  public func trackProjectCommentsView() {
    self.track(event: "Project Comment View")
  }

  public func trackUpdateCommentsView() {
    self.track(event: "Update Comment View")
  }

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
    guard let isStarred = project.isStarred else { return }

    let event = isStarred ? "Project Star" : "Project Unstar"
    self.track(event: event, properties: projectProperties(project, loggedInUser: self.loggedInUser))
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

    // TODO: device_fingerprint, apple_pay_capable, iphone_uuid, preferred_content_size_category,
    //       device_orientation

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
  properties["percent_raised"] = project.fundingProgress
  properties["has_video"] = project.video != nil
  properties["state"] = project.state.rawValue
  properties["update_count"] = project.stats.updatesCount
  properties["comments_count"] = project.stats.commentsCount

  let now = NSDate().timeIntervalSince1970
  properties["hours_remaining"] = Int(ceil(max(0.0, (project.deadline - now) / 3_600.0)))
  properties["duration"] = Int(project.deadline - project.launchedAt)

  properties["category"] = project.category.name
  properties["parent_category"] = project.category.parent?.name

  properties["location"] = project.location.name

  var loggedInUserProperties: [String:AnyObject] = [:]
  if let user = loggedInUser {
    loggedInUserProperties["user_is_project_creator"] = project.creator.id == user.id
    loggedInUserProperties["user_is_backer"] = project.isBacking ?? false
    loggedInUserProperties["user_has_starred"] = project.isStarred ?? false
  }


  return properties.prefixedKeys(prefix)
    .withAllValuesFrom(userProperties(project.creator, prefix: "creator_"))
    .withAllValuesFrom(loggedInUserProperties)
}

private func userProperties(user: User, prefix: String = "user_") -> [String:AnyObject] {

  var properties = [String:AnyObject]()

  properties["uid"] = user.id
  properties["backed_projects_count"] = user.stats?.backedProjectsCount
  properties["created_projects_count"] = user.stats?.createdProjectsCount
  properties["starred_projects_count"] = user.stats?.starredProjectsCount

  return properties.prefixedKeys(prefix)
}
