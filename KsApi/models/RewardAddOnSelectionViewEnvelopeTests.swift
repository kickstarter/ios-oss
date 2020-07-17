@testable import KsApi
import XCTest

final class RewardAddOnSelectionViewEnvelopeTests: XCTestCase {
  func testJSONParsing_WithCompleteData() {
    let dictionary: [String: Any] = [
      "project": [
        "pid": 747_474_738,
        "fxRate": 1.082342,
        "actions": [
          "displayConvertAmount": true
        ],
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
              "limit": nil,
              "limitPerBacker": 2,
              "name": "Crowdfunding Special",
              "remainingQuantity": nil,
              "startsAt": nil,
              "shippingPreference": "restricted",
              "shippingRules": [
                [
                  "id": "U2hpcHBpbmdSdWxlLTEwMzc5NTgz",
                  "location": [
                    "id": "TG9jYXRpb24tMQ=="
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
      XCTAssertEqual(value.project.actions.displayConvertAmount, true)
      XCTAssertEqual(value.project.fxRate, 1.082342)

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
      XCTAssertEqual(value.project.addOns?.nodes[0].limit, nil)
      XCTAssertEqual(value.project.addOns?.nodes[0].limitPerBacker, 2)
      XCTAssertEqual(value.project.addOns?.nodes[0].remainingQuantity, nil)
      XCTAssertEqual(value.project.addOns?.nodes[0].startsAt, nil)
      XCTAssertEqual(value.project.addOns?.nodes[0].shippingPreference, .restricted)
      XCTAssertEqual(value.project.addOns?.nodes[0].shippingRules?[0].id, "U2hpcHBpbmdSdWxlLTEwMzc5NTgz")
      XCTAssertEqual(value.project.addOns?.nodes[0].shippingRules?[0].location.id, "TG9jYXRpb24tMQ==")
    } catch {
      XCTFail((error as NSError).description)
    }
  }
}
