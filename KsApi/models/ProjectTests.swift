import XCTest
@testable import KsApi
import Prelude

final class ProjectTests: XCTestCase {

  func testFundingProgress() {
    let halfFunded = Project.template
      |> Project.lens.stats.fundingProgress .~ 0.5

    XCTAssertEqual(0.5, halfFunded.stats.fundingProgress)
    XCTAssertEqual(50, halfFunded.stats.percentFunded)

    let badGoalData = Project.template
      |> Project.lens.stats.pledged .~ 0
      <> Project.lens.stats.goal .~ 0

    XCTAssertEqual(0.0, badGoalData.stats.fundingProgress)
    XCTAssertEqual(0, badGoalData.stats.percentFunded)
  }

  func testEndsIn48Hours_WithJustLaunchedProject() {

    let justLaunched = Project.template
      |> Project.lens.dates.launchedAt .~ Date(timeIntervalSince1970: 1475361315).timeIntervalSince1970

    XCTAssertFalse(justLaunched.endsIn48Hours(today: Date(timeIntervalSince1970: 1475361315)))
  }

  func testEndsIn48Hours_WithEndingSoonProject() {
    let endingSoon = Project.template
      |> Project.lens.dates.deadline .~ (Date(timeIntervalSince1970: 1475361315)
        .timeIntervalSince1970 - 60.0 * 60.0)

    XCTAssertTrue(endingSoon.endsIn48Hours(today: Date(timeIntervalSince1970: 1475361315)))
  }

  func testEndsIn48Hours_WithTimeZoneEdgeCaseProject() {
    let edgeCase = Project.template
      |> Project.lens.dates.deadline .~ (Date(timeIntervalSince1970: 1475361315)
        .timeIntervalSince1970 - 60.0 * 60.0 * 47.0)

    XCTAssertTrue(edgeCase.endsIn48Hours(today: Date(timeIntervalSince1970: 1475361315)))
  }

  func testEquatable() {
    XCTAssertEqual(Project.template, Project.template)
    XCTAssertNotEqual(Project.template, Project.template |> Project.lens.id %~ { $0 + 1 })
  }

  func testDescription() {
    XCTAssertNotEqual("", Project.template.debugDescription)
  }

  func testJSONParsing_WithCompleteData() {
    let project = Project.decodeJSONDictionary([
      "id": 1,
      "name": "Project",
      "blurb": "The project blurb",
      "pledged": 1_000,
      "goal": 2_000,
      "category": [
        "id": 1,
        "name": "Art",
        "slug": "art",
        "position": 1
      ],
      "creator": [
        "id": 1,
        "name": "Blob",
        "avatar": [
          "medium": "http://www.kickstarter.com/medium.jpg",
          "small": "http://www.kickstarter.com/small.jpg"
        ]
      ],
      "photo": [
        "full": "http://www.kickstarter.com/full.jpg",
        "med": "http://www.kickstarter.com/med.jpg",
        "small": "http://www.kickstarter.com/small.jpg",
        "1024x768": "http://www.kickstarter.com/1024x768.jpg",
      ],
      "location": [
        "country": "US",
        "id": 1,
        "displayable_name": "Brooklyn, NY",
        "name": "Brooklyn"
      ],
      "video": [
        "id": 1,
        "high": "kickstarter.com/video.mp4"
      ],
      "backers_count": 10,
      "currency_symbol": "$",
      "currency": "USD",
      "currency_trailing_code": false,
      "country": "US",
      "launched_at": 1000,
      "deadline": 1000,
      "state_changed_at": 1000,
      "static_usd_rate": 1.0,
      "slug": "project",
      "urls": [
        "web": [
          "project": "https://www.kickstarter.com/projects/blob/project"
        ]
      ],
      "state": "live"
      ])

    XCTAssertNil(project.error)
    XCTAssertEqual("US", project.value?.country.countryCode)
  }

  func testJSONParsing_WithMemberData() {
    let memberData = Project.MemberData.decodeJSONDictionary([
      "last_update_published_at": 123456789,
      "permissions": [
        "edit_project",
        "bad_data",
        "edit_faq",
        "post",
        "comment",
        "bad_data",
        "view_pledges",
        "fulfillment"
      ],
      "unread_messages_count": 1,
      "unseen_activity_count": 2
      ])

    XCTAssertNil(memberData.error)
    XCTAssertEqual(123456789, memberData.value?.lastUpdatePublishedAt)
    XCTAssertEqual(1, memberData.value?.unreadMessagesCount)
    XCTAssertEqual(2, memberData.value?.unseenActivityCount)
    XCTAssertEqual([.editProject, .editFaq, .post, .comment, .viewPledges, .fulfillment],
                   memberData.value?.permissions ?? [])
  }

  func testJSONParsing_WithPesonalizationData() {
    let project = Project.decodeJSONDictionary([
      "id": 1,
      "name": "Project",
      "blurb": "The project blurb",
      "pledged": 1_000,
      "goal": 2_000,
      "category": [
        "id": 1,
        "name": "Art",
        "slug": "art",
        "position": 1
      ],
      "creator": [
        "id": 1,
        "name": "Blob",
        "avatar": [
          "medium": "http://www.kickstarter.com/medium.jpg",
          "small": "http://www.kickstarter.com/small.jpg"
        ]
      ],
      "photo": [
        "full": "http://www.kickstarter.com/full.jpg",
        "med": "http://www.kickstarter.com/med.jpg",
        "small": "http://www.kickstarter.com/small.jpg",
        "1024x768": "http://www.kickstarter.com/1024x768.jpg",
      ],
      "location": [
        "country": "US",
        "id": 1,
        "displayable_name": "Brooklyn, NY",
        "name": "Brooklyn"
      ],
      "video": [
        "id": 1,
        "high": "kickstarter.com/video.mp4"
      ],
      "backers_count": 10,
      "currency_symbol": "$",
      "currency": "USD",
      "currency_trailing_code": false,
      "country": "US",
      "launched_at": 1000,
      "deadline": 1000,
      "state_changed_at": 1000,
      "static_usd_rate": 1.0,
      "slug": "project",
      "urls": [
        "web": [
          "project": "https://www.kickstarter.com/projects/my-cool-projects"
        ]
      ],
      "state": "live",
      "is_backing": true,
      "is_starred": true
    ])

    XCTAssertNil(project.error)
    XCTAssertEqual("US", project.value?.country.countryCode)
    XCTAssertEqual(true, project.value?.personalization.isBacking)
  }

  func testPledgedUsd() {
    let project = .template
      |> Project.lens.stats.staticUsdRate .~ 2.0
      |> Project.lens.stats.pledged .~ 1_000

    XCTAssertEqual(2_000, project.stats.pledgedUsd)
  }
}
