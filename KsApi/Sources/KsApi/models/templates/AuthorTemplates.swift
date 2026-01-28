import Foundation

extension ActivityCommentAuthor {
  internal static let template = ActivityCommentAuthor(
    avatar: .template,
    id: 1,
    name: "Nino Teixeira",
    urls: .template
  )
}

extension ActivityCommentAuthor.Avatar {
  internal static let template = ActivityCommentAuthor.Avatar(
    medium: "http://www.kickstarter.com/large.jpg",
    small: "http://www.kickstarter.com/medium.jpg",
    thumb: "http://www.kickstarter.com/small.jpg"
  )
}

extension ActivityCommentAuthor.Url {
  internal static let template = ActivityCommentAuthor.Url(
    api: "http://api.kickstarter.com",
    web: "http://www.kickstarter.com"
  )
}
