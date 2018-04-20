import XCTest
@testable import KsApi
@testable import Argo

final class ProjectStatsEnvelopeTests: XCTestCase {
  func testJSONDecoding() {
    let fundingStats: [[String: Any]] = [
      [
        "cumulative_backers_count": 7,
        "cumulative_pledged": "30",
        "pledged": "38.0",
        "date": 555444333,
        "backers_count": 13
      ],
      [
        "cumulative_backers_count": 14,
        "cumulative_pledged": 1000,
        "pledged": "909.0",
        "date": 333222111,
        "backers_count": 1
      ],
      ["date": 555444334],
      ["date": 555444335]
    ]
    let json: [String: Any] = [
      "referral_aggregates" : [
        "custom": 1.0,
        "external": "15.0",
        "internal": 14.0
      ],
      "referral_distribution": [
        [
          "code": "my_wonderful_referrer_code",
          "referrer_name": "My wonderful referrer name",
          "percentage_of_dollars": "0.250",
          "referrer_type": "External",
          "pledged": "20.5",
          "backers_count": 8
        ],
        [
          "code": "my_okay_referrer_code",
          "referrer_name": "My okay referrer name",
          "percentage_of_dollars": "0.001",
          "referrer_type": "Kickstarter",
          "pledged": "1.0",
          "backers_count": 1
        ]
      ],
      "reward_distribution": [
        [
          "pledged": "1.0",
          "reward_id": 0,
          "backers_count": 5
        ],
        [
          "pledged": "25.0",
          "reward_id": 123456,
          "backers_count": 10,
          "minimum": 5.0
        ],
        [
          "pledged": "25.0",
          "reward_id": 57393985,
          "backers_count": 20,
          "minimum": "25.0"
        ]
      ],
      "cumulative": [
        "pledged": "40.0",
        "average_pledge": 17.38,
        "percent_raised": 2.666666666666667,
        "backers_count": 20,
        "goal": "15.0"
      ],
      "funding_distribution": fundingStats,
      "video_stats": [
        "external_completions": 5,
        "external_starts": 14,
        "internal_completions": 10,
        "internal_starts": 14
      ]
    ]

    let stats = ProjectStatsEnvelope.decodeJSONDictionary(json)
    XCTAssertNotNil(stats)

    XCTAssertEqual(40, stats.value?.cumulativeStats.pledged)
    XCTAssertEqual(17, stats.value?.cumulativeStats.averagePledge)
    XCTAssertEqual(20, stats.value?.cumulativeStats.backersCount)

    XCTAssertEqual(5, stats.value?.videoStats?.externalCompletions)
    XCTAssertEqual(14, stats.value?.videoStats?.internalStarts)

    XCTAssertEqual(1.0, stats.value?.referralAggregateStats.custom)
    XCTAssertEqual(15.0, stats.value?.referralAggregateStats.external)
    XCTAssertEqual(14.0, stats.value?.referralAggregateStats.kickstarter)


    let fundingDistribution = stats.value?.fundingDistribution ?? []
    let rewardDistribution = stats.value?.rewardDistribution ?? []
    let referralDistribution = stats.value?.referralDistribution ?? []

    XCTAssertEqual(7, fundingDistribution[0].cumulativeBackersCount)
    XCTAssertEqual(14, fundingDistribution[1].cumulativeBackersCount)
    XCTAssertEqual(2, fundingDistribution.count, "Funding stats with nil values discarded.")

    XCTAssertEqual("my_wonderful_referrer_code", referralDistribution[0].code)
    XCTAssertEqual(8, referralDistribution[0].backersCount)
    XCTAssertEqual(20.5, referralDistribution[0].pledged)
    XCTAssertEqual(ProjectStatsEnvelope.ReferrerStats.ReferrerType.external,
                   referralDistribution[0].referrerType)
    XCTAssertEqual("my_okay_referrer_code", referralDistribution[1].code)
    XCTAssertEqual(1, referralDistribution[1].backersCount)
    XCTAssertEqual(ProjectStatsEnvelope.ReferrerStats.ReferrerType.internal,
                   referralDistribution[1].referrerType)

    XCTAssertEqual(0, rewardDistribution[0].rewardId)
    XCTAssertEqual(123456, rewardDistribution[1].rewardId)
    XCTAssertEqual(1, rewardDistribution[0].pledged)
    XCTAssertEqual(25, rewardDistribution[1].pledged)
    XCTAssertEqual(5, rewardDistribution[0].backersCount)
    XCTAssertEqual(10, rewardDistribution[1].backersCount)
    XCTAssertEqual(nil, rewardDistribution[0].minimum)
    XCTAssertEqual(5, rewardDistribution[1].minimum)
    XCTAssertEqual(25, rewardDistribution[2].minimum)
  }

  func testJSONDecoding_MissingData() {
    let json: [String: Any] = [
      "referral_distribution": [],
      "reward_distribution": [],
      "cumulative": [],
      "funding_distribution": [],
      "video_stats": []
    ]

    let stats = ProjectStatsEnvelope.decodeJSONDictionary(json)

    XCTAssertNil(stats.value?.cumulativeStats)
    XCTAssertNil(stats.value?.fundingDistribution)
    XCTAssertNil(stats.value?.referralDistribution)
    XCTAssertNil(stats.value?.rewardDistribution)
    XCTAssertNil(stats.value?.videoStats)
  }
}
