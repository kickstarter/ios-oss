import Apollo
import Foundation
import GraphAPI
@testable import KsApi

public enum FetchProjectRewardsByIdQueryTemplate {
  case validRewardWithAllFields
  case expandedShippingReward

  /// `FetchProjectBySlug` returns identical data.
  var data: GraphAPI.FetchProjectRewardsByIdQuery.Data {
    switch self {
    case .validRewardWithAllFields:
      return try! testGraphObject(
        jsonString: self.validRewardWithAllFieldsJSON,
        variables: [
          "includeLocalPickup": true,
          "includeShippingRules": true
        ]
      )
    case .expandedShippingReward:
      return try! testGraphObject(
        jsonString: self.expandedShippingRewardJSON,
        variables: ["includeShippingRules": true]
      )
    }
  }

  // MARK: Private Properties

  private var validRewardWithAllFieldsJSON: String {
    return """
    {
      "project": {
        "rewards": {
          "__typename": "ProjectRewardsConnection",
          "nodes": [
            {
              "__typename": "Reward",
              "amount": {
                "__typename": "Money",
                "amount": "400.0",
                "currency": "EUR",
                "symbol": "€"
              },
              "localReceiptLocation": {
                "__typename": "Location",
                "country": "US",
                "countryName": "United States",
                "displayableName": "San Jose, CA",
                "id": "TG9jYXRpb24tMjQ4ODA0Mg==",
                "name": "San Jose"
              },
              "allowedAddons": {
                "__typename": "RewardConnection",
                "pageInfo": {
                  "__typename": "PageInfo",
                  "startCursor": null
                }
              },
              "backersCount": 1,
              "convertedAmount": {
                "__typename": "Money",
                "amount": "599.0",
                "currency": "CAD",
                "symbol": "$"
              },
              "description": "Signed first edition of the book The Quiet with a personal inscription and one of 10 limited edition gallery prints (numbered and signed) on Aluminium Dibond of a photo of your choice from the book (Format: 30x45cm) / Signierte Erstausgabe des Buchs The Quiet mit einer persönlichen WIdmung und einem von 10 limitierten Alu-Dibond Galleryprint (nummeriert und signiert) eines Fotos deiner Wahl aus dem Buch im Format 30 cm x 45 cm.",
              "displayName": "SIGNED BOOK + GALLERY PRINT (30x45cm) (€400)",
              "endsAt": null,
              "estimatedDeliveryOn": "2021-11-01",
              "id": "UmV3YXJkLTgzNDExODA=",
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
                      "id": "UmV3YXJkSXRlbS0xMjYxMTQ1",
                      "name": "BOOK The Quiet"
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
              "latePledgeAmount": {
                "__typename": "Money",
                "amount": "5.0",
                "currency": "EUR",
                "symbol": "€"
              },
              "limit": 10,
              "limitPerBacker": 1,
              "name": "SIGNED BOOK + GALLERY PRINT (30x45cm)",
              "pledgeAmount": {
                "__typename": "Money",
                "amount": "5.0",
                "currency": "EUR",
                "symbol": "€"
              },
              "postCampaignPledgingEnabled": false,
              "project": {
                "__typename": "Project",
                "id": "UHJvamVjdC05MDQ3MDIxMTY=",
                "story": "",
                "risks": "",
                "environmentalCommitments": [],
                "faqs": {
                  "__typename": "ProjectFaqConnection",
                  "nodes": []
                }
              },
              "remainingQuantity": 9,
              "shippingPreference": "restricted",
              "shippingSummary": "Ships worldwide",
              "shippingRules": [
                {
                  "__typename": "ShippingRule",
                  "cost": {
                    "__typename": "Money",
                    "amount": "6.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjk5NDQ4",
                  "location": {
                    "__typename": "Location",
                    "country": "DE",
                    "countryName": "Germany",
                    "displayableName": "Germany",
                    "id": "TG9jYXRpb24tMjM0MjQ4Mjk=",
                    "name": "Germany"
                  }
                },
                {
                  "__typename": "ShippingRule",
                  "cost": {
                    "__typename": "Money",
                    "amount": "15.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjk5NDUy",
                  "location": {
                    "__typename": "Location",
                    "country": "CH",
                    "countryName": "Switzerland",
                    "displayableName": "Switzerland",
                    "id": "TG9jYXRpb24tMjM0MjQ5NTc=",
                    "name": "Switzerland"
                  }
                },
                {
                  "__typename": "ShippingRule",
                  "cost": {
                    "__typename": "Money",
                    "amount": "15.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjk5NDUx",
                  "location": {
                    "__typename": "Location",
                    "country": "GB",
                    "countryName": "United Kingdom",
                    "displayableName": "United Kingdom",
                    "id": "TG9jYXRpb24tMjM0MjQ5NzU=",
                    "name": "United Kingdom"
                  }
                },
                {
                  "__typename": "ShippingRule",
                  "cost": {
                    "__typename": "Money",
                    "amount": "10.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjk5NDQ5",
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
              "simpleShippingRulesExpanded": [
                {
                  "__typename": "SimpleShippingRule",
                  "cost": "6.0",
                  "currency": "USD",
                  "estimatedMax": null,
                  "estimatedMin": null,
                  "locationId": "TG9jYXRpb24tMjM0MjQ4Mjk=",
                  "locationName": "Germany",
                  "country": "DE"
                },
                {
                  "__typename": "SimpleShippingRule",
                  "cost": "15.0",
                  "currency": "USD",
                  "estimatedMax": null,
                  "estimatedMin": null,
                  "locationId": "TG9jYXRpb24tMjM0MjQ5NTc=",
                  "locationName": "Switzerland",
                  "country": "CH"
                },
                {
                  "__typename": "SimpleShippingRule",
                  "cost": "15.0",
                  "currency": "USD",
                  "estimatedMax": null,
                  "estimatedMin": null,
                  "locationId": "TG9jYXRpb24tMjM0MjQ5NzU=",
                  "locationName": "United Kingdom",
                  "country": "GB"
                },
                {
                  "__typename": "SimpleShippingRule",
                  "cost": "10.0",
                  "currency": "USD",
                  "estimatedMax": null,
                  "estimatedMin": null,
                  "locationId": "TG9jYXRpb24tMjM0MjQ3NTA=",
                  "locationName": "Austria",
                  "country": "AT"
                },
                {
                  "__typename": "SimpleShippingRule",
                  "cost": "10.0",
                  "currency": "USD",
                  "estimatedMax": null,
                  "estimatedMin": null,
                  "locationId": "TG9jYXRpb24tMjM0MjQ3NTc=",
                  "locationName": "Belgium",
                  "country": "BE"
                },
                {
                  "__typename": "SimpleShippingRule",
                  "cost": "10.0",
                  "currency": "USD",
                  "estimatedMax": null,
                  "estimatedMin": null,
                  "locationId": "TG9jYXRpb24tMjM0MjQ3NzE=",
                  "locationName": "Bulgaria",
                  "country": "BG"
                },
                {
                  "__typename": "SimpleShippingRule",
                  "cost": "10.0",
                  "currency": "USD",
                  "estimatedMax": null,
                  "estimatedMin": null,
                  "locationId": "TG9jYXRpb24tMjM0MjQ4NDM=",
                  "locationName": "Croatia",
                  "country": "HR"
                },
                {
                  "__typename": "SimpleShippingRule",
                  "cost": "10.0",
                  "currency": "USD",
                  "estimatedMax": null,
                  "estimatedMin": null,
                  "locationId": "TG9jYXRpb24tMjY4MTIzNDY=",
                  "locationName": "Cyprus",
                  "country": "CY"
                },
                {
                  "__typename": "SimpleShippingRule",
                  "cost": "10.0",
                  "currency": "USD",
                  "estimatedMax": null,
                  "estimatedMin": null,
                  "locationId": "TG9jYXRpb24tMjM0MjQ4MTA=",
                  "locationName": "Czech Republic",
                  "country": "CZ"
                },
                {
                  "__typename": "SimpleShippingRule",
                  "cost": "10.0",
                  "currency": "USD",
                  "estimatedMax": null,
                  "estimatedMin": null,
                  "locationId": "TG9jYXRpb24tMjM0MjQ3OTY=",
                  "locationName": "Denmark",
                  "country": "DK"
                },
                {
                  "__typename": "SimpleShippingRule",
                  "cost": "10.0",
                  "currency": "USD",
                  "estimatedMax": null,
                  "estimatedMin": null,
                  "locationId": "TG9jYXRpb24tMjM0MjQ4MDU=",
                  "locationName": "Estonia",
                  "country": "EE"
                },
                {
                  "__typename": "SimpleShippingRule",
                  "cost": "10.0",
                  "currency": "USD",
                  "estimatedMax": null,
                  "estimatedMin": null,
                  "locationId": "TG9jYXRpb24tMjM0MjQ4MTI=",
                  "locationName": "Finland",
                  "country": "FI"
                },
                {
                  "__typename": "SimpleShippingRule",
                  "cost": "10.0",
                  "currency": "USD",
                  "estimatedMax": null,
                  "estimatedMin": null,
                  "locationId": "TG9jYXRpb24tMjM0MjQ4MTk=",
                  "locationName": "France",
                  "country": "FR"
                },
                {
                  "__typename": "SimpleShippingRule",
                  "cost": "10.0",
                  "currency": "USD",
                  "estimatedMax": null,
                  "estimatedMin": null,
                  "locationId": "TG9jYXRpb24tMjM0MjQ4MzM=",
                  "locationName": "Greece",
                  "country": "GR"
                },
                {
                  "__typename": "SimpleShippingRule",
                  "cost": "10.0",
                  "currency": "USD",
                  "estimatedMax": null,
                  "estimatedMin": null,
                  "locationId": "TG9jYXRpb24tMjM0MjQ4NDQ=",
                  "locationName": "Hungary",
                  "country": "HU"
                },
                {
                  "__typename": "SimpleShippingRule",
                  "cost": "10.0",
                  "currency": "USD",
                  "estimatedMax": null,
                  "estimatedMin": null,
                  "locationId": "TG9jYXRpb24tMjM0MjQ4MDM=",
                  "locationName": "Ireland",
                  "country": "IE"
                },
                {
                  "__typename": "SimpleShippingRule",
                  "cost": "10.0",
                  "currency": "USD",
                  "estimatedMax": null,
                  "estimatedMin": null,
                  "locationId": "TG9jYXRpb24tMjM0MjQ4NTM=",
                  "locationName": "Italy",
                  "country": "IT"
                },
                {
                  "__typename": "SimpleShippingRule",
                  "cost": "10.0",
                  "currency": "USD",
                  "estimatedMax": null,
                  "estimatedMin": null,
                  "locationId": "TG9jYXRpb24tMjM0MjQ4NzQ=",
                  "locationName": "Latvia",
                  "country": "LV"
                },
                {
                  "__typename": "SimpleShippingRule",
                  "cost": "10.0",
                  "currency": "USD",
                  "estimatedMax": null,
                  "estimatedMin": null,
                  "locationId": "TG9jYXRpb24tMjM0MjQ4NzU=",
                  "locationName": "Lithuania",
                  "country": "LT"
                },
                {
                  "__typename": "SimpleShippingRule",
                  "cost": "10.0",
                  "currency": "USD",
                  "estimatedMax": null,
                  "estimatedMin": null,
                  "locationId": "TG9jYXRpb24tMjM0MjQ4ODE=",
                  "locationName": "Luxembourg",
                  "country": "LU"
                },
                {
                  "__typename": "SimpleShippingRule",
                  "cost": "10.0",
                  "currency": "USD",
                  "estimatedMax": null,
                  "estimatedMin": null,
                  "locationId": "TG9jYXRpb24tMjM0MjQ4OTc=",
                  "locationName": "Malta",
                  "country": "MT"
                },
                {
                  "__typename": "SimpleShippingRule",
                  "cost": "10.0",
                  "currency": "USD",
                  "estimatedMax": null,
                  "estimatedMin": null,
                  "locationId": "TG9jYXRpb24tMjM0MjQ5MDk=",
                  "locationName": "Netherlands",
                  "country": "NL"
                },
                {
                  "__typename": "SimpleShippingRule",
                  "cost": "10.0",
                  "currency": "USD",
                  "estimatedMax": null,
                  "estimatedMin": null,
                  "locationId": "TG9jYXRpb24tMjM0MjQ5MjM=",
                  "locationName": "Poland",
                  "country": "PL"
                },
                {
                  "__typename": "SimpleShippingRule",
                  "cost": "10.0",
                  "currency": "USD",
                  "estimatedMax": null,
                  "estimatedMin": null,
                  "locationId": "TG9jYXRpb24tMjM0MjQ5MjU=",
                  "locationName": "Portugal",
                  "country": "PT"
                },
                {
                  "__typename": "SimpleShippingRule",
                  "cost": "10.0",
                  "currency": "USD",
                  "estimatedMax": null,
                  "estimatedMin": null,
                  "locationId": "TG9jYXRpb24tMjM0MjQ5MzM=",
                  "locationName": "Romania",
                  "country": "RO"
                },
                {
                  "__typename": "SimpleShippingRule",
                  "cost": "10.0",
                  "currency": "USD",
                  "estimatedMax": null,
                  "estimatedMin": null,
                  "locationId": "TG9jYXRpb24tMjM0MjQ4Nzc=",
                  "locationName": "Slovakia",
                  "country": "SK"
                },
                {
                  "__typename": "SimpleShippingRule",
                  "cost": "10.0",
                  "currency": "USD",
                  "estimatedMax": null,
                  "estimatedMin": null,
                  "locationId": "TG9jYXRpb24tMjM0MjQ5NDU=",
                  "locationName": "Slovenia",
                  "country": "SI"
                },
                {
                  "__typename": "SimpleShippingRule",
                  "cost": "10.0",
                  "currency": "USD",
                  "estimatedMax": null,
                  "estimatedMin": null,
                  "locationId": "TG9jYXRpb24tMjM0MjQ5NTA=",
                  "locationName": "Spain",
                  "country": "ES"
                },
                {
                  "__typename": "SimpleShippingRule",
                  "cost": "10.0",
                  "currency": "USD",
                  "estimatedMax": null,
                  "estimatedMin": null,
                  "locationId": "TG9jYXRpb24tMjM0MjQ5NTQ=",
                  "locationName": "Sweden",
                  "country": "SE"
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
        "__typename": "Project"
      }
    }
    """
  }

  private var expandedShippingRewardJSON: String {
    return """
        {
          "project": {
            "rewards": {
              "__typename": "ProjectRewardsConnection",
              "nodes": [
                {
                  "__typename": "Reward",
                  "available": true,
                  "project": {
                    "__typename": "Project",
                    "id": "UHJvamVjdC0xMTg3NjM3ODg3"
                  },
                  "latePledgeAmount": {
                    "__typename": "Money",
                    "currency": "USD",
                    "symbol": "$",
                    "amount": "5.0"
                  },
                  "pledgeAmount": {
                    "amount": "1.0",
                    "currency": "USD",
                    "symbol": "$",
                    "__typename": "Money"
                  },
                  "endsAt": null,
                  "items": {
                    "edges": [
                      {
                        "node": {
                          "__typename": "RewardItem",
                          "id": "UmV3YXJkSXRlbS0yNTcyODA4",
                          "name": "T-Shirt 2"
                        },
                        "quantity": 1,
                        "__typename": "RewardItemEdge"
                      }
                    ],
                    "__typename": "RewardItemsConnection"
                  },
                  "convertedAmount": {
                    "symbol": "$",
                    "amount": "5.0",
                    "currency": "USD",
                    "__typename": "Money"
                  },
                  "localReceiptLocation": null,
                  "shippingRules": [
                    {
                      "estimatedMax": null,
                      "location": {
                        "name": "European Union",
                        "id": "TG9jYXRpb24tNTU5NDkwNjg=",
                        "country": "ZZ",
                        "__typename": "Location",
                        "countryName": null,
                        "displayableName": "European Union"
                      },
                      "estimatedMin": null,
                      "__typename": "ShippingRule",
                      "id": "U2hpcHBpbmdSdWxlLTE1NjMwMjA2",
                      "cost": {
                        "amount": "5.0",
                        "symbol": "$",
                        "currency": "USD",
                        "__typename": "Money"
                      }
                    }
                  ],
                  "limitPerBacker": 1,
                  "description": "Charging shipping to EU $5",
                  "id": "UmV3YXJkLTEwMDU0MTI1",
                  "remainingQuantity": null,
                  "amount": {
                    "amount": "5.0",
                    "symbol": "$",
                    "__typename": "Money",
                    "currency": "USD"
                  },
                  "shippingSummary": "Only European Union",
                  "displayName": "Testing charge shipping just EU ($1)",
                  "simpleShippingRulesExpanded": [
                    {
                      "country": "AT",
                      "locationId": "TG9jYXRpb24tMjM0MjQ3NTA=",
                      "estimatedMin": "2",
                      "cost": "5.0",
                      "estimatedMax": "10",
                      "locationName": "Austria",
                      "__typename": "SimpleShippingRule",
                      "currency": "USD"
                    },
                    {
                      "locationName": "Belgium",
                      "__typename": "SimpleShippingRule",
                      "estimatedMax": null,
                      "cost": "5.0",
                      "estimatedMin": null,
                      "locationId": "TG9jYXRpb24tMjM0MjQ3NTc=",
                      "currency": "USD",
                      "country": "BE"
                    },
                    {
                      "__typename": "SimpleShippingRule",
                      "locationName": "Bulgaria",
                      "estimatedMax": null,
                      "estimatedMin": null,
                      "country": "BG",
                      "currency": "USD",
                      "cost": "5.0",
                      "locationId": "TG9jYXRpb24tMjM0MjQ3NzE="
                    },
                    {
                      "estimatedMax": null,
                      "country": "HR",
                      "locationId": "TG9jYXRpb24tMjM0MjQ4NDM=",
                      "__typename": "SimpleShippingRule",
                      "cost": "5.0",
                      "currency": "USD",
                      "estimatedMin": null,
                      "locationName": "Croatia"
                    },
                    {
                      "locationName": "Cyprus",
                      "estimatedMax": null,
                      "__typename": "SimpleShippingRule",
                      "country": "CY",
                      "cost": "5.0",
                      "currency": "USD",
                      "locationId": "TG9jYXRpb24tMjY4MTIzNDY=",
                      "estimatedMin": null
                    },
                    {
                      "locationName": "Czech Republic",
                      "currency": "USD",
                      "estimatedMin": null,
                      "estimatedMax": null,
                      "__typename": "SimpleShippingRule",
                      "locationId": "TG9jYXRpb24tMjM0MjQ4MTA=",
                      "cost": "5.0",
                      "country": "CZ"
                    },
                    {
                      "cost": "5.0",
                      "estimatedMin": null,
                      "locationId": "TG9jYXRpb24tMjM0MjQ3OTY=",
                      "__typename": "SimpleShippingRule",
                      "country": "DK",
                      "currency": "USD",
                      "estimatedMax": null,
                      "locationName": "Denmark"
                    },
                    {
                      "locationId": "TG9jYXRpb24tMjM0MjQ4MDU=",
                      "cost": "5.0",
                      "estimatedMax": null,
                      "currency": "USD",
                      "estimatedMin": null,
                      "locationName": "Estonia",
                      "country": "EE",
                      "__typename": "SimpleShippingRule"
                    },
                    {
                      "locationName": "Finland",
                      "estimatedMin": null,
                      "estimatedMax": null,
                      "currency": "USD",
                      "cost": "5.0",
                      "country": "FI",
                      "locationId": "TG9jYXRpb24tMjM0MjQ4MTI=",
                      "__typename": "SimpleShippingRule"
                    },
                    {
                      "estimatedMax": null,
                      "__typename": "SimpleShippingRule",
                      "locationId": "TG9jYXRpb24tMjM0MjQ4MTk=",
                      "locationName": "France",
                      "cost": "5.0",
                      "estimatedMin": null,
                      "currency": "USD",
                      "country": "FR"
                    },
                    {
                      "estimatedMin": null,
                      "locationName": "Germany",
                      "cost": "5.0",
                      "estimatedMax": null,
                      "currency": "USD",
                      "country": "DE",
                      "locationId": "TG9jYXRpb24tMjM0MjQ4Mjk=",
                      "__typename": "SimpleShippingRule"
                    },
                    {
                      "locationName": "Greece",
                      "currency": "USD",
                      "locationId": "TG9jYXRpb24tMjM0MjQ4MzM=",
                      "estimatedMax": null,
                      "cost": "5.0",
                      "__typename": "SimpleShippingRule",
                      "estimatedMin": null,
                      "country": "GR"
                    },
                    {
                      "currency": "USD",
                      "estimatedMax": null,
                      "country": "HU",
                      "__typename": "SimpleShippingRule",
                      "locationName": "Hungary",
                      "estimatedMin": null,
                      "cost": "5.0",
                      "locationId": "TG9jYXRpb24tMjM0MjQ4NDQ="
                    },
                    {
                      "locationId": "TG9jYXRpb24tMjM0MjQ4MDM=",
                      "cost": "5.0",
                      "country": "IE",
                      "locationName": "Ireland",
                      "estimatedMax": null,
                      "currency": "USD",
                      "__typename": "SimpleShippingRule",
                      "estimatedMin": null
                    },
                    {
                      "estimatedMax": null,
                      "__typename": "SimpleShippingRule",
                      "country": "IT",
                      "estimatedMin": null,
                      "locationName": "Italy",
                      "cost": "5.0",
                      "locationId": "TG9jYXRpb24tMjM0MjQ4NTM=",
                      "currency": "USD"
                    },
                    {
                      "locationName": "Latvia",
                      "__typename": "SimpleShippingRule",
                      "locationId": "TG9jYXRpb24tMjM0MjQ4NzQ=",
                      "cost": "5.0",
                      "country": "LV",
                      "estimatedMin": null,
                      "estimatedMax": null,
                      "currency": "USD"
                    },
                    {
                      "currency": "USD",
                      "estimatedMax": null,
                      "locationId": "TG9jYXRpb24tMjM0MjQ4NzU=",
                      "__typename": "SimpleShippingRule",
                      "estimatedMin": null,
                      "locationName": "Lithuania",
                      "country": "LT",
                      "cost": "5.0"
                    },
                    {
                      "locationName": "Luxembourg",
                      "country": "LU",
                      "estimatedMin": null,
                      "locationId": "TG9jYXRpb24tMjM0MjQ4ODE=",
                      "__typename": "SimpleShippingRule",
                      "cost": "5.0",
                      "estimatedMax": null,
                      "currency": "USD"
                    },
                    {
                      "estimatedMax": null,
                      "locationName": "Malta",
                      "cost": "5.0",
                      "estimatedMin": null,
                      "locationId": "TG9jYXRpb24tMjM0MjQ4OTc=",
                      "country": "MT",
                      "currency": "USD",
                      "__typename": "SimpleShippingRule"
                    },
                    {
                      "estimatedMin": null,
                      "country": "NL",
                      "currency": "USD",
                      "cost": "5.0",
                      "locationId": "TG9jYXRpb24tMjM0MjQ5MDk=",
                      "locationName": "Netherlands",
                      "estimatedMax": null,
                      "__typename": "SimpleShippingRule"
                    },
                    {
                      "estimatedMin": null,
                      "currency": "USD",
                      "locationId": "TG9jYXRpb24tMjM0MjQ5MjM=",
                      "estimatedMax": null,
                      "cost": "5.0",
                      "country": "PL",
                      "__typename": "SimpleShippingRule",
                      "locationName": "Poland"
                    },
                    {
                      "locationName": "Portugal",
                      "cost": "5.0",
                      "estimatedMin": null,
                      "__typename": "SimpleShippingRule",
                      "estimatedMax": null,
                      "country": "PT",
                      "locationId": "TG9jYXRpb24tMjM0MjQ5MjU=",
                      "currency": "USD"
                    },
                    {
                      "locationName": "Romania",
                      "__typename": "SimpleShippingRule",
                      "estimatedMin": null,
                      "cost": "5.0",
                      "estimatedMax": null,
                      "country": "RO",
                      "currency": "USD",
                      "locationId": "TG9jYXRpb24tMjM0MjQ5MzM="
                    },
                    {
                      "currency": "USD",
                      "__typename": "SimpleShippingRule",
                      "locationId": "TG9jYXRpb24tMjM0MjQ4Nzc=",
                      "estimatedMax": null,
                      "country": "SK",
                      "estimatedMin": null,
                      "locationName": "Slovakia",
                      "cost": "5.0"
                    },
                    {
                      "country": "SI",
                      "__typename": "SimpleShippingRule",
                      "estimatedMin": null,
                      "locationName": "Slovenia",
                      "estimatedMax": null,
                      "locationId": "TG9jYXRpb24tMjM0MjQ5NDU=",
                      "cost": "5.0",
                      "currency": "USD"
                    },
                    {
                      "estimatedMax": null,
                      "locationName": "Spain",
                      "locationId": "TG9jYXRpb24tMjM0MjQ5NTA=",
                      "cost": "5.0",
                      "__typename": "SimpleShippingRule",
                      "country": "ES",
                      "currency": "USD",
                      "estimatedMin": null
                    },
                    {
                      "estimatedMax": null,
                      "locationName": "Sweden",
                      "currency": "USD",
                      "country": "SE",
                      "__typename": "SimpleShippingRule",
                      "cost": "5.0",
                      "locationId": "TG9jYXRpb24tMjM0MjQ5NTQ=",
                      "estimatedMin": null
                    }
                  ],
                  "__typename": "Reward",
                  "backersCount": 0,
                  "name": "Testing charge shipping just EU",
                  "postCampaignPledgingEnabled": true,
                  "allowedAddons": {
                    "__typename": "RewardConnection",
                    "pageInfo": {
                      "__typename": "PageInfo",
                      "startCursor": "MQ=="
                    }
                  },
                  "estimatedDeliveryOn": "2028-12-01",
                  "limit": null,
                  "isMaxPledge": false,
                  "shippingPreference": "restricted",
                  "startsAt": null,
                  "audienceData": {
                    "__typename": "ResourceAudience",
                    "secret": false
                  }
                }
              ]
            },
            "__typename": "Project"
          }
        }
    """
  }
}
