@testable import KsApi
import Prelude
import XCTest

final class Project_ProjectFragmentTests: XCTestCase {
  func test() {
    do {
      let variables = [
        "withStoredCards": true
      ]
      let fragment = try GraphAPI.ProjectFragment(jsonObject: self.projectDictionary(), variables: variables)
      XCTAssertNotNil(fragment)

      let project = Project.project(
        from: fragment,
        currentUserChosenCurrency: nil
      )

      guard let project = project else {
        XCTFail("project should not be nil")

        return
      }

      XCTAssertEqual(project.country.countryCode, Project.Country.us.countryCode)
      XCTAssertEqual(project.country.currencySymbol, Project.Country.us.currencySymbol)
      XCTAssertEqual(project.country.currencyCode, Project.Country.us.currencyCode)
      XCTAssertEqual(project.country.maxPledge, 8_500)
      XCTAssertEqual(project.country.minPledge, 23)
      XCTAssertEqual(project.country.trailingCode, true)
      XCTAssertEqual(project.availableCardTypes?.count, 7)
      XCTAssertEqual(
        project.blurb,
        "In this unforgiving Hell, people are forced to fight to the death in an elite gamble for their souls."
      )
      XCTAssertEqual(project.category.name, "Comic Books")
      XCTAssertEqual(project.creator.id, decompose(id: "VXNlci0xMDA3NTM5MDAy"))
      XCTAssertEqual(project.memberData.permissions.last, .comment)
      XCTAssertEqual(project.dates.deadline, 1_630_591_053)
      XCTAssertEqual(project.id, 1_841_936_784)
      XCTAssertEqual(project.location.country, "US")
      XCTAssertEqual(project.name, "FINAL GAMBLE Issue #1")
      XCTAssertEqual(project.slug, "final-gamble-issue-1")
      XCTAssertEqual(
        project.photo.full,
        "https://ksr-qa-ugc.imgix.net/assets/034/416/156/330099be1dd12ed741db4e29d9986840_original.png?ixlib=rb-4.0.2&crop=faces&w=1024&h=576&fit=crop&v=1628078003&auto=format&frame=1&q=92&s=2f006a2e8f17f1a83c21385ac010574c"
      )
      XCTAssertEqual(project.state, .live)
      XCTAssertEqual(project.stats.convertedPledgedAmount!, 4_509.09467367)
      XCTAssertEqual(project.tags!.first!, "LGBTQIA+")
      XCTAssertEqual(
        project.urls.web.updates!,
        "https://staging.kickstarter.com/projects/bandofbards/final-gamble-issue-1/posts"
      )
      XCTAssertEqual(
        project.video?.high,
        "https://v.kickstarter.com/1631473358_b73a85bd690a6353b9e29af6ef78496e2d20858c/projects/4196183/video-1116448-h264_high.mp4"
      )
      XCTAssertTrue(project.rewardData.rewards.isEmpty)
      XCTAssertTrue(project.staffPick)
      XCTAssertTrue(project.prelaunchActivated!)
      XCTAssertFalse(project.displayPrelaunch!)
      XCTAssertNil(project.personalization.backing)
      XCTAssertNil(project.rewardData.addOns)

      guard let extendedProjectProperties = project.extendedProjectProperties else {
        XCTFail()

        return
      }

      XCTAssertNotNil(extendedProjectProperties.story)
      XCTAssertNotNil(extendedProjectProperties.risks)
      XCTAssertEqual(extendedProjectProperties.environmentalCommitments.count, 1)
      XCTAssertEqual(
        extendedProjectProperties.environmentalCommitments.last?.category,
        .longLastingDesign
      )
      XCTAssertEqual(
        extendedProjectProperties.environmentalCommitments.last?.description,
        "High quality materials and cards - there is nothing design or tech-wise that would render Dustbiters obsolete besides losing the cards."
      )
      XCTAssertEqual(
        extendedProjectProperties.environmentalCommitments.last?.id,
        decompose(id: "RW52aXJvbm1lbnRhbENvbW1pdG1lbnQtMTI2NTA2")
      )
      XCTAssertEqual(extendedProjectProperties.faqs.count, 1)
      XCTAssertEqual(
        extendedProjectProperties.faqs.last!.question,
        "Are you planning any expansions for Dustbiters?"
      )
      XCTAssertEqual(
        extendedProjectProperties.faqs.last!.answer,
        "This may sound weird in the world of big game boxes with hundreds of tokens, cards and thick manuals, but through years of playtesting and refinement we found our ideal experience is these 21 unique cards we have now. Dustbiters is balanced for quick and furious games with different strategies every time you jump back in, and we currently have no plans to mess with that."
      )
      XCTAssertEqual(
        extendedProjectProperties.faqs.last!.id,
        decompose(id: "UHJvamVjdEZhcS0zNzA4MDM=")
      )
      XCTAssertEqual(extendedProjectProperties.faqs.last!.createdAt!, TimeInterval(1_628_103_400))
      XCTAssertEqual(extendedProjectProperties.minimumPledgeAmount, 23)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }

  private func projectDictionary() -> [String: Any] {
    let json = """
    {
       "__typename":"Project",
       "availableCardTypes":[
          "VISA",
          "MASTERCARD",
          "AMEX",
          "DISCOVER",
          "JCB",
          "DINERS",
          "UNION_PAY"
       ],
       "backersCount":78,
       "category":{
          "__typename":"Category",
          "id":"Q2F0ZWdvcnktMjUw",
          "name":"Comic Books",
          "analyticsName":"Comic Books",
          "parentCategory":{
             "__typename":"Category",
             "id":"Q2F0ZWdvcnktMw==",
             "name":"Comics",
             "analyticsName":"Comics",
          }
       },
       "canComment":true,
       "commentsCount":0,
       "country":{
          "__typename":"Country",
          "code":"US",
          "name":"the United States"
       },
       "creator":{
          "__typename":"User",
          "chosenCurrency":null,
          "backings":{
             "__typename":"UserBackingsConnection",
             "nodes":[
                {
                   "__typename":"Backing",
                   "errorReason":null
                },
                {
                   "__typename":"Backing",
                   "errorReason":"Something went wrong"
                },
                {
                   "__typename":"Backing",
                   "errorReason":null
                }
             ]
          },
          "newsletterSubscriptions":{
             "__typename":"NewsletterSubscriptions",
             "artsCultureNewsletter":true,
             "filmNewsletter":false,
             "musicNewsletter":false,
             "inventNewsletter":false,
             "publishingNewsletter":false,
             "promoNewsletter":false,
             "weeklyNewsletter":false,
             "happeningNewsletter":false,
             "gamesNewsletter":false,
             "alumniNewsletter":true
          },
          "optedOutOfRecommendations":true,
          "notifications":[
             {
                "__typename":"Notification",
                "topic":"messages",
                "email":true,
                "mobile":true
             },
             {
                "__typename":"Notification",
                "topic":"backings",
                "email":false,
                "mobile":true
             },
             {
                "__typename":"Notification",
                "topic":"creator_digest",
                "email":true,
                "mobile":false
             },
             {
                "__typename":"Notification",
                "topic":"updates",
                "email":true,
                "mobile":true
             },
             {
                "__typename":"Notification",
                "topic":"follower",
                "email":true,
                "mobile":true
             },
             {
                "__typename":"Notification",
                "topic":"friend_activity",
                "email":true,
                "mobile":false
             },
             {
                "__typename":"Notification",
                "topic":"friend_signup",
                "email":true,
                "mobile":true
             },
             {
                "__typename":"Notification",
                "topic":"comments",
                "email":true,
                "mobile":true
             },
             {
                "__typename":"Notification",
                "topic":"comment_replies",
                "email":true,
                "mobile":true
             },
             {
                "__typename":"Notification",
                "topic":"creator_edu",
                "email":true,
                "mobile":true
             },
             {
                "__typename":"Notification",
                "topic":"marketing_update",
                "email":true,
                "mobile":false
             },
             {
                "__typename":"Notification",
                "topic":"project_launch",
                "email":true,
                "mobile":true
             }
          ],
          "createdProjects":{
             "__typename":"UserCreatedProjectsConnection",
             "totalCount":16
          },
          "membershipProjects":{
             "__typename":"MembershipProjectsConnection",
             "totalCount":10
          },
          "savedProjects":{
             "__typename":"UserSavedProjectsConnection",
             "totalCount":11
          },
          "backingsCount":3,
          "hasUnreadMessages":false,
          "isSocializing":true,
          "hasUnseenActivity":true,
          "email":"tim_stolinski@yahoo.com.ksr",
          "hasPassword":null,
          "id":"VXNlci0xMDA3NTM5MDAy",
          "imageUrl":"https://ksr-qa-ugc.imgix.net/assets/033/589/257/1202c14c958cc40645e67f7792a8b10a_original.png?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1621524013&auto=format&frame=1&q=92&s=9466c13d19f3870da6565cea4170f752",
          "isAppleConnected":null,
          "isCreator":true,
          "isDeliverable":null,
          "isEmailVerified":true,
          "isFacebookConnected":true,
          "isKsrAdmin":false,
          "isFollowing":true,
          "name":"Band of Bards Comics",
          "needsFreshFacebookToken":false,
          "showPublicProfile":true,
          "uid":"1007539002",
          "location":{
             "__typename":"Location",
             "country":"US",
             "countryName":"United States",
             "displayableName":"Las Vegas, NV",
             "id":"TG9jYXRpb24tMjQzNjcwNA==",
             "name":"Las Vegas"
          },
          "surveyResponses": {
             "__typename":"SurveyResponsesConnection",
             "totalCount": 2
          },
          "storedCards":{
             "__typename":"UserCreditCardTypeConnection",
             "nodes":[
                
             ],
             "totalCount":0
          }
       },
       "currency":"USD",
       "deadlineAt":1630591053,
       "description":"In this unforgiving Hell, people are forced to fight to the death in an elite gamble for their souls.",
       "finalCollectionDate":null,
       "fxRate":1.26411401,
       "friends":{
          "__typename":"ProjectBackerFriendsConnection",
          "nodes":[
             
          ]
       },
       "goal":{
          "__typename":"Money",
          "amount":"6000.0",
          "currency":"USD",
          "symbol":"$"
       },
       "image":{
          "__typename":"Photo",
          "id":"UGhvdG8tMzQ0MTYxNTY=",
          "url":"https://ksr-qa-ugc.imgix.net/assets/034/416/156/330099be1dd12ed741db4e29d9986840_original.png?ixlib=rb-4.0.2&crop=faces&w=1024&h=576&fit=crop&v=1628078003&auto=format&frame=1&q=92&s=2f006a2e8f17f1a83c21385ac010574c"
       },
       "isProjectWeLove":true,
       "isProjectOfTheDay":false,
       "isWatched":false,
       "isLaunched":true,
       "launchedAt":1627999053,
       "location":{
          "__typename":"Location",
          "country":"US",
          "countryName":"United States",
          "displayableName":"Buffalo, NY",
          "id":"TG9jYXRpb24tMjM3MTQ2NA==",
          "name":"Buffalo"
       },
       "maxPledge": 8500,
       "minPledge": 23,
       "name":"FINAL GAMBLE Issue #1",
       "pid":1841936784,
       "pledged":{
          "__typename":"Money",
          "amount":"3567.0",
          "currency":"USD",
          "symbol":"$"
       },
       "posts":{
          "__typename":"PostConnection",
          "totalCount":3
       },
       "prelaunchActivated":true,
       "slug":"bandofbards/final-gamble-issue-1",
       "state":"LIVE",
       "stateChangedAt":1627999055,
       "tags":[
          {
             "__typename":"Tag",
             "name":"LGBTQIA+"
          }
       ],
       "story": "API returns this as HTML wrapped in a string. But here HTML breaks testing because the serializer does not recognize escape characters within a string.",
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
       "risks": "As with any project of this nature, there are always some risks involved with manufacturing and shipping. That's why we're collaborating with the iam8bit team, they have many years of experience producing and delivering all manner of items to destinations all around the world. We do not expect any delays or hiccups with reward fulfillment. But if anything comes up, we will be clear and communicative about what is happening and how it might affect you.",
       "url":"https://staging.kickstarter.com/projects/bandofbards/final-gamble-issue-1",
       "usdExchangeRate":1,
       "video":{
          "__typename":"Video",
          "id":"VmlkZW8tMTExNjQ0OA==",
          "videoSources":{
             "__typename":"VideoSources",
             "high":{
                "__typename":"VideoSourceInfo",
                "src":"https://v.kickstarter.com/1631473358_b73a85bd690a6353b9e29af6ef78496e2d20858c/projects/4196183/video-1116448-h264_high.mp4"
             },
             "hls":{
                "__typename":"VideoSourceInfo",
                "src":"https://v.kickstarter.com/1631473358_b73a85bd690a6353b9e29af6ef78496e2d20858c/projects/4196183/video-1116448-hls_playlist.m3u8"
             }
          }
       }
    }
    """

    let data = Data(json.utf8)
    var resultMap = (try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) ?? [:]

    let updatedEnvironmentalCommitments =
      [[
        "__typename": "EnvironmentalCommitment",
        "commitmentCategory": GraphAPI.EnvironmentalCommitmentCategory.longLastingDesign.rawValue,
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

    resultMap["faqs"] = updatedFaqs
    resultMap["environmentalCommitments"] = updatedEnvironmentalCommitments

    return resultMap
  }
}
