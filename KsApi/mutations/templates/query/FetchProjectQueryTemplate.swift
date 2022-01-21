import Apollo
@testable import KsApi

public enum FetchProjectQueryTemplate {
  case valid
  case errored

  /// `FetchProjectBySlug` returns identical data.
  var data: GraphAPI.FetchProjectByIdQuery.Data {
    switch self {
    case .valid:
      return GraphAPI.FetchProjectByIdQuery.Data(unsafeResultMap: self.validResultMap)
    case .errored:
      return GraphAPI.FetchProjectByIdQuery.Data(unsafeResultMap: self.erroredResultMap)
    }
  }

  // MARK: Private Properties

  private var validResultMap: [String: Any] {
    let json = """
    {
       "me":{
          "chosenCurrency":"CAD"
       },
       "project":{
          "backing": {
            "id": "QmFja2luZy0xNDgwMTQwMzQ="
          },
          "__typename":"Project",
          "availableCardTypes":[
             "VISA",
             "MASTERCARD",
             "AMEX"
          ],
          "backersCount":148,
          "category":{
             "__typename":"Category",
             "id":"Q2F0ZWdvcnktMjgw",
             "name":"Photobooks",
             "analyticsName": "Photobooks",
             "parentCategory":{
                "__typename":"Category",
                "id":"Q2F0ZWdvcnktMTU=",
                "name":"Photography",
                "analyticsName":"Photography"
             }
          },
          "canComment": true,
          "commentsCount":0,
          "country":{
             "__typename":"Country",
             "code":"CA",
             "name":"Canada"
          },
          "creator":{
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
             "isFacebookConnected": false,
             "isFollowing": true,
             "isKsrAdmin": true,
             "name":"Thea Schneider",
             "needsFreshFacebookToken": true,
             "showPublicProfile": true,
             "uid":"1532357997",
             "location": {
               "country": "US",
               "countryName": "United States",
               "displayableName": "Las Vegas, NV",
               "id": "TG9jYXRpb24tMjQzNjcwNA==",
               "name": "Las Vegas"
             },
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
             "storedCards":{
                "__typename":"UserCreditCardTypeConnection",
                "nodes":[],
                "totalCount":0
             },
              "surveyResponses": {
                "__typename": "SurveyResponsesConnection",
                "totalCount": 2
              },
              "hasUnreadMessages": false,
              "hasUnseenActivity": true
          },
          "currency":"EUR",
          "deadlineAt":1628622000,
          "description":"A photographic book about the daily life and work on board of a Russian research vessel during the MOSAiC expedition in the Arctic.",
          "finalCollectionDate":null,
          "fxRate":1.49547966,
          "friends":{
             "__typename":"ProjectBackerFriendsConnection",
             "nodes":[]
          },
          "goal":{
             "__typename":"Money",
             "amount":"2000.0",
             "currency":"EUR",
             "symbol":"€"
          },
          "image":{
             "__typename":"Photo",
             "id":"UGhvdG8tMzM4NDYwNDQ=",
             "url":"https://ksr-qa-ugc.imgix.net/assets/033/846/044/7134a6f4504bd636327de703a1d2dd1c_original.jpg?ixlib=rb-4.0.2&crop=faces&w=1024&h=576&fit=crop&v=1623348736&auto=format&frame=1&q=92&s=a7b486e4831db1bcbf393201bc64a40a"
          },
          "isProjectWeLove":true,
          "isProjectOfTheDay":false,
          "isWatched":false,
          "isLaunched":true,
          "launchedAt":1625118948,
          "location":{
             "__typename":"Location",
             "country":"DE",
             "countryName":"Germany",
             "displayableName":"München, Germany",
             "id":"TG9jYXRpb24tNjc2NzU2",
             "name":"München"
          },
          "maxPledge": 8500,
          "minPledge": 1,
          "name":"The Quiet",
          "pid":904702116,
          "pledged":{
             "__typename":"Money",
             "amount":"7827.6",
             "currency":"EUR",
             "symbol":"€"
          },
          "posts":{
             "__typename":"PostConnection",
             "totalCount":5
          },
          "prelaunchActivated":true,
          "slug":"theaschneider/thequiet",
          "state":"LIVE",
          "stateChangedAt":1625118950,
          "tags":[],
          "url":"https://staging.kickstarter.com/projects/theaschneider/thequiet",
          "usdExchangeRate":1.18302594,
          "video": {
            "__typename": "Video",
            "id": "VmlkZW8tMTExNjQ0OA==",
            "videoSources": {
              "__typename": "VideoSources",
              "high": {
                "__typename": "VideoSourceInfo",
                "src": "https://v.kickstarter.com/1631480664_a23b86f39dcfa7b0009309fa0f668ceb5e13b8a8/projects/4196183/video-1116448-h264_high.mp4"
              },
              "hls": {
                "__typename": "VideoSourceInfo",
                "src": "https://v.kickstarter.com/1631480664_a23b86f39dcfa7b0009309fa0f668ceb5e13b8a8/projects/4196183/video-1116448-hls_playlist.m3u8"
              }
            }
          },
          "environmentalCommitments": [
            {
              "__typename": "EnvironmentalCommitment",
              "commitmentCategory": "longLastingDesign",
              "description": "High quality materials and cards - there is nothing design or tech-wise that would render Dustbiters obsolete besides losing the cards.",
              "id": "RW52aXJvbm1lbnRhbENvbW1pdG1lbnQtMTI2NTA2"
            }
          ],
          "faqs": {
            "__typename": "ProjectFaqConnection",
            "nodes": [
              {
                "__typename": "ProjectFaq",
                "question": "Are you planning any expansions for Dustbiters?",
                "answer": "This may sound weird in the world of big game boxes with hundreds of tokens, cards and thick manuals, but through years of playtesting and refinement we found our ideal experience is these 21 unique cards we have now. Dustbiters is balanced for quick and furious games with different strategies every time you jump back in, and we currently have no plans to mess with that.",
                "id": "UHJvamVjdEZhcS0zNzA4MDM=",
                "createdAt": 1628103400
              }
            ]
          },
          "risks": "Risks",
          "story": "<p><a href="http://record.pt/" target=\"_blank\" rel=\"noopener\"><strong>What about a bold link to that same newspaper website?</strong></a></p>\n<p><a href="http://recordblabla.pt/" target=\"_blank\" rel=\"noopener\"><em>Maybe an italic one?</em></a></p>"
       }
    }
    """

    let data = Data(json.utf8)
    var resultMap = (try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) ?? [:]

    /** NOTE: A lot of these mappings had to be customized to `GraphAPI` types from their raw data because the `ApolloClient` `fetch` and `perform` functions return `Query.Data` not raw json into their result handlers. This means that Apollo creates the models itself from the raw json returned before we can access them after the network request.
     */

    guard var projectResultMap = resultMap["project"] as? [String: Any],
      let countryResultMap = projectResultMap["country"] as? [String: Any],
      let creatorResultMap = projectResultMap["creator"] as? [String: Any] else {
      return resultMap
    }

    var updatedCountryResultMap = countryResultMap
    var updatedCreatorResultMap = creatorResultMap
    updatedCountryResultMap["code"] = KsApi.GraphAPI.CountryCode.ca
    projectResultMap["country"] = updatedCountryResultMap
    projectResultMap["deadlineAt"] = "1628622000"
    projectResultMap["launchedAt"] = "1625118948"
    projectResultMap["stateChangedAt"] = "1625118950"
    projectResultMap["availableCardTypes"] = [
      KsApi.GraphAPI.CreditCardTypes.visa,
      KsApi.GraphAPI.CreditCardTypes.amex,
      KsApi.GraphAPI.CreditCardTypes.mastercard
    ]
    projectResultMap["state"] = KsApi.GraphAPI.ProjectState.live
    projectResultMap["currency"] = KsApi.GraphAPI.CurrencyCode.eur

    updatedCreatorResultMap["notifications"] = [
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

    let updatedEnvironmentalCommitments =
      [[
        "__typename": "EnvironmentalCommitment",
        "commitmentCategory": GraphAPI.EnvironmentalCommitmentCategory.longLastingDesign,
        "description": "High quality materials and cards - there is nothing design or tech-wise that would render Dustbiters obsolete besides losing the cards.",
        "id": "RW52aXJvbm1lbnRhbENvbW1pdG1lbnQtMTI2NTA2"
      ]]

    let updatedFaqs =
      [
        "__typename": "ProjectFaqConnection",
        "nodes": [[
          "__typename": "ProjectFaq",
          "question": "Are you planning any expansions for Dustbiters?",
          "answer": "This may sound weird in the world of big game boxes with hundreds of tokens, cards and thick manuals, but through years of playtesting and refinement we found our ideal experience is these 21 unique cards we have now. Dustbiters is balanced for quick and furious games with different strategies every time you jump back in, and we currently have no plans to mess with that.",
          "id": "UHJvamVjdEZhcS0zNzA4MDM=",
          "createdAt": "1628103400"
        ]]
      ] as [String: Any]

    projectResultMap["faqs"] = updatedFaqs
    projectResultMap["environmentalCommitments"] = updatedEnvironmentalCommitments
    projectResultMap["creator"] = updatedCreatorResultMap

    resultMap["project"] = projectResultMap

    return resultMap
  }

  private var erroredResultMap: [String: Any?] {
    return [:]
  }
}
