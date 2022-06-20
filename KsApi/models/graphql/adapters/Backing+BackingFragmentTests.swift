import Apollo
@testable import KsApi
import XCTest

final class Backing_BackingFragmentTests: XCTestCase {
  func test() {
    do {
      let variables = [
        "withStoredCards": true,
        "includeShippingRules": true,
        "includeLocalPickup": true
      ]
      let fragment = try GraphAPI.BackingFragment(jsonObject: backingDictionary(), variables: variables)
      XCTAssertNotNil(fragment)

      guard let backing = Backing.backing(from: fragment) else {
        XCTFail("Backing should created from fragment")

        return
      }

      XCTAssertNotNil(backing)
      XCTAssertEqual(backing.amount, 90.0)
      XCTAssertNotNil(backing.backer)
      XCTAssertNotNil(backing.backerId)
      XCTAssertEqual(backing.backerCompleted, false)
      XCTAssertEqual(backing.bonusAmount, 5.0)
      XCTAssertEqual(backing.cancelable, true)
      XCTAssertEqual(backing.id, decompose(id: "QmFja2luZy0xNDQ5NTI3MTc="))
      XCTAssertEqual(backing.locationId, decompose(id: "TG9jYXRpb24tMjM0MjQ3NzU="))
      XCTAssertEqual(backing.locationName, "Canada")
      XCTAssertEqual(backing.paymentSource?.type, .visa)
      XCTAssertEqual(backing.pledgedAt, 1_625_613_342.0)
      XCTAssertEqual(backing.projectCountry, "US")
      XCTAssertEqual(backing.projectId, 1_596_594_463)
      XCTAssertNotNil(backing.reward)
      XCTAssertEqual(backing.rewardId, decompose(id: "UmV3YXJkLTgxNzM5MDE="))
      XCTAssertEqual(backing.sequence, 148)
      XCTAssertEqual(backing.shippingAmount, 10.0)
      XCTAssertEqual(backing.status, .pledged)

      guard let reward = backing.reward else {
        XCTFail("reward should exist")

        return
      }

      XCTAssertTrue(reward.hasAddOns)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }

  func test_noReward() {
    do {
      let variables = [
        "withStoredCards": true,
        "includeShippingRules": true
      ]
      var dict = backingDictionary()
      dict["addOns"] = NSNull()
      dict["reward"] = NSNull()

      let fragment = try GraphAPI.BackingFragment(jsonObject: dict, variables: variables)
      XCTAssertNotNil(fragment)

      let backing = Backing.backing(from: fragment)
      XCTAssertNotNil(backing)
      XCTAssertEqual(backing?.reward?.isNoReward, true)
      XCTAssertEqual(backing?.reward?.convertedMinimum, 1.23244501)
      XCTAssertEqual(backing?.reward?.minimum, 1.0)
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
          "allowedAddons": {
             "__typename": "RewardConnection",
             "pageInfo": {
               "__typename": "PageInfo",
               "startCursor": null
             }
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
            "edges": [
              {
                "__typename": "RewardItemEdge",
                "quantity": 1,
                "node": {
                  "__typename": "RewardItem",
                  "id": "UmV3YXJkSXRlbS0xMTcwODA4",
                  "name":"Art Book (8.5x11)"
                }
              }
            ]
          },
          "localReceiptLocation": null,
          "limit": null,
          "limitPerBacker": 10,
          "name": "Art of the Quietly Quixotic",
          "remainingQuantity": null,
          "shippingPreference": "unrestricted",
          "shippingSummary": "Ships worldwide",
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
          "allowedAddons": {
            "__typename": "RewardConnection",
             "pageInfo": {
               "__typename": "PageInfo",
               "startCursor": null
             }
          },
          "localReceiptLocation": null,
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
            "edges": []
          },
          "limit": null,
          "limitPerBacker": 10,
          "name": "Wee William Journal & Coloring Book",
          "remainingQuantity": null,
          "shippingPreference": "unrestricted",
          "shippingSummary": "Ships worldwide",
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
          "localReceiptLocation": null,
          "allowedAddons": {
            "__typename": "RewardConnection",
            "pageInfo": {
              "__typename": "PageInfo",
              "startCursor": null
            }
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
            "edges": []
          },
          "limit": null,
          "limitPerBacker": 10,
          "name": "Wee William Journal & Coloring Book",
          "remainingQuantity": null,
          "shippingPreference": "unrestricted",
          "shippingSummary": "Ships worldwide",
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
          "localReceiptLocation": null,
          "allowedAddons": {
            "__typename": "RewardConnection",
            "pageInfo": {
              "__typename": "PageInfo",
              "startCursor": null
            }
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
            "edges": []
          },
          "limit": null,
          "limitPerBacker": 10,
          "name": "Wee William Journal & Coloring Book",
          "remainingQuantity": null,
          "shippingPreference": "unrestricted",
          "shippingSummary": "Ships worldwide",
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
      "chosenCurrency": "USD",
      "backings":{
        "__typename": "UserBackingsConnection",
        "nodes":[
            {
              "__typename": "Backing",
              "errorReason":null
            },
            {
              "__typename": "Backing",
              "errorReason":"Something went wrong"
            },
            {
              "__typename": "Backing",
              "errorReason":null
            }
        ]
      },
      "backingsCount": 3,
      "email": "foo@bar.com",
      "createdProjects": {
        "__typename": "UserCreatedProjectsConnection",
        "totalCount": 16
      },
      "membershipProjects": {
        "__typename": "MembershipProjectsConnection",
        "totalCount": 10
      },
      "savedProjects": {
        "__typename": "UserSavedProjectsConnection",
        "totalCount": 11
      },
      "hasUnreadMessages": false,
      "hasUnseenActivity": true,
      "surveyResponses": {
        "__typename": "SurveyResponsesConnection",
         "totalCount": 2
      },
      "optedOutOfRecommendations": true,
      "hasPassword": true,
      "id": "VXNlci0xMTA4OTI0NjQw",
      "imageUrl": "https://ksr-qa-ugc.imgix.net/assets/014/148/024/902b3aee57c0325f82d93af888194c5e_original.png?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1476734758&auto=format&frame=1&q=92&s=81a3c902ee2131666a590702b71ba5c2",
      "isAppleConnected": false,
      "isCreator": false,
      "isDeliverable": true,
      "isEmailVerified": true,
      "isFacebookConnected": true,
      "isKsrAdmin": false,
      "isFollowing": true,
      "name": "Justin Swart",
      "isSocializing": true,
      "newsletterSubscriptions": null,
      "notifications": null,
      "needsFreshFacebookToken": true,
      "showPublicProfile": true,
      "location": {
        "__typename": "Location",
        "country": "US",
        "countryName": "United States",
        "displayableName": "Las Vegas, NV",
        "id": "TG9jYXRpb24tMjQzNjcwNA==",
        "name": "Las Vegas"
      },
      "storedCards": {
        "__typename": "UserCreditCardTypeConnection",
        "nodes": [
          {
          "__typename": "CreditCard",
            "expirationDate": "2023-01-01",
            "id": "6",
            "lastFour": "4242",
            "type": "VISA"
          }
        ],
        "totalCount": 1
      },
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
      "availableCardTypes": [
          "VISA",
          "MASTERCARD",
          "AMEX"
      ],
      "backersCount": 135,
      "backing": {
        "__typename": "Backing",
        "backer": {
          "__typename": "User",
          "uid": "618005886",
          "isSocializing": true,
          "newsletterSubcriptions": null,
          "notifications": null
        }
      },
      "category": {
        "__typename": "Category",
        "id": "Q2F0ZWdvcnktNDc=",
        "name": "Fiction",
        "analyticsName": "Comic Books",
        "parentCategory": {
          "__typename": "Category",
          "id": "Q2F0ZWdvcnktMTg=",
          "name": "Publishing",
          "analyticsName": "Publishing"
        }
      },
      "story": "API returns this as HTML wrapped in a string. But here HTML breaks testing because the serializer does not recognize escape characters within a string.",
      "environmentalCommitments": [
        {
          "__typename": "EnvironmentalCommitment",
          "commitmentCategory": "longLastingDesign",
          "description": "High quality materials and cards - there is nothing design or tech-wise that would render Dustbiters obsolete besides losing the cards.",
          "id": "RW52aXJvbm1lbnRhbENvbW1pdG1lbnQtMTI2NTA2"
        }
      ],
      "faqs": {
        "__typename": "ProjectFaqConnection",
        "nodes": [
          {
            "__typename": "ProjectFaq",
            "question": "Are you planning any expansions for Dustbiters?",
            "answer": "This may sound weird in the world of big game boxes with hundreds of tokens, cards and thick manuals, but through years of playtesting and refinement we found our ideal experience is these 21 unique cards we have now. Dustbiters is balanced for quick and furious games with different strategies every time you jump back in, and we currently have no plans to mess with that.",
            "id": "UHJvamVjdEZhcS0zNzA4MDM=",
            "createdAt": 1628103400
          }
        ]
      },
      "risks": "As with any project of this nature, there are always some risks involved with manufacturing and shipping. That's why we're collaborating with the iam8bit team, they have many years of experience producing and delivering all manner of items to destinations all around the world. We do not expect any delays or hiccups with reward fulfillment. But if anything comes up, we will be clear and communicative about what is happening and how it might affect you.",
      "canComment": false,
      "commentsCount": 0,
      "country": {
        "__typename": "Country",
        "code": "US",
        "name": "the United States"
      },
      "creator": {
        "__typename": "User",
        "chosenCurrency": "USD",
        "backings":{
          "__typename": "UserBackingsConnection",
          "nodes":[
              {
                "__typename": "Backing",
                "errorReason":null
              },
              {
                "__typename": "Backing",
                "errorReason":"Something went wrong"
              },
              {
                "__typename": "Backing",
                "errorReason":null
              }
          ]
        },
        "backingsCount": 23,
        "email": "foo@bar.com",
        "hasPassword": true,
        "id": "VXNlci02MzE4MTEzODc=",
        "imageUrl": "https://ksr-qa-ugc.imgix.net/assets/026/582/411/0064c9eba577b99cbb09d9bb197e215a_original.jpeg?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1617736562&auto=format&frame=1&q=92&s=085218a7258d22c455492bed76f5433a",
        "isAppleConnected": false,
        "isCreator": null,
        "isDeliverable": true,
        "isEmailVerified": true,
        "isFacebookConnected": true,
        "isKsrAdmin": false,
        "isFollowing": true,
        "name": "Hugh Alan Samples",
        "newsletterSubscriptions": null,
        "notifications": null,
        "isSocializing": true,
        "needsFreshFacebookToken": true,
        "showPublicProfile": true,
        "location": {
          "__typename": "Location",
          "country": "US",
          "countryName": "United States",
          "displayableName": "Las Vegas, NV",
          "id": "TG9jYXRpb24tMjQzNjcwNA==",
          "name": "Las Vegas"
        },
        "createdProjects": {
          "__typename": "UserCreatedProjectsConnection",
          "totalCount": 16
        },
        "membershipProjects": {
          "__typename": "MembershipProjectsConnection",
          "totalCount": 10
        },
        "savedProjects": {
          "__typename": "UserSavedProjectsConnection",
          "totalCount": 11
        },
        "hasUnreadMessages": false,
        "hasUnseenActivity": true,
        "surveyResponses": {
          "__typename": "SurveyResponsesConnection",
          "totalCount": 2
        },
        "optedOutOfRecommendations": true,
        "storedCards": {
          "__typename": "UserCreditCardTypeConnection",
          "nodes": [
            {
            "__typename": "CreditCard",
              "expirationDate": "2023-01-01",
              "id": "6",
              "lastFour": "4242",
              "type": "VISA"
            }
          ],
          "totalCount": 1
        },
        "uid": "631811387"
      },
      "currency": "USD",
      "deadlineAt": 1620478771,
      "description": "Dark Fantasy Novel & Tarot Cards",
      "finalCollectionDate": null,
      "friends": {
        "__typename": "ProjectBackerFriendsConnection",
        "nodes": []
      },
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
      "isProjectOfTheDay": false,
      "isWatched": false,
      "launchedAt": 1617886771,
      "isLaunched": true,
      "location": {
        "__typename": "Location",
        "country": "US",
        "countryName": "United States",
        "displayableName": "Henderson, KY",
        "id": "TG9jYXRpb24tMjQxOTk0NA==",
        "name": "Henderson"
      },
      "maxPledge": 8500,
      "minPledge": 1,
      "name": "WEE WILLIAM WITCHLING",
      "pid": 1596594463,
      "pledged": {
        "__typename": "Money",
        "amount": "9841.0",
        "currency": "USD",
        "symbol": "$"
      },
      "posts": {
        "__typename": "PostConnection",
        "totalCount": 3
      },
      "prelaunchActivated": true,
      "slug": "parliament-of-rooks/wee-william-witchling",
      "state": "LIVE",
      "stateChangedAt": 1617886773,
      "tags": [
        {
          "__typename": "Tag",
          "name": "LGBTQIA+"
        }
      ],
      "url": "https://staging.kickstarter.com/projects/parliament-of-rooks/wee-william-witchling",
      "usdExchangeRate": 1,
      "video": {
        "__typename": "Video",
        "id": "VmlkZW8tMTExNjQ0OA==",
        "videoSources": {
          "__typename": "VideoSources",
          "high": {
            "__typename": "VideoSourceInfo",
            "src": "https://v.kickstarter.com/1631480664_a23b86f39dcfa7b0009309fa0f668ceb5e13b8a8/projects/4196183/video-1116448-h264_high.mp4"
          },
          "hls": {
            "__typename": "VideoSourceInfo",
            "src": "https://v.kickstarter.com/1631480664_a23b86f39dcfa7b0009309fa0f668ceb5e13b8a8/projects/4196183/video-1116448-hls_playlist.m3u8"
          }
        }
      }
    },
    "reward": {
      "__typename": "Reward",
      "amount": {
        "__typename": "Money",
        "amount": "25.0",
        "currency": "USD",
        "symbol": "$"
      },
      "localReceiptLocation": null,
      "allowedAddons": {
        "__typename": "RewardConnection",
        "pageInfo": {
          "__typename": "PageInfo",
          "startCursor": "WzIsODMzNzczN10="
        }
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
        "edges": [
          {
            "__typename": "RewardItemEdge",
            "quantity": 1,
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
              "id": "UmV3YXJkSXRlbS0xMjY0ODAz",
              "name": "GALLERY PRINT (30x45cm)"
            }
          }
        ]
      },
      "limit": null,
      "limitPerBacker": 1,
      "name": "Soft Cover Book (Signed)",
      "project": {
        "__typename": "Project",
        "id": "UHJvamVjdC0xNTk2NTk0NDYz",
        "friends": {
          "__typename": "ProjectBackerFriendsConnection",
          "nodes": []
        },
        "isWatched": false
      },
      "remainingQuantity": null,
      "shippingPreference": "unrestricted",
      "shippingSummary": "Ships worldwide",
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

  var resultMap = (try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) ?? [:]

  resultMap["environmentalCommitments"] =
    [[
      "__typename": "EnvironmentalCommitment",
      "commitmentCategory": GraphAPI.EnvironmentalCommitmentCategory.longLastingDesign,
      "description": "High quality materials and cards - there is nothing design or tech-wise that would render Dustbiters obsolete besides losing the cards.",
      "id": "RW52aXJvbm1lbnRhbENvbW1pdG1lbnQtMTI2NTA2"
    ]]

  return resultMap
}
