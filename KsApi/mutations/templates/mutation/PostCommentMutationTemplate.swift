import Apollo
@testable import KsApi

public enum PostCommentMutationTemplate {
  case valid
  case errored

  var data: GraphAPI.PostCommentMutation.Data {
    switch self {
    case .valid:
      return GraphAPI.PostCommentMutation
        .Data(unsafeResultMap: self.postCommentMutationSourceResultMap)
    case .errored:
      return GraphAPI.PostCommentMutation
        .Data(unsafeResultMap: self.postCommentMutationSourceErroredResultMap)
    }
  }

  // MARK: Private Properties

  private var postCommentMutationSourceResultMap: [String: Any?] {
    let rawDictionary = [
      "createComment": [
        "__typename": "PostCommentPayload",
        "comment": [
          "__typename": "Comment",
          "author": [
            "__typename": "User",
            "id": "VXNlci02MTgwMDU4ODY=",
            "imageUrl": "https://i.kickstarter.com/missing_user_avatar.png?anim=false&fit=crop&height=200&origin=ugc-qa&q=92&width=200&sig=hCxjTNPjsj1RjnPaahuVIrBSb1iEgJHJ8g%2FyXiMpZWI%3D",
            "isCreator": false,
            "name": "Some author"
          ],
          "authorBadges": [GraphAPI.CommentBadge.superbacker],
          "body": "body test",
          "id": "Q29tbWVudC0zNDQ3MjY2MQ==",
          "parentId": "Q29tbWVudC0zNDQ3MjY1OQ==",
          "createdAt": "1636499465",
          "deleted": false,
          "replies": [
            "__typename": "CommentConnection",
            "totalCount": 0
          ]
        ]
      ]
    ]

    return rawDictionary
  }

  private var postCommentMutationSourceErroredResultMap: [String: Any?] {
    return [:]
  }
}
