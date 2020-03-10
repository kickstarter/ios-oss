import Foundation
import KsApi

private let cookieSeparator = "?"
private let escapedCookieSeparator = "%3F"

// Extracts the ref tag stored in cookies for a particular project. Returns `nil` if no such cookie has
// been previously set.
public func cookieRefTagFor(project: Project) -> RefTag? {
  return AppEnvironment.current.cookieStorage.cookies?
    .filter { cookie in cookie.name == cookieName(project) }
    .first
    .map(refTagName(fromCookie:))
    .flatMap(RefTag.init(code:))
}

// Derives the name of the ref cookie from the project.
private func cookieName(_ project: Project) -> String {
  return "ref_\(project.id)"
}

// Tries to extract the name of the ref tag from a cookie. It has to do double work in case the cookie
// is accidentally encoded with a `%3F` instead of a `?`.
private func refTagName(fromCookie cookie: HTTPCookie) -> String {
  return cleanUp(refTagString: cookie.value)
}

// Tries to remove cruft from a ref tag.
public func cleanUp(refTag: RefTag) -> RefTag {
  return RefTag(code: cleanUp(refTagString: refTag.stringTag))
}

// Tries to remove cruft from a ref tag string.
private func cleanUp(refTagString: String) -> String {
  let secondPass = refTagString.components(separatedBy: escapedCookieSeparator)
  if let name = secondPass.first, secondPass.count == 2 {
    return String(name)
  }

  let firstPass = refTagString.components(separatedBy: cookieSeparator)
  if let name = firstPass.first, firstPass.count == 2 {
    return String(name)
  }

  return refTagString
}

// Constructs a cookie from a ref tag and project.
public func cookieFrom(refTag: RefTag, project: Project) -> HTTPCookie? {
  let timestamp = Int(AppEnvironment.current.scheduler.currentDate.timeIntervalSince1970)

  var properties: [HTTPCookiePropertyKey: Any] = [:]
  properties[.name] = cookieName(project)
  properties[.value] = "\(refTag.stringTag)\(cookieSeparator)\(timestamp)"
  properties[.domain] = URL(string: project.urls.web.project)?.host
  properties[.path] = URL(string: project.urls.web.project)?.path
  properties[.version] = 0
  properties[.expires] = AppEnvironment.current.dateType
    .init(timeIntervalSince1970: project.dates.deadline).date

  return HTTPCookie(properties: properties)
}
