import Argo
import Curry
import Foundation
import KsApi

public enum Navigation {
  case tab(Tab)
  case project(Param, Navigation.Project, refTag: RefTag?)
  case authorize

  public enum Tab {
    case discovery(Navigation.Discovery)
    case search
    case activity
//    case dashboard(project: Param)
//    case login
    case me
  }

  public enum Discovery {
    case root
    case advanced
    case category(category: Param, subcategory: Param?)
  }

  public enum Project {
    case root
    case comments
    case creatorBio
    case description
    case friends
    case messageCreator
    case updates
    case update(Int, Navigation.Project.Update)
    case survey(Int)

    public enum Update {
      case root
      case comments
    }
  }
}

extension Navigation: Equatable {}
// swiftlint:disable cyclomatic_complexity
public func == (lhs: Navigation, rhs: Navigation) -> Bool {
  switch (lhs, rhs) {
  case (.tab(.discovery(.root)), (.tab(.discovery(.root)))),
       (.tab(.discovery(.advanced)), (.tab(.discovery(.advanced)))),
       (.tab(.search), (.tab(.search))),
       (.tab(.activity), (.tab(.activity))),
//       (.tab(.login), (.tab(.login))),
       (.tab(.me), (.tab(.me))),
       (.authorize, .authorize):
    return true
  case let (.tab(.discovery(.category(lhsCat, lhsSubCat))), .tab(.discovery(.category(rhsCat, rhsSubCat)))):
    return lhsCat == rhsCat && lhsSubCat == rhsSubCat
//  case let (.tab(.dashboard(lhsProject)), .tab(.dashboard(rhsProject))):
//    return lhsProject == rhsProject
  case let (.project(lhsParam, .root, lhsRefTag), .project(rhsParam, .root, rhsRefTag)):
    return lhsParam == rhsParam && lhsRefTag == rhsRefTag
  case let (.project(lhsParam, .comments, lhsRefTag), .project(rhsParam, .comments, rhsRefTag)):
    return lhsParam == rhsParam && lhsRefTag == rhsRefTag
  case let (.project(lhsParam, .creatorBio, lhsRefTag), .project(rhsParam, .creatorBio, rhsRefTag)):
    return lhsParam == rhsParam && lhsRefTag == rhsRefTag
  case let (.project(lhsParam, .description, lhsRefTag), .project(rhsParam, .description, rhsRefTag)):
    return lhsParam == rhsParam && lhsRefTag == rhsRefTag
  case let (.project(lhsParam, .friends, lhsRefTag), .project(rhsParam, .friends, rhsRefTag)):
    return lhsParam == rhsParam && lhsRefTag == rhsRefTag
  case let (.project(lhsParam, .messageCreator, lhsRefTag), .project(rhsParam, .messageCreator, rhsRefTag)):
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
  "/discover": discovery,
  "/discover/advanced": discoveryAdvanced,
  "/discover/categories/:category_param": category,
  "/discover/categories/:category_param/:subcategory_param": category,
  "/profile/:user_param": me,
  "/search": search,
  "/projects/:creator_param/:project_param": project,
  "/projects/:creator_param/:project_param/comments": projectComments,
  "/projects/:creator_param/:project_param/creator_bio": creatorBio,
  "/projects/:creator_param/:project_param/description": projectDescription,
  "/projects/:creator_param/:project_param/friends": friends,
  "/projects/:creator_param/:project_param/messages/new": messageCreator,
  "/projects/:creator_param/:project_param/posts": posts,
  "/projects/:creator_param/:project_param/posts/:update_param": update,
  "/projects/:creator_param/:project_param/posts/:update_param/comments": updateComments,
  "/projects/:creator_param/:project_param/surveys/:survey_param": survey,
]

extension Navigation.Project {
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
}

// MARK: Router

// Argo calls their nebulous data blob `JSON`, but we will interpret it as route params.
public typealias RouteParams = JSON

private func activity(_: RouteParams) -> Decoded<Navigation> {
  return .Success(.tab(.activity))
}

private func authorize(_: RouteParams) -> Decoded<Navigation> {
  return .Success(.authorize)
}

private func discovery(_: RouteParams) -> Decoded<Navigation> {
  return .Success(.tab(.discovery(.root)))
}

private func discoveryAdvanced(_: RouteParams) -> Decoded<Navigation> {
  return .Success(.tab(.discovery(.advanced)))
}

private func category(params: RouteParams) -> Decoded<Navigation> {
  let categoryMatch = curry(Navigation.Discovery.category)
    <^> params <| "category_param"
    <*> params <|? "subcategory_param"

  guard let category = categoryMatch.value else { return .Failure(.Custom("Failed to route category")) }

  return .Success(.tab(.discovery(category)))
}

private func me(_: RouteParams) -> Decoded<Navigation> {
  return .Success(.tab(.me))
}

private func search(_: RouteParams) -> Decoded<Navigation> {
  return .Success(.tab(.search))
}

private func project(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .Success(.root)
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

private func projectDescription(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .Success(.description)
    <*> params <|? "ref_tag"
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
