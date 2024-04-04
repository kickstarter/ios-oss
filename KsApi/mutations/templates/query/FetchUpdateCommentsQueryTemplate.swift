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
                "email": "jasonwf78@gmail.com.ksr",
                "hasPassword": null,
                "id": "VXNlci0xNjcxNzM0MDA1",
                "imageUrl": "https://i.kickstarter.com/missing_user_avatar.png?anim=false&fit=crop&height=1024&origin=ugc-qa&q=92&width=1024&sig=3CEELuVLNdj97Pjx4PDy7Q9OTZfKyMEZyeIlQicGPBY%3D",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "Jason fuhrman",
                "uid": "1671734005"
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
                "email": "ccrossley4@comcast.net.ksr",
                "hasPassword": null,
                "id": "VXNlci0xNjI4MTEzNTYz",
                "imageUrl": "https://i.kickstarter.com/assets/006/823/439/fbc2b94a5d9003aceafa22a93406db2a_original.jpg?anim=false&fit=crop&height=1024&origin=ugc-qa&q=92&width=1024&sig=GxNJ72wn%2FnXTa85LLGW1I7H0oRy%2FzQ4IKb682%2BnlTY0%3D",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "MidnightBlue",
                "uid": "1628113563"
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
                "email": "paragonlostinspace@gmail.com.ksr",
                "hasPassword": null,
                "id": "VXNlci0xNDg2NzY4MTk3",
                "imageUrl": "https://i.kickstarter.com/assets/029/666/984/f039c6bc1fc61bd0def30e46ad73a08e_original.PNG?anim=false&fit=crop&height=1024&origin=ugc-qa&q=92&width=1024&sig=G3SotALauKg6ko6qDm1HGzSwog%2BrVbM8P0gmRmgHfAw%3D",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "Paragonlostinspace",
                "uid": "1486768197"
              },
              "authorBadges": [],
              "body": "OK, I am confused.",
              "createdAt": 1628090170,
              "deleted": false,
              "id": "Q29tbWVudC0zMzY1MDgwNw==",
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
                "email": "bergimus@gmail.com.ksr",
                "hasPassword": null,
                "id": "VXNlci02MDY5ODM4Nw==",
                "imageUrl": "https://i.kickstarter.com/missing_user_avatar.png?anim=false&fit=crop&height=1024&origin=ugc-qa&q=92&width=1024&sig=3CEELuVLNdj97Pjx4PDy7Q9OTZfKyMEZyeIlQicGPBY%3D",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "KBerg",
                "uid": "60698387"
              },
              "authorBadges": [],
              "body": "That's great! (But I don't want to REDUCE my pledge.... hmmm... if only I hadn't just bought the Raven's Purge PDF or I'd get the hardcopy.... that was shortsighted knowing the KS was on the horizon.  I'm not really in the market for another RPG.... though Mutant Year Zero and Things from the Flood are both tempting... hmmm.)",
              "createdAt": 1628081075,
              "deleted": false,
              "id": "Q29tbWVudC0zMzY0OTIzNQ==",
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
                "email": "info@frialigan.se.ksr",
                "hasPassword": null,
                "id": "VXNlci0xMTkyMDUzMDEx",
                "imageUrl": "https://i.kickstarter.com/assets/007/122/443/a674042059f8aa7a9bf8e731f0f00330_original.png?anim=false&fit=crop&height=1024&origin=ugc-qa&q=92&width=1024&sig=SDlapGu%2BwygmPNGT2gZBjWkB8Mr5Qo8gzUKIMj7fcu0%3D",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "Free League",
                "uid": "1192053011"
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
          }, {
            "__typename": "CommentEdge",
            "node": {
              "__typename": "Comment",
              "author": {
                "__typename": "User",
                "chosenCurrency": null,
                "email": "a.bergquist68@gmail.com.ksr",
                "hasPassword": null,
                "id": "VXNlci01Mjk4NjA1MzY=",
                "imageUrl": "https://i.kickstarter.com/missing_user_avatar.png?anim=false&fit=crop&height=1024&origin=ugc-qa&q=92&width=1024&sig=3CEELuVLNdj97Pjx4PDy7Q9OTZfKyMEZyeIlQicGPBY%3D",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "Andreas Bergquist",
                "uid": "529860536"
              },
              "authorBadges": [],
              "body": "I assume the add on page still needs to be updated? I have removed my separate map & cards add on and just keeping the book add on trusting that this will be a bundle instead, correct?",
              "createdAt": 1628075633,
              "deleted": false,
              "id": "Q29tbWVudC0zMzY0ODU5Mw==",
              "parentId": null,
              "replies": {
                "__typename": "CommentConnection",
                "totalCount": 3
              }
            }
          }, {
            "__typename": "CommentEdge",
            "node": {
              "__typename": "Comment",
              "author": {
                "__typename": "User",
                "chosenCurrency": null,
                "email": "k.baussart@gmail.com.ksr",
                "hasPassword": null,
                "id": "VXNlci00ODc2MTkwMDg=",
                "imageUrl": "https://i.kickstarter.com/missing_user_avatar.png?anim=false&fit=crop&height=1024&origin=ugc-qa&q=92&width=1024&sig=3CEELuVLNdj97Pjx4PDy7Q9OTZfKyMEZyeIlQicGPBY%3D",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "Kevin Baussart",
                "uid": "487619008"
              },
              "authorBadges": [],
              "body": "You guys are the best!",
              "createdAt": 1628071489,
              "deleted": false,
              "id": "Q29tbWVudC0zMzY0ODE2Nw==",
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
                "email": "frederic.oriol@gmail.com.ksr",
                "hasPassword": null,
                "id": "VXNlci0xNDcyMDQxMzEy",
                "imageUrl": "https://i.kickstarter.com/assets/010/575/985/bd7a2af611d17ef4ae0904b636c34d9d_original.jpg?anim=false&fit=crop&height=1024&origin=ugc-qa&q=92&width=1024&sig=p9WEmeyZHQ1%2BWdcSLjhnQ%2BoKf3m54VYBkxCx%2FlZVoA4%3D",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "Frederic Oriol",
                "uid": "1472041312"
              },
              "authorBadges": [],
              "body": "When I select add-ons in the pledge manager, is there a Bitter Reach bundle that I can select, because at the moment it's still separate items: core book.",
              "createdAt": 1628071442,
              "deleted": false,
              "id": "Q29tbWVudC0zMzY0ODE2MA==",
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
                "email": "doeweling@gmx.de.ksr",
                "hasPassword": null,
                "id": "VXNlci00NzkwMjU0Njk=",
                "imageUrl": "https://i.kickstarter.com/assets/010/425/119/97b9e5e0b2f403c419d3af80abd1eb5c_original.jpg?anim=false&fit=crop&height=1024&origin=ugc-qa&q=92&width=1024&sig=Dtt%2B%2BmD0Fw%2FF3kFyLaxznPseGKXZgpgnJ1OnHZUe3JI%3D",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "Sebastian D.",
                "uid": "479025469"
              },
              "authorBadges": ["superbacker"],
              "body": "Great service for those that newly join the game!",
              "createdAt": 1628071370,
              "deleted": false,
              "id": "Q29tbWVudC0zMzY0ODE1Mg==",
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
                "email": "post@tjittedevries.com.ksr",
                "hasPassword": null,
                "id": "VXNlci0xNjEzMTIwNTM5",
                "imageUrl": "https://i.kickstarter.com/assets/006/031/729/2a82079fd5f6b58d71ad35047c5f19e8_original.jpg?anim=false&fit=crop&height=1024&origin=ugc-qa&q=92&width=1024&sig=GgY7MpiFWwtdHTu9gHHeW75u9pTkmSz9k4bME5tF3JI%3D",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "Tjitte de Vries",
                "uid": "1613120539"
              },
              "authorBadges": [],
              "body": "Very nice, I already own it, but good for everyone who wants the complete their collection,",
              "createdAt": 1628071250,
              "deleted": false,
              "id": "Q29tbWVudC0zMzY0ODEzNw==",
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
                "email": "thomas.lazaridis@gmail.com.ksr",
                "hasPassword": null,
                "id": "VXNlci0xNjMwMzY1Mjk=",
                "imageUrl": "https://i.kickstarter.com/assets/029/256/256/4ebabf176f48ad987808d872a7497c6c_original.jpg?anim=false&fit=crop&height=1024&origin=ugc-qa&q=92&width=1024&sig=v2mmcpA3KGOAn8%2BYhtRLlCrWQrvzYqQUNS0MDCDFKv4%3D",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "Thomas",
                "uid": "163036529"
              },
              "authorBadges": [],
              "body": "Awesome I was about to enquiry about that issue !",
              "createdAt": 1628071238,
              "deleted": false,
              "id": "Q29tbWVudC0zMzY0ODEzNA==",
              "parentId": null,
              "replies": {
                "__typename": "CommentConnection",
                "totalCount": 0
              }
            }
          }],
          "pageInfo": {
            "__typename": "PageInfo",
            "endCursor": "WzMzNjQ4MTM0XQ==",
            "hasNextPage": false
          },
          "totalCount": 11
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
