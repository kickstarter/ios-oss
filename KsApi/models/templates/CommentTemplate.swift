import Foundation

extension Comment {
  public static let template = Comment(
    author: Author(
      id: "AFD8hsfh7gsSf9==",
      isCreator: true,
      name: "Federico Fellini"
    ),
    body: "Hello World",
    id: "89DJa89jdSDJ89sd8==",
    uid: 12_345,
    replyCount: 2
  )

  public static let anotherTemplate = Comment(
    author: Author(
      id: "AFD8hsfh7sdSf9==",
      isCreator: false,
      name: "Federico Fellini"
    ),
    body: "Hello World Again",
    id: "89DJa89jdSDJ00sd8==",
    uid: 12_315,
    replyCount: 3
  )
}
