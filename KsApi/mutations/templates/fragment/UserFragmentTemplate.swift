import Apollo
@testable import KsApi

public enum UserFragmentTemplate {
  case valid
  case errored

  var data: [String: Any?] {
    switch self {
    case .valid:
      return self.validResultMap()
    case .errored:
      return [:]
    }
  }

  // MARK: Private Properties

  private func validResultMap() -> [String: Any] {
    let json = """
    {
       "__typename":"User",
       "chosenCurrency":"USD",
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
       "email":"mubarak@kickstarter.com",
       "isAppleConnected":true,
       "isEmailVerified":false,
       "isDeliverable":true,
       "isFacebookConnected": true,
       "isKsrAdmin": false,
       "isFollowing": true,
       "hasPassword":false,
       "location": {
         "country": "US",
         "countryName": "United States",
         "displayableName": "Las Vegas, NV",
         "id": "TG9jYXRpb24tMjQzNjcwNA==",
         "name": "Las Vegas"
       },
       "needsFreshFacebookToken": true,
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
       "id":"Q2F0ZWdvcnktNDc=",
       "imageUrl":"http://www.kickstarter.com/image.jpg",
       "isCreator":false,
       "name":"Billy Bob",
       "uid":"47"
    }
    """

    let data = Data(json.utf8)
    return (try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) ?? [:]
  }
}
