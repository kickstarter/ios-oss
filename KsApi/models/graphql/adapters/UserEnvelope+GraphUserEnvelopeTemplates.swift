@testable import KsApi

public struct GraphUserEnvelopeTemplates {
  static let userJSONDict: [String: Any?] =
    [
      "me": [
        "chosenCurrency": nil,
        "email": "user@example.com",
        "hasPassword": true,
        "id": "fakeId",
        "imageUrl": "https://i.kickstarter.com/missing_user_avatar.png",
        "isAppleConnected": false,
        "isBlocked": false,
        "isCreator": false,
        "isDeliverable": true,
        "isEmailVerified": true,
        "name": "Example User",
        "storedCards": [
          "nodes": [
            [
              "expirationDate": "2023-01-01",
              "id": "6",
              "lastFour": "4242",
              "type": GraphAPI.CreditCardTypes(rawValue: "VISA") as Any,
              "stripeCardId": "pm_1OtGFX4VvJ2PtfhK3Gp00SWK"
            ]
          ],
          "totalCount": 1
        ],
        "uid": "11111"
      ]
    ]
}
