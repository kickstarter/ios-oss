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
                "imageUrl": "https://ksr-qa-ugc.imgix.net/missing_user_avatar.png?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=&auto=format&frame=1&q=92&s=e17a7b6f853aa6320cfe67ee783eb3d8",
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
                "imageUrl": "https://ksr-qa-ugc.imgix.net/assets/006/823/439/fbc2b94a5d9003aceafa22a93406db2a_original.jpg?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1461413993&auto=format&frame=1&q=92&s=23340d4296a2fea82c334b84da107f64",
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
                "imageUrl": "https://ksr-qa-ugc.imgix.net/assets/029/666/984/f039c6bc1fc61bd0def30e46ad73a08e_original.PNG?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1593617057&auto=format&frame=1&q=92&s=60ca3d245c949269cf5f16a278a900b2",
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
                "imageUrl": "https://ksr-qa-ugc.imgix.net/missing_user_avatar.png?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=&auto=format&frame=1&q=92&s=e17a7b6f853aa6320cfe67ee783eb3d8",
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
                "imageUrl": "https://ksr-qa-ugc.imgix.net/assets/007/122/443/a674042059f8aa7a9bf8e731f0f00330_original.png?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1461436389&auto=format&frame=1&q=92&s=10f8c89d79638b1b25a54c6c7a7a52c8",
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
                "imageUrl": "https://ksr-qa-ugc.imgix.net/missing_user_avatar.png?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=&auto=format&frame=1&q=92&s=e17a7b6f853aa6320cfe67ee783eb3d8",
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
                "imageUrl": "https://ksr-qa-ugc.imgix.net/missing_user_avatar.png?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=&auto=format&frame=1&q=92&s=e17a7b6f853aa6320cfe67ee783eb3d8",
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
                "imageUrl": "https://ksr-qa-ugc.imgix.net/assets/010/575/985/bd7a2af611d17ef4ae0904b636c34d9d_original.jpg?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1461698970&auto=format&frame=1&q=92&s=9e016a188cd6376d647068dcb0417436",
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
                "imageUrl": "https://ksr-qa-ugc.imgix.net/assets/010/425/119/97b9e5e0b2f403c419d3af80abd1eb5c_original.jpg?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1604185412&auto=format&frame=1&q=92&s=062f520d3054756ab90f9c1730cbdb1b",
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
                "imageUrl": "https://ksr-qa-ugc.imgix.net/assets/006/031/729/2a82079fd5f6b58d71ad35047c5f19e8_original.jpg?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1461362055&auto=format&frame=1&q=92&s=3958b2c03213e5f861ab2e65a48204f4",
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
                "imageUrl": "https://ksr-qa-ugc.imgix.net/assets/029/256/256/4ebabf176f48ad987808d872a7497c6c_original.jpg?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1613054677&auto=format&frame=1&q=92&s=76557bd4866776b76932efacf2827b68",
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
