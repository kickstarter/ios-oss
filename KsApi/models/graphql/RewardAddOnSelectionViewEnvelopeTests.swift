@testable import KsApi
import XCTest

final class RewardAddOnSelectionViewEnvelopeTests: XCTestCase {
  func testJSONParsing_WithCompleteData() {
    let dictionary: [String: Any] = [
      "project": [
        "name": "My Special Project",
        "slug": "project-slug",
        "pid": 747_474_738,
        "fxRate": 1.082342,
        "actions": [
          "displayConvertAmount": true
        ],
        "category": [
          "id": "Q2F0ZWdvcnktNTI=",
          "name": "Hardware",
          "parentCategory": [
            "id": "Q2F0ZWdvcnktMTY=",
            "name": "Technology"
          ]
        ],
        "finalCollectionDate": "2020-07-01",
        "location": [
          "country": "CA",
          "countryName": "Canada",
          "displayableName": "Canada",
          "id": "TG9jYXRpb24tMjM0MjQ3NzU=",
          "name": "Canada"
        ],
        "isProjectWeLove": true,
        "prelaunchActivated": false,
        "deadlineAt": 158_750_211,
        "launchedAt": 158_740_211,
        "stateChangedAt": 1_587_502_131,
        "backersCount": 5,
        "creator": [
          "imageUrl": "http://www.kickstarter.com/avatar.jpg",
          "id": "VXNlci0xMjA3OTk3NjQ5",
          "name": "Creator McBaggins",
          "uid": "32434234"
        ],
        "currency": "USD",
        "country": [
          "code": "CA",
          "name": "Canada"
        ],
        "description": "Project description",
        "goal": [
          "amount": "150",
          "currency": "USD",
          "symbol": "$"
        ],
        "pledged": [
          "amount": "173434.0",
          "currency": "USD",
          "symbol": "$"
        ],
        "url": "http://www.kickstarter.com/my/project",
        "usdExchangeRate": 1,
        "image": [
          "id": "UGhvdG8tMTEyNTczMzI=",
          "url": "http://www.kickstarter.com/my/image.jpg"
        ],
        "state": "LIVE",
        "addOns": [
          "nodes": [
            [
              "amount": [
                "amount": "179.0",
                "currency": "USD",
                "symbol": "$"
              ],
              "convertedAmount": [
                "amount": "150.0",
                "currency": "USD",
                "symbol": "$"
              ],
              "backersCount": 2,
              "description": "Best Add-on",
              "displayName": "Crowdfunding Special ($179)",
              "estimatedDeliveryOn": "2020-07-01",
              "id": "UmV3YXJkLTc2MDEyNDk=",
              "isMaxPledge": false,
              "items": [
                "nodes": []
              ],
              "limit": 66,
              "limitPerBacker": 2,
              "name": "Crowdfunding Special",
              "remainingQuantity": 5,
              "endsAt": 747_474_744,
              "startsAt": 747_474_228,
              "shippingPreference": "restricted",
              "shippingRules": [
                [
                  "cost": [
                    "amount": "15.0",
                    "currency": "USD",
                    "symbol": "$"
                  ],
                  "id": "U2hpcHBpbmdSdWxlLTEwMzc5NTgz",
                  "location": [
                    "country": "CA",
                    "countryName": "Canada",
                    "displayableName": "Canada",
                    "id": "TG9jYXRpb24tMjM0MjQ3NzU=",
                    "name": "Canada"
                  ]
                ]
              ]
            ]
          ]
        ]
      ]
    ]

    guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
      XCTFail("Should have data")
      return
    }

    do {
      let value = try JSONDecoder().decode(RewardAddOnSelectionViewEnvelope.self, from: data)

      XCTAssertEqual(value.project.pid, 747_474_738)
      XCTAssertEqual(value.project.name, "My Special Project")
      XCTAssertEqual(value.project.slug, "project-slug")
      XCTAssertEqual(value.project.state, .live)
      XCTAssertEqual(value.project.actions.displayConvertAmount, true)
      XCTAssertEqual(value.project.fxRate, 1.082342)
      XCTAssertEqual(value.project.deadlineAt, 158_750_211.0)
      XCTAssertEqual(value.project.launchedAt, 158_740_211)
      XCTAssertEqual(value.project.stateChangedAt, 1_587_502_131.0)
      XCTAssertEqual(value.project.description, "Project description")
      XCTAssertEqual(value.project.finalCollectionDate, "2020-07-01")
      XCTAssertEqual(value.project.isProjectWeLove, true)
      XCTAssertEqual(value.project.prelaunchActivated, false)
      XCTAssertEqual(value.project.goal, Money(amount: 150, currency: .usd, symbol: "$"))
      XCTAssertEqual(value.project.pledged, Money(amount: 173_434.0, currency: .usd, symbol: "$"))
      XCTAssertEqual(value.project.url, "http://www.kickstarter.com/my/project")
      XCTAssertEqual(value.project.usdExchangeRate, 1)

      XCTAssertEqual(value.project.location?.name, "Canada")
      XCTAssertEqual(value.project.location?.countryName, "Canada")
      XCTAssertEqual(value.project.location?.country, "CA")
      XCTAssertEqual(value.project.location?.displayableName, "Canada")
      XCTAssertEqual(value.project.location?.id, "TG9jYXRpb24tMjM0MjQ3NzU=")

      XCTAssertEqual(value.project.image?.id, "UGhvdG8tMTEyNTczMzI=")
      XCTAssertEqual(value.project.image?.url, "http://www.kickstarter.com/my/image.jpg")

      XCTAssertEqual(value.project.category?.id, "Q2F0ZWdvcnktNTI=")
      XCTAssertEqual(value.project.category?.name, "Hardware")
      XCTAssertEqual(value.project.category?.parentCategory?.id, "Q2F0ZWdvcnktMTY=")
      XCTAssertEqual(value.project.category?.parentCategory?.name, "Technology")

      XCTAssertEqual(value.project.creator.id, "VXNlci0xMjA3OTk3NjQ5")
      XCTAssertEqual(value.project.creator.uid, "32434234")
      XCTAssertEqual(value.project.creator.name, "Creator McBaggins")
      XCTAssertEqual(value.project.creator.imageUrl, "http://www.kickstarter.com/avatar.jpg")

      XCTAssertEqual(value.project.addOns?.nodes[0].id, "UmV3YXJkLTc2MDEyNDk=")
      XCTAssertEqual(value.project.addOns?.nodes[0].amount, Money(amount: 179.0, currency: .usd, symbol: "$"))
      XCTAssertEqual(
        value.project.addOns?.nodes[0].convertedAmount,
        Money(amount: 150.0, currency: .usd, symbol: "$")
      )
      XCTAssertEqual(value.project.addOns?.nodes[0].backersCount, 2)
      XCTAssertEqual(value.project.addOns?.nodes[0].description, "Best Add-on")
      XCTAssertEqual(value.project.addOns?.nodes[0].displayName, "Crowdfunding Special ($179)")
      XCTAssertEqual(value.project.addOns?.nodes[0].name, "Crowdfunding Special")
      XCTAssertEqual(value.project.addOns?.nodes[0].isMaxPledge, false)
      XCTAssertEqual(value.project.addOns?.nodes[0].items?.nodes.count, 0)
      XCTAssertEqual(value.project.addOns?.nodes[0].limit, 66)
      XCTAssertEqual(value.project.addOns?.nodes[0].limitPerBacker, 2)
      XCTAssertEqual(value.project.addOns?.nodes[0].remainingQuantity, 5)
      XCTAssertEqual(value.project.addOns?.nodes[0].estimatedDeliveryOn, "2020-07-01")
      XCTAssertEqual(value.project.addOns?.nodes[0].endsAt, 747_474_744)
      XCTAssertEqual(value.project.addOns?.nodes[0].startsAt, 747_474_228)
      XCTAssertEqual(value.project.addOns?.nodes[0].shippingPreference, .restricted)
      XCTAssertEqual(
        value.project.addOns?.nodes[0].shippingRules?[0].cost,
        Money(amount: 15.0, currency: .usd, symbol: "$")
      )
      XCTAssertEqual(value.project.addOns?.nodes[0].shippingRules?[0].id, "U2hpcHBpbmdSdWxlLTEwMzc5NTgz")
      XCTAssertEqual(value.project.addOns?.nodes[0].shippingRules?[0].location.id, "TG9jYXRpb24tMjM0MjQ3NzU=")
      XCTAssertEqual(value.project.addOns?.nodes[0].shippingRules?[0].location.country, "CA")
      XCTAssertEqual(value.project.addOns?.nodes[0].shippingRules?[0].location.countryName, "Canada")
      XCTAssertEqual(value.project.addOns?.nodes[0].shippingRules?[0].location.displayableName, "Canada")
      XCTAssertEqual(value.project.addOns?.nodes[0].shippingRules?[0].location.name, "Canada")

      guard let graphReward = value.project.addOns?.nodes.first else {
        XCTFail("Should have a graphReward")
        return
      }

      XCTAssertNotNil(
        Reward.reward(from: graphReward, projectId: value.project.pid),
        "A Reward can be created from this GraphReward"
      )
      XCTAssertNotNil(
        Project.project(from: value.project),
        "A Project can be created from this GraphProject"
      )
    } catch {
      XCTFail((error as NSError).description)
    }
  }
}
