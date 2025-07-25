import Apollo
import GraphAPI
@testable import KsApi

public enum FetchUserBackingsQueryTemplate {
  case valid
  case errored

  var data: GraphAPI.FetchUserBackingsQuery.Data {
    switch self {
    case .valid:
      return try! testGraphObject(data: self.validResultMap)
    case .errored:
      return try! testGraphObject(data: self.erroredResultMap)
    }
  }

  // MARK: Private Properties

  private var validResultMap: [String: Any] {
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
                "email": "user@example.com",
                "hasPassword": true,
                "id": "VXNlci0xNDcwOTUyNTQ1",
                "imageUrl": "example.com/profile-pic",
                "isAppleConnected": false,
                "isCreator": false,
                "isDeliverable": true,
                "isEmailVerified": true,
                "name": "Example Backer",
                "uid": "12345"
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
                "type": "VISA",
                "stripeCardId": "pm_1OtGFX4VvJ2PtfhK3Gp00SWK"
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
                  "email": "c@example.com",
                  "hasPassword": nil,
                  "id": "VXNlci03NDAzNzgwNzc=",
                  "imageUrl": "example.com/creator-image",
                  "isAppleConnected": nil,
                  "isCreator": nil,
                  "isDeliverable": true,
                  "isEmailVerified": true,
                  "name": "Creator",
                  "uid": "56789"
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
                  "url": "https://i.kickstarter.com/assets/011/257/336/a371c892fb6e936dc1824774bea14a1b_original.jpg?anim=false&fit=crop&gravity=auto&height=576&origin=ugc-qa&q=92&width=1024&sig=gYjf1yGnIKXiZGrSDIM%2Bhsa4oy0JdYNXtxyj4fsepW4%3D"
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
          "imageUrl": "https://i.kickstarter.com/missing_user_avatar.png?anim=false&fit=crop&height=1024&origin=ugc-qa&q=92&width=1024&sig=3CEELuVLNdj97Pjx4PDy7Q9OTZfKyMEZyeIlQicGPBY%3D",
          "name": "Hari Singh",
          "uid": "1470952545"
        ]
      ]
    ]
  }

  private var erroredResultMap: [String: Any] {
    return [:]
  }
}
