import Apollo
import Foundation
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
       "backingsCount": 1,
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
       "newsletterSubscriptions": {
          "artsCultureNewsletter": true,
          "filmNewsletter": false,
          "musicNewsletter": false,
          "inventNewsletter": false,
          "publishingNewsletter": false,
          "promoNewsletter": false,
          "weeklyNewsletter": false,
          "happeningNewsletter": false,
          "gamesNewsletter": false,
          "alumniNewsletter": true
       },
       "isSocializing": true,
       "notifications": [
        {
          "topic": "messages",
          "email": true,
          "mobile": true
        },
        {
          "topic": "backings",
          "email": false,
          "mobile": true
        },
        {
          "topic": "creator_digest",
          "email": true,
          "mobile": false
        },
        {
          "topic": "updates",
          "email": true,
          "mobile": true
        },
        {
          "topic": "follower",
          "email": true,
          "mobile": true
        },
        {
          "topic": "friend_activity",
          "email": true,
          "mobile": false
        },
        {
          "topic": "friend_signup",
          "email": true,
          "mobile": true
        },
        {
          "topic": "comments",
          "email": true,
          "mobile": true
        },
        {
          "topic": "comment_replies",
          "email": true,
          "mobile": true
        },
        {
          "topic": "creator_edu",
          "email": true,
          "mobile": true
        },
        {
          "topic": "marketing_update",
          "email": true,
          "mobile": false
        },
        {
          "topic": "project_launch",
          "email": true,
          "mobile": true
        }
       ],
       "createdProjects": {
         "totalCount": 16
       },
       "membershipProjects": {
         "totalCount": 10
       },
       "savedProjects": {
         "totalCount": 11
       },
       "showPublicProfile": true,
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
       "isCreator":true,
       "name":"Billy Bob",
       "uid":"47",
       "hasUnreadMessages": false,
       "hasUnseenActivity": true,
       "surveyResponses": {
          "totalCount": 2
       },
       "optedOutOfRecommendations": true
    }
    """

    let data = Data(json.utf8)
    let resultMap = (try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) ?? [:]

    /** NOTE: A lot of these mappings had to be customized to `GraphAPI` types from their raw data because the `ApolloClient` `fetch` and `perform` functions return `Query.Data` not raw json into their result handlers. This means that Apollo creates the models itself from the raw json returned before we can access them after the network request.
     */

    var updatedNotificationsResultMap = resultMap
    updatedNotificationsResultMap["notifications"] = [
      [
        "topic": GraphAPI.UserNotificationTopic.messages,
        "email": true,
        "mobile": true
      ],
      [
        "topic": GraphAPI.UserNotificationTopic.backings,
        "email": false,
        "mobile": true
      ],
      [
        "topic": GraphAPI.UserNotificationTopic.creatorDigest,
        "email": true,
        "mobile": false
      ],
      [
        "topic": GraphAPI.UserNotificationTopic.updates,
        "email": true,
        "mobile": true
      ],
      [
        "topic": GraphAPI.UserNotificationTopic.follower,
        "email": true,
        "mobile": true
      ],
      [
        "topic": GraphAPI.UserNotificationTopic.friendActivity,
        "email": true,
        "mobile": false
      ],
      [
        "topic": GraphAPI.UserNotificationTopic.friendSignup,
        "email": true,
        "mobile": false
      ],
      [
        "topic": GraphAPI.UserNotificationTopic.comments,
        "email": true,
        "mobile": true
      ],
      [
        "topic": GraphAPI.UserNotificationTopic.commentReplies,
        "email": true,
        "mobile": true
      ],
      [
        "topic": GraphAPI.UserNotificationTopic.creatorEdu,
        "email": true,
        "mobile": true
      ],
      [
        "topic": GraphAPI.UserNotificationTopic.marketingUpdate,
        "email": true,
        "mobile": false
      ],
      [
        "topic": GraphAPI.UserNotificationTopic.projectLaunch,
        "email": true,
        "mobile": true
      ]
    ]

    return updatedNotificationsResultMap
  }
}
