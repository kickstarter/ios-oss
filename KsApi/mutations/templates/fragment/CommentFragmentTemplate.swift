import Apollo
import Foundation
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
        "backingsCount": 3,
        "createdProjects": {
          "__typename": "UserCreatedProjectsConnection",
          "totalCount": 16
        },
        "membershipProjects":{
           "__typename":"MembershipProjectsConnection",
           "totalCount":10
        },
        "savedProjects":{
           "__typename":"UserSavedProjectsConnection",
           "totalCount":11
        },
        "surveyResponses": {
           "__typename":"SurveyResponsesConnection",
           "totalCount": 2
        },
        "optedOutOfRecommendations":true,
        "email": "m@example.com",
        "isAppleConnected": true,
        "isBlocked": false,
        "isEmailVerified": false,
        "isDeliverable": true,
        "isFacebookConnected": true,
        "isKsrAdmin": false,
        "isFollowing": true,
        "isSocializing": false,
        "hasPassword": false,
        "needsFreshFacebookToken": true,
        "newsletterSubscriptions": null,
        "notifications": null,
        "hasUnreadMessages": true,
        "hasUnseenActivity": true,
        "showPublicProfile": true,
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
              "type": "VISA",
              "stripeCardId": "pm_1OtGFX4VvJ2PtfhK3Gp00SWK",
            }
          ],
          "totalCount": 1
        },
        "id": "VXNlci02MTgwMDU4ODY=",
        "imageUrl": "https://i.kickstarter.com/missing_user_avatar.png?anim=false&fit=crop&height=1024&origin=ugc-qa&q=92&width=1024&sig=3CEELuVLNdj97Pjx4PDy7Q9OTZfKyMEZyeIlQicGPBY%3D",
        "isCreator": null,
        "name": "Example User",
        "uid": "11223"
      },
      "authorBadges": [
        "collaborator"
      ],
      "body": "new post",
      "createdAt": 1624917189,
      "deleted": false,
      "id": "Q29tbWVudC0zMjY2NDEwNQ==",
      "parentId": null,
      "replies": {
        "__typename": "CommentConnection",
        "totalCount": 3
      },
      "hasFlaggings": false,
      "removedPerGuidelines": false,
      "sustained": false
    }
    """

    let data = Data(json.utf8)
    return (try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) ?? [:]
  }
}
