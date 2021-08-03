import Apollo
@testable import KsApi
import XCTest

final class Backing_BackingFragmentTests: XCTestCase {
  func test() {
    do {
      let fragment = try GraphAPI.BackingFragment(jsonObject: backingDictionary())
      XCTAssertNotNil(fragment)

      let backing = Backing.backing(from: fragment)
      XCTAssertNotNil(backing)
      XCTAssertEqual(backing?.amount, 90.0)
      XCTAssertNotNil(backing?.backer)
      XCTAssertNotNil(backing?.backerId)
      XCTAssertEqual(backing?.backerCompleted, false)
      XCTAssertEqual(backing?.bonusAmount, 5.0)
      XCTAssertEqual(backing?.cancelable, true)
      XCTAssertEqual(backing?.id, decompose(id: "QmFja2luZy0xNDQ5NTI3MTc="))
      XCTAssertEqual(backing?.locationId, decompose(id: "TG9jYXRpb24tMjM0MjQ3NzU="))
      XCTAssertEqual(backing?.locationName, "Canada")
      XCTAssertEqual(backing?.paymentSource?.type, .visa)
      XCTAssertEqual(backing?.pledgedAt, 1_625_613_342.0)
      XCTAssertEqual(backing?.projectCountry, "US")
      XCTAssertEqual(backing?.projectId, 1_596_594_463)
      XCTAssertNotNil(backing?.reward)
      XCTAssertEqual(backing?.rewardId, 8_173_901)
      XCTAssertEqual(backing?.sequence, 148)
      XCTAssertEqual(backing?.shippingAmount, 10.0)
      XCTAssertEqual(backing?.status, .pledged)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }

  func test_noReward() {
    do {
      var dict = backingDictionary()
      dict["addOns"] = NSNull()
      dict["reward"] = NSNull()

      let fragment = try GraphAPI.BackingFragment(jsonObject: dict)
      XCTAssertNotNil(fragment)

      let backing = Backing.backing(from: fragment)
      XCTAssertNotNil(backing)
      XCTAssertEqual(backing?.reward?.isNoReward, true)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
}

private func backingDictionary() -> [String: Any] {
  let json = """
  {
    "__typename": "Backing",
    "addOns": {
      "__typename": "RewardTotalCountConnection",
      "nodes": [
        {
          "__typename": "Reward",
          "amount": {
            "__typename": "Money",
            "amount": "30.0",
            "currency": "USD",
            "symbol": "$"
          },
          "backersCount": 2,
          "convertedAmount": {
            "__typename": "Money",
            "amount": "37.0",
            "currency": "CAD",
            "symbol": "$"
          },
          "description": "",
          "displayName": "Art of the Quietly Quixotic ($30)",
          "endsAt": null,
          "estimatedDeliveryOn": "2021-12-01",
          "id": "UmV3YXJkLTgxNzM5Mjg=",
          "isMaxPledge": false,
          "items": {
            "__typename": "RewardItemsConnection",
            "nodes": [
              {
                "__typename": "RewardItem",
                "id": "UmV3YXJkSXRlbS0xMTcwODA4",
                "name": "Art Book (8.5x11)"
              }
            ]
          },
          "limit": null,
          "limitPerBacker": 10,
          "name": "Art of the Quietly Quixotic",
          "remainingQuantity": null,
          "shippingPreference": "unrestricted",
          "shippingRules": [
            {
              "__typename": "ShippingRule",
              "cost": {
                "__typename": "Money",
                "amount": "0.0",
                "currency": "USD",
                "symbol": "$"
              },
              "id": "U2hpcHBpbmdSdWxlLTExNDEzMzg0",
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
              "id": "U2hpcHBpbmdSdWxlLTExMjc4ODEw",
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
        },
        {
          "__typename": "Reward",
          "amount": {
            "__typename": "Money",
            "amount": "10.0",
            "currency": "USD",
            "symbol": "$"
          },
          "backersCount": 23,
          "convertedAmount": {
            "__typename": "Money",
            "amount": "13.0",
            "currency": "CAD",
            "symbol": "$"
          },
          "description": "A 160 page coloring book and tarot journal with all 78 cards available for your enjoyment!",
          "displayName": "Wee William Journal & Coloring Book ($10)",
          "endsAt": null,
          "estimatedDeliveryOn": "2021-12-01",
          "id": "UmV3YXJkLTgyNDgxOTM=",
          "isMaxPledge": false,
          "items": {
            "__typename": "RewardItemsConnection",
            "nodes": []
          },
          "limit": null,
          "limitPerBacker": 10,
          "name": "Wee William Journal & Coloring Book",
          "remainingQuantity": null,
          "shippingPreference": "unrestricted",
          "shippingRules": [
            {
              "__typename": "ShippingRule",
              "cost": {
                "__typename": "Money",
                "amount": "0.0",
                "currency": "USD",
                "symbol": "$"
              },
              "id": "U2hpcHBpbmdSdWxlLTExNDY2NTM4",
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
              "id": "U2hpcHBpbmdSdWxlLTExNDY2NTM5",
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
        },
        {
          "__typename": "Reward",
          "amount": {
            "__typename": "Money",
            "amount": "10.0",
            "currency": "USD",
            "symbol": "$"
          },
          "backersCount": 23,
          "convertedAmount": {
            "__typename": "Money",
            "amount": "13.0",
            "currency": "CAD",
            "symbol": "$"
          },
          "description": "A 160 page coloring book and tarot journal with all 78 cards available for your enjoyment!",
          "displayName": "Wee William Journal & Coloring Book ($10)",
          "endsAt": null,
          "estimatedDeliveryOn": "2021-12-01",
          "id": "UmV3YXJkLTgyNDgxOTM=",
          "isMaxPledge": false,
          "items": {
            "__typename": "RewardItemsConnection",
            "nodes": []
          },
          "limit": null,
          "limitPerBacker": 10,
          "name": "Wee William Journal & Coloring Book",
          "remainingQuantity": null,
          "shippingPreference": "unrestricted",
          "shippingRules": [
            {
              "__typename": "ShippingRule",
              "cost": {
                "__typename": "Money",
                "amount": "0.0",
                "currency": "USD",
                "symbol": "$"
              },
              "id": "U2hpcHBpbmdSdWxlLTExNDY2NTM4",
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
              "id": "U2hpcHBpbmdSdWxlLTExNDY2NTM5",
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
        },
        {
          "__typename": "Reward",
          "amount": {
            "__typename": "Money",
            "amount": "10.0",
            "currency": "USD",
            "symbol": "$"
          },
          "backersCount": 23,
          "convertedAmount": {
            "__typename": "Money",
            "amount": "13.0",
            "currency": "CAD",
            "symbol": "$"
          },
          "description": "A 160 page coloring book and tarot journal with all 78 cards available for your enjoyment!",
          "displayName": "Wee William Journal & Coloring Book ($10)",
          "endsAt": null,
          "estimatedDeliveryOn": "2021-12-01",
          "id": "UmV3YXJkLTgyNDgxOTM=",
          "isMaxPledge": false,
          "items": {
            "__typename": "RewardItemsConnection",
            "nodes": []
          },
          "limit": null,
          "limitPerBacker": 10,
          "name": "Wee William Journal & Coloring Book",
          "remainingQuantity": null,
          "shippingPreference": "unrestricted",
          "shippingRules": [
            {
              "__typename": "ShippingRule",
              "cost": {
                "__typename": "Money",
                "amount": "0.0",
                "currency": "USD",
                "symbol": "$"
              },
              "id": "U2hpcHBpbmdSdWxlLTExNDY2NTM4",
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
              "id": "U2hpcHBpbmdSdWxlLTExNDY2NTM5",
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
      ]
    },
    "amount": {
      "__typename": "Money",
      "amount": "90.0",
      "currency": "USD",
      "symbol": "$"
    },
    "backer": {
      "__typename": "User",
      "id": "VXNlci0xMTA4OTI0NjQw",
      "imageUrl": "https://ksr-qa-ugc.imgix.net/assets/014/148/024/902b3aee57c0325f82d93af888194c5e_original.png?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1476734758&auto=format&frame=1&q=92&s=81a3c902ee2131666a590702b71ba5c2",
      "isCreator": false,
      "name": "Justin Swart",
      "uid": "1108924640"
    },
    "backerCompleted": false,
    "bonusAmount": {
      "__typename": "Money",
      "amount": "5.0",
      "currency": "USD",
      "symbol": "$"
    },
    "cancelable": true,
    "creditCard": {
      "__typename": "CreditCard",
      "expirationDate": "2033-03-01",
      "id": "69021181",
      "lastFour": "4242",
      "paymentType": "CREDIT_CARD",
      "state": "ACTIVE",
      "type": "VISA"
    },
    "id": "QmFja2luZy0xNDQ5NTI3MTc=",
    "location": {
      "__typename": "Location",
      "country": "CA",
      "countryName": "Canada",
      "displayableName": "Canada",
      "id": "TG9jYXRpb24tMjM0MjQ3NzU=",
      "name": "Canada"
    },
    "pledgedOn": 1625613342,
    "project": {
      "__typename": "Project",
      "actions": {
        "__typename": "ProjectActions",
        "displayConvertAmount": false
      },
      "backersCount": 135,
      "category": {
        "__typename": "Category",
        "id": "Q2F0ZWdvcnktNDc=",
        "name": "Fiction",
        "parentCategory": {
          "__typename": "Category",
          "id": "Q2F0ZWdvcnktMTg=",
          "name": "Publishing"
        }
      },
      "country": {
        "__typename": "Country",
        "code": "US",
        "name": "the United States"
      },
      "creator": {
        "__typename": "User",
        "id": "VXNlci02MzE4MTEzODc=",
        "imageUrl": "https://ksr-qa-ugc.imgix.net/assets/026/582/411/0064c9eba577b99cbb09d9bb197e215a_original.jpeg?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1617736562&auto=format&frame=1&q=92&s=085218a7258d22c455492bed76f5433a",
        "isCreator": null,
        "name": "Hugh Alan Samples",
        "uid": "631811387"
      },
      "currency": "USD",
      "deadlineAt": 1620478771,
      "description": "Dark Fantasy Novel & Tarot Cards",
      "finalCollectionDate": null,
      "fxRate": 1.23244501,
      "goal": {
        "__typename": "Money",
        "amount": "3000.0",
        "currency": "USD",
        "symbol": "$"
      },
      "image": {
        "__typename": "Photo",
        "id": "UGhvdG8tMzI0NTYxMDE=",
        "url": "https://ksr-qa-ugc.imgix.net/assets/032/456/101/d32b5e2097301e5ccf4aa1e4f0be9086_original.tiff?ixlib=rb-4.0.2&crop=faces&w=1024&h=576&fit=crop&v=1613880671&auto=format&frame=1&q=92&s=617def65783295f2dabdff1b39005eca"
      },
      "isProjectWeLove": true,
      "launchedAt": 1617886771,
      "location": {
        "__typename": "Location",
        "country": "US",
        "countryName": "United States",
        "displayableName": "Henderson, KY",
        "id": "TG9jYXRpb24tMjQxOTk0NA==",
        "name": "Henderson"
      },
      "name": "WEE WILLIAM WITCHLING",
      "pid": 1596594463,
      "pledged": {
        "__typename": "Money",
        "amount": "9841.0",
        "currency": "USD",
        "symbol": "$"
      },
      "slug": "parliament-of-rooks/wee-william-witchling",
      "state": "LIVE",
      "stateChangedAt": 1617886773,
      "url": "https://staging.kickstarter.com/projects/parliament-of-rooks/wee-william-witchling",
      "usdExchangeRate": 1
    },
    "reward": {
      "__typename": "Reward",
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
      "description": "",
      "displayName": "Soft Cover Book (Signed) ($25)",
      "endsAt": null,
      "estimatedDeliveryOn": "2021-12-01",
      "id": "UmV3YXJkLTgxNzM5MDE=",
      "isMaxPledge": false,
      "items": {
        "__typename": "RewardItemsConnection",
        "nodes": [
          {
            "__typename": "RewardItem",
            "id": "UmV3YXJkSXRlbS0xMTcwNzk5",
            "name": "Soft-Cover Book (Signed)"
          },
          {
            "__typename": "RewardItem",
            "id": "UmV3YXJkSXRlbS0xMTcwODEz",
            "name": "Custom Bookmark"
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
      "shippingPreference": "unrestricted",
      "shippingRules": [
        {
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
    },
    "sequence": 148,
    "shippingAmount": {
      "__typename": "Money",
      "amount": "10.0",
      "currency": "USD",
      "symbol": "$"
    },
    "status": "pledged"
  }
  """

  let data = Data(json.utf8)
  return (try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) ?? [:]
}
