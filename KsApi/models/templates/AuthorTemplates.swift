import Foundation

extension DeprecatedAuthor {
  internal static let template = DeprecatedAuthor(
    avatar: .template,
    id: 1,
    name: "Nino Teixeira",
    urls: .template
  )
}

extension DeprecatedAuthor.Avatar {
  internal static let template = DeprecatedAuthor.Avatar(
    medium: "http://www.kickstarter.com/large.jpg",
    small: "http://www.kickstarter.com/medium.jpg",
    thumb: "http://www.kickstarter.com/small.jpg"
  )
}

extension DeprecatedAuthor.Url {
  internal static let template = DeprecatedAuthor.Url(
    api: "http://api.kickstarter.com",
    web: "http://www.kickstarter.com"
  )
}
