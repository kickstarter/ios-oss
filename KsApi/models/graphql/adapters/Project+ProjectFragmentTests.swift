@testable import KsApi
import Prelude
import XCTest

final class Project_ProjectFragmentTests: XCTestCase {
  func test() {
    do {
      let variables = ["withStoredCards": true]
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

      XCTAssertEqual(project.country, .us)
      XCTAssertEqual(project.availableCardTypes?.count, 7)
      XCTAssertEqual(
        project.blurb,
        "In this unforgiving Hell, people are forced to fight to the death in an elite gamble for their souls."
      )
      XCTAssertEqual(project.category.name, "Comic Books")
      XCTAssertEqual(project.creator.id, decompose(id: "VXNlci0xMDA3NTM5MDAy"))
      XCTAssertEqual(project.category.name, "Comic Books")
      XCTAssertEqual(project.memberData.permissions.last, .comment)
      XCTAssertEqual(project.dates.deadline, 1_630_591_053)
      XCTAssertEqual(project.id, 1_841_936_784)
      XCTAssertEqual(project.location.country, "US")
      XCTAssertEqual(project.name, "FINAL GAMBLE Issue #1")
      XCTAssertEqual(project.slug, "bandofbards/final-gamble-issue-1")
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
    } catch {
      XCTFail(error.localizedDescription)
    }
  }

  private func projectDictionary() -> [String: Any] {
    let json = """
    {
       "__typename":"Project",
       "actions":{
          "__typename":"ProjectActions",
          "displayConvertAmount":false
       },
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
          "analyticsName": "Comic Books",
          "parentCategory":{
             "__typename":"Category",
             "id":"Q2F0ZWdvcnktMw==",
             "name":"Comics"
          }
       },
       "canComment": true,
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
          "email":"tim_stolinski@yahoo.com.ksr",
          "hasPassword":null,
          "id":"VXNlci0xMDA3NTM5MDAy",
          "imageUrl":"https://ksr-qa-ugc.imgix.net/assets/033/589/257/1202c14c958cc40645e67f7792a8b10a_original.png?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1621524013&auto=format&frame=1&q=92&s=9466c13d19f3870da6565cea4170f752",
          "isAppleConnected":null,
          "isCreator":true,
          "isDeliverable":null,
          "isEmailVerified":true,
          "isFacebookConnected": true,
          "isKsrAdmin": false,
          "isFollowing": true,
          "name":"Band of Bards Comics",
          "uid":"1007539002",
          "location": {
            "__typename": "Location",
            "country": "US",
            "countryName": "United States",
            "displayableName": "Las Vegas, NV",
            "id": "TG9jYXRpb24tMjQzNjcwNA==",
            "name": "Las Vegas"
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
    return (try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) ?? [:]
  }
}
