@testable import KsApi

public struct GraphUserEnvelopeTemplates {
  static let userJSONDict: [String: Any?] =
    [
      "me": [
        "chosenCurrency": nil,
        "email": "nativesquad@ksr.com",
        "hasPassword": true,
        "id": "VXNlci0xNDcwOTUyNTQ1",
        "imageUrl": "https://ksr-qa-ugc.imgix.net/missing_user_avatar.png?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=&auto=format&frame=1&q=92&s=e17a7b6f853aa6320cfe67ee783eb3d8",
        "isAppleConnected": false,
        "isCreator": false,
        "isDeliverable": true,
        "isEmailVerified": true,
        "name": "Hari Singh",
        "storedCards": [
          "nodes": [
            [
              "expirationDate": "2023-01-01",
              "id": "6",
              "lastFour": "4242",
              "type": GraphAPI.CreditCardTypes(rawValue: "VISA") as Any
            ]
          ],
          "totalCount": 1
        ],
        "uid": "1470952545"
      ]
    ]
}
