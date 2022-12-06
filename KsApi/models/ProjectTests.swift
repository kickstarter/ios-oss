@testable import KsApi
import Prelude
import XCTest

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
      |> Project.lens.dates.launchedAt .~ Date(timeIntervalSince1970: 1_475_361_315).timeIntervalSince1970

    XCTAssertEqual(false, justLaunched.endsIn48Hours(today: Date(timeIntervalSince1970: 1_475_361_315)))
  }

  func testEndsIn48Hours_WithEndingSoonProject() {
    let endingSoon = Project.template
      |> Project.lens.dates.deadline .~ (Date(timeIntervalSince1970: 1_475_361_315)
        .timeIntervalSince1970 - 60.0 * 60.0)

    XCTAssertEqual(true, endingSoon.endsIn48Hours(today: Date(timeIntervalSince1970: 1_475_361_315)))
  }

  func testEndsIn48Hours_WithTimeZoneEdgeCaseProject() {
    let edgeCase = Project.template
      |> Project.lens.dates.deadline .~ (Date(timeIntervalSince1970: 1_475_361_315)
        .timeIntervalSince1970 - 60.0 * 60.0 * 47.0)

    XCTAssertEqual(true, edgeCase.endsIn48Hours(today: Date(timeIntervalSince1970: 1_475_361_315)))
  }

  func testEquatable() {
    XCTAssertEqual(Project.template, Project.template)
    XCTAssertNotEqual(Project.template, Project.template |> Project.lens.id %~ { $0 + 1 })
  }

  func testDescription() {
    XCTAssertNotEqual("", Project.template.debugDescription)
  }

  func testJSONParsing_WithCompleteData() {
    let project: Project = try! Project.decodeJSONDictionary([
      "id": 1,
      "name": "Project",
      "blurb": "The project blurb",
      "staff_pick": false,
      "pledged": 1_000,
      "goal": 2_000,
      "category": [
        "analytics_name": "Ceramics",
        "id": 1,
        "name": "Ceramics",
        "parent_id": 5,
        "parent_name": "Art",
        "slug": "art",
        "position": 1
      ],
      "creator": [
        "id": 1,
        "name": "Blob",
        "avatar": [
          "medium": "http://www.kickstarter.com/medium.jpg",
          "small": "http://www.kickstarter.com/small.jpg"
        ],
        "needs_password": false
      ],
      "photo": [
        "full": "http://www.kickstarter.com/full.jpg",
        "med": "http://www.kickstarter.com/med.jpg",
        "small": "http://www.kickstarter.com/small.jpg",
        "1024x768": "http://www.kickstarter.com/1024x768.jpg"
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
      "launched_at": 1_000,
      "deadline": 1_000,
      "state_changed_at": 1_000,
      "static_usd_rate": 1.0,
      "slug": "project",
      "urls": [
        "web": [
          "project": "https://www.kickstarter.com/projects/blob/project"
        ]
      ],
      "state": "live"
    ])

    XCTAssertEqual("US", project.country.countryCode)
    XCTAssertEqual("Ceramics", project.category.analyticsName)
    XCTAssertEqual(1, project.category.id)
    XCTAssertEqual("Ceramics", project.category.name)
    XCTAssertEqual(5, project.category.parentId)
    XCTAssertEqual("Art", project.category.parentName)
  }

  func testJSONParsing_WithCompleteData_SpanishCategory() {
    let project: Project = try! Project.decodeJSONDictionary([
      "id": 1,
      "name": "Project",
      "blurb": "The project blurb",
      "staff_pick": false,
      "pledged": 1_000,
      "goal": 2_000,
      "category": [
        "analytics_name": "Ceramics",
        "id": 1,
        "name": "Cerámica",
        "parent_id": 5,
        "parent_name": "Art",
        "slug": "art",
        "position": 1
      ],
      "creator": [
        "id": 1,
        "name": "Blob",
        "avatar": [
          "medium": "http://www.kickstarter.com/medium.jpg",
          "small": "http://www.kickstarter.com/small.jpg"
        ],
        "needs_password": false
      ],
      "photo": [
        "full": "http://www.kickstarter.com/full.jpg",
        "med": "http://www.kickstarter.com/med.jpg",
        "small": "http://www.kickstarter.com/small.jpg",
        "1024x768": "http://www.kickstarter.com/1024x768.jpg"
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
      "launched_at": 1_000,
      "deadline": 1_000,
      "state_changed_at": 1_000,
      "static_usd_rate": 1.0,
      "slug": "project",
      "urls": [
        "web": [
          "project": "https://www.kickstarter.com/projects/blob/project"
        ]
      ],
      "state": "live"
    ])

    XCTAssertEqual("US", project.country.countryCode)
    XCTAssertEqual("Ceramics", project.category.analyticsName)
    XCTAssertEqual(1, project.category.id)
    XCTAssertEqual("Cerámica", project.category.name)
    XCTAssertEqual(5, project.category.parentId)
    XCTAssertEqual("Art", project.category.parentName)
  }

  func testJSONParsing_WithMemberData() {
    let memberData: Project.MemberData = try! Project.MemberData.decodeJSONDictionary([
      "last_update_published_at": 123_456_789,
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

    XCTAssertEqual(123_456_789, memberData.lastUpdatePublishedAt)
    XCTAssertEqual(1, memberData.unreadMessagesCount)
    XCTAssertEqual(2, memberData.unseenActivityCount)
    XCTAssertEqual(
      [.editProject, .editFaq, .post, .comment, .viewPledges, .fulfillment],
      memberData.permissions
    )
  }

  func testJSONParsing_WithPesonalizationData() {
    let project: Project = try! Project.decodeJSONDictionary([
      "id": 1,
      "name": "Project",
      "blurb": "The project blurb",
      "staff_pick": false,
      "pledged": 1_000,
      "goal": 2_000,
      "category": [
        "analytics_name": "Ceramics",
        "id": 1,
        "name": "Ceramics",
        "parent_id": 5,
        "parent_name": "Art",
        "slug": "art",
        "position": 1
      ],
      "creator": [
        "id": 1,
        "name": "Blob",
        "avatar": [
          "medium": "http://www.kickstarter.com/medium.jpg",
          "small": "http://www.kickstarter.com/small.jpg"
        ],
        "needs_password": false
      ],
      "photo": [
        "full": "http://www.kickstarter.com/full.jpg",
        "med": "http://www.kickstarter.com/med.jpg",
        "small": "http://www.kickstarter.com/small.jpg",
        "1024x768": "http://www.kickstarter.com/1024x768.jpg"
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
      "launched_at": 1_000,
      "deadline": 1_000,
      "state_changed_at": 1_000,
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

    XCTAssertEqual("US", project.country.countryCode)
    XCTAssertEqual(true, project.personalization.isBacking)
  }

  func testPledgedUsd() {
    let project = .template
      |> Project.lens.stats.staticUsdRate .~ 2.0
      |> Project.lens.stats.pledged .~ 1_000

    XCTAssertEqual(2_000, project.stats.pledgedUsd)
  }

  func testTotalAmountPledgedUsdCurrency() {
    let project = .template
      |> Project.lens.stats.usdExchangeRate .~ 1.56
      |> Project.lens.stats.pledged .~ 80_400

    XCTAssertEqual(125_423.99, project.stats.totalAmountPledgedUsdCurrency)
  }

  func testGoalCurrentCurrency() {
    let project = .template
      |> Project.lens.stats.currentCurrencyRate .~ 2.68
      |> Project.lens.stats.goal .~ 30_000

    XCTAssertEqual(80_400, project.stats.goalCurrentCurrency)
  }

  func testGoalUsdCurrency() {
    let project = .template
      |> Project.lens.stats.usdExchangeRate .~ 1.56
      |> Project.lens.stats.goal .~ 30_000

    XCTAssertEqual(46_800, project.stats.goalUsdCurrency)
  }

  func testGoalUsd() {
    let project = .template
      |> Project.lens.stats.staticUsdRate .~ 13.56
      |> Project.lens.stats.goal .~ 30_000

    XCTAssertEqual(406_800.0, project.stats.goalUsd)
  }

  func testDuration() {
    let launchedAt = DateComponents()
      |> \.day .~ 15
      |> \.month .~ 3
      |> \.year .~ 2_020
      |> \.timeZone .~ TimeZone(secondsFromGMT: 0)

    // 1 month after launch
    let deadline = DateComponents()
      |> \.day .~ 14
      |> \.month .~ 4
      |> \.year .~ 2_020
      |> \.timeZone .~ TimeZone(secondsFromGMT: 0)

    let calendar = Calendar(identifier: .gregorian)

    let deadlineInterval = calendar.date(from: deadline)?.timeIntervalSince1970
    let launchedAtInterval = calendar.date(from: launchedAt)?.timeIntervalSince1970

    let project = Project.template
      |> Project.lens.dates.deadline .~ deadlineInterval!
      |> Project.lens.dates.launchedAt .~ launchedAtInterval!

    XCTAssertEqual(30, project.dates.duration(using: calendar))
  }

  func testHoursRemaining() {
    let deadline = DateComponents()
      |> \.day .~ 2
      |> \.month .~ 3
      |> \.year .~ 2_020
      |> \.timeZone .~ TimeZone(secondsFromGMT: 0)

    // 24 hours before deadline
    let now = DateComponents()
      |> \.day .~ 1
      |> \.month .~ 3
      |> \.year .~ 2_020
      |> \.timeZone .~ TimeZone(secondsFromGMT: 0)

    let calendar = Calendar(identifier: .gregorian)
    let nowDate = calendar.date(from: now)
    let deadlineInterval = calendar.date(from: deadline)?.timeIntervalSince1970

    let project = Project.template
      |> Project.lens.dates.deadline .~ deadlineInterval!

    XCTAssertEqual(24, project.dates.hoursRemaining(from: nowDate!, using: calendar))
  }

  func testHoursRemaining_LessThanZero() {
    let deadline = DateComponents()
      |> \.day .~ 2
      |> \.month .~ 3
      |> \.year .~ 2_020
      |> \.timeZone .~ TimeZone(secondsFromGMT: 0)

    // 24 hours after deadline
    let now = DateComponents()
      |> \.day .~ 3
      |> \.month .~ 3
      |> \.year .~ 2_020
      |> \.timeZone .~ TimeZone(secondsFromGMT: 0)

    let calendar = Calendar(identifier: .gregorian)
    let nowDate = calendar.date(from: now)
    let deadlineInterval = calendar.date(from: deadline)?.timeIntervalSince1970

    let project = Project.template
      |> Project.lens.dates.deadline .~ deadlineInterval!

    XCTAssertEqual(0, project.dates.hoursRemaining(from: nowDate!, using: calendar))
  }

  func testGoalMet_PledgedIsLessThanGoal() {
    let project = Project.template
      |> \.stats.goal .~ 1_000
      |> \.stats.pledged .~ 50

    XCTAssertFalse(project.stats.goalMet)
  }

  func testGoalMet_PledgedEqualToGoal() {
    let project = Project.template
      |> \.stats.goal .~ 1_000
      |> \.stats.pledged .~ 1_000

    XCTAssertTrue(project.stats.goalMet)
  }

  func testGoalMet_PledgedIsGreaterThanGoal() {
    let project = Project.template
      |> \.stats.goal .~ 1_000
      |> \.stats.pledged .~ 2_000

    XCTAssertTrue(project.stats.goalMet)
  }

  func testTags() {
    let tags = ["Witchstarter", "Arts", "Games"]
    let project = Project.template |> Project.lens.tags .~ tags
    XCTAssertEqual(3, project.tags?.count)
    XCTAssertEqual("Witchstarter, Arts, Games", project.tags?.joined(separator: ", "))
  }
}
