import Foundation

extension Author {
  internal static let template = Author(
    avatar: .template,
    id: 1,
    name: "Nino Teixeira",
    urls: .template
  )
}

extension Author.Avatar {
  internal static let template = Author.Avatar(
    medium: "http://www.kickstarter.com/large.jpg",
    small: "http://www.kickstarter.com/medium.jpg",
    thumb: "http://www.kickstarter.com/small.jpg"
  )
}

extension Author.Url {
  internal static let template = Author.Url(
    api: "http://api.kickstarter.com",
    web: "http://www.kickstarter.com"
  )
}
