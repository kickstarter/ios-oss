@testable import KsApi

public struct GraphUserEnvelopeTemplates {
  static let userJSONDict: [String: Any?] =
    [
      "me": [
        "chosenCurrency": nil,
        "email": "nativesquad@ksr.com",
        "hasPassword": true,
        "id": "VXNlci0xNDcwOTUyNTQ1",
        "imageUrl": "https://i.kickstarter.com/missing_user_avatar.png?anim=false&fit=crop&height=1024&origin=ugc-qa&q=92&width=1024&sig=3CEELuVLNdj97Pjx4PDy7Q9OTZfKyMEZyeIlQicGPBY%3D",
        "isAppleConnected": false,
        "isBlocked": false,
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
              "type": GraphAPI.CreditCardTypes(rawValue: "VISA") as Any,
              "stripeCardId": "pm_1OtGFX4VvJ2PtfhK3Gp00SWK"
            ]
          ],
          "totalCount": 1
        ],
        "uid": "1470952545"
      ]
    ]
}
