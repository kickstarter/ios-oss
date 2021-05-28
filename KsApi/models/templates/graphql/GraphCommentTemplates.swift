import Foundation

extension GraphComment {
  static let expectedAuthorId = "VXNlci0xOTE1MDY0NDY3"
  static let expectedAuthorName = "Author McGee"
  static let expectedAuthorImageUrl =
    "https://ksr-qa-ugc.imgix.net/assets/025/728/103/99122f45d8b5aec075a5ffbfc55a79c8_original.bmp?ixlib=rb-4.0.2&w=200&h=200&fit=crop&v=1562525786&auto=format&frame=1&q=92&s=bca695ad4a05db453e70dc4c7c1dc4fa"
  static let expectedCommentBody =
    "I hope you guys all remembered to write in Bat Boy/Bigfoot on your ballots! Bat Boy 2020!!"
  static let expectedCommentId = "VXNlci0yMDU3OTc4MTQ2"
  static let expectedCommentReplyCount = 4
  static let expectedCommentCreatedAt = TimeInterval.leastNormalMagnitude
  static let template = GraphComment(
    author: GraphAuthor(
      id: expectedAuthorId,
      isCreator: false,
      name: expectedAuthorName,
      imageUrl: expectedAuthorImageUrl
    ),
    authorBadges: [.superbacker],
    body: expectedCommentBody,
    id: expectedCommentId,
    replyCount: expectedCommentReplyCount,
    deleted: false,
    createdAt: expectedCommentCreatedAt
  )
}
