import Apollo
import GraphAPI
@testable import KsApi
import XCTest

class UserCreditCards_UserFragmentTests: XCTestCase {
  func test_WithStoredCards() {
    let variables = ["withStoredCards": true]

    do {
      let userFragment: GraphAPI.UserFragment = try testGraphObject(
        jsonString: validJSONWithStoredCards,
        variables: variables
      )

      XCTAssertTrue(UserCreditCards.userCreditCards(from: userFragment).storedCards.count == 1)
    } catch {
      XCTFail()
    }
  }

  func test_WithNoStoredCards() {
    let variables = ["withStoredCards": false]
    do {
      let userFragment: GraphAPI.UserFragment = try testGraphObject(
        jsonString: validJSONWithNoStoredCards,
        variables: variables
      )

      XCTAssertTrue(UserCreditCards.userCreditCards(from: userFragment).storedCards.count == 0)
    } catch {
      XCTFail()
    }
  }
}

let validJSONWithStoredCards = """
{
      "__typename": "User",
      "backings": {
        "__typename": "UserBackingsConnection",
        "nodes": [
          {
            "__typename": "Backing",
            "errorReason": null
          }
        ]
      },
      "backingsCount": 1,
      "chosenCurrency": "USD",
      "createdProjects": {
        "__typename": "UserCreatedProjectsConnection",
        "totalCount": 6
      },
      "email": "test@test.com",
      "hasPassword": true,
      "hasUnreadMessages": true,
      "hasUnseenActivity": false,
      "id": "test",
      "imageUrl": "http://www.kickstarter.com/fake.png",
      "isAppleConnected": false,
      "isBlocked": null,
      "isCreator": true,
      "isDeliverable": true,
      "isEmailVerified": true,
      "isFacebookConnected": false,
      "isKsrAdmin": true,
      "isFollowing": false,
      "isSocializing": true,
      "location": {
        "__typename": "Location",
        "country": "US",
        "countryName": "United States",
        "displayableName": "Las Vegas, NV",
        "id": "TG9jYXRpb24tMjQzNjcwNA==",
        "name": "Las Vegas"
      },
      "name": "Some Person",
      "needsFreshFacebookToken": false,
      "newsletterSubscriptions": {
        "__typename": "NewsletterSubscriptions",
        "artsCultureNewsletter": false,
        "filmNewsletter": false,
        "musicNewsletter": false,
        "inventNewsletter": false,
        "gamesNewsletter": true,
        "publishingNewsletter": false,
        "promoNewsletter": false,
        "weeklyNewsletter": false,
        "happeningNewsletter": false,
        "alumniNewsletter": false
      },
      "notifications": [
        {
          "__typename": "Notification",
          "email": true,
          "mobile": true,
          "topic": "messages"
        },
        {
          "__typename": "Notification",
          "email": false,
          "mobile": true,
          "topic": "backings"
        },
        {
          "__typename": "Notification",
          "email": false,
          "mobile": false,
          "topic": "creator_digest"
        },
        {
          "__typename": "Notification",
          "email": true,
          "mobile": true,
          "topic": "updates"
        },
        {
          "__typename": "Notification",
          "email": false,
          "mobile": false,
          "topic": "follower"
        },
        {
          "__typename": "Notification",
          "email": false,
          "mobile": false,
          "topic": "friend_activity"
        },
        {
          "__typename": "Notification",
          "email": true,
          "mobile": true,
          "topic": "friend_signup"
        },
        {
          "__typename": "Notification",
          "email": true,
          "mobile": true,
          "topic": "comments"
        },
        {
          "__typename": "Notification",
          "email": true,
          "mobile": false,
          "topic": "comment_replies"
        },
        {
          "__typename": "Notification",
          "email": true,
          "mobile": true,
          "topic": "creator_edu"
        },
        {
          "__typename": "Notification",
          "email": true,
          "mobile": false,
          "topic": "marketing_update"
        },
        {
          "__typename": "Notification",
          "email": true,
          "mobile": true,
          "topic": "project_launch"
        }
      ],
      "optedOutOfRecommendations": false,
      "showPublicProfile": false,
      "savedProjects": {
        "__typename": "UserSavedProjectsConnection",
        "totalCount": 7
      },
      "storedCards": {
      "__typename": "UserCreditCardTypeConnection",
      "nodes":
        [ 
        {
          "__typename": "CreditCard",
          "expirationDate": "2025-02-01",
          "id": "69021256",
          "lastFour": "4242",
          "type": "VISA",
          "stripeCardId": "fake_stripe_card_id"
          }
        ],
      "totalCount": 1
      },
      "surveyResponses": {
        "__typename": "SurveyResponsesConnection",
        "totalCount": 0
      },
      "uid": "1951437049"
}
"""

let validJSONWithNoStoredCards = """
{
      "__typename": "User",
      "backings": {
        "__typename": "UserBackingsConnection",
        "nodes": [
          {
            "__typename": "Backing",
            "errorReason": null
          }
        ]
      },
      "backingsCount": 1,
      "chosenCurrency": "USD",
      "createdProjects": {
        "__typename": "UserCreatedProjectsConnection",
        "totalCount": 6
      },
      "email": "test@test.com",
      "hasPassword": true,
      "hasUnreadMessages": true,
      "hasUnseenActivity": false,
      "id": "test",
      "imageUrl": "http://www.kickstarter.com/fake.png",
      "isAppleConnected": false,
      "isBlocked": null,
      "isCreator": true,
      "isDeliverable": true,
      "isEmailVerified": true,
      "isFacebookConnected": false,
      "isKsrAdmin": true,
      "isFollowing": false,
      "isSocializing": true,
      "location": {
        "__typename": "Location",
        "country": "US",
        "countryName": "United States",
        "displayableName": "Las Vegas, NV",
        "id": "TG9jYXRpb24tMjQzNjcwNA==",
        "name": "Las Vegas"
      },
      "name": "Some Person",
      "needsFreshFacebookToken": false,
      "newsletterSubscriptions": {
        "__typename": "NewsletterSubscriptions",
        "artsCultureNewsletter": false,
        "filmNewsletter": false,
        "musicNewsletter": false,
        "inventNewsletter": false,
        "gamesNewsletter": true,
        "publishingNewsletter": false,
        "promoNewsletter": false,
        "weeklyNewsletter": false,
        "happeningNewsletter": false,
        "alumniNewsletter": false
      },
      "notifications": [
        {
          "__typename": "Notification",
          "email": true,
          "mobile": true,
          "topic": "messages"
        },
        {
          "__typename": "Notification",
          "email": false,
          "mobile": true,
          "topic": "backings"
        },
        {
          "__typename": "Notification",
          "email": false,
          "mobile": false,
          "topic": "creator_digest"
        },
        {
          "__typename": "Notification",
          "email": true,
          "mobile": true,
          "topic": "updates"
        },
        {
          "__typename": "Notification",
          "email": false,
          "mobile": false,
          "topic": "follower"
        },
        {
          "__typename": "Notification",
          "email": false,
          "mobile": false,
          "topic": "friend_activity"
        },
        {
          "__typename": "Notification",
          "email": true,
          "mobile": true,
          "topic": "friend_signup"
        },
        {
          "__typename": "Notification",
          "email": true,
          "mobile": true,
          "topic": "comments"
        },
        {
          "__typename": "Notification",
          "email": true,
          "mobile": false,
          "topic": "comment_replies"
        },
        {
          "__typename": "Notification",
          "email": true,
          "mobile": true,
          "topic": "creator_edu"
        },
        {
          "__typename": "Notification",
          "email": true,
          "mobile": false,
          "topic": "marketing_update"
        },
        {
          "__typename": "Notification",
          "email": true,
          "mobile": true,
          "topic": "project_launch"
        }
      ],
      "optedOutOfRecommendations": false,
      "showPublicProfile": false,
      "savedProjects": {
        "__typename": "UserSavedProjectsConnection",
        "totalCount": 7
      },
      "storedCards": {
        "__typename": "UserCreditCardTypeConnection",
        "nodes": [],
        "totalCount": 0
      },
      "surveyResponses": {
        "__typename": "SurveyResponsesConnection",
        "totalCount": 0
      },
      "uid": "1951437049"
}
"""
