import Apollo
import Foundation
@testable import KsApi

public enum FetchProjectCommentsQueryTemplate {
  case valid
  case errored

  var data: GraphAPI.FetchProjectCommentsQuery.Data {
    switch self {
    case .valid:
      return GraphAPI.FetchProjectCommentsQuery.Data(unsafeResultMap: self.validResultMap)
    case .errored:
      return GraphAPI.FetchProjectCommentsQuery.Data(unsafeResultMap: self.erroredResultMap)
    }
  }

  // MARK: Private Properties

  private var validResultMap: [String: Any?] {
    let json = """
    {
      "project": {
        "__typename": "Project",
        "comments": {
          "__typename": "CommentConnection",
          "edges": [{
            "__typename": "CommentEdge",
            "node": {
              "__typename": "Comment",
              "author": {
                "__typename": "User",
                "chosenCurrency": null,
                "email": "j@example.com",
                "hasPassword": null,
                "id": "VXNlci0xOTE0Njg1MDc2",
                "imageUrl": "example.com/fake-profile-image-j",
                "isAppleConnected": null,
                "isCreator": true,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "J Example",
                "uid": "31"
              },
              "authorBadges": ["creator"],
              "body": "Generally poking my head in to say hello.",
              "createdAt": 1628095037,
              "deleted": false,
              "id": "Q29tbWVudC0zMzY1MTc5OA==",
              "parentId": null,
              "replies": {
                "__typename": "CommentConnection",
                "totalCount": 0
              }
            }
          }, {
            "__typename": "CommentEdge",
            "node": {
              "__typename": "Comment",
              "author": {
                "__typename": "User",
                "chosenCurrency": null,
                "email": "b@example.com",
                "hasPassword": null,
                "id": "VXNlci0xODMyNTk4MjQ4",
                "imageUrl": "https://i.kickstarter.com/missing_user_avatar.png?anim=false&fit=crop&height=1024&origin=ugc-qa&q=92&width=1024&sig=3CEELuVLNdj97Pjx4PDy7Q9OTZfKyMEZyeIlQicGPBY%3D",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "B",
                "uid": "32"
              },
              "authorBadges": [],
              "body": "I GMd 1st edition when I was in high school, waaaaaay back in the days of Contested Grounds.",
              "createdAt": 1628040518,
              "deleted": false,
              "id": "Q29tbWVudC0zMzY0NDk0Ng==",
              "parentId": null,
              "replies": {
                "__typename": "CommentConnection",
                "totalCount": 1
              }
            }
          }, {
            "__typename": "CommentEdge",
            "node": {
              "__typename": "Comment",
              "author": {
                "__typename": "User",
                "chosenCurrency": null,
                "email": "l@example.com",
                "hasPassword": null,
                "id": "VXNlci02MjMxODYxMjg=",
                "imageUrl": "example.com/fake-profile-l",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "Lisa Smith",
                "uid": "33"
              },
              "authorBadges": ["superbacker"],
              "body": "Love the 3 Coins idea plus the possibility of physical coins as an add-on.",
              "createdAt": 1628029491,
              "deleted": false,
              "id": "Q29tbWVudC0zMzY0MzUxNw==",
              "parentId": null,
              "replies": {
                "__typename": "CommentConnection",
                "totalCount": 2
              }
            }
          }, {
            "__typename": "CommentEdge",
            "node": {
              "__typename": "Comment",
              "author": {
                "__typename": "User",
                "chosenCurrency": null,
                "email": "a@example.com",
                "hasPassword": null,
                "id": "VXNlci0yOTI1NTA5MDQ=",
                "imageUrl": "example.com/fake-profile-a",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "A Lastname",
                "uid": "34"
              },
              "authorBadges": null,
              "body": "Pledged £1 to get a peek at the preview and judge whether I wanted to commit. Saw commitment in preview to providing in-depth details on a good swathe of the setting mysteries. Backed for hard copy.",
              "createdAt": 1628012917,
              "deleted": false,
              "id": "Q29tbWVudC0zMzY0MDIzMQ==",
              "parentId": null,
              "replies": {
                "__typename": "CommentConnection",
                "totalCount": 1
              }
            }
          }, {
            "__typename": "CommentEdge",
            "node": {
              "__typename": "Comment",
              "author": {
                "__typename": "User",
                "chosenCurrency": null,
                "email": "john@example.com",
                "hasPassword": null,
                "id": "VXNlci0xMzQyNDMxNzk2",
                "imageUrl": "example.com/john-profile-pic",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "John Example",
                "uid": "35"
              },
              "authorBadges": [],
              "body": "Hullo, @Jon",
              "createdAt": 1628012271,
              "deleted": false,
              "id": "Q29tbWVudC0zMzY0MDA5OQ==",
              "parentId": null,
              "replies": {
                "__typename": "CommentConnection",
                "totalCount": 2
              }
            }
          }, {
            "__typename": "CommentEdge",
            "node": {
              "__typename": "Comment",
              "author": {
                "__typename": "User",
                "chosenCurrency": null,
                "email": "bee@example.com",
                "hasPassword": null,
                "id": "VXNlci02MjMxODYxMjg=",
                "imageUrl": "https://i.kickstarter.com/missing_user_avatar.png?anim=false&fit=crop&height=1024&origin=ugc-qa&q=92&width=1024&sig=3CEELuVLNdj97Pjx4PDy7Q9OTZfKyMEZyeIlQicGPBY%3D",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "Bee",
                "uid": "36"
              },
              "authorBadges": ["superbacker"],
              "body": "Closing in on another stretch goal! 🎉🎊",
              "createdAt": 1627975428,
              "deleted": false,
              "id": "Q29tbWVudC0zMzYzMzk2Mw==",
              "parentId": null,
              "replies": {
                "__typename": "CommentConnection",
                "totalCount": 8
              }
            }
          }],
          "pageInfo": {
            "__typename": "PageInfo",
            "endCursor": "WzMzNTc0MTMzXQ==",
            "hasNextPage": false
          },
          "totalCount": 14
        },
        "id": "UHJvamVjdC00NDc1MzA4NQ==",
        "slug": "jonhodgsonmaptiles2/a-state-rpg-second-edition"
      }
    }
    """

    let data = Data(json.utf8)

    return (try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any?]) ?? [:]
  }

  private var erroredResultMap: [String: Any?] {
    return CommentFragmentTemplate.valid.data
  }
}
