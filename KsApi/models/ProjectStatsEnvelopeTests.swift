@testable import KsApi
import XCTest

final class ProjectStatsEnvelopeTests: XCTestCase {
  func testJSONDecoding() {
    let fundingStats: [[String: Any]] = [
      [
        "cumulative_backers_count": 7,
        "cumulative_pledged": "30",
        "pledged": "38.0",
        "date": 555_444_333,
        "backers_count": 13
      ],
      [
        "cumulative_backers_count": 14,
        "cumulative_pledged": 1_000,
        "pledged": "909.0",
        "date": 333_222_111,
        "backers_count": 1
      ],
      ["date": 555_444_334],
      ["date": 555_444_335]
    ]
    let json: [String: Any] = [
      "referral_aggregates": [
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
          "reward_id": 123_456,
          "backers_count": 10,
          "minimum": 5.0
        ],
        [
          "pledged": "25.0",
          "reward_id": 57_393_985,
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

    let stats: ProjectStatsEnvelope = try! ProjectStatsEnvelope.decodeJSONDictionary(json)
    XCTAssertNotNil(stats)

    XCTAssertEqual(40, stats.cumulativeStats.pledged)
    XCTAssertEqual(17, stats.cumulativeStats.averagePledge)
    XCTAssertEqual(20, stats.cumulativeStats.backersCount)

    XCTAssertEqual(5, stats.videoStats?.externalCompletions)
    XCTAssertEqual(14, stats.videoStats?.internalStarts)

    XCTAssertEqual(1.0, stats.referralAggregateStats.custom)
    XCTAssertEqual(15.0, stats.referralAggregateStats.external)
    XCTAssertEqual(14.0, stats.referralAggregateStats.kickstarter)

    let fundingDistribution = stats.fundingDistribution
    let rewardDistribution = stats.rewardDistribution
    let referralDistribution = stats.referralDistribution

    XCTAssertEqual(7, fundingDistribution[0].cumulativeBackersCount)
    XCTAssertEqual(14, fundingDistribution[1].cumulativeBackersCount)
    XCTAssertEqual(2, fundingDistribution.count, "Funding stats with nil values discarded.")

    XCTAssertEqual("my_wonderful_referrer_code", referralDistribution[0].code)
    XCTAssertEqual(8, referralDistribution[0].backersCount)
    XCTAssertEqual(20.5, referralDistribution[0].pledged)
    XCTAssertEqual(
      ProjectStatsEnvelope.ReferrerStats.ReferrerType.external,
      referralDistribution[0].referrerType
    )
    XCTAssertEqual("my_okay_referrer_code", referralDistribution[1].code)
    XCTAssertEqual(1, referralDistribution[1].backersCount)
    XCTAssertEqual(
      ProjectStatsEnvelope.ReferrerStats.ReferrerType.internal,
      referralDistribution[1].referrerType
    )

    XCTAssertEqual(0, rewardDistribution[0].rewardId)
    XCTAssertEqual(123_456, rewardDistribution[1].rewardId)
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

    let stats: ProjectStatsEnvelope? = ProjectStatsEnvelope.decodeJSONDictionary(json)

    XCTAssertNil(stats?.cumulativeStats)
    XCTAssertNil(stats?.fundingDistribution)
    XCTAssertNil(stats?.referralDistribution)
    XCTAssertNil(stats?.rewardDistribution)
    XCTAssertNil(stats?.videoStats)
  }
}
