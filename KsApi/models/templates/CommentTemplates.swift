import Foundation

extension Comment {
  internal static let template = Comment(
    author: .template,
    body: "Exciting!",
    createdAt: Date(timeIntervalSince1970: 1475361315).timeIntervalSince1970,
    deletedAt: nil,
    id: 1
  )
}
