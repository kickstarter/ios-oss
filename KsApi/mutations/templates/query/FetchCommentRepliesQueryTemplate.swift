import Apollo
import Foundation
@testable import KsApi

public enum FetchCommentRepliesQueryTemplate {
  case valid
  case errored

  var data: GraphAPI.FetchCommentRepliesQuery.Data {
    switch self {
    case .valid:
      return GraphAPI.FetchCommentRepliesQuery.Data(unsafeResultMap: self.validResultMap)
    case .errored:
      return GraphAPI.FetchCommentRepliesQuery.Data(unsafeResultMap: self.erroredResultMap)
    }
  }

  // MARK: Private Properties

  private var validResultMap: [String: Any] {
    let json = """
    {
        "comment": {
          "__typename": "Comment",
          "author": {
            "__typename": "User",
            "backings": null,
            "backingsCount": 42,
            "chosenCurrency": null,
            "createdProjects": {
              "totalCount": 0
            },
            "email": "lord@example.com",
            "hasPassword": null,
            "hasUnreadMessages": null,
            "hasUnseenActivity": null,
            "id": "VXNlci04MjkwODk1MDY=",
            "imageUrl": "example.com/lord-of-profile-pictures",
            "isAppleConnected": null,
            "isCreator": null,
            "isDeliverable": null,
            "isEmailVerified": true,
            "isFacebookConnected": null,
            "isKsrAdmin": null,
            "isFollowing": false,
            "isSocializing": null,
            "location": null,
            "name": "Lord of Creation",
            "needsFreshFacebookToken": null,
            "newsletterSubscriptions": null,
            "notifications": null,
            "optedOutOfRecommendations": null,
            "showPublicProfile": null,
            "savedProjects": null,
            "surveyResponses": null,
            "uid": "41"
          },
          "authorBadges": ["collaborator"],
          "body": "Does the machine laser engrave on brass and copper? What’s max depth look like?",
          "createdAt": 1636515629,
          "deleted": false,
          "id": "Q29tbWVudC0zNDc0MDc3NA==",
          "parentId": null,
          "replies": {
            "__typename": "CommentConnection",
            "edges": [
              {
                "__typename": "CommentEdge",
                "node": {
                  "__typename": "Comment",
                  "author": {
                    "backings": null,
                    "backingsCount": 3,
                    "chosenCurrency": null,
                    "createdProjects": {
                      "totalCount": 0
                    },
                    "email": "r@example.com",
                    "hasPassword": null,
                    "hasUnreadMessages": null,
                    "hasUnseenActivity": null,
                    "id": "VXNlci02ODY0MDk3NzM=",
                    "imageUrl": "example.com/profile-pic-r",
                    "isAppleConnected": null,
                    "isCreator": null,
                    "isDeliverable": null,
                    "isEmailVerified": true,
                    "isFacebookConnected": null,
                    "isKsrAdmin": null,
                    "isFollowing": false,
                    "isSocializing": null,
                    "location": null,
                    "name": "R Rabbit",
                    "needsFreshFacebookToken": null,
                    "newsletterSubscriptions": null,
                    "notifications": null,
                    "optedOutOfRecommendations": null,
                    "showPublicProfile": null,
                    "savedProjects": null,
                    "surveyResponses": null,
                    "uid": "42"
                  },
                  "authorBadges": [],
                  "body": "Maybe blade-engraving?",
                  "createdAt": 1636543217,
                  "deleted": false,
                  "id": "Q29tbWVudC0zNDc0Mzc2Mg==",
                  "parentId": "Q29tbWVudC0zNDc0MDc3NA==",
                  "replies": {
                    "totalCount": 0
                  }
                }
              },
              {
                "__typename": "CommentEdge",
                "node": {
                  "__typename": "Comment",
                  "author": {
                    "backings": null,
                    "backingsCount": 42,
                    "chosenCurrency": null,
                    "createdProjects": {
                      "totalCount": 0
                    },
                    "email": "lord@example.com",
                    "hasPassword": null,
                    "hasUnreadMessages": null,
                    "hasUnseenActivity": null,
                    "id": "VXNlci04MjkwODk1MDY=",
                    "imageUrl": "example.com/lord-of-profile-pictures",
                    "isAppleConnected": null,
                    "isCreator": null,
                    "isDeliverable": null,
                    "isEmailVerified": true,
                    "isFacebookConnected": null,
                    "isKsrAdmin": null,
                    "isFollowing": false,
                    "isSocializing": null,
                    "location": null,
                    "name": "Lord of Creation",
                    "needsFreshFacebookToken": null,
                    "newsletterSubscriptions": null,
                    "notifications": null,
                    "optedOutOfRecommendations": null,
                    "showPublicProfile": null,
                    "savedProjects": null,
                    "surveyResponses": null,
                    "uid": "41"
                  },
                  "authorBadges": [],
                  "body": "What prevents it from engraving brass or copper? What metals can it engrave?",
                  "createdAt": 1636551577,
                  "deleted": false,
                  "id": "Q29tbWVudC0zNDc0NDk4Nw==",
                  "parentId": "Q29tbWVudC0zNDc0MDc3NA==",
                  "replies": {
                    "totalCount": 0
                  }
                }
              },
              {
                "__typename": "CommentEdge",
                "node": {
                  "__typename": "Comment",
                  "author": {
                    "backings": null,
                    "backingsCount": 4,
                    "chosenCurrency": null,
                    "createdProjects": {
                      "totalCount": 0
                    },
                    "email": "b@example.com",
                    "hasPassword": null,
                    "hasUnreadMessages": null,
                    "hasUnseenActivity": null,
                    "id": "VXNlci0xODMyMzE0ODY2",
                    "imageUrl": "https://i.kickstarter.com/missing_user_avatar.png?anim=false&fit=crop&height=1024&origin=ugc-qa&q=92&width=1024&sig=3CEELuVLNdj97Pjx4PDy7Q9OTZfKyMEZyeIlQicGPBY%3D",
                    "isAppleConnected": null,
                    "isCreator": null,
                    "isDeliverable": null,
                    "isEmailVerified": true,
                    "isFacebookConnected": null,
                    "isKsrAdmin": null,
                    "isFollowing": false,
                    "isSocializing": null,
                    "location": null,
                    "name": "B Bear",
                    "needsFreshFacebookToken": null,
                    "newsletterSubscriptions": null,
                    "notifications": null,
                    "optedOutOfRecommendations": null,
                    "showPublicProfile": null,
                    "savedProjects": null,
                    "surveyResponses": null,
                    "uid": "43"
                  },
                  "authorBadges": [],
                  "body": "I think this is simply a matter of physics. A 10W laser of this type can not heat those metals enough to mark them. In regards to the cutter, it's a blade like a small sharp knife. If you can't cut it with a sharp knife, it's not going to be able to cut it. This doesn't mean you can't customize items made of brass or copper, it just means you can't do it directly. As in, you need to add something to them that can be customized such as vinyl or a coating.",
                  "createdAt": 1636554789,
                  "deleted": false,
                  "id": "Q29tbWVudC0zNDc0NTUyNA==",
                  "parentId": "Q29tbWVudC0zNDc0MDc3NA==",
                  "replies": {
                    "totalCount": 0
                  }
                }
              },
              {
                "__typename": "CommentEdge",
                "node": {
                  "__typename": "Comment",
                  "author": {
                    "backings": null,
                    "backingsCount": 3,
                    "chosenCurrency": null,
                    "createdProjects": {
                      "totalCount": 0
                    },
                    "email": "r@example.com",
                    "hasPassword": null,
                    "hasUnreadMessages": null,
                    "hasUnseenActivity": null,
                    "id": "VXNlci02ODY0MDk3NzM=",
                    "imageUrl": "example.com/profile-pic-r",
                    "isAppleConnected": null,
                    "isCreator": null,
                    "isDeliverable": null,
                    "isEmailVerified": true,
                    "isFacebookConnected": null,
                    "isKsrAdmin": null,
                    "isFollowing": false,
                    "isSocializing": null,
                    "location": null,
                    "name": "R Rabbit",
                    "needsFreshFacebookToken": null,
                    "newsletterSubscriptions": null,
                    "notifications": null,
                    "optedOutOfRecommendations": null,
                    "showPublicProfile": null,
                    "savedProjects": null,
                    "surveyResponses": null,
                    "uid": "42"
                  },
                  "authorBadges": [],
                  "body": "i was unsure about the cutting tool.",
                  "createdAt": 1636555599,
                  "deleted": false,
                  "id": "Q29tbWVudC0zNDc0NTY2Nw==",
                  "parentId": "Q29tbWVudC0zNDc0MDc3NA==",
                  "replies": {
                    "totalCount": 0
                  }
                }
              },
              {
                "__typename": "CommentEdge",
                "node": {
                  "__typename": "Comment",
                  "author": {
                    "backings": null,
                    "backingsCount": 42,
                    "chosenCurrency": null,
                    "createdProjects": {
                      "totalCount": 0
                    },
                    "email": "lord@example.com",
                    "hasPassword": null,
                    "hasUnreadMessages": null,
                    "hasUnseenActivity": null,
                    "id": "VXNlci04MjkwODk1MDY=",
                    "imageUrl": "example.com/lord-of-profile-pictures",
                    "isAppleConnected": null,
                    "isCreator": null,
                    "isDeliverable": null,
                    "isEmailVerified": true,
                    "isFacebookConnected": null,
                    "isKsrAdmin": null,
                    "isFollowing": false,
                    "isSocializing": null,
                    "location": null,
                    "name": "Lord of Creation",
                    "needsFreshFacebookToken": null,
                    "newsletterSubscriptions": null,
                    "notifications": null,
                    "optedOutOfRecommendations": null,
                    "showPublicProfile": null,
                    "savedProjects": null,
                    "surveyResponses": null,
                    "uid": "41"
                  },
                  "authorBadges": [],
                  "body": "The materials list",
                  "createdAt": 1636558376,
                  "deleted": false,
                  "id": "Q29tbWVudC0zNDc0NjMxMA==",
                  "parentId": "Q29tbWVudC0zNDc0MDc3NA==",
                  "replies": {
                    "totalCount": 0
                  }
                }
              },
              {
                "__typename": "CommentEdge",
                "node": {
                  "__typename": "Comment",
                  "author": {
                    "backings": null,
                    "backingsCount": 4,
                    "chosenCurrency": null,
                    "createdProjects": {
                      "totalCount": 0
                    },
                    "email": "b@example.com",
                    "hasPassword": null,
                    "hasUnreadMessages": null,
                    "hasUnseenActivity": null,
                    "id": "VXNlci0xODMyMzE0ODY2",
                    "imageUrl": "https://i.kickstarter.com/missing_user_avatar.png?anim=false&fit=crop&height=1024&origin=ugc-qa&q=92&width=1024&sig=3CEELuVLNdj97Pjx4PDy7Q9OTZfKyMEZyeIlQicGPBY%3D",
                    "isAppleConnected": null,
                    "isCreator": null,
                    "isDeliverable": null,
                    "isEmailVerified": true,
                    "isFacebookConnected": null,
                    "isKsrAdmin": null,
                    "isFollowing": false,
                    "isSocializing": null,
                    "location": null,
                    "name": "B Bear",
                    "needsFreshFacebookToken": null,
                    "newsletterSubscriptions": null,
                    "notifications": null,
                    "optedOutOfRecommendations": null,
                    "showPublicProfile": null,
                    "savedProjects": null,
                    "surveyResponses": null,
                    "uid": "43"
                  },
                  "authorBadges": [],
                  "body": "I think I saw them state elsewhere that for stainless steel it actually oxidizes it, which marks it. If you google oxidize stainless steel with laser some studies come up about how that works.",
                  "createdAt": 1636584802,
                  "deleted": false,
                  "id": "Q29tbWVudC0zNDc1MjkxOQ==",
                  "parentId": "Q29tbWVudC0zNDc0MDc3NA==",
                  "replies": {
                    "totalCount": 0
                  }
                }
              },
              {
                "__typename": "CommentEdge",
                "node": {
                  "__typename": "Comment",
                  "author": {
                    "backings": null,
                    "backingsCount": 2,
                    "chosenCurrency": null,
                    "createdProjects": {
                      "totalCount": 9
                    },
                    "email": "ksr@example.com",
                    "hasPassword": null,
                    "hasUnreadMessages": null,
                    "hasUnseenActivity": null,
                    "id": "VXNlci0xODE4NTA1NjEz",
                    "imageUrl": "example.com/ksr",
                    "isAppleConnected": null,
                    "isCreator": null,
                    "isDeliverable": null,
                    "isEmailVerified": true,
                    "isFacebookConnected": true,
                    "isKsrAdmin": null,
                    "isFollowing": false,
                    "isSocializing": null,
                    "location": {
                      "country": "JP",
                      "countryName": "Japan",
                      "displayableName": "Omachi, Japan",
                      "id": "TG9jYXRpb24tOTAwMzU3NDI=",
                      "name": "Omachi"
                    },
                    "name": "Kickstarter",
                    "needsFreshFacebookToken": null,
                    "newsletterSubscriptions": null,
                    "notifications": null,
                    "optedOutOfRecommendations": null,
                    "showPublicProfile": null,
                    "savedProjects": null,
                    "surveyResponses": null,
                    "uid": "44"
                  },
                  "authorBadges": [
                    "creator"
                  ],
                  "body": "Hi all",
                  "createdAt": 1636605009,
                  "deleted": false,
                  "id": "Q29tbWVudC0zNDc1NTU5NA==",
                  "parentId": "Q29tbWVudC0zNDc0MDc3NA==",
                  "replies": {
                    "totalCount": 0
                  }
                }
              }
            ],
            "pageInfo": {
              "__typename": "PageInfo",
              "hasPreviousPage": true,
              "startCursor": "Mg=="
            },
            "totalCount": 8
          }
        }
    }
    """

    let data = Data(json.utf8)

    return (try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) ?? [:]
  }

  private var erroredResultMap: [String: Any?] {
    return CommentFragmentTemplate.valid.data
  }
}
