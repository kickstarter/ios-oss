@testable import KsApi
import Prelude
import XCTest

final class Reward_RewardFragmentTests: XCTestCase {
  func test() {
    do {
      let variables = ["includeShippingRules": true, "includeLocalPickup": true]
      let fragment = try GraphAPI.RewardFragment(jsonObject: rewardDictionary(), variables: variables)
      XCTAssertNotNil(fragment)

      let dateFormatter = DateFormatter()
      dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
      dateFormatter.dateFormat = "yyyy-MM-dd"

      guard let v1Reward = Reward.reward(
        from: fragment,
        dateFormatter: dateFormatter
      ) else {
        XCTFail("reward should be created from fragment")

        return
      }

      XCTAssertEqual(v1Reward.backersCount, 13)
      XCTAssertEqual(v1Reward.convertedMinimum, 31.0)
      XCTAssertEqual(v1Reward.description, "Description")
      XCTAssertEqual(v1Reward.endsAt, nil)
      XCTAssertEqual(v1Reward.estimatedDeliveryOn, 1_638_316_800.0)
      XCTAssertEqual(v1Reward.id, 8_173_901)
      XCTAssertEqual(v1Reward.limit, nil)
      XCTAssertEqual(v1Reward.limitPerBacker, 1)
      XCTAssertEqual(v1Reward.minimum, 25.0)
      XCTAssertEqual(v1Reward.localPickup?.country, "US")
      XCTAssertEqual(v1Reward.localPickup?.localizedName, "San Jose")
      XCTAssertEqual(v1Reward.localPickup?.displayableName, "San Jose, CA")
      XCTAssertEqual(v1Reward.localPickup?.id, decompose(id: "TG9jYXRpb24tMjQ4ODA0Mg=="))
      XCTAssertEqual(v1Reward.localPickup?.name, "San Jose")
      XCTAssertTrue(v1Reward.hasAddOns)
      XCTAssertEqual(v1Reward.remaining, nil)
      XCTAssertEqual(v1Reward.rewardsItems[0].item.id, 1_170_799)
      XCTAssertEqual(v1Reward.rewardsItems[0].item.name, "Soft-Cover Book (Signed)")
      XCTAssertEqual(v1Reward.rewardsItems[0].quantity, 2)
      XCTAssertEqual(v1Reward.rewardsItems[1].item.id, 1_170_813)
      XCTAssertEqual(v1Reward.rewardsItems[1].item.name, "Custom Bookmark")
      XCTAssertEqual(v1Reward.rewardsItems[1].quantity, 1)

      XCTAssertEqual(v1Reward.shipping.enabled, true)
      XCTAssertEqual(v1Reward.shipping.preference, .unrestricted)
      XCTAssertEqual(v1Reward.shipping.summary, "Ships worldwide")
      XCTAssertEqual(v1Reward.shippingRules?.count, 2)
      XCTAssertEqual(v1Reward.startsAt, nil)
      XCTAssertEqual(v1Reward.title, "Soft Cover Book (Signed)")

      XCTAssertEqual(v1Reward.isLimitedQuantity, false)
      XCTAssertEqual(v1Reward.isLimitedTime, false)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
}

private func rewardDictionary() -> [String: Any] {
  let json = """
  {
    "__typename": "Reward",
    "allowedAddons": {
      "__typename": "RewardConnection",
      "pageInfo": {
        "__typename": "PageInfo",
        "startCursor": "WzIsODMzNzczN10="
      }
    },
    "localReceiptLocation": {
      "__typename": "Location",
      "country": "US",
      "countryName": "United States",
      "displayableName": "San Jose, CA",
      "id": "TG9jYXRpb24tMjQ4ODA0Mg==",
      "name": "San Jose"
    },
    "amount": {
      "__typename": "Money",
      "amount": "25.0",
      "currency": "USD",
      "symbol": "$"
    },
    "backersCount": 13,
    "convertedAmount": {
      "__typename": "Money",
      "amount": "31.0",
      "currency": "CAD",
      "symbol": "$"
    },
    "description": "Description",
    "displayName": "Soft Cover Book (Signed) ($25)",
    "endsAt": null,
    "estimatedDeliveryOn": "2021-12-01",
    "id": "UmV3YXJkLTgxNzM5MDE=",
    "isMaxPledge": false,
    "items": {
      "__typename": "RewardItemsConnection",
      "edges": [
        {
          "__typename": "RewardItemEdge",
          "quantity": 2,
          "node": {
            "__typename": "RewardItem",
            "id": "UmV3YXJkSXRlbS0xMTcwNzk5",
            "name": "Soft-Cover Book (Signed)"
          }
        },
        {
          "__typename": "RewardItemEdge",
          "quantity": 1,
          "node": {
            "__typename": "RewardItem",
            "id": "UmV3YXJkSXRlbS0xMTcwODEz",
            "name": "Custom Bookmark"
          }
        }
      ]
    },
    "limit": null,
    "limitPerBacker": 1,
    "name": "Soft Cover Book (Signed)",
    "project": {
      "__typename": "Project",
      "id": "UHJvamVjdC0xNTk2NTk0NDYz"
    },
    "remainingQuantity": null,
    "shippingSummary": "Ships worldwide",
    "shippingPreference": "unrestricted",
    "shippingRules": [{
        "__typename": "ShippingRule",
        "cost": {
          "__typename": "Money",
          "amount": "0.0",
          "currency": "USD",
          "symbol": "$"
        },
        "id": "U2hpcHBpbmdSdWxlLTExNDEzMzc5",
        "location": {
          "__typename": "Location",
          "country": "ZZ",
          "countryName": null,
          "displayableName": "Earth",
          "id": "TG9jYXRpb24tMQ==",
          "name": "Rest of World"
        }
      },
      {
        "__typename": "ShippingRule",
        "cost": {
          "__typename": "Money",
          "amount": "0.0",
          "currency": "USD",
          "symbol": "$"
        },
        "id": "U2hpcHBpbmdSdWxlLTExMjc4NzUy",
        "location": {
          "__typename": "Location",
          "country": "US",
          "countryName": "United States",
          "displayableName": "United States",
          "id": "TG9jYXRpb24tMjM0MjQ5Nzc=",
          "name": "United States"
        }
      }
    ],
    "startsAt": null
  }
  """

  let data = Data(json.utf8)
  return (try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) ?? [:]
}
