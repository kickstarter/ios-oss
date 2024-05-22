import Apollo
import Foundation
@testable import KsApi

public enum FetchUpdateCommentsQueryTemplate {
  case valid
  case errored

  var data: GraphAPI.FetchUpdateCommentsQuery.Data {
    switch self {
    case .valid:
      return GraphAPI.FetchUpdateCommentsQuery.Data(unsafeResultMap: self.validResultMap)
    case .errored:
      return GraphAPI.FetchUpdateCommentsQuery.Data(unsafeResultMap: self.erroredResultMap)
    }
  }

  // MARK: Private Properties

  private var validResultMap: [String: Any?] {
    let json = """
    {
      "post": {
        "__typename": "FreeformPost",
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
                "id": "VXNlci0xNjcxNzM0MDA1",
                "imageUrl": "https://i.kickstarter.com/missing_user_avatar.png?anim=false&fit=crop&height=1024&origin=ugc-qa&q=92&width=1024&sig=3CEELuVLNdj97Pjx4PDy7Q9OTZfKyMEZyeIlQicGPBY%3D",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "J Jester",
                "uid": "71"
              },
              "authorBadges": ["superbacker"],
              "body": "Thanks, this is great! I was waiting for your next kickstarter to go all in on Forbidden Lands so I got the Completionist Bundle. Good to know it's everything.",
              "createdAt": 1628102582,
              "deleted": false,
              "id": "Q29tbWVudC0zMzY1MzIzNQ==",
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
                "email": "c@example.com",
                "hasPassword": null,
                "id": "VXNlci0xNjI4MTEzNTYz",
                "imageUrl": "example.com/c-profile",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "Deep Blue C",
                "uid": "72"
              },
              "authorBadges": ["superbacker"],
              "body": "Wow...that is INCREDIBLY generous!  If I didn't already have all previous materials, you definitely would have sold me, again!  =)",
              "createdAt": 1628100855,
              "deleted": false,
              "id": "Q29tbWVudC0zMzY1MjkyMg==",
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
                "email": "info@example.com",
                "hasPassword": null,
                "id": "VXNlci0xMTkyMDUzMDEx",
                "imageUrl": "example.com/info-image",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "Info",
                "uid": "73"
              },
              "authorBadges": ["creator"],
              "body": "To clarify:  We cannot change add-ons or pledges post-launch, so The Bitter Reach text will stay the way it is for the rest of the KS - but we will add map, stickers and cards to anyone pledging or adding it as an add-on. You have our word on this and hope you help us spread it to those asking.",
              "createdAt": 1628076984,
              "deleted": false,
              "id": "Q29tbWVudC0zMzY0ODc0NQ==",
              "parentId": null,
              "replies": {
                "__typename": "CommentConnection",
                "totalCount": 2
              }
            }
          }],
          "pageInfo": {
            "__typename": "PageInfo",
            "endCursor": "WzMzNjQ4MTM0XQ==",
            "hasNextPage": false
          },
          "totalCount": 4
        },
        "id": "RnJlZWZvcm1Qb3N0LTMyNjQ5MDU="
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
