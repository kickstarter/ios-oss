import Apollo
@testable import KsApi

public enum CommentFragmentTemplate {
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
      "__typename": "Comment",
      "author": {
        "__typename": "User",
        "chosenCurrency": "USD",
        "backings":{
          "__typename": "UserBackingsConnection",
          "nodes":[
              {
                "__typename": "Backing",
                "errorReason":null
              },
              {
                "__typename": "Backing",
                "errorReason":"Something went wrong"
              },
              {
                "__typename": "Backing",
                "errorReason":null
              }
          ]
        },
        "email": "mubarak@kickstarter.com",
        "isAppleConnected": true,
        "isEmailVerified": false,
        "isDeliverable": true,
        "isFacebookConnected": true,
        "isKsrAdmin": false,
        "isFollowing": true,
        "hasPassword": false,
        "needsFreshFacebookToken": true,
        "location": {
          "__typename": "Location",
          "country": "US",
          "countryName": "United States",
          "displayableName": "Las Vegas, NV",
          "id": "TG9jYXRpb24tMjQzNjcwNA==",
          "name": "Las Vegas"
        },
        "storedCards": {
          "__typename": "UserCreditCardTypeConnection",
          "nodes": [
            {
              "__typename": "CreditCard",
              "expirationDate": "2023-01-01",
              "id": "6",
              "lastFour": "4242",
              "type": "VISA"
            }
          ],
          "totalCount": 1
        },
        "id": "VXNlci02MTgwMDU4ODY=",
        "imageUrl": "https://ksr-qa-ugc.imgix.net/missing_user_avatar.png?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=&auto=format&frame=1&q=92&s=e17a7b6f853aa6320cfe67ee783eb3d8",
        "isCreator": null,
        "name": "Mubarak Sadoon",
        "uid": "618005886"
      },
      "authorBadges": [],
      "body": "new post",
      "createdAt": 1624917189,
      "deleted": false,
      "id": "Q29tbWVudC0zMjY2NDEwNQ==",
      "parentId": null,
      "replies": {
        "__typename": "CommentConnection",
        "totalCount": 3
      }
    }
    """

    let data = Data(json.utf8)
    return (try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) ?? [:]
  }
}
