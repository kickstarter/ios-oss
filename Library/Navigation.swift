import Foundation
import KsApi

public enum Navigation: Equatable {
  case checkout(Int, Navigation.Checkout)
  case creatorMessages(Param, messageThreadId: Int)
  case projectActivity(Param)
  case emailClick
  case messages(messageThreadId: Int)
  case profile(Profile)
  case signup
  case tab(Tab)
  case project(Param, Navigation.Project, refTag: RefTag?)
  case projectPreview(Param, Navigation.Project, refTag: RefTag?, token: String)
  case settings(Navigation.Settings)
  case user(Param, Navigation.User)

  public enum Checkout: Equatable {
    case payments(Navigation.Checkout.Payment)

    public enum Payment: Equatable {
      case applePay(payload: String)
      case new
      case root
      case useStoredCard
    }
  }

  public enum Tab: Equatable {
    case discovery([String: String]?)
    case search
    case activity
    case dashboard(project: Param?)
    case login
    case me
  }

  public enum Profile: Equatable {
    case verifyEmail
  }

  public enum Project: Equatable {
    case checkout(Int, Navigation.Project.Checkout)
    case root
    case comments
    case commentThread(String?, String?)
    case creatorBio
    case faqs
    case friends
    case messageCreator
    case pledge(Navigation.Project.Pledge)
    case updates
    case update(Int, Navigation.Project.Update)
    case survey(Int)

    public enum Checkout: Equatable {
      case thanks(racing: Bool?)
    }

    public enum Pledge: Equatable {
      case bigPrint
      case changeMethod
      case destroy
      case edit
      case manage
      case new
      case root
    }

    public enum Update: Equatable {
      case root
      case comments
      case commentThread(String?, String?)
    }
  }

  public enum Settings: Equatable {
    case notifications(String, Bool)
  }

  public enum User: Equatable {
    case survey(Int)
  }
}

extension Navigation.Project.Update {}
public func == (lhs: Navigation.Project.Update, rhs: Navigation.Project.Update) -> Bool {
  switch (lhs, rhs) {
  case (.root, .root):
    return true
  case (.comments, .comments):
    return true
  case let (.commentThread(commentId, replyId), .commentThread(otherCommentId, otherReplyId)):
    return commentId == otherCommentId && replyId == otherReplyId
  default:
    return false
  }
}

extension Navigation {
  public static func match(_ url: URL) -> Navigation? {
    return allRoutes.reduce(nil) { accum, templateAndRoute in
      let (template, route) = templateAndRoute
      return accum ?? parsedParams(url: url, fromTemplate: template).flatMap(route)
    }
  }

  public static func deepLinkMatch(_ url: URL) -> Navigation? {
    return deepLinkRoutes.reduce(nil) { accum, templateAndRoute in
      let (template, route) = templateAndRoute
      return accum ?? parsedParams(url: url, fromTemplate: template).flatMap(route)
    }
  }

  public static func match(_ request: URLRequest) -> Navigation? {
    return request.url.flatMap(self.match)
  }
}

private let allRoutes: [String: (RouteParamsDecoded) -> Navigation?] = [
  "/": emailClick,
  "/activity": activity,
  "/authorize": authorize,
  "/checkouts/:checkout_param/payments": paymentsRoot,
  "/checkouts/:checkout_param/payments/new": paymentsNew,
  "/checkouts/:checkout_param/payments/apple-pay": paymentsApplePay,
  "/checkouts/:checkout_param/payments/use_stored_card": paymentsUseStoredCard,
  "/discover": discovery,
  "/discover/advanced": discovery,
  "/discover/categories/:category_id": discovery,
  "/discover/categories/:parent_category_id/:category_id": discovery,
  "/messages/:message_thread_id": messages,
  "/profile/:user_param": me,
  "/profile/verify_email": verifyEmail,
  "/search": search,
  "/signup": signup,
  "/projects/:creator_param/:project_param": project,
  "/projects/:creator_param/:project_param/checkouts/:checkout_param/thanks": thanks,
  "/projects/:creator_param/:project_param/comments": projectComments,
  "/projects/:creator_param/:project_param/creator_bio": creatorBio,
  "/projects/:creator_param/:project_param/dashboard": dashboard,
  "/projects/:creator_param/:project_param/description": project,
  "/projects/:creator_param/:project_param/faqs": faqs,
  "/projects/:creator_param/:project_param/friends": friends,
  "/projects/:creator_param/:project_param/messages/new": messageCreator,
  "/projects/:creator_param/:project_param/pledge": pledgeRoot,
  "/projects/:creator_param/:project_param/pledge/big_print": pledgeBigPrint,
  "/projects/:creator_param/:project_param/pledge/change_method": pledgeChangeMethod,
  "/projects/:creator_param/:project_param/pledge/destroy": pledgeDestroy,
  "/projects/:creator_param/:project_param/pledge/edit": pledgeEdit,
  "/projects/:creator_param/:project_param/pledge/new": pledgeNew,
  "/projects/:creator_param/:project_param/posts": posts,
  "/projects/:creator_param/:project_param/posts/:update_param": update,
  "/projects/:creator_param/:project_param/updates": updates,
  "/projects/:creator_param/:project_param/posts/:update_param/comments": updateComments,
  "/projects/:creator_param/:project_param/surveys/:survey_param": projectSurvey,
  "/settings/:notification_param/:enabled_param": settingsNotifications,
  "/users/:user_param/surveys/:survey_response_id": userSurvey
]

private let deepLinkRoutes: [String: (RouteParamsDecoded) -> Navigation?] = allRoutes.restrict(
  keys: [
    "/",
    "/activity",
    "/discover",
    "/discover/advanced",
    "/discover/categories/:category_id",
    "/discover/categories/:parent_category_id/:category_id",
    "/messages/:message_thread_id",
    "/profile/verify_email",
    "/projects/:creator_param/:project_param",
    "/projects/:creator_param/:project_param/comments",
    "/projects/:creator_param/:project_param/dashboard",
    "/projects/:creator_param/:project_param/posts",
    "/projects/:creator_param/:project_param/posts/:update_param",
    "/projects/:creator_param/:project_param/posts/:update_param/comments",
    "/projects/:creator_param/:project_param/surveys/:survey_param",
    "/projects/:creator_param/:project_param/pledge",
    "/settings/:notification_param/:enabled_param",
    "/users/:user_param/surveys/:survey_response_id"
  ]
)

extension Navigation.Project {
  public static func withRequest(_ request: URLRequest) -> (Param, RefTag?)? {
    guard let nav = Navigation.match(request), case let .project(project, .root, refTag) = nav
    else { return nil }
    return (project, refTag)
  }

  public static func updateWithRequest(_ request: URLRequest) -> (Param, Int)? {
    guard let nav = Navigation.match(request), case let .project(project, .update(update, .root), _) = nav
    else { return nil }
    return (project, update)
  }

  public static func updateCommentsWithRequest(_ request: URLRequest) -> (Param, Int)? {
    guard let nav = Navigation.match(request), case let .project(project, .update(update, .comments), _) = nav
    else { return nil }
    return (project, update)
  }
}

// MARK: - Router

public typealias RouteParamsDecoded = [String: String]

private func emailClick(_: RouteParamsDecoded) -> Navigation {
  return Navigation.emailClick
}

private func activity(_: RouteParamsDecoded) -> Navigation {
  return .tab(.activity)
}

private func authorize(_: RouteParamsDecoded) -> Navigation {
  return .tab(.login)
}

private func messages(_ params: RouteParamsDecoded) -> Navigation? {
  guard let messageId = params.messageThreadId() else {
    return nil
  }
  return Navigation.messages(messageThreadId: messageId)
}

private func messagesDecoded(_ params: RouteParamsDecoded) -> Navigation? {
  guard let messageId = params.messageThreadId() else {
    return nil
  }
  return Navigation.messages(messageThreadId: messageId)
}

private func paymentsNew(_ params: RouteParamsDecoded) -> Navigation? {
  if let checkoutParam = params.checkoutParam() {
    return Navigation.checkout(checkoutParam, .payments(.new))
  }
  return nil
}

private func paymentsApplePay(_ params: RouteParamsDecoded) -> Navigation? {
  if let checkoutParam = params.checkoutParam(),
    let payload = params.payload() {
    return Navigation.checkout(checkoutParam, Navigation.Checkout.payments(.applePay(payload: payload)))
  }
  return nil
}

private func paymentsRoot(_ params: RouteParamsDecoded) -> Navigation? {
  if let checkoutParam = params.checkoutParam() {
    return Navigation.checkout(checkoutParam, .payments(.root))
  }
  return nil
}

private func paymentsUseStoredCard(_ params: RouteParamsDecoded) -> Navigation? {
  if let checkoutParam = params.checkoutParam() {
    return Navigation.checkout(checkoutParam, .payments(.useStoredCard))
  }
  return nil
}

private func discovery(_ params: RouteParamsDecoded) -> Navigation {
  guard !params.isEmpty else {
    return .tab(.discovery(nil))
  }

  return .tab(.discovery(params))
}

private func me(_ params: RouteParamsDecoded) -> Navigation {
  // Avoid ambiguity with :user_param
  if case let .slug(slug) = params.userParam(), slug == "verify_email" {
    return verifyEmail(params)
  }

  return .tab(.me)
}

private func verifyEmail(_: RouteParamsDecoded) -> Navigation {
  return .profile(.verifyEmail)
}

private func search(_: RouteParamsDecoded) -> Navigation {
  return .tab(.search)
}

private func signup(_: RouteParamsDecoded) -> Navigation {
  return .signup
}

private func project(_ params: RouteParamsDecoded) -> Navigation? {
  if params.token() != nil {
    return nil
  } else if let projectParam = params.projectParam() {
    let refTag = params.refTag()
    return Navigation.project(projectParam, .root, refTag: refTag)
  }

  return nil
}

private func thanks(_ params: RouteParamsDecoded) -> Navigation? {
  if let projectParam = params.projectParam(),
    let checkoutParam = params.checkoutParam() {
    let refTag = params.refTag()
    let thanks = Navigation.Project.Checkout.thanks(racing: params.racing())
    let checkout = Navigation.Project.checkout(checkoutParam, thanks)
    return Navigation.project(projectParam, checkout, refTag: refTag)
  }

  return nil
}

private func projectComments(_ params: RouteParamsDecoded) -> Navigation? {
  if let projectParam = params.projectParam() {
    let refTag = params.refTag()

    guard let commentId = params.comment() else {
      return .project(projectParam, .comments, refTag: refTag)
    }

    return .project(projectParam, .commentThread(commentId, params.reply()), refTag: refTag)
  }

  return nil
}

private func creatorBio(_ params: RouteParamsDecoded) -> Navigation? {
  if let projectParam = params.projectParam() {
    let refTag = params.refTag()
    return Navigation.project(projectParam, .creatorBio, refTag: refTag)
  }

  return nil
}

private func dashboard(_ params: RouteParamsDecoded) -> Navigation? {
  if let projectParam = params.projectParam() {
    let dashboard = Navigation.Tab.dashboard(project: projectParam)
    return .tab(dashboard)
  }

  return nil
}

private func faqs(_ params: RouteParamsDecoded) -> Navigation? {
  if let projectParam = params.projectParam() {
    let refTag = params.refTag()
    return Navigation.project(projectParam, .faqs, refTag: refTag)
  }

  return nil
}

private func friends(_ params: RouteParamsDecoded) -> Navigation? {
  if let projectParam = params.projectParam() {
    let refTag = params.refTag()
    return Navigation.project(projectParam, .friends, refTag: refTag)
  }

  return nil
}

private func messageCreator(_ params: RouteParamsDecoded) -> Navigation? {
  if let projectParam = params.projectParam() {
    let refTag = params.refTag()
    return Navigation.project(projectParam, .messageCreator, refTag: refTag)
  }

  return nil
}

private func pledgeBigPrint(_ params: RouteParamsDecoded) -> Navigation? {
  if let projectParam = params.projectParam() {
    let refTag = params.refTag()
    return Navigation.project(projectParam, .pledge(.bigPrint), refTag: refTag)
  }

  return nil
}

private func pledgeChangeMethod(_ params: RouteParamsDecoded) -> Navigation? {
  if let projectParam = params.projectParam() {
    let refTag = params.refTag()
    return Navigation.project(projectParam, .pledge(.changeMethod), refTag: refTag)
  }

  return nil
}

private func pledgeDestroy(_ params: RouteParamsDecoded) -> Navigation? {
  if let projectParam = params.projectParam() {
    let refTag = params.refTag()
    return Navigation.project(projectParam, .pledge(.destroy), refTag: refTag)
  }

  return nil
}

private func pledgeEdit(_ params: RouteParamsDecoded) -> Navigation? {
  if let projectParam = params.projectParam() {
    let refTag = params.refTag()
    return Navigation.project(projectParam, .pledge(.edit), refTag: refTag)
  }

  return nil
}

private func pledgeNew(_ params: RouteParamsDecoded) -> Navigation? {
  if let projectParam = params.projectParam() {
    let refTag = params.refTag()
    return Navigation.project(projectParam, .pledge(.new), refTag: refTag)
  }

  return nil
}

private func pledgeRoot(_ params: RouteParamsDecoded) -> Navigation? {
  if let projectParam = params.projectParam() {
    let refTag = params.refTag()
    let parseRoot = Navigation.project(projectParam, .pledge(.root), refTag: refTag)
    guard refTag == .emailBackerFailedTransaction else {
      return parseRoot
    }
    return Navigation.project(projectParam, .pledge(.manage), refTag: refTag)
  }

  return nil
}

private func posts(_ params: RouteParamsDecoded) -> Navigation? {
  if let projectParam = params.projectParam() {
    let refTag = params.refTag()
    return Navigation.project(projectParam, Navigation.Project.updates, refTag: refTag)
  }

  return nil
}

private func projectSurvey(_ params: RouteParamsDecoded) -> Navigation? {
  if let projectParam = params.projectParam(),
    let surveyParam = params.surveyParam() {
    let refTag = params.refTag()
    let survey = Navigation.Project.survey(surveyParam)
    return Navigation.project(projectParam, survey, refTag: refTag)
  }

  return nil
}

private func update(_ params: RouteParamsDecoded) -> Navigation? {
  if let projectParam = params.projectParam(),
    let updateParam = params.updateParam() {
    let refTag = params.refTag()
    let update = Navigation.Project.update(updateParam, .root)
    return Navigation.project(projectParam, update, refTag: refTag)
  }

  return nil
}

private func updateComments(_ params: RouteParamsDecoded) -> Navigation? {
  if let projectParam = params.projectParam(),
    let updateParam = params.updateParam() {
    let refTag = params.refTag()

    guard let commentId = params.comment() else {
      return .project(
        projectParam,
        .update(updateParam, .comments),
        refTag: refTag
      )
    }

    return .project(
      projectParam,
      .update(updateParam, .commentThread(commentId, params.reply())),
      refTag: refTag
    )
  }

  return nil
}

private func updates(_ params: RouteParamsDecoded) -> Navigation? {
  if let projectParam = params.projectParam() {
    let refTag = params.refTag()
    return Navigation.project(projectParam, Navigation.Project.updates, refTag: refTag)
  }

  return nil
}

private func userSurvey(_ params: RouteParamsDecoded) -> Navigation? {
  if let userParam = params.userParam(),
    let surveyResponseId = params.surveyResponseId() {
    return Navigation.user(userParam, Navigation.User.survey(surveyResponseId))
  }

  return nil
}

private func settingsNotifications(_ params: RouteParamsDecoded) -> Navigation? {
  guard
    let notificationsParam = params.notificationParam(),
    let enabled = params.enabledParam()
  else { return nil }

  return Navigation.settings(.notifications(notificationsParam, enabled))
}

// MARK: - Helpers

private func parsedParams(url: URL, fromTemplate template: String) -> RouteParamsDecoded? {
  let recognizedEmailHosts = [
    "me.kickstarter.com",
    "ea.kickstarter.com",
    "clicks.kickstarter.com",
    "click.e.kickstarter.com",
    "click.em.kickstarter.com",
    "emails.kickstarter.com",
    "email.kickstarter.com",
    "e2.kickstarter.com",
    "e3.kickstarter.com"
  ]

  let hostRecognizer = { accum, host in
    accum || url.host.map { $0.hasPrefix(host) } == .some(true)
  }

  let isRecognizedEmailHost = recognizedEmailHosts.reduce(false, hostRecognizer)

  let recognizedHosts = [
    AppEnvironment.current.apiService.serverConfig.apiBaseUrl.host,
    AppEnvironment.current.apiService.serverConfig.webBaseUrl.host
  ].compact()

  let isRecognizedHost = recognizedHosts.reduce(false, hostRecognizer)

  guard isRecognizedHost || isRecognizedEmailHost else { return nil }

  let templateComponents = template
    .components(separatedBy: "/")
    .filter { $0 != "" }
  let urlComponents = url
    .path
    .components(separatedBy: "/")
    .filter { $0 != "" && !$0.hasPrefix("?") }

  // if we're parsing against the '/' emailClick template and this is a recognized email host
  // return the expected params for that route to be resolved
  if templateComponents.isEmpty, isRecognizedEmailHost {
    return [:]
  }

  guard templateComponents.count == urlComponents.count else { return nil }

  var params: [String: String] = [:]

  for (templateComponent, urlComponent) in zip(templateComponents, urlComponents) {
    if templateComponent.hasPrefix(":") {
      // matched a token
      let paramName = String(templateComponent.dropFirst())
      params[paramName] = urlComponent
    } else if templateComponent != urlComponent {
      return nil
    }
  }

  URLComponents(url: url, resolvingAgainstBaseURL: false)?
    .queryItems?
    .forEach { item in
      params[item.name] = item.value
    }

  var object: RouteParamsDecoded = [:]
  params.forEach { key, value in
    object[key] = value
  }

  return object
}

private func stringToInt(_ string: String) -> Int? {
  return Int(string)
}

extension Dictionary {
  fileprivate func restrict(keys: Set<Key>) -> Dictionary {
    var result = Dictionary()
    self.forEach { key, value in
      if keys.contains(key) {
        result[key] = value
      }
    }
    return result
  }
}

extension RouteParamsDecoded {
  fileprivate enum CodingKeys: String, CodingKey {
    case comment
    case messageThreadId = "message_thread_id"
    case notificationParam = "notification_param"
    case checkoutParam = "checkout_param"
    case enabledParam = "enabled_param"
    case payload
    case projectParam = "project_param"
    case ref
    case token
    case racing
    case reply
    case updateParam = "update_param"
    case surveyParam = "survey_param"
    case userParam = "user_param"
    case surveyResponseId = "survey_response_id"
  }

  public func comment() -> String? {
    let key = CodingKeys.comment.rawValue
    return self[key].flatMap { String($0) }
  }

  public func enabledParam() -> Bool? {
    let key = CodingKeys.enabledParam.rawValue
    return self[key].flatMap(Bool.init)
  }

  public func refTag() -> RefTag? {
    let key = CodingKeys.ref.rawValue
    return self[key].flatMap { RefTag.init(code: $0) }
  }

  public func reply() -> String? {
    let key = CodingKeys.reply.rawValue
    return self[key].flatMap { String($0) }
  }

  public func token() -> String? {
    let key = CodingKeys.token.rawValue
    return self[key]
  }

  public func projectParam() -> Param? {
    let key = CodingKeys.projectParam.rawValue
    return self[key].flatMap { .slug($0) }
  }

  public func userParam() -> Param? {
    let key = CodingKeys.userParam.rawValue
    return self[key].flatMap { .slug($0) }
  }

  public func surveyParam() -> Int? {
    let key = CodingKeys.surveyParam.rawValue
    return self[key].flatMap { Int($0) }
  }

  public func updateParam() -> Int? {
    let key = CodingKeys.updateParam.rawValue
    return self[key].flatMap { Int($0) }
  }

  public func messageThreadId() -> Int? {
    let key = CodingKeys.messageThreadId.rawValue
    return self[key].flatMap { Int($0) }
  }

  public func notificationParam() -> String? {
    let key = CodingKeys.notificationParam.rawValue
    return self[key]
  }

  public func checkoutParam() -> Int? {
    let key = CodingKeys.checkoutParam.rawValue
    return self[key].flatMap { Int($0) }
  }

  public func payload() -> String? {
    let key = CodingKeys.payload.rawValue
    return self[key]
  }

  public func racing() -> Bool? {
    let key = CodingKeys.racing.rawValue
    return self[key].flatMap { Int($0) }.map { $0 == 1 }
  }

  public func surveyResponseId() -> Int? {
    let key = CodingKeys.surveyResponseId.rawValue
    return self[key].flatMap { Int($0) }
  }
}
