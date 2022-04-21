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
                "email": "jonnyhodgsonart@gmail.com.ksr",
                "hasPassword": null,
                "id": "VXNlci0xOTE0Njg1MDc2",
                "imageUrl": "https://ksr-qa-ugc.imgix.net/assets/008/165/274/b08e5665d487daaaef3c96fd02d4e29f_original.jpeg?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1624558095&auto=format&frame=1&q=92&s=3112180f84bfe53cc889475e29022ecf",
                "isAppleConnected": null,
                "isCreator": true,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "Jon Hodgson",
                "uid": "1914685076"
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
                "email": "benvenutto.paolo@gmail.com.ksr",
                "hasPassword": null,
                "id": "VXNlci0xODMyNTk4MjQ4",
                "imageUrl": "https://ksr-qa-ugc.imgix.net/missing_user_avatar.png?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=&auto=format&frame=1&q=92&s=e17a7b6f853aa6320cfe67ee783eb3d8",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "Paolo",
                "uid": "1832598248"
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
                "email": "blferguson1@gmail.com.ksr",
                "hasPassword": null,
                "id": "VXNlci02MjMxODYxMjg=",
                "imageUrl": "https://ksr-qa-ugc.imgix.net/assets/006/194/087/ea5ac83371173d1d8c9c2a12e312e919_original.jpg?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1517599740&auto=format&frame=1&q=92&s=e31dc3da13f11c7cdd085c5d61b03ec8",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "Ben Ferguson",
                "uid": "623186128"
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
                "email": "arthur.boff@gmail.com.ksr",
                "hasPassword": null,
                "id": "VXNlci0yOTI1NTA5MDQ=",
                "imageUrl": "https://ksr-qa-ugc.imgix.net/missing_user_avatar.png?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=&auto=format&frame=1&q=92&s=e17a7b6f853aa6320cfe67ee783eb3d8",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "Arthur B",
                "uid": "292550904"
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
                "email": "johnk100@sympatico.ca.ksr",
                "hasPassword": null,
                "id": "VXNlci0xMzQyNDMxNzk2",
                "imageUrl": "https://ksr-qa-ugc.imgix.net/assets/005/811/165/dcb2d0028b4aa7c01251aef674dd5190_original.jpeg?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1461086710&auto=format&frame=1&q=92&s=a9bedfd55fc60269887b9355bc27848a",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "John M. Kahane",
                "uid": "1342431796"
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
                "email": "blferguson1@gmail.com.ksr",
                "hasPassword": null,
                "id": "VXNlci02MjMxODYxMjg=",
                "imageUrl": "https://ksr-qa-ugc.imgix.net/assets/006/194/087/ea5ac83371173d1d8c9c2a12e312e919_original.jpg?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1517599740&auto=format&frame=1&q=92&s=e31dc3da13f11c7cdd085c5d61b03ec8",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "Ben Ferguson",
                "uid": "623186128"
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
          }, {
            "__typename": "CommentEdge",
            "node": {
              "__typename": "Comment",
              "author": {
                "__typename": "User",
                "chosenCurrency": null,
                "email": "poetisland@hotmail.com.ksr",
                "hasPassword": null,
                "id": "VXNlci0yMzU0NDQ3Nzk=",
                "imageUrl": "https://ksr-qa-ugc.imgix.net/missing_user_avatar.png?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=&auto=format&frame=1&q=92&s=e17a7b6f853aa6320cfe67ee783eb3d8",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "Devin Croak",
                "uid": "235444779"
              },
              "authorBadges": ["superbacker"],
              "body": "This sounds like an exciting FintD system with a good focus on changing it mildly to fit the setting. I got some add-ons but I might have some coin to put to more add-ons later will they be a pledge manager after the campaign?",
              "createdAt": 1627953847,
              "deleted": false,
              "id": "Q29tbWVudC0zMzYzMjIwMA==",
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
                "email": "buklo46@gmail.com.ksr",
                "hasPassword": null,
                "id": "VXNlci0xNDgxNDQ0OTQy",
                "imageUrl": "https://ksr-qa-ugc.imgix.net/missing_user_avatar.png?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=&auto=format&frame=1&q=92&s=e17a7b6f853aa6320cfe67ee783eb3d8",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "Jarno Humala",
                "uid": "1481444942"
              },
              "authorBadges": [],
              "body": "Infernal machine. Is it from 1st Ed.",
              "createdAt": 1627834766,
              "deleted": false,
              "id": "Q29tbWVudC0zMzYxOTU2Nw==",
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
                "email": "jonnyhodgsonart@gmail.com.ksr",
                "hasPassword": null,
                "id": "VXNlci0xOTE0Njg1MDc2",
                "imageUrl": "https://ksr-qa-ugc.imgix.net/assets/008/165/274/b08e5665d487daaaef3c96fd02d4e29f_original.jpeg?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1624558095&auto=format&frame=1&q=92&s=3112180f84bfe53cc889475e29022ecf",
                "isAppleConnected": null,
                "isCreator": true,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "Jon Hodgson",
                "uid": "1914685076"
              },
              "authorBadges": ["creator"],
              "body": "Looks like we've made it across that line...",
              "createdAt": 1627829296,
              "deleted": false,
              "id": "Q29tbWVudC0zMzYxOTA4OA==",
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
                "email": "sablefox@icloud.com.ksr",
                "hasPassword": null,
                "id": "VXNlci0xNzc4NDQ5Mjk3",
                "imageUrl": "https://ksr-qa-ugc.imgix.net/assets/007/425/250/1efacdb4e54d6acaa598ec669a2ae42c_original.gif?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1461456598&auto=format&frame=1&q=92&s=081a35505c2aa3d22b7dcd307ec3c420",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "SableFox",
                "uid": "1778449297"
              },
              "authorBadges": ["superbacker"],
              "body": "More extra art is on its way :-)",
              "createdAt": 1627823973,
              "deleted": false,
              "id": "Q29tbWVudC0zMzYxODY3MQ==",
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
                "email": "jonathan.fish@ntlworld.com.ksr",
                "hasPassword": null,
                "id": "VXNlci03MDE5OTM4MDM=",
                "imageUrl": "https://ksr-qa-ugc.imgix.net/missing_user_avatar.png?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=&auto=format&frame=1&q=92&s=e17a7b6f853aa6320cfe67ee783eb3d8",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "Jonathan Fish",
                "uid": "701993803"
              },
              "authorBadges": [],
              "body": "Looking forward to this. Back in the day, I started on a conversion to BTRC's EABA rules - never finished it though. I will admit that I'm not 100% sure on the use of FiTD rules for this (I like FITD but think I would prefer something less mission focussed for A-State) but the comments I have seen so far have been good, so remain optimistic.",
              "createdAt": 1627761382,
              "deleted": false,
              "id": "Q29tbWVudC0zMzYxNDg3Nw==",
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
                "email": "jonnyhodgsonart@gmail.com.ksr",
                "hasPassword": null,
                "id": "VXNlci0xOTE0Njg1MDc2",
                "imageUrl": "https://ksr-qa-ugc.imgix.net/assets/008/165/274/b08e5665d487daaaef3c96fd02d4e29f_original.jpeg?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1624558095&auto=format&frame=1&q=92&s=3112180f84bfe53cc889475e29022ecf",
                "isAppleConnected": null,
                "isCreator": true,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "Jon Hodgson",
                "uid": "1914685076"
              },
              "authorBadges": ["creator"],
              "body": "Just a quick hello from Saturday night in the UK. Things are still chugging along nicely, eh? I’ll do a proper update tomorrow, so let’s see where we get to then!",
              "createdAt": 1627755286,
              "deleted": false,
              "id": "Q29tbWVudC0zMzYxNDMzOQ==",
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
                "email": "jdellercsp@googlemail.com.ksr",
                "hasPassword": null,
                "id": "VXNlci01MzMzNDYxOTc=",
                "imageUrl": "https://ksr-qa-ugc.imgix.net/assets/034/376/830/55f6bf0850210ab0f7dfbf56af1ea8a2_original.jpg?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1627753384&auto=format&frame=1&q=92&s=79e332df35a9f946e43b7902f7bca1f2",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "Mech",
                "uid": "533346197"
              },
              "authorBadges": [],
              "body": "I just really hope we get Fantasy grounds, Foundry etc support! Love the preview so far lotta great and unique ideas, really got my LM juices flowing.",
              "createdAt": 1627753489,
              "deleted": false,
              "id": "Q29tbWVudC0zMzYxNDE3Nw==",
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
                "email": "gvaward@icloud.com.ksr",
                "hasPassword": null,
                "id": "VXNlci0xNzQ1ODQxNTk=",
                "imageUrl": "https://ksr-qa-ugc.imgix.net/assets/018/073/556/88909627983527812b35428f261f9b25_original.jpeg?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1588032504&auto=format&frame=1&q=92&s=f28eac1e911b3e378b6647ad70c580ef",
                "isAppleConnected": null,
                "isCreator": false,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "Scott Hodgman",
                "uid": "174584159"
              },
              "authorBadges": [],
              "body": "Hi Jon, always appreciate the posts provided by you and the team.",
              "createdAt": 1627648617,
              "deleted": false,
              "id": "Q29tbWVudC0zMzYwMzgxNA==",
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
                "email": "jake31.rodgers@gmail.com.ksr",
                "hasPassword": null,
                "id": "VXNlci0xMDA4OTU3Nzg=",
                "imageUrl": "https://ksr-qa-ugc.imgix.net/assets/014/549/655/3ce622f0a611395af86882f757f0fcfe_original.jpg?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1627296631&auto=format&frame=1&q=92&s=dd0d9fabda52cc3ca7d131d937eeeed0",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "Jacob Rodgers",
                "uid": "100895778"
              },
              "authorBadges": ["collaborator"],
              "body": "We've made it to 20k!!! With that, we've unlocked The Grand Emporium, for all your window-shopping needs in The City.",
              "createdAt": 1627603305,
              "deleted": false,
              "id": "Q29tbWVudC0zMzU5OTM3NA==",
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
                "email": "johnk100@sympatico.ca.ksr",
                "hasPassword": null,
                "id": "VXNlci0xMzQyNDMxNzk2",
                "imageUrl": "https://ksr-qa-ugc.imgix.net/assets/005/811/165/dcb2d0028b4aa7c01251aef674dd5190_original.jpeg?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1461086710&auto=format&frame=1&q=92&s=a9bedfd55fc60269887b9355bc27848a",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "John M. Kahane",
                "uid": "1342431796"
              },
              "authorBadges": [],
              "body": "Hullo, folks.",
              "createdAt": 1627573621,
              "deleted": false,
              "id": "Q29tbWVudC0zMzU5NDc1Ng==",
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
                "email": "johnk100@sympatico.ca.ksr",
                "hasPassword": null,
                "id": "VXNlci0xMzQyNDMxNzk2",
                "imageUrl": "https://ksr-qa-ugc.imgix.net/assets/005/811/165/dcb2d0028b4aa7c01251aef674dd5190_original.jpeg?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1461086710&auto=format&frame=1&q=92&s=a9bedfd55fc60269887b9355bc27848a",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "John M. Kahane",
                "uid": "1342431796"
              },
              "authorBadges": [],
              "body": "Hey, folks.",
              "createdAt": 1627525418,
              "deleted": false,
              "id": "Q29tbWVudC0zMzU4OTYxOA==",
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
                "email": "jake31.rodgers@gmail.com.ksr",
                "hasPassword": null,
                "id": "VXNlci0xMDA4OTU3Nzg=",
                "imageUrl": "https://ksr-qa-ugc.imgix.net/assets/014/549/655/3ce622f0a611395af86882f757f0fcfe_original.jpg?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1627296631&auto=format&frame=1&q=92&s=dd0d9fabda52cc3ca7d131d937eeeed0",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "Jacob Rodgers",
                "uid": "100895778"
              },
              "authorBadges": ["collaborator"],
              "body": "Another Stretch Goal completed!",
              "createdAt": 1627522105,
              "deleted": false,
              "id": "Q29tbWVudC0zMzU4OTMwNA==",
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
                "email": "sablefox@icloud.com.ksr",
                "hasPassword": null,
                "id": "VXNlci0xNzc4NDQ5Mjk3",
                "imageUrl": "https://ksr-qa-ugc.imgix.net/assets/007/425/250/1efacdb4e54d6acaa598ec669a2ae42c_original.gif?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1461456598&auto=format&frame=1&q=92&s=081a35505c2aa3d22b7dcd307ec3c420",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "SableFox",
                "uid": "1778449297"
              },
              "authorBadges": ["superbacker"],
              "body": "A question to @Jon or everyone else who cares to answer.",
              "createdAt": 1627515366,
              "deleted": false,
              "id": "Q29tbWVudC0zMzU4ODU3Ng==",
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
                "email": "blferguson1@gmail.com.ksr",
                "hasPassword": null,
                "id": "VXNlci02MjMxODYxMjg=",
                "imageUrl": "https://ksr-qa-ugc.imgix.net/assets/006/194/087/ea5ac83371173d1d8c9c2a12e312e919_original.jpg?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1517599740&auto=format&frame=1&q=92&s=e31dc3da13f11c7cdd085c5d61b03ec8",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "Ben Ferguson",
                "uid": "623186128"
              },
              "authorBadges": ["superbacker"],
              "body": "Really pleased to see.",
              "createdAt": 1627503431,
              "deleted": false,
              "id": "Q29tbWVudC0zMzU4NzA3OQ==",
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
                "email": "jonnyhodgsonart@gmail.com.ksr",
                "hasPassword": null,
                "id": "VXNlci0xOTE0Njg1MDc2",
                "imageUrl": "https://ksr-qa-ugc.imgix.net/assets/008/165/274/b08e5665d487daaaef3c96fd02d4e29f_original.jpeg?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1624558095&auto=format&frame=1&q=92&s=3112180f84bfe53cc889475e29022ecf",
                "isAppleConnected": null,
                "isCreator": true,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "Jon Hodgson",
                "uid": "1914685076"
              },
              "authorBadges": ["creator"],
              "body": "Good morning from the UK!",
              "createdAt": 1627460286,
              "deleted": false,
              "id": "Q29tbWVudC0zMzU4MDYwOA==",
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
                "email": "dom.mooney@gmail.com.ksr",
                "hasPassword": null,
                "id": "VXNlci0xMjI0ODc0MjMz",
                "imageUrl": "https://ksr-qa-ugc.imgix.net/assets/006/042/978/8a2a72e1d3cdfad29739bb24c9a1ba58_original.jpg?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1461362788&auto=format&frame=1&q=92&s=0e01c487c80292e657af96929bbee067",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "Dominic Mooney",
                "uid": "1224874233"
              },
              "authorBadges": ["superbacker"],
              "body": "I keep on getting the urge to call this new edition.",
              "createdAt": 1627422228,
              "deleted": false,
              "id": "Q29tbWVudC0zMzU3Njg1Mg==",
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
                "email": "jwmuk@yahoo.co.uk.ksr",
                "hasPassword": null,
                "id": "VXNlci0zMTY1MDM5NTI=",
                "imageUrl": "https://ksr-qa-ugc.imgix.net/assets/005/781/197/99bfd9ca7f3847a61bc39f6cc688f416_original.jpeg?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1461085020&auto=format&frame=1&q=92&s=9bad295f8a45bec38d3a2f9e3c8ae733",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "Jim McCarthy",
                "uid": "316503952"
              },
              "authorBadges": [],
              "body": "Great to see this funded!  Would be perfect to see a Foundry VTT set-up as a stretch goal!!",
              "createdAt": 1627411073,
              "deleted": false,
              "id": "Q29tbWVudC0zMzU3NDk0MQ==",
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
                "email": "dom.mooney@gmail.com.ksr",
                "hasPassword": null,
                "id": "VXNlci0xMjI0ODc0MjMz",
                "imageUrl": "https://ksr-qa-ugc.imgix.net/assets/006/042/978/8a2a72e1d3cdfad29739bb24c9a1ba58_original.jpg?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1461362788&auto=format&frame=1&q=92&s=0e01c487c80292e657af96929bbee067",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "Dominic Mooney",
                "uid": "1224874233"
              },
              "authorBadges": ["superbacker"],
              "body": "Brilliant. Been waiting for this for a long time, with rising excitement after I ran Nicely Done.",
              "createdAt": 1627407615,
              "deleted": false,
              "id": "Q29tbWVudC0zMzU3NDMyNQ==",
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
                "email": "lt.nemo@gmail.com.ksr",
                "hasPassword": null,
                "id": "VXNlci0xMTYxNDcxOTA=",
                "imageUrl": "https://ksr-qa-ugc.imgix.net/missing_user_avatar.png?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=&auto=format&frame=1&q=92&s=e17a7b6f853aa6320cfe67ee783eb3d8",
                "isAppleConnected": null,
                "isCreator": null,
                "isDeliverable": null,
                "isEmailVerified": true,
                "name": "John Fleming",
                "uid": "116147190"
              },
              "authorBadges": [],
              "body": "Funded!",
              "createdAt": 1627406634,
              "deleted": false,
              "id": "Q29tbWVudC0zMzU3NDEzMw==",
              "parentId": null,
              "replies": {
                "__typename": "CommentConnection",
                "totalCount": 1
              }
            }
          }],
          "pageInfo": {
            "__typename": "PageInfo",
            "endCursor": "WzMzNTc0MTMzXQ==",
            "hasNextPage": false
          },
          "totalCount": 34
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
