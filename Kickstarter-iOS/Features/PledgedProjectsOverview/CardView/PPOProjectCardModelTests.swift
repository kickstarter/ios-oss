import Combine
@testable import Kickstarter_Framework
@testable import KsApi
import XCTest

final class PPOProjectCardModelTests: XCTestCase {
  func testParsingNoAddress() throws {
    let model = try XCTUnwrap(self.mockModel(addressJSON: "null"))
    XCTAssertNil(model.address)
  }

  func testParsingBasicAddress() throws {
    let model = try XCTUnwrap(self.mockModel(addressJSON: """
    {
      "__typename": "DeliveryAddress",
      "id": "0",
      "recipientName": "Firsty Lasty",
      "addressLine1": "123 First Street",
      "addressLine2": null,
      "city": "Los Angeles",
      "region": "CA",
      "postalCode": "90025-1234",
      "phoneNumber": null,
      "countryCode": "US",
    }
    """))

    let lines = (try XCTUnwrap(model.address)).split(separator: "\n")
    XCTAssertEqual(lines, [
      "Firsty Lasty",
      "123 First Street",
      "Los Angeles, CA 90025-1234",
      "US"
    ])
  }

  func testParsingTwoLineAddress() throws {
    let model = try XCTUnwrap(self.mockModel(addressJSON: """
    {
      "__typename": "DeliveryAddress",
      "id": "0",
      "recipientName": "Firsty Lasty",
      "addressLine1": "123 First Street",
      "addressLine2": "Apt #5678",
      "city": "Los Angeles",
      "region": "CA",
      "postalCode": "90025-1234",
      "phoneNumber": null,
      "countryCode": "US",
    }
    """))

    let lines = (try XCTUnwrap(model.address)).split(separator: "\n")
    XCTAssertEqual(lines, [
      "Firsty Lasty",
      "123 First Street",
      "Apt #5678",
      "Los Angeles, CA 90025-1234",
      "US"
    ])
  }

  func testParsingTwoLineAddressPhone() throws {
    let model = try XCTUnwrap(self.mockModel(addressJSON: """
    {
      "__typename": "DeliveryAddress",
      "id": "0",
      "recipientName": "Firsty Lasty",
      "addressLine1": "123 First Street",
      "addressLine2": "Apt #5678",
      "city": "Los Angeles",
      "region": "CA",
      "postalCode": "90025-1234",
      "phoneNumber": "(555) 555-5425",
      "countryCode": "US",
    }
    """))

    let lines = (try XCTUnwrap(model.address)).split(separator: "\n")
    XCTAssertEqual(lines, [
      "Firsty Lasty",
      "123 First Street",
      "Apt #5678",
      "Los Angeles, CA 90025-1234",
      "US",
      "(555) 555-5425"
    ])
  }

  private func mockModel(addressJSON: String) -> PPOProjectCardModel? {
    do {
      return PPOProjectCardModel(node: try .init(jsonString: """
            {
              "__typename": "PledgeProjectOverviewItem",
              "backing": {
                "__typename": "Backing",
                "amount": {
                  "__typename": "Money",
                  "amount": "1.0",
                  "currency": "USD",
                  "symbol": "$"
                },
                "id": "QmFja2luZy0xNzUxMTY1MDE=",
                "project": {
                  "__typename": "Project",
                  "addOns": {
                    "__typename": "ProjectRewardConnection",
                    "totalCount": 4
                  },
                  "backersCount": 1,
                  "backing": {
                    "__typename": "Backing",
                    "id": "QmFja2luZy0xNzUxMTY1MDE="
                  },
                  "category": {
                    "__typename": "Category",
                    "analyticsName": "Art",
                    "parentCategory": null
                  },
                  "commentsCount": 0,
                  "country": {
                    "__typename": "Country",
                    "code": "US"
                  },
                  "creator": {
                    "__typename": "User",
                    "id": "VXNlci0yMDcxMzk5NTYx",
                    "createdProjects": {
                      "__typename": "UserCreatedProjectsConnection",
                      "totalCount": 4
                    },
                    "email": null,
                    "name": "Santiago Sosa"
                  },
                  "currency": "USD",
                  "deadlineAt": 1785369600,
                  "launchedAt": 1722374256,
                  "pid": 999498397,
                  "name": "PPO - failed payment",
                  "isInPostCampaignPledgingPhase": false,
                  "isWatched": false,
                  "percentFunded": 0,
                  "isPrelaunchActivated": false,
                  "projectTags": [],
                  "postCampaignPledgingEnabled": true,
                  "rewards": {
                    "__typename": "ProjectRewardConnection",
                    "totalCount": 4
                  },
                  "state": "LIVE",
                  "video": null,
                  "pledged": {
                    "__typename": "Money",
                    "amount": "1.0"
                  },
                  "fxRate": 1.0,
                  "usdExchangeRate": 1.0,
                  "posts": {
                    "__typename": "PostConnection",
                    "totalCount": 0
                  },
                  "goal": {
                    "__typename": "Money",
                    "amount": "1000.0"
                  },
                  "image": {
                    "__typename": "Photo",
                    "id": "UGhvdG8tNDU5MDY3MzU=",
                    "url": "https://i-dev.kickstarter.com/assets/045/906/735/79d07ae7d8fcd1da46ac51de4aebf7c2_original.png?anim=false&fit=cover&gravity=auto&height=576&origin=ugc-qa&q=92&v=1724342846&width=1024&sig=gAmSWBqkhfolJ%2F1VL2rrYIHp75YjKGC2CkL6rOaR6RY%3D"
                  },
                  "slug": "2071399561/ppo-failed-payment-0"
                },
                "backingDetailsPageRoute": "https://staging.kickstarter.com/projects/2071399561/ppo-failed-payment-0/backing/survey_responses",
                "deliveryAddress": \(addressJSON),
                "clientSecret": null
              },
              "tierType": "Tier1PaymentFailed",
              "flags": [
                {
                  "__typename": "PledgedProjectsOverviewPledgeFlags",
                  "icon": "alert",
                  "message": "Payment failed",
                  "type": "alert"
                },
                {
                  "__typename": "PledgedProjectsOverviewPledgeFlags",
                  "icon": "time",
                  "message": "Pledge will be dropped in 0 days",
                  "type": "alert"
                }
              ]
            }
      """))
    } catch {
      print("error parsing: \(error)")
      return nil
    }
  }
}
