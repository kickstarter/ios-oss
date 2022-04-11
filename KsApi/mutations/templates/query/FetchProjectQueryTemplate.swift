import Apollo
import Foundation
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
          "risks": "Risks"
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
    projectResultMap["story"] = """
    <p><a href="http://record.pt/" target="_blank" rel="noopener"><strong>What about a bold link to that same newspaper website?</strong></a></p>\n<p><a href="http://recordblabla.pt/" target="_blank" rel="noopener"><em>Maybe an italic one?</em></a></p><a href="https://producthype.co/most-powerful-crowdfunding-newsletter/?utm_source=ProductHype&utm_medium=Banner&utm_campaign=Homi" target="_blank" rel="noopener"> <div class="template asset" contenteditable="false" data-alt-text="" data-caption="Viktor Pushkarev using lino-cutting to create the cover art." data-id="34488736">\n <figure>\n <img alt="" class="fit js-lazy-image" data-src="https://ksr-qa-ugc.imgix.net/assets/034/488/736/c35446a93f1f9faedd76e9db814247bf_original.gif?ixlib=rb-4.0.2&w=700&fit=max&v=1628654686&auto=format&gif-q=50&q=92&s=061483d5e8fac13bd635b67e2ae8a258" src="https://ksr-qa-ugc.imgix.net/assets/034/488/736/c35446a93f1f9faedd76e9db814247bf_original.gif?ixlib=rb-4.0.2&w=700&fit=max&v=1628654686&auto=format&frame=1&q=92&s=463cb21e97dd89bd564e6fc898ea6075">\n </figure>\n\n </div>\n </a>\n\n <div class="template asset" contenteditable="false" data-id="35786501"> \n <figure class="page-anchor" id="asset-35786501"> \n <div class="video-player" data-video-url="https://v.kickstarter.com/1646345127_8366452d275cb8330ca0cee82a6c5259a1df288e/assets/035/786/501/b99cdfe87fc9b942dce0fe9a59a3767a_h264_high.mp4" data-image="https://dr0rfahizzuzj.cloudfront.net/assets/035/786/501/b99cdfe87fc9b942dce0fe9a59a3767a_h264_base.jpg?2021" data-dimensions='{"width":640,"height":360}' data-context="Story Description"> \n <video class="landscape" preload="none"> \n <source src="https://v.kickstarter.com/1646345127_8366452d275cb8330ca0cee82a6c5259a1df288e/assets/035/786/501/b99cdfe87fc9b942dce0fe9a59a3767a_h264_high.mp4" type='video/mp4; codecs="avc1.64001E, mp4a.40.2"'></source> \n <source src="https://v.kickstarter.com/1646345127_8366452d275cb8330ca0cee82a6c5259a1df288e/assets/035/786/501/b99cdfe87fc9b942dce0fe9a59a3767a_h264_base.mp4" type='video/mp4; codecs="avc1.42E01E, mp4a.40.2"'></source> \nYou'll need an HTML5 capable browser to see this content.\n </video> \n<img class="has_played_hide full-width poster landscape" alt=" project video thumbnail" src="https://dr0rfahizzuzj.cloudfront.net/assets/035/786/501/b99cdfe87fc9b942dce0fe9a59a3767a_h264_base.jpg?2021">\n <div class="play_button_container absolute-center has_played_hide">\n<button aria-label="Play video" class="play_button_big play_button_dark radius2px" type="button">\n<span class="ksr-icon__play" aria-hidden="true"></span>\nPlay\n</button>\n</div>\n <div class="reset-video js-reset-video-once"> \n <div class="reset-video__icon"> \n <div class="audio-indicator js-autoplay-svg"> \n<svg version="1.1" viewbox="0 0 18 17.2" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg">\n <g> \n\n\n<polygon class="audio-indicator-bar" points="0,0 2,0 2,11.5 2,17.2 0,17.2">\n<animate attributename="points" begin="0s" calcmode="spline" dur="1.2s" keysplines="0.18 0.01 0.37 0.99;0.18 0.01 0.37 0.99;0.18 0.01 0.37 0.99" keytimes="0; 0.3; 0.9; 1" repeatcount="indefinite" values="0,0 2,0 2,11.5 2,17.2 0,17.2;0,2.6 2,2.6 2,8.2 2,17.2 0,17.2;0,12.1 2,12.1 2,14 2,17.2 0,17.2;0,0 2,0 2,11.5 2,17.2 0,17.2"></animate>\n</polygon>\n\n<polygon class="audio-indicator-bar" points="4,3.9 6,3.9 6,8.6 6,17.2 4,17.2">\n<animate attributename="points" begin="0s" calcmode="spline" dur="1.2s" keysplines="0.18 0.01 0.37 0.99;0.18 0.01 0.37 0.99;0.18 0.01 0.37 0.99" keytimes="0; 0.2; 0.6; 1" repeatcount="indefinite" values="4,3.9 6,3.9 6,8.6 6,17.2 4,17.2;4,10.6 6,10.6 6,12.9 6,17.2 4,17.2;4,6.4 6,6.4 6,10.2 6,17.2 4,17.2;4,3.9 6,3.9 6,8.6 6,17.2 4,17.2"></animate>\n</polygon>\n\n<polygon class="audio-indicator-bar" points="8,7 10,7 10,8.3 10,17.2 8,17.2">\n<animate attributename="points" begin="0s" calcmode="spline" dur="1.2s" keysplines="0.18 0.01 0.37 0.99;0.18 0.01 0.37 0.99;0.18 0.01 0.37 0.99" keytimes="0; 0.3; 0.5; 1" repeatcount="indefinite" values="8,7 10,7 10,8.3 10,17.2 8,17.2;8,13.9 10,13.9 10,14.3 10,17.2 8,17.2;8,0 10,0 10,2.3 10,17.2 8,17.2;8,7 10,7 10,8.3 10,17.2 8,17.2"></animate>\n</polygon>\n\n<polygon class="audio-indicator-bar" points="12,0 14,0 14,4.3 14,17.2 12,17.2">\n<animate attributename="points" begin="0s" calcmode="spline" dur="1.2s" keysplines="0.18 0.01 0.37 0.99;0.18 0.01 0.37 0.99;0.18 0.01 0.37 0.99" keytimes="0; 0.3; 0.9; 1" repeatcount="indefinite" values="12,0 14,0 14,4.3 14,17.2 12,17.2;12,6.1 14,6.1 14,8.9 14,17.2 12,17.2;12,10.6 14,10.6 14,12.2 14,17.2 12,17.2;12,0 14,0 14,4.3 14,17.2 12,17.2"></animate>\n</polygon>\n\n<polygon class="audio-indicator-bar" points="16,1.9 18,1.9 18,3.9 18,17.2 16,17.2">\n<animate attributename="points" begin="0s" calcmode="spline" dur="1.2s" keysplines="0.18 0.01 0.37 0.99;0.18 0.01 0.37 0.99;0.18 0.01 0.37 0.99" keytimes="0; 0.4; 0.6; 1" repeatcount="indefinite" values="16,1.9 18,1.9 18,3.9 18,17.2 16,17.2;16,8.6 18,8.6 18,9.7 18,17.2 16,17.2;16,16.6 18,16.6 18,9.7 18,17.2 16,17.2;16,1.9 18,1.9 18,3.9 18,17.2 16,17.2"></animate>\n</polygon>\n </g> \n</svg>\n </div>\n\n </div>\n <div class="reset-video__label">\nReplay with sound\n</div>\n </div>\n <div class="rewind-video js-reset-video-once"> \n <div class="rewind-video__wrapper absolute-center"> \n <div class="rewind-video__inner"> \n <div class="rewind-video__button"> \n <div class="rewind-video__button_inner"> \n <div class="rewind-video__icon"></div>\n <div class="rewind-video__label">\nPlay with <br>sound\n</div>\n </div>\n </div>\n </div>\n </div>\n </div>\n <div class="player_controls absolute-bottom mb3 radius2px white bg-green-dark forces-video-controls_hide"> \n <div class="left full-height"> \n <button class="flex btn btn--with-svg btn--dark-green left playpause play mr2 ml0 full-height keyboard-focusable"> \n <svg class="svg-icon__play" aria-hidden="true"> <use xlink:href="#play"></use> </svg> \n <svg class="svg-icon__pause" aria-hidden="true"> <use xlink:href="#pause"></use> </svg> \n </button> \n<time class="time current_time left video-time--current">00:00</time>\n </div>\n <div class="right full-height"> \n<time class="time total_time left mr2 video-time--total">00:00</time>\n<button class="m0 left button button_icon button_icon_white volume full-height keyboard-focusable">\n<span class="ss-icon ss-volume icon_volume_nudge"></span>\n<span class="ss-icon ss-highvolume"></span>\n</button>\n <div class="volume_container left"> \n <div class="progress_bar progress_bar_dark progress_bg"> \n <div class="progress_bar_bg"></div>\n <div class="progress progress_bar_progress"></div>\n <div aria-label="Volume" class="progress_handle progress_bar_handle keyboard-focusable" role="slider" tabindex="0"></div>\n </div>\n </div>\n<button aria-label="Fullscreen" class="m0 left button button_icon button_icon_white fullscreen full-height keyboard-focusable">\n<span class="ss-icon ss-expand"></span>\n<span class="ss-icon ss-delete"></span>\n</button>\n </div>\n <div class="clip"> \n <div class="progress_container pr2 pl2"> \n <div class="progress_bar progress_bar_dark progress_bg"> \n <div class="progress_bar_bg"></div>\n <div class="buffer progress_bar_buffer"></div>\n <div class="progress progress_bar_progress"></div>\n <div aria-label="Played" class="progress_handle progress_bar_handle keyboard-focusable" role="slider" tabindex="0"></div>\n </div>\n </div>\n </div>\n <div class="clear"></div>\n </div>\n </div>\n </figure> \n\n </div>
    """

    resultMap["project"] = projectResultMap

    return resultMap
  }

  private var erroredResultMap: [String: Any?] {
    return [:]
  }
}
