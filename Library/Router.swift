import Argo
import Curry
import KsApi

// Argo calls their nebulous data blob `JSON`, but we will interpret it as route params.
public typealias RouteParams = JSON

public enum Router {
  public struct Project {
    public let projectParam: Param, refTag: RefTag?
  }
  public struct ProjectComments {
    public let projectParam: Param
  }
  public struct Update {
    public let projectParam: Param, updateId: Int
  }
  public struct UpdateComments {
    public let projectParam: Param, updateId: Int
  }

  public static func decodeProject(request request: NSURLRequest) -> Router.Project? {
    return Router.recognize(request: request,
                            againstTemplate: "/projects/:creator_param/:project_param").value
  }

  public static func decodeProjectComments(request request: NSURLRequest) -> Router.ProjectComments? {
    return Router.recognize(request: request,
                            againstTemplate: "/projects/:creator_param/:project_param/comments").value
  }

  public static func decodeUpdate(request request: NSURLRequest) -> Router.Update? {
    return Router.recognize(request: request,
                            againstTemplate: "/projects/:creator_param/:project_param/posts/:update_id").value
  }

  public static func decodeUpdateComments(request request: NSURLRequest) -> Router.UpdateComments? {
    return Router.recognize(
      request: request,
      againstTemplate: "/projects/:creator_param/:project_param/posts/:update_id/comments").value
  }

  private static func recognize <A: Decodable where A == A.DecodedType>
    (request request: NSURLRequest, againstTemplate templates: [String]) -> Decoded<A> {

    guard let url = request.URL else {
      return .Failure(.Custom("Malformed URL provided."))
    }

    let unrecognizedFailure = Decoded<A>.Failure(
      .Custom("URL was not recognized. You provided \(url) and we could not match it to \(templates)")
    )

    return templates.reduce(unrecognizedFailure) { accum, template in
      accum <|> A.decode(parsedParams(url: url, fromTemplate: template))
    }
  }

  private static func recognize <A: Decodable where A == A.DecodedType>
    (request request: NSURLRequest, againstTemplate template: String) -> Decoded<A> {
    return recognize(request: request, againstTemplate: [template])
  }
}

extension Router.Project: Decodable {
  public static func decode(route: RouteParams) -> Decoded<Router.Project> {
    return curry(Router.Project.init)
      <^> route <| "project_param"
      <*> route <|? "ref_tag"
  }
}

extension Router.ProjectComments: Decodable {
  public static func decode(route: RouteParams) -> Decoded<Router.ProjectComments> {
    return curry(Router.ProjectComments.init)
      <^> route <| "project_param"
  }
}

extension Router.Update: Decodable {
  public static func decode(route: RouteParams) -> Decoded<Router.Update> {
    return curry(Router.Update.init)
      <^> route <| "project_param"
      <*> (route <| "update_id" >>- stringToInt)
  }
}

extension Router.UpdateComments: Decodable {
  public static func decode(route: RouteParams) -> Decoded<Router.UpdateComments> {
    return curry(Router.UpdateComments.init)
      <^> route <| "project_param"
      <*> (route <| "update_id" >>- stringToInt)
  }
}

/**
 A very naive implementation of a URL parser. Tokens are represented by `:token`. For example,

 template: /projects/:project_param/updates/:update_id
 url:      /projects/double-fine/updates/12345

 Parsing the above will return params ["project_param": "double_fine", "update_id": "12345"].

 - parameter url:       The URL to try to parse.
 - parameter template:  The template to use for parsing. Path components that begin with a `:` will be
                        used as param keys.

 - returns: A value that represents all of the parsed params. Every recognized param in the URL will
            be returned, in addition to any query params.
 */
private func parsedParams(url url: NSURL, fromTemplate template: String) -> RouteParams {

  // early out on URL's that are not recognized as kickstarter URL's
  let isApiURL = url.absoluteString
    .hasPrefix(AppEnvironment.current.apiService.serverConfig.apiBaseUrl.absoluteString)
  let isWebURL = url.absoluteString
    .hasPrefix(AppEnvironment.current.apiService.serverConfig.webBaseUrl.absoluteString)
  guard isApiURL || isWebURL else { return .Null }

  let routeComponents = template
    .componentsSeparatedByString("/")
    .filter { $0 != "" }
  let urlComponents = url
    .path?
    .componentsSeparatedByString("/")
    .filter { $0 != "" && !$0.hasPrefix("?") } ?? []

  guard routeComponents.count == urlComponents.count else { return .Null }

  var params: [String:String]? = [:]

  zip(routeComponents, urlComponents).forEach { routeComponent, urlComponent in
    if routeComponent.hasPrefix(":") {
      // matched a token
      let paramName = routeComponent.substringFromIndex(routeComponent.startIndex.advancedBy(1))
      params?[paramName] = urlComponent
    } else if routeComponent == urlComponent {
      // matched a component, nothing to do
    } else {
      // mismatch, clear all params
      params = nil
    }
  }

  NSURLComponents(URL: url, resolvingAgainstBaseURL: false)?
    .queryItems?
    .forEach { item in
      params?[item.name] = item.value
  }

  var object: [String:RouteParams] = [:]
  (params ?? [:]).forEach { key, value in
    object[key] = .String(value)
  }

  return .Object(object)
}

private func stringToInt(string: String) -> Decoded<Int> {
  return Int(string).map(Decoded.Success) ?? .Failure(.Custom("Could not parse string into int."))
}
