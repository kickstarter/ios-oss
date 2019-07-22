import Argo
import Curry
import Foundation
import KsApi
import Runes

public enum Navigation: Equatable {
  case checkout(Int, Navigation.Checkout)
  case creatorMessages(Param, messageThreadId: Int)
  case projectActivity(Param)
  case emailClick
  case messages(messageThreadId: Int)
  case signup
  case tab(Tab)
  case project(Param, Navigation.Project, refTag: RefTag?)
  case projectPreview(Param, Navigation.Project, refTag: RefTag?, token: String)
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

  public enum Project: Equatable {
    case checkout(Int, Navigation.Project.Checkout)
    case root
    case comments
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
      case new
      case root
    }

    public enum Update: Equatable {
      case root
      case comments
    }
  }

  public enum User: Equatable {
    case survey(Int)
  }
}

extension Navigation {
  public static func match(_ url: URL) -> Navigation? {
    return allRoutes.reduce(nil) { accum, templateAndRoute in
      let (template, route) = templateAndRoute
      return accum ?? parsedParams(url: url, fromTemplate: template).flatMap(route)?.value
    }
  }

  public static func deepLinkMatch(_ url: URL) -> Navigation? {
    return deepLinkRoutes.reduce(nil) { accum, templateAndRoute in
      let (template, route) = templateAndRoute
      return accum ?? parsedParams(url: url, fromTemplate: template).flatMap(route)?.value
    }
  }

  public static func match(_ request: URLRequest) -> Navigation? {
    return request.url.flatMap(self.match)
  }
}

private let allRoutes: [String: (RouteParams) -> Decoded<Navigation>] = [
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
  "/users/:user_param/surveys/:survey_response_id": userSurvey
]

private let deepLinkRoutes: [String: (RouteParams) -> Decoded<Navigation>] = allRoutes.restrict(
  keys: [
    "/",
    "/activity",
    "/discover",
    "/discover/advanced",
    "/discover/categories/:category_id",
    "/discover/categories/:parent_category_id/:category_id",
    "/messages/:message_thread_id",
    "/projects/:creator_param/:project_param",
    "/projects/:creator_param/:project_param/comments",
    "/projects/:creator_param/:project_param/dashboard",
    "/projects/:creator_param/:project_param/posts",
    "/projects/:creator_param/:project_param/posts/:update_param",
    "/projects/:creator_param/:project_param/posts/:update_param/comments",
    "/projects/:creator_param/:project_param/surveys/:survey_param",
    "/users/:user_param/surveys/:survey_response_id"
  ]
)

extension Navigation.Project {
  // swiftlint:disable conditional_binding_cascade
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

  // swiftlint:enable conditional_binding_cascade
}

// MARK: - Router

// Argo calls their nebulous data blob `JSON`, but we will interpret it as route params.
public typealias RouteParams = JSON

private func emailClick(_: RouteParams) -> Decoded<Navigation> {
  return .success(Navigation.emailClick)
}

private func activity(_: RouteParams) -> Decoded<Navigation> {
  return .success(.tab(.activity))
}

private func authorize(_: RouteParams) -> Decoded<Navigation> {
  return .success(.tab(.login))
}

private func messages(_ params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.messages)
    <^> (params <| "message_thread_id" >>- stringToInt)
}

private func paymentsNew(_ params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.checkout)
    <^> (params <| "checkout_param" >>- stringToInt)
    <*> .success(.payments(.new))
}

private func paymentsApplePay(_ params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.checkout)
    <^> (params <| "checkout_param" >>- stringToInt)
    <*> (curry(Navigation.Checkout.payments)
      <^> (curry(Navigation.Checkout.Payment.applePay)
        <^> params <| "payload"))
}

private func paymentsRoot(_ params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.checkout)
    <^> (params <| "checkout_param" >>- stringToInt)
    <*> .success(.payments(.root))
}

private func paymentsUseStoredCard(_ params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.checkout)
    <^> (params <| "checkout_param" >>- stringToInt)
    <*> .success(.payments(.useStoredCard))
}

private func discovery(_ params: RouteParams) -> Decoded<Navigation> {
  guard case let .object(object) = params
  else { return .failure(.custom("Failed to extact discovery params")) }

  var discoveryParams: [String: String] = [:]
  for (key, value) in object {
    guard case let .string(stringValue) = value
    else { return .failure(.custom("Failed to extact discovery params")) }
    discoveryParams[key] = stringValue
  }

  guard discoveryParams != [:] else {
    return .success(.tab(.discovery(nil)))
  }

  return .success(.tab(.discovery(discoveryParams)))
}

private func me(_: RouteParams) -> Decoded<Navigation> {
  return .success(.tab(.me))
}

private func search(_: RouteParams) -> Decoded<Navigation> {
  return .success(.tab(.search))
}

private func signup(_: RouteParams) -> Decoded<Navigation> {
  return .success(.signup)
}

private func project(_ params: RouteParams) -> Decoded<Navigation> {
  let projectPreview = curry(Navigation.projectPreview)
    <^> params <| "project_param"
    <*> .success(.root)
    <*> params <|? "ref"
    <*> params <| "token"

  // If we're certain this is not a project preview link, try to decode it as a normal project link.
  if case .failure = projectPreview {
    return curry(Navigation.project)
      <^> params <| "project_param"
      <*> .success(.root)
      <*> params <|? "ref"
  }

  // Fail here as we don't currently support project preview links.
  return .failure(.custom("Project preview links are unsupported"))
}

private func thanks(_ params: RouteParams) -> Decoded<Navigation> {
  let thanks = curry(Navigation.Project.Checkout.thanks)
    <^> (params <|? "racing" >>- oneToBool)

  let checkout = curry(Navigation.Project.checkout)
    <^> (params <| "checkout_param" >>- stringToInt)
    <*> thanks

  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> checkout
    <*> params <|? "ref"
}

private func projectComments(_ params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .success(.comments)
    <*> params <|? "ref"
}

private func creatorBio(_ params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .success(.creatorBio)
    <*> params <|? "ref"
}

private func dashboard(_ params: RouteParams) -> Decoded<Navigation> {
  guard let dashboard = (Navigation.Tab.dashboard <^> params <|? "project_param").value
  else { return .failure(.custom("Failed to extract project param")) }

  return .success(.tab(dashboard))
}

private func faqs(_ params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .success(.faqs)
    <*> params <|? "ref"
}

private func friends(_ params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .success(.friends)
    <*> params <|? "ref"
}

private func messageCreator(_ params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .success(.messageCreator)
    <*> params <|? "ref"
}

private func pledgeBigPrint(_ params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .success(.pledge(.bigPrint))
    <*> params <|? "ref"
}

private func pledgeChangeMethod(_ params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .success(.pledge(.changeMethod))
    <*> params <|? "ref"
}

private func pledgeDestroy(_ params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .success(.pledge(.destroy))
    <*> params <|? "ref"
}

private func pledgeEdit(_ params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .success(.pledge(.edit))
    <*> params <|? "ref"
}

private func pledgeNew(_ params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .success(.pledge(.new))
    <*> params <|? "ref"
}

private func pledgeRoot(_ params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .success(.pledge(.root))
    <*> params <|? "ref"
}

private func posts(_ params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .success(Navigation.Project.updates)
    <*> params <|? "ref"
}

private func projectSurvey(_ params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> (Navigation.Project.survey <^> (params <| "survey_param" >>- stringToInt))
    <*> params <|? "ref"
}

private func update(_ params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> (curry(Navigation.Project.update)
      <^> (params <| "update_param" >>- stringToInt)
      <*> .success(.root))
    <*> params <|? "ref"
}

private func updateComments(_ params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> (curry(Navigation.Project.update)
      <^> (params <| "update_param" >>- stringToInt)
      <*> .success(.comments))
    <*> params <|? "ref"
}

private func updates(_ params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .success(Navigation.Project.updates)
    <*> params <|? "ref"
}

private func userSurvey(_ params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.user)
    <^> params <| "user_param"
    <*> (Navigation.User.survey <^> (params <| "survey_response_id" >>- stringToInt))
}

// MARK: - Helpers

private func parsedParams(url: URL, fromTemplate template: String) -> RouteParams? {
  let recognizedEmailHosts = [
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
    return .object([:])
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

  var object: [String: RouteParams] = [:]
  params.forEach { key, value in
    object[key] = .string(value)
  }

  return .object(object)
}

private func oneToBool(_ string: String?) -> Decoded<Bool?> {
  return string.flatMap { Int($0) }.map { $0 == 1 }.map(Decoded.success) ?? .success(nil)
}

private func stringToInt(_ string: String) -> Decoded<Int> {
  return Int(string).map(Decoded.success) ?? .failure(.custom("Could not parse string into int."))
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
