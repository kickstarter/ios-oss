import Apollo
import Foundation
@testable import KsApi

public enum FetchProjectFriendsQueryTemplate {
  case valid
  case errored

  /// `FetchProjectBySlug` returns identical data.
  var data: GraphAPI.FetchProjectFriendsByIdQuery.Data {
    switch self {
    case .valid:
      return GraphAPI.FetchProjectFriendsByIdQuery.Data(unsafeResultMap: self.validResultMap)
    case .errored:
      return GraphAPI.FetchProjectFriendsByIdQuery.Data(unsafeResultMap: self.erroredResultMap)
    }
  }

  // MARK: Private Properties

  private var validResultMap: [String: Any] {
    let json = """
    {
       "project":{
          "friends":{
             "__typename":"ProjectBackerFriendsConnection",
             "nodes":[
                {
                   "__typename":"User",
                   "chosenCurrency":"USD",
                   "email":"foo@bar.com",
                   "backingsCount": 0,
                   "hasPassword":true,
                   "id":"VXNlci0xNzA1MzA0MDA2",
                   "imageUrl":"https://i.kickstarter.com/assets/033/090/101/8667751e512228a62d426c77f6eb8a0b_original.jpg?anim=false&fit=crop&height=1024&origin=ugc-qa&q=92&width=1024&sig=rx0xtkeNd0nbjmCk7YUFmX6r9wC1ygRS%2BX8OkjVWg%2Bw%3D",
                   "isAppleConnected":false,
                   "isBlocked":null,
                   "isCreator":null,
                   "isDeliverable":true,
                   "isEmailVerified":true,
                   "isFollowing":true,
                   "name":"Peppermint Fox",
                   "location":{
                      "country":"US",
                      "countryName":"United States",
                      "displayableName":"Las Vegas, NV",
                      "id":"TG9jYXRpb24tMjQzNjcwNA==",
                      "name":"Las Vegas"
                   },
                   "storedCards":{
                      "__typename":"UserCreditCardTypeConnection",
                      "nodes":[
                         {
                            "__typename":"CreditCard",
                            "expirationDate":"2023-01-01",
                            "id":"6",
                            "lastFour":"4242",
                            "type":"VISA",
                            "stripeCardId": "pm_1OtGFX4VvJ2PtfhK3Gp00SWK",
                         }
                      ],
                      "totalCount":1
                   },
                   "uid":"1705304006"
                },
                {
                   "__typename":"User",
                   "backings":{
                      "nodes":[
                         {
                            "errorReason":null
                         },
                         {
                            "errorReason":"Something went wrong"
                         },
                         {
                            "errorReason":null
                         }
                      ]
                   },
                   "backingsCount": 3,
                   "chosenCurrency":null,
                   "email":"theaschneider@gmx.net.ksr",
                   "hasPassword":null,
                   "id":"VXNlci0xNTMyMzU3OTk3",
                   "imageUrl":"https://i.kickstarter.com/assets/033/846/528/69cae8b2ccc2403e233b5715cb1f869f_original.png?anim=false&fit=crop&height=1024&origin=ugc-qa&q=92&width=1024&sig=Aqxdt8UgJpaDfrw6J1yrxsCD1IMS%2FZMnpPjISr2HX7I%3D",
                   "isAppleConnected":null,
                   "isBlocked":false,
                   "isCreator":true,
                   "isDeliverable":null,
                   "isEmailVerified":true,
                   "isFacebookConnected":false,
                   "isFollowing":true,
                   "isKsrAdmin":true,
                   "name":"Thea Schneider",
                   "needsFreshFacebookToken":true,
                   "showPublicProfile":true,
                   "uid":"1532357997",
                   "location":{
                      "country":"US",
                      "countryName":"United States",
                      "displayableName":"Las Vegas, NV",
                      "id":"TG9jYXRpb24tMjQzNjcwNA==",
                      "name":"Las Vegas"
                   },
                   "storedCards":{
                      "__typename":"UserCreditCardTypeConnection",
                      "nodes":[

                      ],
                      "totalCount":0
                   }
                }
             ]
          }
       }
    }
    """

    let data = Data(json.utf8)
    let resultMap = (try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) ?? [:]

    return resultMap
  }

  private var erroredResultMap: [String: Any?] {
    return [:]
  }
}
