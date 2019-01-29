import Foundation

extension Author {
internal static let template = Author.init(avatar: .template, id: 1, name: "")
}

extension Author.Avatar {
  internal static let template = Author.Avatar(
    medium: "http://www.kickstarter.com/large.jpg",
    small: "http://www.kickstarter.com/medium.jpg",
    thumb: "http://www.kickstarter.com/small.jpg"
  )
}


extension Comment {
  internal static let template = Comment(
    author: .template,
    body: "Exciting!",
    createdAt: Date(timeIntervalSince1970: 1475361315).timeIntervalSince1970,
    deletedAt: nil,
    id: 1
  )
}
