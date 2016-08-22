// swiftlint:disable file_length
import Argo
import Curry
import Foundation
import KsApi

public enum Navigation {
  case checkout(Int, Navigation.Checkout)
  case signup
  case tab(Tab)
  case project(Param, Navigation.Project, refTag: RefTag?)

  public enum Checkout {
    case payments(Navigation.Checkout.Payment)

    public enum Payment {
      case new
      case root
      case useStoredCard
    }
  }

  public enum Tab {
    case discovery(DiscoveryParams, Navigation.Discovery)
    case search
    case activity
    case dashboard(project: Param)
    case login
    case me
  }

  public enum Discovery {
    case root
    case advanced
    case category(category: Param, subcategory: Param?)
  }

  public enum Project {
    case checkout(Int, Navigation.Project.Checkout)
    case root
    case comments
    case creatorBio
    case friends
    case messageCreator
    case pledge(Navigation.Project.Pledge)
    case updates
    case update(Int, Navigation.Project.Update)
    case survey(Int)

    public enum Checkout {
      case thanks
    }

    public enum Pledge {
      case destroy
      case edit
      case new
      case root
    }

    public enum Update {
      case root
      case comments
    }
  }
}

extension Navigation: Equatable {}
// swiftlint:disable cyclomatic_complexity
// swiftlint:disable function_body_length
public func == (lhs: Navigation, rhs: Navigation) -> Bool {
  switch (lhs, rhs) {
  case let (.checkout(lhsParam, .payments(.root)), .checkout(rhsParam, .payments(.root))):
    return lhsParam == rhsParam
  case let (.checkout(lhsParam, (.payments(.new))), .checkout(rhsParam, (.payments(.new)))):
    return lhsParam == rhsParam
  case let (.checkout(lhsParam, (.payments(.useStoredCard))),
    .checkout(rhsParam, (.payments(.useStoredCard)))):
    return lhsParam == rhsParam
  case (.signup, .signup),
       (.tab(.search), (.tab(.search))),
       (.tab(.activity), (.tab(.activity))),
       (.tab(.login), (.tab(.login))),
       (.tab(.me), (.tab(.me))):
    return true
  case let (.tab(.discovery(lhsParams, .root)), (.tab(.discovery(rhsParams, .root)))):
    return lhsParams == rhsParams
  case let (.tab(.discovery(lhsParams, .advanced)), (.tab(.discovery(rhsParams, .advanced)))):
    return lhsParams == rhsParams
  case let (.tab(.discovery(lhsParams, .category(lhsCat, lhsSubCat))),
    .tab(.discovery(rhsParams, .category(rhsCat, rhsSubCat)))):
    return lhsParams == rhsParams && lhsCat == rhsCat && lhsSubCat == rhsSubCat
  case let (.tab(.dashboard(lhsProject)), .tab(.dashboard(rhsProject))):
    return lhsProject == rhsProject
  case let (.project(lhsParam, .root, lhsRefTag), .project(rhsParam, .root, rhsRefTag)):
    return lhsParam == rhsParam && lhsRefTag == rhsRefTag
  case let (.project(lparam, .checkout(lid, .thanks), lref), .project(rparam, .checkout(rid, .thanks), rref)):
    return lparam == rparam && lid == rid && lref == rref
  case let (.project(lhsParam, .comments, lhsRefTag), .project(rhsParam, .comments, rhsRefTag)):
    return lhsParam == rhsParam && lhsRefTag == rhsRefTag
  case let (.project(lhsParam, .creatorBio, lhsRefTag), .project(rhsParam, .creatorBio, rhsRefTag)):
    return lhsParam == rhsParam && lhsRefTag == rhsRefTag
  case let (.project(lhsParam, .friends, lhsRefTag), .project(rhsParam, .friends, rhsRefTag)):
    return lhsParam == rhsParam && lhsRefTag == rhsRefTag
  case let (.project(lhsParam, .messageCreator, lhsRefTag), .project(rhsParam, .messageCreator, rhsRefTag)):
    return lhsParam == rhsParam && lhsRefTag == rhsRefTag
  case let (.project(lhsParam, .pledge(.destroy), lhsRefTag),
    .project(rhsParam, .pledge(.destroy), rhsRefTag)):
    return lhsParam == rhsParam && lhsRefTag == rhsRefTag
  case let (.project(lhsParam, .pledge(.edit), lhsRefTag), .project(rhsParam, .pledge(.edit), rhsRefTag)):
    return lhsParam == rhsParam && lhsRefTag == rhsRefTag
  case let (.project(lhsParam, .pledge(.new), lhsRefTag), .project(rhsParam, .pledge(.new), rhsRefTag)):
    return lhsParam == rhsParam && lhsRefTag == rhsRefTag
  case let (.project(lhsParam, .pledge(.root), lhsRefTag), .project(rhsParam, .pledge(.root), rhsRefTag)):
    return lhsParam == rhsParam && lhsRefTag == rhsRefTag
  case let (.project(lhsParam, .updates, lhsRefTag), .project(rhsParam, .updates, rhsRefTag)):
    return lhsParam == rhsParam && lhsRefTag == rhsRefTag
  case let (.project(lparam, .update(lid, .root), lref), .project(rparam, .update(rid, .root), rref)):
    return lparam == rparam && lid == rid && lref == rref
  case let (.project(lparam, .update(lid, .comments), lref), .project(rparam, .update(rid, .comments), rref)):
    return lparam == rparam && lid == rid && lref == rref
  case let (.project(lparam, .survey(lid), lref), .project(rparam, .survey(rid), rref)):
    return lparam == rparam && lid == rid && lref == rref
  default:
    return false
  }
}
// swiftlint:enable function_body_length
// swiftlint:enable cyclomatic_complexity

extension Navigation {
  public static func match(url: NSURL) -> Navigation? {
    return routes.reduce(nil) { accum, templateAndRoute in
      let (template, route) = templateAndRoute
      return accum ?? parsedParams(url: url, fromTemplate: template).flatMap(route)?.value
    }
  }

  public static func match(request: NSURLRequest) -> Navigation? {
    return request.URL.flatMap(match)
  }
}

private let routes = [
  "/activity": activity,
  "/authorize": authorize,
  "/checkouts/:checkout_param/payments": paymentsRoot,
  "/checkouts/:checkout_param/payments/new": paymentsNew,
  "/checkouts/:checkout_param/payments/use_stored_card": paymentsUseStoredCard,
  "/discover": discovery,
  "/discover/advanced": discoveryAdvanced,
  "/discover/categories/:category_param": category,
  "/discover/categories/:category_param/:subcategory_param": category,
  "/profile/:user_param": me,
  "/search": search,
  "/signup": signup,
  "/projects/:creator_param/:project_param": project,
  "/projects/:creator_param/:project_param/checkouts/:checkout_param/thanks": thanks,
  "/projects/:creator_param/:project_param/comments": projectComments,
  "/projects/:creator_param/:project_param/creator_bio": creatorBio,
  "/projects/:creator_param/:project_param/dashboard": dashboard,
  "/projects/:creator_param/:project_param/description": project,
  "/projects/:creator_param/:project_param/friends": friends,
  "/projects/:creator_param/:project_param/messages/new": messageCreator,
  "/projects/:creator_param/:project_param/pledge": pledgeRoot,
  "/projects/:creator_param/:project_param/pledge/destroy": pledgeDestroy,
  "/projects/:creator_param/:project_param/pledge/edit": pledgeEdit,
  "/projects/:creator_param/:project_param/pledge/new": pledgeNew,
  "/projects/:creator_param/:project_param/posts": posts,
  "/projects/:creator_param/:project_param/posts/:update_param": update,
  "/projects/:creator_param/:project_param/posts/:update_param/comments": updateComments,
  "/projects/:creator_param/:project_param/surveys/:survey_param": survey,
]

extension Navigation.Project {
  // swiftlint:disable conditional_binding_cascade
  public static func withRequest(request: NSURLRequest) -> (Param, RefTag?)? {
    guard let nav = Navigation.match(request), case let .project(project, .root, refTag) = nav
      else { return nil }
    return (project, refTag)
  }

  public static func updateWithRequest(request: NSURLRequest) -> (Param, Int)? {
    guard let nav = Navigation.match(request), case let .project(project, .update(update, .root), _) = nav
      else { return nil }
    return (project, update)
  }

  public static func updateCommentsWithRequest(request: NSURLRequest) -> (Param, Int)? {
    guard let nav = Navigation.match(request), case let .project(project, .update(update, .comments), _) = nav
      else { return nil }
    return (project, update)
  }
  // swiftlint:enable conditional_binding_cascade
}

// MARK: Router

// Argo calls their nebulous data blob `JSON`, but we will interpret it as route params.
public typealias RouteParams = JSON

private func activity(_: RouteParams) -> Decoded<Navigation> {
  return .Success(.tab(.activity))
}

private func authorize(_: RouteParams) -> Decoded<Navigation> {
  return .Success(.tab(.login))
}

private func paymentsNew(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.checkout)
    <^> (params <| "checkout_param" >>- stringToInt)
    <*> .Success(.payments(.new))
}

private func paymentsRoot(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.checkout)
    <^> (params <| "checkout_param" >>- stringToInt)
    <*> .Success(.payments(.root))
}

private func paymentsUseStoredCard(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.checkout)
    <^> (params <| "checkout_param" >>- stringToInt)
    <*> .Success(.payments(.useStoredCard))
}

private func discovery(params: RouteParams) -> Decoded<Navigation> {
  guard let discoveryParams = DiscoveryParams.decode(params).value
    else { return .Failure(.Custom("Failed to extact discovery params")) }
  return .Success(.tab(.discovery(discoveryParams, .root)))
}

private func discoveryAdvanced(params: RouteParams) -> Decoded<Navigation> {
  guard let discoveryParams = DiscoveryParams.decode(params).value
    else { return .Failure(.Custom("Failed to extact discovery params")) }
  return .Success(.tab(.discovery(discoveryParams, .advanced)))
}

private func category(params: RouteParams) -> Decoded<Navigation> {
  guard let discoveryParams = DiscoveryParams.decode(params).value
    else { return .Failure(.Custom("Failed to extact discovery params")) }

  let categoryMatch = curry(Navigation.Discovery.category)
    <^> params <| "category_param"
    <*> params <|? "subcategory_param"

  guard let category = categoryMatch.value else { return .Failure(.Custom("Failed to route category")) }

  return .Success(.tab(.discovery(discoveryParams, category)))
}

private func me(_: RouteParams) -> Decoded<Navigation> {
  return .Success(.tab(.me))
}

private func search(_: RouteParams) -> Decoded<Navigation> {
  return .Success(.tab(.search))
}

private func signup(_: RouteParams) -> Decoded<Navigation> {
  return .Success(.signup)
}

private func project(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .Success(.root)
    <*> params <|? "ref_tag"
}

private func thanks(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> (curry(Navigation.Project.checkout)
      <^> (params <| "checkout_param" >>- stringToInt)
      <*> .Success(.thanks))
    <*> params <|? "ref_tag"
}

private func projectComments(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .Success(.comments)
    <*> params <|? "ref_tag"
}

private func creatorBio(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .Success(.creatorBio)
    <*> params <|? "ref_tag"
}

private func dashboard(params: RouteParams) -> Decoded<Navigation> {
  guard let dashboard = (Navigation.Tab.dashboard <^> params <| "project_param").value
    else { return .Failure(.Custom("Failed to extract project param")) }

  return .Success(.tab(dashboard))
}

private func friends(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .Success(.friends)
    <*> params <|? "ref_tag"
}

private func messageCreator(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .Success(.messageCreator)
    <*> params <|? "ref_tag"
}

private func pledgeDestroy(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .Success(.pledge(.destroy))
    <*> params <|? "ref_tag"
}

private func pledgeEdit(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .Success(.pledge(.edit))
    <*> params <|? "ref_tag"
}

private func pledgeNew(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .Success(.pledge(.new))
    <*> params <|? "ref_tag"
}

private func pledgeRoot(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .Success(.pledge(.root))
    <*> params <|? "ref_tag"
}

private func posts(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .Success(Navigation.Project.updates)
    <*> params <|? "ref_tag"
}

private func update(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> (curry(Navigation.Project.update)
      <^> (params <| "update_param" >>- stringToInt)
      <*> .Success(.root))
    <*> params <|? "ref_tag"
}

private func updateComments(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> (curry(Navigation.Project.update)
      <^> (params <| "update_param" >>- stringToInt)
      <*> .Success(.comments))
    <*> params <|? "ref_tag"
}

private func survey(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> (Navigation.Project.survey <^> (params <| "survey_param" >>- stringToInt))
    <*> params <|? "ref_tag"
}

// MARK: Helpers

private func parsedParams(url url: NSURL, fromTemplate template: String) -> RouteParams? {

  // early out on URL's that are not recognized as kickstarter URL's
  let isApiURL = url.absoluteString
    .hasPrefix(AppEnvironment.current.apiService.serverConfig.apiBaseUrl.absoluteString)
  let isWebURL = url.absoluteString
    .hasPrefix(AppEnvironment.current.apiService.serverConfig.webBaseUrl.absoluteString)
  guard isApiURL || isWebURL else { return nil }

  let templateComponents = template
    .componentsSeparatedByString("/")
    .filter { $0 != "" }
  let urlComponents = url
    .path?
    .componentsSeparatedByString("/")
    .filter { $0 != "" && !$0.hasPrefix("?") } ?? []

  guard templateComponents.count == urlComponents.count else { return nil }

  var params: [String:String] = [:]

  for (templateComponent, urlComponent) in zip(templateComponents, urlComponents) {
    if templateComponent.hasPrefix(":") {
      // matched a token
      let paramName = String(templateComponent.characters.dropFirst())
      params[paramName] = urlComponent
    } else if templateComponent != urlComponent {
      return nil
    }
  }

  NSURLComponents(URL: url, resolvingAgainstBaseURL: false)?
    .queryItems?
    .forEach { item in
      params[item.name] = item.value
  }

  var object: [String:RouteParams] = [:]
  params.forEach { key, value in
    object[key] = .String(value)
  }

  return .Object(object)
}

private func stringToInt(string: String) -> Decoded<Int> {
  return Int(string).map(Decoded.Success) ?? .Failure(.Custom("Could not parse string into int."))
}
