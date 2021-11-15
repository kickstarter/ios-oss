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
            "imageUrl": "https://ksr-qa-ugc.imgix.net/missing_user_avatar.png?ixlib=rb-4.0.2&w=200&h=200&fit=crop&v=&auto=format&frame=1&q=92&s=e5c4e9017b28bb95181ff20d61b17f99",
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
