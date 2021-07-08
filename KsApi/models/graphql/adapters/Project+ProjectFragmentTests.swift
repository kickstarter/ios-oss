@testable import KsApi
import XCTest

final class Project_ProjectFragmentTests: XCTestCase {
  func test() {
    do {
      let dict = self.projectDictionary()

      let addOns = (dict["addOns"] as? [String: [[String: Any]]])?["nodes"]?
        .compactMap { try? GraphAPI.RewardFragment(jsonObject: $0) }
        .compactMap { Reward.reward(from: $0) }
      let rewards = (dict["rewards"] as? [String: [[String: Any]]])?["nodes"]?
        .compactMap { try? GraphAPI.RewardFragment(jsonObject: $0) }
        .compactMap { Reward.reward(from: $0) } ?? []

      let fragment = try GraphAPI.ProjectFragment(jsonObject: self.projectDictionary())
      XCTAssertNotNil(fragment)

      let project = Project.project(
        from: fragment,
        rewards: rewards,
        addOns: addOns
      )

      XCTAssertNotNil(project)
      XCTAssertEqual(project?.addOns?.count, 2)
      XCTAssertEqual(project?.rewards.count, 2)
    } catch {
      XCTFail(error.localizedDescription)
    }

    XCTAssertNotNil(Project.project(from: .template))
  }

  private func projectDictionary() -> [String: Any] {
    let json = """
    {
      "__typename": "Project",
      "actions": {
        "__typename": "ProjectActions",
        "displayConvertAmount": false
      },
      "backersCount": 136,
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
      "fxRate": 1.25195501,
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
        "amount": "9893.0",
        "currency": "USD",
        "symbol": "$"
      },
      "addOns": {
        "nodes": [
          {
            "__typename": "Reward",
            "amount": {
              "__typename": "Money",
              "amount": "10.0",
              "currency": "USD",
              "symbol": "$"
            },
            "backersCount": 26,
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
              "amount": "25.0",
              "currency": "USD",
              "symbol": "$"
            },
            "backersCount": 21,
            "convertedAmount": {
              "__typename": "Money",
              "amount": "32.0",
              "currency": "CAD",
              "symbol": "$"
            },
            "description": "Add the soft bound edition to an existing reward tier!",
            "displayName": "Soft-cover signed Book ($25)",
            "endsAt": null,
            "estimatedDeliveryOn": "2021-12-01",
            "id": "UmV3YXJkLTgyMjcyOTM=",
            "isMaxPledge": false,
            "items": {
              "__typename": "RewardItemsConnection",
              "nodes": []
            },
            "limit": null,
            "limitPerBacker": 10,
            "name": "Soft-cover signed Book",
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
                "id": "U2hpcHBpbmdSdWxlLTExNDEzMzgz",
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
                "id": "U2hpcHBpbmdSdWxlLTExNDA2OTkz",
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
      "rewards": {
        "nodes": [
          {
            "__typename": "Reward",
            "amount": {
              "__typename": "Money",
              "amount": "10.0",
              "currency": "USD",
              "symbol": "$"
            },
            "backersCount": 7,
            "convertedAmount": {
              "__typename": "Money",
              "amount": "13.0",
              "currency": "CAD",
              "symbol": "$"
            },
            "description": "",
            "displayName": "Digital Copy ($10)",
            "endsAt": null,
            "estimatedDeliveryOn": "2021-12-01",
            "id": "UmV3YXJkLTgxNzM4OTk=",
            "isMaxPledge": false,
            "items": {
              "__typename": "RewardItemsConnection",
              "nodes": [
                {
                  "__typename": "RewardItem",
                  "id": "UmV3YXJkSXRlbS0xMTcwNzk2",
                  "name": "Wee William Witchling (PDF) Digital Copy"
                }
              ]
            },
            "limit": null,
            "limitPerBacker": 1,
            "name": "Digital Copy",
            "project": {
            "__typename": "Project",
              "id": "UHJvamVjdC0xNTk2NTk0NDYz"
            },
            "remainingQuantity": null,
            "shippingPreference": "none",
            "shippingRules": [],
            "startsAt": null
          },
          {
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
              "amount": "32.0",
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
          }
        ]
      },
      "slug": "parliament-of-rooks/wee-william-witchling",
      "state": "LIVE",
      "stateChangedAt": 1617886773,
      "url": "https://staging.kickstarter.com/projects/parliament-of-rooks/wee-william-witchling",
      "usdExchangeRate": 1
    }
    """

    let data = Data(json.utf8)
    return (try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) ?? [:]
  }
}
