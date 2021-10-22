import Apollo
@testable import KsApi

public enum FetchUserBackingsQueryTemplate {
  case valid
  case errored

  var data: GraphAPI.FetchUserBackingsQuery.Data {
    switch self {
    case .valid:
      return GraphAPI.FetchUserBackingsQuery.Data(unsafeResultMap: self.validResultMap)
    case .errored:
      return GraphAPI.FetchUserBackingsQuery.Data(unsafeResultMap: self.erroredResultMap)
    }
  }

  // MARK: Private Properties

  private var validResultMap: [String: Any?] {
    [
      "data": [
        "me": [
          "__typename": "User",
          "backings": [
            "__typename": "UserBackingsConnection",
            "nodes": [[
              "__typename": "Backing",
              "addOns": [
                "__typename": "RewardTotalCountConnection",
                "nodes": []
              ],
              "errorReason": "Your card was declined.",
              "amount": [
                "__typename": "Money",
                "amount": "1.0",
                "currency": "USD",
                "symbol": "$"
              ],
              "backer": [
                "__typename": "User",
                "chosenCurrency": "USD",
                "email": "singh.harichandan@gmail.com",
                "hasPassword": true,
                "id": "VXNlci0xNDcwOTUyNTQ1",
                "imageUrl": "https://ksr-qa-ugc.imgix.net/missing_user_avatar.png?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=&auto=format&frame=1&q=92&s=e17a7b6f853aa6320cfe67ee783eb3d8",
                "isAppleConnected": false,
                "isCreator": false,
                "isDeliverable": true,
                "isEmailVerified": true,
                "name": "Hari Singh",
                "uid": "1470952545"
              ],
              "backerCompleted": false,
              "bonusAmount": [
                "__typename": "Money",
                "amount": "1.0",
                "currency": "USD",
                "symbol": "$"
              ],
              "cancelable": false,
              "creditCard": [
                "__typename": "CreditCard",
                "expirationDate": "2023-01-01",
                "id": "69021312",
                "lastFour": "0341",
                "paymentType": "CREDIT_CARD",
                "state": "ACTIVE",
                "type": "VISA"
              ],
              "id": "QmFja2luZy0xNDQ5NTI3NTQ=",
              "location": nil,
              "pledgedOn": 1_627_592_045,
              "project": [
                "__typename": "Project",
                "backersCount": 4,
                "category": [
                  "__typename": "Category",
                  "id": "Q2F0ZWdvcnktMjg1",
                  "name": "Plays",
                  "parentCategory": [
                    "__typename": "Category",
                    "id": "Q2F0ZWdvcnktMTc=",
                    "name": "Theater"
                  ]
                ],
                "canComment": false,
                "country": [
                  "__typename": "Country",
                  "code": "US",
                  "name": "the United States"
                ],
                "creator": [
                  "__typename": "User",
                  "chosenCurrency": nil,
                  "email": "afees.olabisi@gmail.com",
                  "hasPassword": nil,
                  "id": "VXNlci03NDAzNzgwNzc=",
                  "imageUrl": "https://ksr-qa-ugc.imgix.net/assets/033/406/310/0643a06ea18a1462cc8466af5718d9ef_original.jpeg?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1620659730&auto=format&frame=1&q=92&s=86608b67fc0b349026722388df683a89",
                  "isAppleConnected": nil,
                  "isCreator": nil,
                  "isDeliverable": true,
                  "isEmailVerified": true,
                  "name": "Afees Lawal",
                  "uid": "740378077"
                ],
                "currency": "USD",
                "deadlineAt": 1_683_676_800,
                "description": "test blurb",
                "finalCollectionDate": nil,
                "fxRate": 1.0,
                "friends": [
                  "__typename": "ProjectBackerFriendsConnection",
                  "nodes": []
                ],
                "goal": [
                  "__typename": "Money",
                  "amount": "19974.0",
                  "currency": "USD",
                  "symbol": "$"
                ],
                "image": [
                  "__typename": "Photo",
                  "id": "UGhvdG8tMTEyNTczMzY=",
                  "url": "https://ksr-qa-ugc.imgix.net/assets/011/257/336/a371c892fb6e936dc1824774bea14a1b_original.jpg?ixlib=rb-4.0.2&crop=faces&w=1024&h=576&fit=crop&v=1463673674&auto=format&frame=1&q=92&s=87715e16f6e9b5a26afa42ea54a33fcc"
                ],
                "isProjectWeLove": false,
                "isWatched": false,
                "launchedAt": 1_620_662_504,
                "location": [
                  "__typename": "Location",
                  "country": "NG",
                  "countryName": "Nigeria",
                  "displayableName": "Nigeria",
                  "id": "TG9jYXRpb24tMjM0MjQ5MDg=",
                  "name": "Nigeria"
                ],
                "name": "Mouth Trumpet Robot Cats",
                "pid": 1_234_627_104,
                "pledged": [
                  "__typename": "Money",
                  "amount": "65.0",
                  "currency": "USD",
                  "symbol": "$"
                ],
                "slug": "afeestest/mouth-trumpet-robot-cats",
                "state": "LIVE",
                "stateChangedAt": 1_620_662_506,
                "url": "https://staging.kickstarter.com/projects/afeestest/mouth-trumpet-robot-cats",
                "usdExchangeRate": 1.0
              ],
              "reward": nil,
              "sequence": 5,
              "shippingAmount": [
                "__typename": "Money",
                "amount": "0.0",
                "currency": "USD",
                "symbol": "$"
              ],
              "status": "errored"
            ]],
            "totalCount": 1
          ],
          "id": "VXNlci0xNDcwOTUyNTQ1",
          "imageUrl": "https://ksr-qa-ugc.imgix.net/missing_user_avatar.png?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=&auto=format&frame=1&q=92&s=e17a7b6f853aa6320cfe67ee783eb3d8",
          "name": "Hari Singh",
          "uid": "1470952545"
        ]
      ]
    ]
  }

  private var erroredResultMap: [String: Any?] {
    return [:]
  }
}
