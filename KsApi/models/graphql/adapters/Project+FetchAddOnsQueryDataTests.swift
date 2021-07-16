import Apollo
@testable import KsApi
import XCTest

final class Project_FetchAddOnsQueryDataTests: XCTestCase {
  func test() {
    do {
      let fragment = try GraphAPI.ProjectFragment(jsonObject: self.projectDictionary())
      XCTAssertNotNil(fragment)

      let project = Project.project(from: fragment)
      XCTAssertEqual(project?.memberData.permissions.count, 6)
      XCTAssertNotNil(project)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }

  private func projectDictionary() -> [String: Any] {
    let json = """
    {
      "__typename": "Project",
      "addOns": {
        "__typename": "ProjectRewardConnection",
        "nodes": [
          {
            "__typename": "Reward",
            "shippingRulesExpanded": {
              "__typename": "RewardShippingRulesConnection",
              "nodes": [
                {
                  "__typename": "ShippingRule",
                  "cost": {
                    "__typename": "Money",
                    "amount": "0.0",
                    "currency": null,
                    "symbol": null
                  },
                  "id": "U2hpcHBpbmdSdWxlLQ==",
                  "location": {
                    "__typename": "Location",
                    "country": "EE",
                    "countryName": "Estonia",
                    "displayableName": "Estonia",
                    "id": "TG9jYXRpb24tMjM0MjQ4MDU=",
                    "name": "Estonia"
                  }
                }
              ]
            },
            "amount": {
              "__typename": "Money",
              "amount": "4.0",
              "currency": "AUD",
              "symbol": "$"
            },
            "backersCount": 9,
            "convertedAmount": {
              "__typename": "Money",
              "amount": "4.0",
              "currency": "CAD",
              "symbol": "$"
            },
            "description": "Translucent Sticker Sheet",
            "displayName": "Paper Sticker Sheet (AU$ 4)",
            "endsAt": null,
            "estimatedDeliveryOn": "2021-06-01",
            "id": "UmV3YXJkLTgxOTAzMjA=",
            "isMaxPledge": false,
            "items": {
              "__typename": "RewardItemsConnection",
              "nodes": [
                {
                  "__typename": "RewardItem",
                  "id": "UmV3YXJkSXRlbS0xMTc5OTgz",
                  "name": "Paper Sticker Sheet"
                }
              ]
            },
            "limit": null,
            "limitPerBacker": 10,
            "name": "Paper Sticker Sheet",
            "project": {
              "__typename": "Project",
              "id": "UHJvamVjdC0xNjA2NTMyODgx"
            },
            "remainingQuantity": null,
            "shippingPreference": "unrestricted",
            "shippingRules": [
              {
                "__typename": "ShippingRule",
                "cost": {
                  "__typename": "Money",
                  "amount": "0.0",
                  "currency": "AUD",
                  "symbol": "$"
                },
                "id": "U2hpcHBpbmdSdWxlLTExMzIxNDA2",
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
                  "currency": "AUD",
                  "symbol": "$"
                },
                "id": "U2hpcHBpbmdSdWxlLTExMzIxNDA3",
                "location": {
                  "__typename": "Location",
                  "country": "AU",
                  "countryName": "Australia",
                  "displayableName": "Australia",
                  "id": "TG9jYXRpb24tMjM0MjQ3NDg=",
                  "name": "Australia"
                }
              }
            ],
            "startsAt": null
          },
          {
            "__typename": "Reward",
            "shippingRulesExpanded": {
              "__typename": "RewardShippingRulesConnection",
              "nodes": [
                {
                  "__typename": "ShippingRule",
                  "cost": {
                    "__typename": "Money",
                    "amount": "0.0",
                    "currency": null,
                    "symbol": null
                  },
                  "id": "U2hpcHBpbmdSdWxlLQ==",
                  "location": {
                    "__typename": "Location",
                    "country": "EE",
                    "countryName": "Estonia",
                    "displayableName": "Estonia",
                    "id": "TG9jYXRpb24tMjM0MjQ4MDU=",
                    "name": "Estonia"
                  }
                }
              ]
            },
            "amount": {
              "__typename": "Money",
              "amount": "8.0",
              "currency": "AUD",
              "symbol": "$"
            },
            "backersCount": 2,
            "convertedAmount": {
              "__typename": "Money",
              "amount": "8.0",
              "currency": "CAD",
              "symbol": "$"
            },
            "description": "Boxed paper tape of 1x 20mm deco tape.",
            "displayName": "Hedgerow Paper Tape (20mm) (AU$ 8)",
            "endsAt": null,
            "estimatedDeliveryOn": "2021-06-01",
            "id": "UmV3YXJkLTgxOTc0NDQ=",
            "isMaxPledge": false,
            "items": {
              "__typename": "RewardItemsConnection",
              "nodes": [
                {
                  "__typename": "RewardItem",
                  "id": "UmV3YXJkSXRlbS0xMTc5OTgx",
                  "name": "Paper Tape Boxed Set"
                }
              ]
            },
            "limit": null,
            "limitPerBacker": 10,
            "name": "Hedgerow Paper Tape (20mm)",
            "project": {
              "__typename": "Project",
              "id": "UHJvamVjdC0xNjA2NTMyODgx"
            },
            "remainingQuantity": null,
            "shippingPreference": "restricted",
            "shippingRules": [
              {
                "__typename": "ShippingRule",
                "cost": {
                  "__typename": "Money",
                  "amount": "0.0",
                  "currency": "AUD",
                  "symbol": "$"
                },
                "id": "U2hpcHBpbmdSdWxlLTExMzM3OTE1",
                "location": {
                  "__typename": "Location",
                  "country": "AU",
                  "countryName": "Australia",
                  "displayableName": "Australia",
                  "id": "TG9jYXRpb24tMjM0MjQ3NDg=",
                  "name": "Australia"
                }
              },
              {
                "__typename": "ShippingRule",
                "cost": {
                  "__typename": "Money",
                  "amount": "0.0",
                  "currency": "AUD",
                  "symbol": "$"
                },
                "id": "U2hpcHBpbmdSdWxlLTExMzM3OTIx",
                "location": {
                  "__typename": "Location",
                  "country": "CA",
                  "countryName": "Canada",
                  "displayableName": "Canada",
                  "id": "TG9jYXRpb24tMjM0MjQ3NzU=",
                  "name": "Canada"
                }
              },
              {
                "__typename": "ShippingRule",
                "cost": {
                  "__typename": "Money",
                  "amount": "0.0",
                  "currency": "AUD",
                  "symbol": "$"
                },
                "id": "U2hpcHBpbmdSdWxlLTExMzM3OTE3",
                "location": {
                  "__typename": "Location",
                  "country": "CN",
                  "countryName": "China",
                  "displayableName": "China",
                  "id": "TG9jYXRpb24tMjM0MjQ3ODE=",
                  "name": "China"
                }
              },
              {
                "__typename": "ShippingRule",
                "cost": {
                  "__typename": "Money",
                  "amount": "0.0",
                  "currency": "AUD",
                  "symbol": "$"
                },
                "id": "U2hpcHBpbmdSdWxlLTExMzM3OTE4",
                "location": {
                  "__typename": "Location",
                  "country": "JP",
                  "countryName": "Japan",
                  "displayableName": "Japan",
                  "id": "TG9jYXRpb24tMjM0MjQ4NTY=",
                  "name": "Japan"
                }
              },
              {
                "__typename": "ShippingRule",
                "cost": {
                  "__typename": "Money",
                  "amount": "0.0",
                  "currency": "AUD",
                  "symbol": "$"
                },
                "id": "U2hpcHBpbmdSdWxlLTExMzM3OTE5",
                "location": {
                  "__typename": "Location",
                  "country": "KR",
                  "countryName": "Korea, Republic of",
                  "displayableName": "South Korea",
                  "id": "TG9jYXRpb24tMjM0MjQ4Njg=",
                  "name": "South Korea"
                }
              },
              {
                "__typename": "ShippingRule",
                "cost": {
                  "__typename": "Money",
                  "amount": "0.0",
                  "currency": "AUD",
                  "symbol": "$"
                },
                "id": "U2hpcHBpbmdSdWxlLTExMzM3OTIz",
                "location": {
                  "__typename": "Location",
                  "country": "MY",
                  "countryName": "Malaysia",
                  "displayableName": "Malaysia",
                  "id": "TG9jYXRpb24tMjM0MjQ5MDE=",
                  "name": "Malaysia"
                }
              },
              {
                "__typename": "ShippingRule",
                "cost": {
                  "__typename": "Money",
                  "amount": "0.0",
                  "currency": "AUD",
                  "symbol": "$"
                },
                "id": "U2hpcHBpbmdSdWxlLTExMzM3OTI1",
                "location": {
                  "__typename": "Location",
                  "country": "NZ",
                  "countryName": "New Zealand",
                  "displayableName": "New Zealand",
                  "id": "TG9jYXRpb24tMjM0MjQ5MTY=",
                  "name": "New Zealand"
                }
              },
              {
                "__typename": "ShippingRule",
                "cost": {
                  "__typename": "Money",
                  "amount": "0.0",
                  "currency": "AUD",
                  "symbol": "$"
                },
                "id": "U2hpcHBpbmdSdWxlLTExMzM3OTIw",
                "location": {
                  "__typename": "Location",
                  "country": "PH",
                  "countryName": "Philippines",
                  "displayableName": "Philippines",
                  "id": "TG9jYXRpb24tMjM0MjQ5MzQ=",
                  "name": "Philippines"
                }
              },
              {
                "__typename": "ShippingRule",
                "cost": {
                  "__typename": "Money",
                  "amount": "0.0",
                  "currency": "AUD",
                  "symbol": "$"
                },
                "id": "U2hpcHBpbmdSdWxlLTExMzM3OTI3",
                "location": {
                  "__typename": "Location",
                  "country": "RU",
                  "countryName": "Russia",
                  "displayableName": "Russia",
                  "id": "TG9jYXRpb24tMjM0MjQ5MzY=",
                  "name": "Russia"
                }
              },
              {
                "__typename": "ShippingRule",
                "cost": {
                  "__typename": "Money",
                  "amount": "0.0",
                  "currency": "AUD",
                  "symbol": "$"
                },
                "id": "U2hpcHBpbmdSdWxlLTExMzM3OTI0",
                "location": {
                  "__typename": "Location",
                  "country": "SG",
                  "countryName": "Singapore",
                  "displayableName": "Singapore",
                  "id": "TG9jYXRpb24tMjM0MjQ5NDg=",
                  "name": "Singapore"
                }
              },
              {
                "__typename": "ShippingRule",
                "cost": {
                  "__typename": "Money",
                  "amount": "0.0",
                  "currency": "AUD",
                  "symbol": "$"
                },
                "id": "U2hpcHBpbmdSdWxlLTExMzM3OTI2",
                "location": {
                  "__typename": "Location",
                  "country": "US",
                  "countryName": "United States",
                  "displayableName": "United States",
                  "id": "TG9jYXRpb24tMjM0MjQ5Nzc=",
                  "name": "United States"
                }
              },
              {
                "__typename": "ShippingRule",
                "cost": {
                  "__typename": "Money",
                  "amount": "0.0",
                  "currency": "AUD",
                  "symbol": "$"
                },
                "id": "U2hpcHBpbmdSdWxlLTExMzM3OTIy",
                "location": {
                  "__typename": "Location",
                  "country": "HK",
                  "countryName": "Hong Kong",
                  "displayableName": "Hong Kong",
                  "id": "TG9jYXRpb24tMjQ4NjU2OTg=",
                  "name": "Hong Kong"
                }
              },
              {
                "__typename": "ShippingRule",
                "cost": {
                  "__typename": "Money",
                  "amount": "0.0",
                  "currency": "AUD",
                  "symbol": "$"
                },
                "id": "U2hpcHBpbmdSdWxlLTExMzM3OTE2",
                "location": {
                  "__typename": "Location",
                  "country": "ZZ",
                  "countryName": null,
                  "displayableName": "European Union",
                  "id": "TG9jYXRpb24tNTU5NDkwNjg=",
                  "name": "European Union"
                }
              }
            ],
            "startsAt": null
          }
        ]
      },
      "actions": {
        "__typename": "ProjectActions",
        "displayConvertAmount": false
      },
      "backersCount": 46,
      "backing": {
        "__typename": "Backing",
        "backer": {
          "__typename": "User",
          "uid": "618005886"
        }
      },
      "category": {
        "__typename": "Category",
        "id": "Q2F0ZWdvcnktMjI=",
        "name": "Illustration",
        "parentCategory": {
          "__typename": "Category",
          "id": "Q2F0ZWdvcnktMQ==",
          "name": "Art"
        }
      },
      "collaboratorPermissions": [
        "edit_project",
        "edit_faq",
        "post",
        "comment",
        "view_pledges",
        "fulfillment"
      ],
      "country": {
        "__typename": "Country",
        "code": "AU",
        "name": "Australia"
      },
      "creator": {
        "__typename": "User",
        "id": "VXNlci0xNzA1MzA0MDA2",
        "imageUrl": "https://ksr-qa-ugc.imgix.net/assets/033/090/101/8667751e512228a62d426c77f6eb8a0b_original.jpg?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1618227451&auto=format&frame=1&q=92&s=36de925b6797139e096d7b6219f743d0",
        "isCreator": null,
        "name": "Peppermint Fox",
        "uid": "1705304006"
      },
      "currency": "AUD",
      "deadlineAt": 1622195758,
      "description": "Notebooks, paper tape and sticker sets from the Peppermint Fox Press, inspired by vintage books. For poets, planners, and storytellers.",
      "finalCollectionDate": null,
      "friends": {
        "__typename": "ProjectBackerFriendsConnection",
        "edges": []
      },
      "fxRate": 0.93110152,
      "goal": {
        "__typename": "Money",
        "amount": "1500.0",
        "currency": "AUD",
        "symbol": "$"
      },
      "image": {
        "__typename": "Photo",
        "id": "UGhvdG8tMzMzOTU0MTI=",
        "url": "https://ksr-qa-ugc.imgix.net/assets/033/395/412/618ee8bdcfcfd731cc0404270a79d98c_original.jpg?ixlib=rb-4.0.2&crop=faces&w=1024&h=576&fit=crop&v=1620193138&auto=format&frame=1&q=92&s=518067d52053dd4f523b5ced0bb1487d"
      },
      "isProjectWeLove": true,
      "isWatched": false,
      "launchedAt": 1619603758,
      "location": {
        "__typename": "Location",
        "country": "AU",
        "countryName": "Australia",
        "displayableName": "Launceston, AU",
        "id": "TG9jYXRpb24tMTEwMzM2OA==",
        "name": "Launceston"
      },
      "name": "Peppermint Fox Press: Notebooks & Stationery",
      "pid": 1606532881,
      "pledged": {
        "__typename": "Money",
        "amount": "6054.32",
        "currency": "AUD",
        "symbol": "$"
      },
      "slug": "peppermintfox/peppermint-fox-press-notebooks-and-stationery",
      "state": "LIVE",
      "stateChangedAt": 1619603760,
      "url": "https://staging.kickstarter.com/projects/peppermintfox/peppermint-fox-press-notebooks-and-stationery",
      "usdExchangeRate": 0.74641181
    }
    """

    let data = Data(json.utf8)
    return (try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) ?? [:]
  }
}
