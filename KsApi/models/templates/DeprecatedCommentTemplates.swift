import Foundation

extension DeprecatedComment {
  internal static let template = DeprecatedComment(
    author: .template,
    body: "Exciting!",
    createdAt: Date(timeIntervalSince1970: 1_475_361_315).timeIntervalSince1970,
    deletedAt: nil,
    id: 1
  )
}
