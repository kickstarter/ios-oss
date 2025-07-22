import Apollo
import Foundation
import GraphAPI
@testable import KsApi

public enum FetchAddsOnsQueryTemplate {
  case valid
  case errored

  var data: GraphAPI.FetchAddOnsQuery.Data {
    switch self {
    case .valid:
      return try! testGraphObject(
        jsonString: self.validResultJSON,
        variables: [
          "includeShippingRules": true,
          "includeLocalPickup": true,
          "shippingEnabled": true
        ]
      )
    case .errored:
      return try! testGraphObject(jsonString: "{}")
    }
  }

  // MARK: Private Properties

  private var validResultJSON: String {
    return """
        {
          "project": {
            "__typename": "Project",
            "addOns": {
              "__typename": "ProjectRewardConnection",
              "nodes": [
                {
                  "__typename": "Reward",
                  "allowedAddons": {
                    "__typename": "RewardConnection",
                    "pageInfo": {
                      "__typename": "PageInfo",
                      "startCursor": null
                    }
                  },
                  "shippingRulesExpanded": {
                    "__typename": "RewardShippingRulesConnection",
                    "nodes": [
                      {
                        "__typename": "ShippingRule",
                        "cost": {
                          "__typename": "Money",
                          "amount": "2.0",
                          "currency": "AUD",
                          "symbol": "$"
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
                  "localReceiptLocation": {
                    "__typename": "Location",
                    "country": "US",
                    "countryName": "United States",
                    "displayableName": "San Jose, CA",
                    "id": "TG9jYXRpb24tMjQ4ODA0Mg==",
                    "name": "San Jose"
                  },
                  "description": "Translucent Sticker Sheet",
                  "displayName": "Paper Sticker Sheet (AU$ 4)",
                  "endsAt": null,
                  "estimatedDeliveryOn": "2021-06-01",
                  "id": "UmV3YXJkLTgxOTAzMjA=",
                  "isMaxPledge": false,
                  "available": false,
                  "items": {
                    "__typename": "RewardItemsConnection",
                    "edges": [
                      {
                        "__typename": "RewardItemEdge",
                        "quantity": 1,
                        "node": {
                          "__typename": "RewardItem",
                          "id": "UmV3YXJkSXRlbS0xMTc5OTgz",
                          "name": "Paper Sticker Sheet"
                        }
                      }
                    ]
                  },
                  "latePledgeAmount": {
                    "__typename": "Money",
                    "amount": "4.0",
                    "currency": "AUD",
                    "symbol": "$"
                  },
                  "limit": null,
                  "limitPerBacker": 10,
                  "name": "Paper Sticker Sheet",
                  "pledgeAmount": {
                    "__typename": "Money",
                    "amount": "4.0",
                    "currency": "AUD",
                    "symbol": "$"
                  },
                  "postCampaignPledgingEnabled": false,
                  "project": {
                    "__typename": "Project",
                    "id": "UHJvamVjdC0xNjA2NTMyODgx"
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
                      },
                      "backersCount": 0,
                      "hasBackers": false
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
                      },
                      "backersCount": 0,
                      "hasBackers": false
                    }
                  ],
                  "startsAt": null,
                  "audienceData": {
                    "__typename": "ResourceAudience",
                    "secret": false
                  }
                }
              ]
            },
            "availableCardTypes": [
              "VISA",
              "MASTERCARD",
              "AMEX"
            ],
            "backersCount": 46,
            "backing": {
              "__typename": "Backing",
              "backer": {
                "__typename": "User",
                "uid": "618005886"
              }
            },
            "sendMetaCapiEvents": false,
            "category": {
              "__typename": "Category",
              "id": "Q2F0ZWdvcnktMjI=",
              "name": "Illustration",
              "analyticsName": "Comic Books",
              "parentCategory": {
                "__typename": "Category",
                "id": "Q2F0ZWdvcnktMQ==",
                "name": "Art",
                "analyticsName": "Art"
              }
            },
            "canComment": false,
            "commentsCount": 5,
            "country": {
              "__typename": "Country",
              "code": "AU",
              "name": "Australia"
            },
            "creator": {
              "__typename": "User",
              "chosenCurrency": "USD",
              "backingsCount": 2,
              "email": "foo@bar.com",
              "hasPassword": true,
              "id": "VXNlci0xNzA1MzA0MDA2",
              "imageUrl": "https://i.kickstarter.com/assets/033/090/101/8667751e512228a62d426c77f6eb8a0b_original.jpg?anim=false&fit=crop&height=1024&origin=ugc-qa&q=92&width=1024&sig=rx0xtkeNd0nbjmCk7YUFmX6r9wC1ygRS%2BX8OkjVWg%2Bw%3D",
              "isAppleConnected": false,
              "isCreator": null,
              "isDeliverable": true,
              "isEmailVerified": true,
              "isFollowing": true,
              "name": "Peppermint Fox",
              "location": {
                "__typename": "Country",
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
                    "type": "VISA",
                    "stripeCardId": "pm_1OtGFX4VvJ2PtfhK3Gp00SWK",
                  }
                ],
                "totalCount": 1
              },
              "uid": "1705304006"
            },
            "currency": "AUD",
            "deadlineAt": 1622195758,
            "description": "Notebooks, paper tape and sticker sets from the Peppermint Fox Press, inspired by vintage books. For poets, planners, and storytellers.",
            "finalCollectionDate": null,
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
              "url": "https://i.kickstarter.com/assets/033/395/412/618ee8bdcfcfd731cc0404270a79d98c_original.jpg?anim=false&fit=crop&gravity=auto&height=576&origin=ugc-qa&q=92&width=1024&sig=xOlHzUBHN42jNCMLDBloActwSriibZ3BAQ4w5h3sjWo%3D"
            },
            "isPledgeOverTimeAllowed": false,
            "isProjectWeLove": true,
            "isProjectOfTheDay": false,
            "isLaunched": true,
            "isWatched": false,
            "launchedAt": 1619603758,
            "lastWave": {
              "__typename": "CheckoutWave",
              "id": "Q2hlY2tvdXRXYXZlLTI1OQ==",
              "active": true
            },
            "location": {
              "__typename": "Location",
              "country": "AU",
              "countryName": "Australia",
              "displayableName": "Launceston, AU",
              "id": "TG9jYXRpb24tMTEwMzM2OA==",
              "name": "Launceston"
            },
            "maxPledge": 8500,
            "minPledge": 1,
            "name": "Peppermint Fox Press: Notebooks & Stationery",
            "pledgeManager": {
              "__typename": "PledgeManager",
              "id": "UGxlZGdlTWFuYWdlci05MQ==",
              "acceptsNewBackers": true
            },
            "pid": 1606532881,
            "pledged": {
              "__typename": "Money",
              "amount": "6054.32",
              "currency": "AUD",
              "symbol": "$"
            },
            "isInPostCampaignPledgingPhase": false,
            "postCampaignPledgingEnabled": false,
            "prelaunchActivated": true,
            "redemptionPageUrl": "https://www.kickstarter.com/projects/creator/a-fun-project/backing/redeem",
            "projectNotice": null,
            "slug": "peppermintfox/peppermint-fox-press-notebooks-and-stationery",
            "state": "LIVE",
            "stateChangedAt": 1619603760,
            "tags": [
              {
                "__typename": "Tag",
                "name": "LGBTQIA+"
              }
            ],
            "url": "https://staging.kickstarter.com/projects/peppermintfox/peppermint-fox-press-notebooks-and-stationery",
            "usdExchangeRate": 0.74641181,
            "story": "API returns this as HTML wrapped in a string. But here HTML breaks testing because the serializer does not recognize escape characters within a string.",
            "environmentalCommitments": [],
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
            "risks": "As with any project of this nature, there are always some risks involved with manufacturing and shipping. That's why we're collaborating with the iam8bit team, they have many years of experience producing and delivering all manner of items to destinations all around the world. We do not expect any delays or hiccups with reward fulfillment. But if anything comes up, we will be clear and communicative about what is happening and how it might affect you."
          }
        }    
    """
  }
}
