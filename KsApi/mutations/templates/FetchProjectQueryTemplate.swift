import Apollo
@testable import KsApi

public enum FetchProjectQueryTemplate {
  case valid
  case errored

  /// `FetchProjectBySlug` returns identical data.
  var data: GraphAPI.FetchProjectByIdQuery.Data {
    switch self {
    case .valid:
      return GraphAPI.FetchProjectByIdQuery.Data(unsafeResultMap: self.validResultMap)
    case .errored:
      return GraphAPI.FetchProjectByIdQuery.Data(unsafeResultMap: self.erroredResultMap)
    }
  }

  // MARK: Private Properties

  private var validResultMap: [String: Any] {
    let json = """
    {
      "project": {
        "rewards": {
          "nodes": [{
              "amount": {
                "amount": "5.0",
                "currency": "EUR",
                "symbol": "€"
              },
              "backersCount": 3,
              "convertedAmount": {
                "amount": "8.0",
                "currency": "CAD",
                "symbol": "$"
              },
              "description": "You’ll receive a personal email from me with a surprise gif!",
              "displayName": "PERSONAL THANK YOU + SURPRISE GIF (€5)",
              "endsAt": null,
              "estimatedDeliveryOn": "2021-09-01",
              "id": "UmV3YXJkLTgzMzQzNTk=",
              "isMaxPledge": false,
              "items": {
                "nodes": []
              },
              "limit": null,
              "limitPerBacker": 1,
              "name": "PERSONAL THANK YOU + SURPRISE GIF",
              "project": {
                "id": "UHJvamVjdC05MDQ3MDIxMTY="
              },
              "remainingQuantity": null,
              "shippingPreference": "none",
              "shippingRules": [],
              "startsAt": null
            },
            {
              "amount": {
                "amount": "10.0",
                "currency": "EUR",
                "symbol": "€"
              },
              "backersCount": 6,
              "convertedAmount": {
                "amount": "15.0",
                "currency": "CAD",
                "symbol": "$"
              },
              "description": "Surprise Set of 5 Postcards.",
              "endsAt": null,
              "estimatedDeliveryOn": "2021-11-01",
              "id": "UmV3YXJkLTgzMzc3MTI=",
              "isMaxPledge": false,
              "items": {
                "nodes": [
                  {
                    "id": "UmV3YXJkSXRlbS0xMjYzMTA5",
                    "name": "POSTCARD / POSTKARTE"
                  }
                ]
              },
              "limit": 50,
              "limitPerBacker": 1,
              "name": "SET OF 5 POSTCARDS",
              "project": {
                "id": "UHJvamVjdC05MDQ3MDIxMTY="
              },
              "remainingQuantity": 44,
              "shippingPreference": "unrestricted",
              "shippingRules": [{
                  "cost": {
                    "amount": "10.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjkxOTE2",
                  "location": {
                    "country": "ZZ",
                    "countryName": null,
                    "displayableName": "Earth",
                    "id": "TG9jYXRpb24tMQ==",
                    "name": "Rest of World"
                  }
                },
                {
                  "cost": {
                    "amount": "5.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjkxOTE3",
                  "location": {
                    "country": "DE",
                    "countryName": "Germany",
                    "displayableName": "Germany",
                    "id": "TG9jYXRpb24tMjM0MjQ4Mjk=",
                    "name": "Germany"
                  }
                },
                {
                  "cost": {
                    "amount": "5.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjkxOTE4",
                  "location": {
                    "country": "ZZ",
                    "countryName": null,
                    "displayableName": "European Union",
                    "id": "TG9jYXRpb24tNTU5NDkwNjg=",
                    "name": "European Union"
                  }
                }
              ],
              "startsAt": null
            },
            {
              "amount": {
                "amount": "16.0",
                "currency": "EUR",
                "symbol": "€"
              },
              "backersCount": 10,
              "convertedAmount": {
                "amount": "24.0",
                "currency": "CAD",
                "symbol": "$"
              },
              "description": "Please be honest and only book this option if you are a pupil or student.",
              "displayName": "SPECIAL OFFER FOR PUPILS (€16)",
              "endsAt": null,
              "estimatedDeliveryOn": "2021-11-01",
              "id": "UmV3YXJkLTgzMzQzOTY=",
              "isMaxPledge": false,
              "items": {
                "nodes": [
                  {
                    "id": "UmV3YXJkSXRlbS0xMjYxMTQ1",
                    "name": "BOOK The Quiet"
                  }
                ]
              },
              "limit": 10,
              "limitPerBacker": 1,
              "name": "SPECIAL OFFER FOR PUPILS",
              "project": {
                "id": "UHJvamVjdC05MDQ3MDIxMTY="
              },
              "remainingQuantity": 0,
              "shippingPreference": "unrestricted",
              "shippingRules": [{
                  "cost": {
                    "amount": "10.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjgyMzI5",
                  "location": {
                    "country": "ZZ",
                    "countryName": null,
                    "displayableName": "Earth",
                    "id": "TG9jYXRpb24tMQ==",
                    "name": "Rest of World"
                  }
                },
                {
                  "cost": {
                    "amount": "5.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjgyMzMw",
                  "location": {
                    "country": "DE",
                    "countryName": "Germany",
                    "displayableName": "Germany",
                    "id": "TG9jYXRpb24tMjM0MjQ4Mjk=",
                    "name": "Germany"
                  }
                }
              ],
              "startsAt": null
            },
            {
              "amount": {
                "amount": "24.0",
                "currency": "EUR",
                "symbol": "€"
              },
              "backersCount": 56,
              "convertedAmount": {
                "amount": "36.0",
                "currency": "CAD",
                "symbol": "$"
              },
              "description": "First edition of the book.",
              "displayName": "FIRST EDITON BOOK",
              "endsAt": null,
              "estimatedDeliveryOn": "2021-11-01",
              "id": "UmV3YXJkLTgzMzA3MDQ=",
              "isMaxPledge": false,
              "items": {
                "nodes": [
                  {
                    "id": "UmV3YXJkSXRlbS0xMjYxMTQ1",
                    "name": "BOOK The Quiet"
                  }
                ]
              },
              "limit": null,
              "limitPerBacker": 1,
              "name": "FIRST EDITON BOOK",
              "project": {
                "id": "UHJvamVjdC05MDQ3MDIxMTY="
              },
              "remainingQuantity": null,
              "shippingPreference": "unrestricted",
              "shippingRules": [{
                  "cost": {
                    "amount": "10.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjcxOTQx",
                  "location": {
                    "country": "ZZ",
                    "countryName": null,
                    "displayableName": "Earth",
                    "id": "TG9jYXRpb24tMQ==",
                    "name": "Rest of World"
                  }
                },
                {
                  "cost": {
                    "amount": "5.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjcxODg1",
                  "location": {
                    "country": "DE",
                    "countryName": "Germany",
                    "displayableName": "Germany",
                    "id": "TG9jYXRpb24tMjM0MjQ4Mjk=",
                    "name": "Germany"
                  }
                },
                {
                  "cost": {
                    "amount": "7.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjcxODg2",
                  "location": {
                    "country": "ZZ",
                    "countryName": null,
                    "displayableName": "European Union",
                    "id": "TG9jYXRpb24tNTU5NDkwNjg=",
                    "name": "European Union"
                  }
                }
              ],
              "startsAt": null
            },
            {
              "amount": {
                "amount": "32.0",
                "currency": "EUR",
                "symbol": "€"
              },
              "backersCount": 10,
              "convertedAmount": {
                "amount": "48.0",
                "currency": "CAD",
                "symbol": "$"
              },
              "description": "Pay a little extra for your signed first edition!",
              "displayName": "SIGNED BOOK",
              "endsAt": null,
              "estimatedDeliveryOn": "2021-11-01",
              "id": "UmV3YXJkLTgzMzQzNjU=",
              "isMaxPledge": false,
              "items": {
                "nodes": [
                  {
                    "id": "UmV3YXJkSXRlbS0xMjYxMTQ1",
                    "name": "BOOK The Quiet"
                  }
                ]
              },
              "limit": 10,
              "limitPerBacker": 1,
              "name": "SIGNED BOOK",
              "project": {
                "id": "UHJvamVjdC05MDQ3MDIxMTY="
              },
              "remainingQuantity": 0,
              "shippingPreference": "unrestricted",
              "shippingRules": [{
                  "cost": {
                    "amount": "10.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjgyMjcy",
                  "location": {
                    "country": "ZZ",
                    "countryName": null,
                    "displayableName": "Earth",
                    "id": "TG9jYXRpb24tMQ==",
                    "name": "Rest of World"
                  }
                },
                {
                  "cost": {
                    "amount": "5.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjgyMjcz",
                  "location": {
                    "country": "DE",
                    "countryName": "Germany",
                    "displayableName": "Germany",
                    "id": "TG9jYXRpb24tMjM0MjQ4Mjk=",
                    "name": "Germany"
                  }
                }
              ],
              "startsAt": null
            },
            {
              "amount": {
                "amount": "44.0",
                "currency": "EUR",
                "symbol": "€"
              },
              "backersCount": 21,
              "convertedAmount": {
                "amount": "66.0",
                "currency": "CAD",
                "symbol": "$"
              },
              "description": "Get 2 signed copies of the first edition of the book.",
              "displayName": "2 SIGNED BOOKS / 2 SIGNIERTE BÜCHER (€44)",
              "endsAt": null,
              "estimatedDeliveryOn": "2021-11-01",
              "id": "UmV3YXJkLTgzNDMwNDM=",
              "isMaxPledge": false,
              "items": {
                "nodes": [
                  {
                    "id": "UmV3YXJkSXRlbS0xMjYxMTQ1",
                    "name": "BOOK The Quiet"
                  }
                ]
              },
              "limit": null,
              "limitPerBacker": 1,
              "name": "2 SIGNED BOOKS",
              "project": {
                "id": "UHJvamVjdC05MDQ3MDIxMTY="
              },
              "remainingQuantity": null,
              "shippingPreference": "unrestricted",
              "shippingRules": [{
                  "cost": {
                    "amount": "10.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNzAzNDc2",
                  "location": {
                    "country": "ZZ",
                    "countryName": null,
                    "displayableName": "Earth",
                    "id": "TG9jYXRpb24tMQ==",
                    "name": "Rest of World"
                  }
                },
                {
                  "cost": {
                    "amount": "5.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNzAzNDc3",
                  "location": {
                    "country": "DE",
                    "countryName": "Germany",
                    "displayableName": "Germany",
                    "id": "TG9jYXRpb24tMjM0MjQ4Mjk=",
                    "name": "Germany"
                  }
                }
              ],
              "startsAt": null
            },
            {
              "amount": {
                "amount": "50.0",
                "currency": "EUR",
                "symbol": "€"
              },
              "backersCount": 9,
              "convertedAmount": {
                "amount": "75.0",
                "currency": "CAD",
                "symbol": "$"
              },
              "description": "First edition of the book.",
              "endsAt": null,
              "estimatedDeliveryOn": "2021-11-01",
              "id": "UmV3YXJkLTgzMzQyNDk=",
              "isMaxPledge": false,
              "items": {
                "nodes": [
                  {
                    "id": "UmV3YXJkSXRlbS0xMjYxMTQ1",
                    "name": "BOOK The Quiet"
                  },
                  {
                    "id": "UmV3YXJkSXRlbS0xMjYxMTQ2",
                    "name": "SPECIAL EDITION PRINT (20cmx30cm)"
                  }
                ]
              },
              "limit": 10,
              "limitPerBacker": 1,
              "name": "BOOK + PRINT (Eisbären)",
              "project": {
                "id": "UHJvamVjdC05MDQ3MDIxMTY="
              },
              "remainingQuantity": 1,
              "shippingPreference": "unrestricted",
              "shippingRules": [{
                  "cost": {
                    "amount": "10.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjgxOTk5",
                  "location": {
                    "country": "ZZ",
                    "countryName": null,
                    "displayableName": "Earth",
                    "id": "TG9jYXRpb24tMQ==",
                    "name": "Rest of World"
                  }
                },
                {
                  "cost": {
                    "amount": "5.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjgyMDAw",
                  "location": {
                    "country": "DE",
                    "countryName": "Germany",
                    "displayableName": "Germany",
                    "id": "TG9jYXRpb24tMjM0MjQ4Mjk=",
                    "name": "Germany"
                  }
                }
              ],
              "startsAt": null
            },
            {
              "amount": {
                "amount": "50.0",
                "currency": "EUR",
                "symbol": "€"
              },
              "backersCount": 10,
              "convertedAmount": {
                "amount": "75.0",
                "currency": "CAD",
                "symbol": "$"
              },
              "description": "First edition of the book.",
              "endsAt": null,
              "estimatedDeliveryOn": "2021-11-01",
              "id": "UmV3YXJkLTgzMzQyNTg=",
              "isMaxPledge": false,
              "items": {
                "nodes": [
                  {
                    "id": "UmV3YXJkSXRlbS0xMjYxMTQ1",
                    "name": "BOOK The Quiet"
                  },
                  {
                    "id": "UmV3YXJkSXRlbS0xMjYxMTQ2",
                    "name": "SPECIAL EDITION PRINT (20cmx30cm)"
                  }
                ]
              },
              "limit": 10,
              "limitPerBacker": 1,
              "name": "BOOK + PRINT (Aurora Borealis)",
              "project": {
                "id": "UHJvamVjdC05MDQ3MDIxMTY="
              },
              "remainingQuantity": 0,
              "shippingPreference": "unrestricted",
              "shippingRules": [{
                  "cost": {
                    "amount": "10.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjgyMDIx",
                  "location": {
                    "country": "ZZ",
                    "countryName": null,
                    "displayableName": "Earth",
                    "id": "TG9jYXRpb24tMQ==",
                    "name": "Rest of World"
                  }
                },
                {
                  "cost": {
                    "amount": "5.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjgyMDIy",
                  "location": {
                    "country": "DE",
                    "countryName": "Germany",
                    "displayableName": "Germany",
                    "id": "TG9jYXRpb24tMjM0MjQ4Mjk=",
                    "name": "Germany"
                  }
                }
              ],
              "startsAt": null
            },
            {
              "amount": {
                "amount": "50.0",
                "currency": "EUR",
                "symbol": "€"
              },
              "backersCount": 3,
              "convertedAmount": {
                "amount": "75.0",
                "currency": "CAD",
                "symbol": "$"
              },
              "description": "First edition of the book.",
              "endsAt": null,
              "estimatedDeliveryOn": "2021-11-01",
              "id": "UmV3YXJkLTgzNDExODg=",
              "isMaxPledge": false,
              "items": {
                "nodes": [
                  {
                    "id": "UmV3YXJkSXRlbS0xMjYxMTQ1",
                    "name": "BOOK The Quiet"
                  },
                  {
                    "id": "UmV3YXJkSXRlbS0xMjYxMTQ2",
                    "name": "SPECIAL EDITION PRINT (20cmx30cm)"
                  }
                ]
              },
              "limit": 10,
              "limitPerBacker": 1,
              "name": "BOOK + PRINT (Schnee)",
              "project": {
                "id": "UHJvamVjdC05MDQ3MDIxMTY="
              },
              "remainingQuantity": 7,
              "shippingPreference": "unrestricted",
              "shippingRules": [{
                  "cost": {
                    "amount": "10.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjk5NDY0",
                  "location": {
                    "country": "ZZ",
                    "countryName": null,
                    "displayableName": "Earth",
                    "id": "TG9jYXRpb24tMQ==",
                    "name": "Rest of World"
                  }
                },
                {
                  "cost": {
                    "amount": "5.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjk5NDY1",
                  "location": {
                    "country": "DE",
                    "countryName": "Germany",
                    "displayableName": "Germany",
                    "id": "TG9jYXRpb24tMjM0MjQ4Mjk=",
                    "name": "Germany"
                  }
                }
              ],
              "startsAt": null
            },
            {
              "amount": {
                "amount": "100.0",
                "currency": "EUR",
                "symbol": "€"
              },
              "backersCount": 4,
              "convertedAmount": {
                "amount": "150.0",
                "currency": "CAD",
                "symbol": "$"
              },
              "description": "First edition of the book.",
              "endsAt": null,
              "estimatedDeliveryOn": "2021-11-01",
              "id": "UmV3YXJkLTgzMzQyNDI=",
              "isMaxPledge": false,
              "items": {
                "nodes": [
                  {
                    "id": "UmV3YXJkSXRlbS0xMjYxMTQ1",
                    "name": "BOOK The Quiet"
                  },
                  {
                    "id": "UmV3YXJkSXRlbS0xMjY1MjY2",
                    "name": "SPECIAL EDITION PRINT (30cmx45cm)"
                  }
                ]
              },
              "limit": 10,
              "limitPerBacker": 1,
              "name": "BOOK + PRINT (Spalte im Eis)",
              "project": {
                "id": "UHJvamVjdC05MDQ3MDIxMTY="
              },
              "remainingQuantity": 6,
              "shippingPreference": "unrestricted",
              "shippingRules": [{
                  "cost": {
                    "amount": "10.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjgxOTg1",
                  "location": {
                    "country": "ZZ",
                    "countryName": null,
                    "displayableName": "Earth",
                    "id": "TG9jYXRpb24tMQ==",
                    "name": "Rest of World"
                  }
                },
                {
                  "cost": {
                    "amount": "5.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjgxOTg2",
                  "location": {
                    "country": "DE",
                    "countryName": "Germany",
                    "displayableName": "Germany",
                    "id": "TG9jYXRpb24tMjM0MjQ4Mjk=",
                    "name": "Germany"
                  }
                }
              ],
              "startsAt": null
            },
            {
              "amount": {
                "amount": "100.0",
                "currency": "EUR",
                "symbol": "€"
              },
              "backersCount": 6,
              "convertedAmount": {
                "amount": "150.0",
                "currency": "CAD",
                "symbol": "$"
              },
              "description": "First edition of the book.",
              "endsAt": null,
              "estimatedDeliveryOn": "2021-11-01",
              "id": "UmV3YXJkLTgzMzQyNTY=",
              "isMaxPledge": false,
              "items": {
                "nodes": [
                  {
                    "id": "UmV3YXJkSXRlbS0xMjYxMTQ1",
                    "name": "BOOK The Quiet"
                  },
                  {
                    "id": "UmV3YXJkSXRlbS0xMjY1MjY2",
                    "name": "SPECIAL EDITION PRINT (30cmx45cm)"
                  }
                ]
              },
              "limit": 10,
              "limitPerBacker": 1,
              "name": "BOOK + PRINT (Meereis)",
              "project": {
                "id": "UHJvamVjdC05MDQ3MDIxMTY="
              },
              "remainingQuantity": 4,
              "shippingPreference": "unrestricted",
              "shippingRules": [{
                  "cost": {
                    "amount": "10.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjgyMDE3",
                  "location": {
                    "country": "ZZ",
                    "countryName": null,
                    "displayableName": "Earth",
                    "id": "TG9jYXRpb24tMQ==",
                    "name": "Rest of World"
                  }
                },
                {
                  "cost": {
                    "amount": "5.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjgyMDE4",
                  "location": {
                    "country": "DE",
                    "countryName": "Germany",
                    "displayableName": "Germany",
                    "id": "TG9jYXRpb24tMjM0MjQ4Mjk=",
                    "name": "Germany"
                  }
                }
              ],
              "startsAt": null
            },
            {
              "amount": {
                "amount": "250.0",
                "currency": "EUR",
                "symbol": "€"
              },
              "backersCount": 3,
              "convertedAmount": {
                "amount": "375.0",
                "currency": "CAD",
                "symbol": "$"
              },
              "description": "First edition of the book.",
              "endsAt": null,
              "estimatedDeliveryOn": "2021-11-01",
              "id": "UmV3YXJkLTgzNDExODM=",
              "isMaxPledge": false,
              "items": {
                "nodes": [
                  {
                    "id": "UmV3YXJkSXRlbS0xMjYxMTQ1",
                    "name": "BOOK The Quiet"
                  },
                  {
                    "id": "UmV3YXJkSXRlbS0xMjY1ODIz",
                    "name": "SPECIAL EDITION PRINT (50cmx75cm)"
                  }
                ]
              },
              "limit": 10,
              "limitPerBacker": 1,
              "name": "BOOK + PRINT (Arktisches Licht)",
              "project": {
                "id": "UHJvamVjdC05MDQ3MDIxMTY="
              },
              "remainingQuantity": 7,
              "shippingPreference": "unrestricted",
              "shippingRules": [{
                  "cost": {
                    "amount": "10.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjk5NDUz",
                  "location": {
                    "country": "ZZ",
                    "countryName": null,
                    "displayableName": "Earth",
                    "id": "TG9jYXRpb24tMQ==",
                    "name": "Rest of World"
                  }
                },
                {
                  "cost": {
                    "amount": "5.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjk5NDU0",
                  "location": {
                    "country": "DE",
                    "countryName": "Germany",
                    "displayableName": "Germany",
                    "id": "TG9jYXRpb24tMjM0MjQ4Mjk=",
                    "name": "Germany"
                  }
                }
              ],
              "startsAt": null
            },
            {
              "amount": {
                "amount": "250.0",
                "currency": "EUR",
                "symbol": "€"
              },
              "backersCount": 1,
              "convertedAmount": {
                "amount": "375.0",
                "currency": "CAD",
                "symbol": "$"
              },
              "description": "First edition of the book.",
              "endsAt": null,
              "estimatedDeliveryOn": "2021-11-01",
              "id": "UmV3YXJkLTgzNDExODU=",
              "isMaxPledge": false,
              "items": {
                "nodes": [
                  {
                    "id": "UmV3YXJkSXRlbS0xMjYxMTQ1",
                    "name": "BOOK The Quiet"
                  },
                  {
                    "id": "UmV3YXJkSXRlbS0xMjY1ODIz",
                    "name": "SPECIAL EDITION PRINT (50cmx75cm)"
                  }
                ]
              },
              "limit": 10,
              "limitPerBacker": 1,
              "name": "BOOK + PRINT (Das erste Eis)",
              "project": {
                "id": "UHJvamVjdC05MDQ3MDIxMTY="
              },
              "remainingQuantity": 9,
              "shippingPreference": "unrestricted",
              "shippingRules": [{
                  "cost": {
                    "amount": "10.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjk5NDU4",
                  "location": {
                    "country": "ZZ",
                    "countryName": null,
                    "displayableName": "Earth",
                    "id": "TG9jYXRpb24tMQ==",
                    "name": "Rest of World"
                  }
                },
                {
                  "cost": {
                    "amount": "5.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjk5NDU5",
                  "location": {
                    "country": "DE",
                    "countryName": "Germany",
                    "displayableName": "Germany",
                    "id": "TG9jYXRpb24tMjM0MjQ4Mjk=",
                    "name": "Germany"
                  }
                }
              ],
              "startsAt": null
            },
            {
              "amount": {
                "amount": "400.0",
                "currency": "EUR",
                "symbol": "€"
              },
              "backersCount": 1,
              "convertedAmount": {
                "amount": "599.0",
                "currency": "CAD",
                "symbol": "$"
              },
              "description": "Signed first edition of the book.",
              "endsAt": null,
              "estimatedDeliveryOn": "2021-11-01",
              "id": "UmV3YXJkLTgzNDExODA=",
              "isMaxPledge": false,
              "items": {
                "nodes": [
                  {
                    "id": "UmV3YXJkSXRlbS0xMjYxMTQ1",
                    "name": "BOOK The Quiet"
                  },
                  {
                    "id": "UmV3YXJkSXRlbS0xMjY0ODAz",
                    "name": "GALLERY PRINT (30x45cm)"
                  }
                ]
              },
              "limit": 10,
              "limitPerBacker": 1,
              "name": "SIGNED BOOK + GALLERY PRINT (30x45cm)",
              "project": {
                "id": "UHJvamVjdC05MDQ3MDIxMTY="
              },
              "remainingQuantity": 9,
              "shippingPreference": "restricted",
              "shippingRules": [{
                  "cost": {
                    "amount": "6.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjk5NDQ4",
                  "location": {
                    "country": "DE",
                    "countryName": "Germany",
                    "displayableName": "Germany",
                    "id": "TG9jYXRpb24tMjM0MjQ4Mjk=",
                    "name": "Germany"
                  }
                },
                {
                  "cost": {
                    "amount": "15.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjk5NDUy",
                  "location": {
                    "country": "CH",
                    "countryName": "Switzerland",
                    "displayableName": "Switzerland",
                    "id": "TG9jYXRpb24tMjM0MjQ5NTc=",
                    "name": "Switzerland"
                  }
                },
                {
                  "cost": {
                    "amount": "15.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjk5NDUx",
                  "location": {
                    "country": "GB",
                    "countryName": "United Kingdom",
                    "displayableName": "United Kingdom",
                    "id": "TG9jYXRpb24tMjM0MjQ5NzU=",
                    "name": "United Kingdom"
                  }
                },
                {
                  "cost": {
                    "amount": "10.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjk5NDQ5",
                  "location": {
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
        "addOns": {
          "nodes": [{
              "amount": {
                "amount": "2.0",
                "currency": "EUR",
                "symbol": "€"
              },
              "backersCount": 68,
              "convertedAmount": {
                "amount": "3.0",
                "currency": "CAD",
                "symbol": "$"
              },
              "description": "A postcard with a surprise motiv from the book.",
              "displayName": "POSTCARD / POSTKARTE (€2)",
              "endsAt": null,
              "estimatedDeliveryOn": "2021-11-01",
              "id": "UmV3YXJkLTgzMzc3Mzc=",
              "isMaxPledge": false,
              "items": {
                "nodes": [
                  {
                    "id": "UmV3YXJkSXRlbS0xMjYzMTA5",
                    "name": "POSTCARD / POSTKARTE"
                  }
                ]
              },
              "limit": null,
              "limitPerBacker": 100,
              "name": "POSTCARD / POSTKARTE",
              "project": {
                "id": "UHJvamVjdC05MDQ3MDIxMTY="
              },
              "remainingQuantity": null,
              "shippingPreference": "unrestricted",
              "shippingRules": [{
                  "cost": {
                    "amount": "0.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjkxOTQz",
                  "location": {
                    "country": "ZZ",
                    "countryName": null,
                    "displayableName": "Earth",
                    "id": "TG9jYXRpb24tMQ==",
                    "name": "Rest of World"
                  }
                },
                {
                  "cost": {
                    "amount": "0.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjkxOTQ0",
                  "location": {
                    "country": "DE",
                    "countryName": "Germany",
                    "displayableName": "Germany",
                    "id": "TG9jYXRpb24tMjM0MjQ4Mjk=",
                    "name": "Germany"
                  }
                }
              ],
              "startsAt": null
            },
            {
              "amount": {
                "amount": "5.0",
                "currency": "EUR",
                "symbol": "€"
              },
              "backersCount": 17,
              "convertedAmount": {
                "amount": "8.0",
                "currency": "CAD",
                "symbol": "$"
              },
              "description": "A round (8cm diameter) sticker.",
              "displayName": "STICKER / AUFKLEBER (€5)",
              "endsAt": null,
              "estimatedDeliveryOn": "2021-11-01",
              "id": "UmV3YXJkLTgzMzc3MjY=",
              "isMaxPledge": false,
              "items": {
                "nodes": [
                  {
                    "id": "UmV3YXJkSXRlbS0xMjYzMTA3",
                    "name": "STICKER / AUFKLEBER"
                  }
                ]
              },
              "limit": null,
              "limitPerBacker": 100,
              "name": "STICKER / AUFKLEBER",
              "project": {
                "id": "UHJvamVjdC05MDQ3MDIxMTY="
              },
              "remainingQuantity": null,
              "shippingPreference": "unrestricted",
              "shippingRules": [{
                  "cost": {
                    "amount": "0.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjkxOTM0",
                  "location": {
                    "country": "ZZ",
                    "countryName": null,
                    "displayableName": "Earth",
                    "id": "TG9jYXRpb24tMQ==",
                    "name": "Rest of World"
                  }
                },
                {
                  "cost": {
                    "amount": "0.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNjkxOTM1",
                  "location": {
                    "country": "DE",
                    "countryName": "Germany",
                    "displayableName": "Germany",
                    "id": "TG9jYXRpb24tMjM0MjQ4Mjk=",
                    "name": "Germany"
                  }
                }
              ],
              "startsAt": null
            },
            {
              "amount": {
                "amount": "24.0",
                "currency": "EUR",
                "symbol": "€"
              },
              "backersCount": 6,
              "convertedAmount": {
                "amount": "36.0",
                "currency": "CAD",
                "symbol": "$"
              },
              "description": "First edition of the book.",
              "displayName": "FIRST EDITION / ERSTAUSGABE (€24)",
              "endsAt": null,
              "estimatedDeliveryOn": "2021-11-01",
              "id": "UmV3YXJkLTgzNjE3Njc=",
              "isMaxPledge": false,
              "items": {
                "nodes": [
                  {
                  "id": "UmV3YXJkSXRlbS0xMjYxMTQ1",
                  "name": "BOOK The Quiet"
                  }
                ]
              },
              "limit": null,
              "limitPerBacker": 10,
              "name": "FIRST EDITION / ERSTAUSGABE",
              "project": {
                "id": "UHJvamVjdC05MDQ3MDIxMTY="
              },
              "remainingQuantity": null,
              "shippingPreference": "unrestricted",
              "shippingRules": [{
                  "cost": {
                    "amount": "5.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNzQ5MzA0",
                  "location": {
                    "country": "ZZ",
                    "countryName": null,
                    "displayableName": "Earth",
                    "id": "TG9jYXRpb24tMQ==",
                    "name": "Rest of World"
                  }
                },
                {
                  "cost": {
                    "amount": "2.0",
                    "currency": "EUR",
                    "symbol": "€"
                  },
                  "id": "U2hpcHBpbmdSdWxlLTExNzQ5MzA1",
                  "location": {
                    "country": "DE",
                    "countryName": "Germany",
                    "displayableName": "Germany",
                    "id": "TG9jYXRpb24tMjM0MjQ4Mjk=",
                    "name": "Germany"
                  }
                }
              ],
              "startsAt": null
            }
          ]
        },
        "actions": {
          "displayConvertAmount": false
        },
        "backersCount": 147,
        "category": {
          "id": "Q2F0ZWdvcnktMjgw",
          "name": "Photobooks",
          "parentCategory": {
            "id": "Q2F0ZWdvcnktMTU=",
            "name": "Photography"
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
          "code": "DE",
          "name": "Germany"
        },
        "creator": {
          "chosenCurrency": null,
          "email": "theaschneider@gmx.net.ksr",
          "hasPassword": null,
          "id": "VXNlci0xNTMyMzU3OTk3",
          "imageUrl": "https://ksr-qa-ugc.imgix.net/assets/033/846/528/69cae8b2ccc2403e233b5715cb1f869f_original.png?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1623351187&auto=format&frame=1&q=92&s=d0d5f5993e64056e5ddf7e42b56e50cd",
          "isAppleConnected": null,
          "isCreator": true,
          "isDeliverable": null,
          "isEmailVerified": true,
          "name": "Thea Schneider",
          "uid": "1532357997",
          "storedCards": {
            "nodes": [],
            "totalCount": 0
          }
        },
        "currency": "EUR",
        "deadlineAt": 1628622000,
        "description": "A photographic book about the daily life and work on board of a Russian research vessel during the MOSAiC expedition in the Arctic.",
        "finalCollectionDate": null,
        "fxRate": 1.49694415,
        "friends": {
          "nodes": []
        },
        "goal": {
          "amount": "2000.0",
          "currency": "EUR",
          "symbol": "€"
        },
        "image": {
          "id": "UGhvdG8tMzM4NDYwNDQ=",
          "url": "https://ksr-qa-ugc.imgix.net/assets/033/846/044/7134a6f4504bd636327de703a1d2dd1c_original.jpg?ixlib=rb-4.0.2&crop=faces&w=1024&h=576&fit=crop&v=1623348736&auto=format&frame=1&q=92&s=a7b486e4831db1bcbf393201bc64a40a"
        },
        "isProjectWeLove": true,
        "isWatched": false,
        "launchedAt": 1625118948,
        "location": {
          "country": "DE",
          "countryName": "Germany",
          "displayableName": "München, Germany",
          "id": "TG9jYXRpb24tNjc2NzU2",
          "name": "München"
        },
        "name": "The Quiet",
        "pid": 904702116,
        "pledged": {
          "amount": "7826.6",
          "currency": "EUR",
          "symbol": "€"
        },
        "slug": "theaschneider/thequiet",
        "state": "LIVE",
        "stateChangedAt": 1625118950,
        "url": "https://staging.kickstarter.com/projects/theaschneider/thequiet",
        "usdExchangeRate": 1.18420975
      }
    }
    """

    let data = Data(json.utf8)
    var resultMap = (try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) ?? [:]

    /** NOTE: A lot of these mappings had to be customized to `GraphAPI` types from their raw data because the `ApolloClient` `fetch` and `perform` functions return `Query.Data` not raw json into their result handlers. This means that Apollo creates the models itself from the raw json returned before we can access them after the network request.
     */

    guard var projectResultMap = resultMap["project"] as? [String: Any],
      let countryResultMap = projectResultMap["country"] as? [String: Any] else {
      return resultMap
    }

    var updatedCountryResultMap = countryResultMap
    updatedCountryResultMap["code"] = KsApi.GraphAPI.CountryCode.de
    projectResultMap["country"] = updatedCountryResultMap
    projectResultMap["deadlineAt"] = "1628622000"
    projectResultMap["launchedAt"] = "1625118948"
    projectResultMap["stateChangedAt"] = "1625118950"
    projectResultMap["collaboratorPermissions"] = [
      KsApi.GraphAPI.CollaboratorPermission.editProject,
      KsApi.GraphAPI.CollaboratorPermission.editFaq,
      KsApi.GraphAPI.CollaboratorPermission.post,
      KsApi.GraphAPI.CollaboratorPermission.comment,
      KsApi.GraphAPI.CollaboratorPermission.viewPledges,
      KsApi.GraphAPI.CollaboratorPermission.fulfillment
    ]
    projectResultMap["state"] = KsApi.GraphAPI.ProjectState.live
    projectResultMap["currency"] = KsApi.GraphAPI.CurrencyCode.eur

    resultMap["project"] = projectResultMap

    return resultMap
  }

  private var erroredResultMap: [String: Any?] {
    return [:]
  }
}
