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
                   "imageUrl":"https://ksr-qa-ugc.imgix.net/assets/033/090/101/8667751e512228a62d426c77f6eb8a0b_original.jpg?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1618227451&auto=format&frame=1&q=92&s=36de925b6797139e096d7b6219f743d0",
                   "isAppleConnected":false,
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
                            "type":"VISA"
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
                   "imageUrl":"https://ksr-qa-ugc.imgix.net/assets/033/846/528/69cae8b2ccc2403e233b5715cb1f869f_original.png?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1623351187&auto=format&frame=1&q=92&s=d0d5f5993e64056e5ddf7e42b56e50cd",
                   "isAppleConnected":null,
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
