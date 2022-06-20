import Apollo
import Foundation
@testable import KsApi

public enum FetchProjectRewardsByIdQueryTemplate {
  case valid
  case errored

  /// `FetchProjectBySlug` returns identical data.
  var data: GraphAPI.FetchProjectRewardsByIdQuery.Data {
    switch self {
    case .valid:
      return GraphAPI.FetchProjectRewardsByIdQuery.Data(unsafeResultMap: self.validResultMap)
    case .errored:
      return GraphAPI.FetchProjectRewardsByIdQuery.Data(unsafeResultMap: self.erroredResultMap)
    }
  }

  // MARK: Private Properties

  private var validResultMap: [String: Any] {
    let json = """
    {
       "project":{
          "rewards":{
             "nodes":[
                {
                   "amount":{
                      "amount":"5.0",
                      "currency":"EUR",
                      "symbol":"€"
                   },
                   "localReceiptLocation": null,
                   "allowedAddons": {
                     "__typename": "RewardConnection",
                     "pageInfo": {
                       "__typename": "PageInfo",
                       "startCursor": "WzIsODMzNzczN10="
                     }
                   },
                   "backersCount":3,
                   "convertedAmount":{
                      "amount":"8.0",
                      "currency":"CAD",
                      "symbol":"$"
                   },
                   "description":"You’ll receive a personal email from me with a surprise gif, only available during the Kickstarter period! Thank you for you support! / Du erhältst eine persönliche E-Mail von mir mit einem Überraschungs-Gif, das nur während der Kickstarter-Periode verfügbar ist! Vielen Dank für deine Unterstützung!",
                   "displayName":"PERSONAL THANK YOU + SURPRISE GIF (€5)",
                   "endsAt":null,
                   "estimatedDeliveryOn":"2021-09-01",
                   "id":"UmV3YXJkLTgzMzQzNTk=",
                   "isMaxPledge":false,
                   "items": {
                     "__typename": "RewardItemsConnection",
                     "edges": []
                   },
                   "limit":null,
                   "limitPerBacker":1,
                   "name":"PERSONAL THANK YOU + SURPRISE GIF",
                   "project":{
                      "id":"UHJvamVjdC05MDQ3MDIxMTY=",
                      "story": "",
                      "risks": "",
                      "environmentalCommitments": [],
                      "faqs": {
                        "__typename": "ProjectFaqConnection",
                        "nodes": []
                     }
                   },
                   "remainingQuantity":null,
                   "shippingPreference":"none",
                   "shippingSummary": "Ships worldwide",
                   "shippingRules":[
                      
                   ],
                   "startsAt":null
                },
                {
                   "amount":{
                      "amount":"10.0",
                      "currency":"EUR",
                      "symbol":"€"
                   },
                   "localReceiptLocation": null,
                   "allowedAddons": {
                     "__typename": "RewardConnection",
                     "pageInfo": {
                       "__typename": "PageInfo",
                       "startCursor": "WzIsODMzNzczN10="
                     }
                   },
                   "backersCount":6,
                   "convertedAmount":{
                      "amount":"15.0",
                      "currency":"CAD",
                      "symbol":"$"
                   },
                   "description":"Surprise Set of 5 Postcards in the format DIN A6 (14,8 x 10,5 cm) with 5 different motives from the book / Überraschungsset aus 5 Postkarten mit 5 verschiedenen Motiven aus dem Buch",
                   "displayName":"SET OF 5 POSTCARDS (€10)",
                   "endsAt":null,
                   "estimatedDeliveryOn":"2021-11-01",
                   "id":"UmV3YXJkLTgzMzc3MTI=",
                   "isMaxPledge":false,
                   "items": {
                     "__typename": "RewardItemsConnection",
                     "edges": [
                       {
                         "__typename": "RewardItemEdge",
                         "quantity": 1,
                         "node": {
                           "__typename": "RewardItem",
                           "id": "UmV3YXJkSXRlbS0xMjYzMTA5",
                           "name": "POSTCARD / POSTKARTE"
                         }
                       }
                     ]
                   },
                   "limit":50,
                   "limitPerBacker":1,
                   "name":"SET OF 5 POSTCARDS",
                   "project":{
                      "id":"UHJvamVjdC05MDQ3MDIxMTY=",
                      "story": "",
                      "risks": "",
                      "environmentalCommitments": [],
                      "faqs": {
                        "__typename": "ProjectFaqConnection",
                        "nodes": []
                     }
                   },
                   "remainingQuantity":44,
                   "shippingPreference":"unrestricted",
                   "shippingSummary": "Ships worldwide",
                   "shippingRules":[
                      {
                         "cost":{
                            "amount":"10.0",
                            "currency":"EUR",
                            "symbol":"€"
                         },
                         "id":"U2hpcHBpbmdSdWxlLTExNjkxOTE2",
                         "location":{
                            "country":"ZZ",
                            "countryName":null,
                            "displayableName":"Earth",
                            "id":"TG9jYXRpb24tMQ==",
                            "name":"Rest of World"
                         }
                      },
                      {
                         "cost":{
                            "amount":"5.0",
                            "currency":"EUR",
                            "symbol":"€"
                         },
                         "id":"U2hpcHBpbmdSdWxlLTExNjkxOTE3",
                         "location":{
                            "country":"DE",
                            "countryName":"Germany",
                            "displayableName":"Germany",
                            "id":"TG9jYXRpb24tMjM0MjQ4Mjk=",
                            "name":"Germany"
                         }
                      },
                      {
                         "cost":{
                            "amount":"5.0",
                            "currency":"EUR",
                            "symbol":"€"
                         },
                         "id":"U2hpcHBpbmdSdWxlLTExNjkxOTE4",
                         "location":{
                            "country":"ZZ",
                            "countryName":null,
                            "displayableName":"European Union",
                            "id":"TG9jYXRpb24tNTU5NDkwNjg=",
                            "name":"European Union"
                         }
                      }
                   ],
                   "startsAt":null
                },
                {
                   "amount":{
                      "amount":"16.0",
                      "currency":"EUR",
                      "symbol":"€"
                   },
                   "localReceiptLocation": null,
                   "allowedAddons": {
                     "__typename": "RewardConnection",
                     "pageInfo": {
                       "__typename": "PageInfo",
                       "startCursor": null
                     }
                   },
                   "backersCount":10,
                   "convertedAmount":{
                      "amount":"24.0",
                      "currency":"CAD",
                      "symbol":"$"
                   },
                   "description":"Please be honest and only book this option if you are a pupil or student, who can not afford the normal pricing. First edition of the book The Quiet for the special price of 16€ (instead of 24€)./ Bitte sei so ehrlich und buche diese Option nur, wenn du ein*e Schüler*in oder Student*in bist, der*die sich nicht den normalen Preis leisten kann. Erstausgabe des Buchs The Quiet für einen ermäßigten Schüler- und Studentenpreis von 16€ (anstatt 24€).",
                   "displayName":"SPECIAL OFFER FOR PUPILS (€16)",
                   "endsAt":null,
                   "estimatedDeliveryOn":"2021-11-01",
                   "id":"UmV3YXJkLTgzMzQzOTY=",
                   "isMaxPledge":false,
                   "items": {
                     "__typename": "RewardItemsConnection",
                     "edges": [
                       {
                         "__typename": "RewardItemEdge",
                         "quantity": 1,
                         "node": {
                           "__typename": "RewardItem",
                           "id": "UmV3YXJkSXRlbS0xMjYxMTQ1",
                           "name":"BOOK The Quiet"
                         }
                       }
                     ]
                   },
                   "limit":10,
                   "limitPerBacker":1,
                   "name":"SPECIAL OFFER FOR PUPILS",
                   "project":{
                      "id":"UHJvamVjdC05MDQ3MDIxMTY=",
                      "story": "",
                      "risks": "",
                      "environmentalCommitments": [],
                      "faqs": {
                        "__typename": "ProjectFaqConnection",
                        "nodes": []
                     }
                   },
                   "remainingQuantity":0,
                   "shippingPreference":"unrestricted",
                   "shippingSummary": "Ships worldwide",
                   "shippingRules":[
                      {
                         "cost":{
                            "amount":"10.0",
                            "currency":"EUR",
                            "symbol":"€"
                         },
                         "id":"U2hpcHBpbmdSdWxlLTExNjgyMzI5",
                         "location":{
                            "country":"ZZ",
                            "countryName":null,
                            "displayableName":"Earth",
                            "id":"TG9jYXRpb24tMQ==",
                            "name":"Rest of World"
                         }
                      },
                      {
                         "cost":{
                            "amount":"5.0",
                            "currency":"EUR",
                            "symbol":"€"
                         },
                         "id":"U2hpcHBpbmdSdWxlLTExNjgyMzMw",
                         "location":{
                            "country":"DE",
                            "countryName":"Germany",
                            "displayableName":"Germany",
                            "id":"TG9jYXRpb24tMjM0MjQ4Mjk=",
                            "name":"Germany"
                         }
                      }
                   ],
                   "startsAt":null
                },
                {
                   "amount":{
                      "amount":"24.0",
                      "currency":"EUR",
                      "symbol":"€"
                   },
                   "localReceiptLocation": null,
                   "allowedAddons": {
                     "__typename": "RewardConnection",
                     "pageInfo": {
                       "__typename": "PageInfo",
                       "startCursor": "WzIsODMzNzczN10="
                     }
                   },
                   "backersCount":56,
                   "convertedAmount":{
                      "amount":"36.0",
                      "currency":"CAD",
                      "symbol":"$"
                   },
                   "description":"First edition of the book The Quiet / Erstausgabe des Buchs The Quiet.",
                   "displayName":"FIRST EDITON BOOK / ERSTAUSGABE (€24)",
                   "endsAt":null,
                   "estimatedDeliveryOn":"2021-11-01",
                   "id":"UmV3YXJkLTgzMzA3MDQ=",
                   "isMaxPledge":false,
                   "items": {
                     "__typename": "RewardItemsConnection",
                     "edges": [
                       {
                         "__typename": "RewardItemEdge",
                         "quantity": 1,
                         "node": {
                           "__typename": "RewardItem",
                           "id": "UmV3YXJkSXRlbS0xMjYxMTQ1",
                           "name":"BOOK The Quiet"
                         }
                       }
                     ]
                   },
                   "limit":null,
                   "limitPerBacker":1,
                   "name":"FIRST EDITON BOOK / ERSTAUSGABE",
                   "project":{
                      "id":"UHJvamVjdC05MDQ3MDIxMTY=",
                      "story": "",
                      "risks": "",
                      "environmentalCommitments": [],
                      "faqs": {
                        "__typename": "ProjectFaqConnection",
                        "nodes": []
                     }
                   },
                   "remainingQuantity":null,
                   "shippingPreference":"unrestricted",
                   "shippingSummary": "Ships worldwide",
                   "shippingRules":[
                      {
                         "cost":{
                            "amount":"10.0",
                            "currency":"EUR",
                            "symbol":"€"
                         },
                         "id":"U2hpcHBpbmdSdWxlLTExNjcxOTQx",
                         "location":{
                            "country":"ZZ",
                            "countryName":null,
                            "displayableName":"Earth",
                            "id":"TG9jYXRpb24tMQ==",
                            "name":"Rest of World"
                         }
                      },
                      {
                         "cost":{
                            "amount":"5.0",
                            "currency":"EUR",
                            "symbol":"€"
                         },
                         "id":"U2hpcHBpbmdSdWxlLTExNjcxODg1",
                         "location":{
                            "country":"DE",
                            "countryName":"Germany",
                            "displayableName":"Germany",
                            "id":"TG9jYXRpb24tMjM0MjQ4Mjk=",
                            "name":"Germany"
                         }
                      },
                      {
                         "cost":{
                            "amount":"7.0",
                            "currency":"EUR",
                            "symbol":"€"
                         },
                         "id":"U2hpcHBpbmdSdWxlLTExNjcxODg2",
                         "location":{
                            "country":"ZZ",
                            "countryName":null,
                            "displayableName":"European Union",
                            "id":"TG9jYXRpb24tNTU5NDkwNjg=",
                            "name":"European Union"
                         }
                      }
                   ],
                   "startsAt":null
                },
                {
                   "amount":{
                      "amount":"32.0",
                      "currency":"EUR",
                      "symbol":"€"
                   },
                   "localReceiptLocation": null,
                   "allowedAddons": {
                     "__typename": "RewardConnection",
                     "pageInfo": {
                       "__typename": "PageInfo",
                       "startCursor": null
                     }
                   },
                   "backersCount":10,
                   "convertedAmount":{
                      "amount":"48.0",
                      "currency":"CAD",
                      "symbol":"$"
                   },
                   "description":"Pay a little extra for your signed first edition of The Quiet with a personal inscription to help finance the lower price for the pupil edition. Thank you! / Bezahle einen etwas höheren Preis für deine signierte Erstausgabe des Buchs The Quiet mit persönlicher Widmung, um den niedrigeren Preis für die Schülerausgabe mitzufinanzieren. Danke!",
                   "displayName":"SIGNED BOOK + PUPIL SUPPORT (€32)",
                   "endsAt":null,
                   "estimatedDeliveryOn":"2021-11-01",
                   "id":"UmV3YXJkLTgzMzQzNjU=",
                   "isMaxPledge":false,
                   "items": {
                     "__typename": "RewardItemsConnection",
                     "edges": [
                       {
                         "__typename": "RewardItemEdge",
                         "quantity": 1,
                         "node": {
                           "__typename": "RewardItem",
                           "id": "UmV3YXJkSXRlbS0xMjYxMTQ1",
                           "name":"BOOK The Quiet"
                         }
                       }
                     ]
                   },
                   "limit":10,
                   "limitPerBacker":1,
                   "name":"SIGNED BOOK + PUPIL SUPPORT",
                   "project":{
                      "id":"UHJvamVjdC05MDQ3MDIxMTY=",
                      "story": "",
                      "risks": "",
                      "environmentalCommitments": [],
                      "faqs": {
                        "__typename": "ProjectFaqConnection",
                        "nodes": []
                     }
                   },
                   "remainingQuantity":0,
                   "shippingPreference":"unrestricted",
                   "shippingSummary": "Ships worldwide",
                   "shippingRules":[
                      {
                         "cost":{
                            "amount":"10.0",
                            "currency":"EUR",
                            "symbol":"€"
                         },
                         "id":"U2hpcHBpbmdSdWxlLTExNjgyMjcy",
                         "location":{
                            "country":"ZZ",
                            "countryName":null,
                            "displayableName":"Earth",
                            "id":"TG9jYXRpb24tMQ==",
                            "name":"Rest of World"
                         }
                      },
                      {
                         "cost":{
                            "amount":"5.0",
                            "currency":"EUR",
                            "symbol":"€"
                         },
                         "id":"U2hpcHBpbmdSdWxlLTExNjgyMjcz",
                         "location":{
                            "country":"DE",
                            "countryName":"Germany",
                            "displayableName":"Germany",
                            "id":"TG9jYXRpb24tMjM0MjQ4Mjk=",
                            "name":"Germany"
                         }
                      }
                   ],
                   "startsAt":null
                },
                {
                   "amount":{
                      "amount":"44.0",
                      "currency":"EUR",
                      "symbol":"€"
                   },
                   "localReceiptLocation": null,
                   "allowedAddons": {
                     "__typename": "RewardConnection",
                     "pageInfo": {
                       "__typename": "PageInfo",
                       "startCursor": null
                     }
                   },
                   "backersCount":21,
                   "convertedAmount":{
                      "amount":"66.0",
                      "currency":"CAD",
                      "symbol":"$"
                   },
                   "description":"Get 2 signed copies of the first edition of the book The Quiet - one for you and one for your loved ones. / Hol dir 2 signierte Erstausgaben des Buches The Quiet - eine für dich und eine für deine Lieben.",
                   "displayName":"2 SIGNED BOOKS / 2 SIGNIERTE BÜCHER (€44)",
                   "endsAt":null,
                   "estimatedDeliveryOn":"2021-11-01",
                   "id":"UmV3YXJkLTgzNDMwNDM=",
                   "isMaxPledge":false,
                   "items": {
                     "__typename": "RewardItemsConnection",
                     "edges": [
                       {
                         "__typename": "RewardItemEdge",
                         "quantity": 1,
                         "node": {
                           "__typename": "RewardItem",
                           "id": "UmV3YXJkSXRlbS0xMjYxMTQ1",
                           "name":"BOOK The Quiet"
                         }
                       }
                     ]
                   },
                   "limit":null,
                   "limitPerBacker":1,
                   "name":"2 SIGNED BOOKS / 2 SIGNIERTE BÜCHER",
                   "project":{
                      "id":"UHJvamVjdC05MDQ3MDIxMTY=",
                      "story": "",
                      "risks": "",
                      "environmentalCommitments": [],
                      "faqs": {
                        "__typename": "ProjectFaqConnection",
                        "nodes": []
                     }
                   },
                   "remainingQuantity":null,
                   "shippingPreference":"unrestricted",
                   "shippingSummary": "Ships worldwide",
                   "shippingRules":[
                      {
                         "cost":{
                            "amount":"10.0",
                            "currency":"EUR",
                            "symbol":"€"
                         },
                         "id":"U2hpcHBpbmdSdWxlLTExNzAzNDc2",
                         "location":{
                            "country":"ZZ",
                            "countryName":null,
                            "displayableName":"Earth",
                            "id":"TG9jYXRpb24tMQ==",
                            "name":"Rest of World"
                         }
                      },
                      {
                         "cost":{
                            "amount":"5.0",
                            "currency":"EUR",
                            "symbol":"€"
                         },
                         "id":"U2hpcHBpbmdSdWxlLTExNzAzNDc3",
                         "location":{
                            "country":"DE",
                            "countryName":"Germany",
                            "displayableName":"Germany",
                            "id":"TG9jYXRpb24tMjM0MjQ4Mjk=",
                            "name":"Germany"
                         }
                      }
                   ],
                   "startsAt":null
                },
                {
                   "amount":{
                      "amount":"50.0",
                      "currency":"EUR",
                      "symbol":"€"
                   },
                   "localReceiptLocation": null,
                   "allowedAddons": {
                     "__typename": "RewardConnection",
                     "pageInfo": {
                       "__typename": "PageInfo",
                       "startCursor": null
                     }
                   },
                   "backersCount":9,
                   "convertedAmount":{
                      "amount":"75.0",
                      "currency":"CAD",
                      "symbol":"$"
                   },
                   "description":"First edition of the book The Quiet and one of 10 limited edition prints of the photo Eisbären (20x30cm, numbered and signed) / Erstausgabe des Buchs The Quiet und einen von 10 limitierten Fotodrucken des Bildes Eisbären im Format 20 cm x 30 cm (nummeriert und signiert).",
                   "displayName":"BOOK + PRINT (Eisbären) (€50)",
                   "endsAt":null,
                   "estimatedDeliveryOn":"2021-11-01",
                   "id":"UmV3YXJkLTgzMzQyNDk=",
                   "isMaxPledge":false,
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
                           "id": "UmV3YXJkSXRlbS0xMjYxMTQ2",
                           "name": "SPECIAL EDITION PRINT (20cmx30cm)"
                         }
                       }
                     ]
                   },
                   "limit":10,
                   "limitPerBacker":1,
                   "name":"BOOK + PRINT (Eisbären)",
                   "project":{
                      "id":"UHJvamVjdC05MDQ3MDIxMTY=",
                      "story": "",
                      "risks": "",
                      "environmentalCommitments": [],
                      "faqs": {
                        "__typename": "ProjectFaqConnection",
                        "nodes": []
                     }
                   },
                   "remainingQuantity":1,
                   "shippingPreference":"unrestricted",
                   "shippingSummary": "Ships worldwide",
                   "shippingRules":[
                      {
                         "cost":{
                            "amount":"10.0",
                            "currency":"EUR",
                            "symbol":"€"
                         },
                         "id":"U2hpcHBpbmdSdWxlLTExNjgxOTk5",
                         "location":{
                            "country":"ZZ",
                            "countryName":null,
                            "displayableName":"Earth",
                            "id":"TG9jYXRpb24tMQ==",
                            "name":"Rest of World"
                         }
                      },
                      {
                         "cost":{
                            "amount":"5.0",
                            "currency":"EUR",
                            "symbol":"€"
                         },
                         "id":"U2hpcHBpbmdSdWxlLTExNjgyMDAw",
                         "location":{
                            "country":"DE",
                            "countryName":"Germany",
                            "displayableName":"Germany",
                            "id":"TG9jYXRpb24tMjM0MjQ4Mjk=",
                            "name":"Germany"
                         }
                      }
                   ],
                   "startsAt":null
                },
                {
                   "amount":{
                      "amount":"50.0",
                      "currency":"EUR",
                      "symbol":"€"
                   },
                   "localReceiptLocation": null,
                   "allowedAddons": {
                     "__typename": "RewardConnection",
                     "pageInfo": {
                       "__typename": "PageInfo",
                       "startCursor": null
                     }
                   },
                   "backersCount":10,
                   "convertedAmount":{
                      "amount":"75.0",
                      "currency":"CAD",
                      "symbol":"$"
                   },
                   "description":"First edition of the book The Quiet and one of 10 limited edition prints of the photo Aurora Borealis (20x30cm, numbered and signed) / Erstausgabe des Buchs The Quiet und einen von 10 limitierten Fotodrucken des Bildes Aurora Borealis im Format 20 cm x 30 cm (nummeriert und signiert).",
                   "displayName":"BOOK + PRINT (Aurora Borealis) (€50)",
                   "endsAt":null,
                   "estimatedDeliveryOn":"2021-11-01",
                   "id":"UmV3YXJkLTgzMzQyNTg=",
                   "isMaxPledge":false,
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
                           "id": "UmV3YXJkSXRlbS0xMjYxMTQ2",
                           "name": "SPECIAL EDITION PRINT (20cmx30cm)"
                         }
                       }
                     ]
                   },
                   "limit":10,
                   "limitPerBacker":1,
                   "name":"BOOK + PRINT (Aurora Borealis)",
                   "project":{
                      "id":"UHJvamVjdC05MDQ3MDIxMTY=",
                      "story": "",
                      "risks": "",
                      "environmentalCommitments": [],
                      "faqs": {
                        "__typename": "ProjectFaqConnection",
                        "nodes": []
                     }
                   },
                   "remainingQuantity":0,
                   "shippingPreference":"unrestricted",
                   "shippingSummary": "Ships worldwide",
                   "shippingRules":[
                      {
                         "cost":{
                            "amount":"10.0",
                            "currency":"EUR",
                            "symbol":"€"
                         },
                         "id":"U2hpcHBpbmdSdWxlLTExNjgyMDIx",
                         "location":{
                            "country":"ZZ",
                            "countryName":null,
                            "displayableName":"Earth",
                            "id":"TG9jYXRpb24tMQ==",
                            "name":"Rest of World"
                         }
                      },
                      {
                         "cost":{
                            "amount":"5.0",
                            "currency":"EUR",
                            "symbol":"€"
                         },
                         "id":"U2hpcHBpbmdSdWxlLTExNjgyMDIy",
                         "location":{
                            "country":"DE",
                            "countryName":"Germany",
                            "displayableName":"Germany",
                            "id":"TG9jYXRpb24tMjM0MjQ4Mjk=",
                            "name":"Germany"
                         }
                      }
                   ],
                   "startsAt":null
                },
                {
                   "amount":{
                      "amount":"50.0",
                      "currency":"EUR",
                      "symbol":"€"
                   },
                   "localReceiptLocation": null,
                   "allowedAddons": {
                     "__typename": "RewardConnection",
                     "pageInfo": {
                       "__typename": "PageInfo",
                       "startCursor": null
                     }
                   },
                   "backersCount":3,
                   "convertedAmount":{
                      "amount":"75.0",
                      "currency":"CAD",
                      "symbol":"$"
                   },
                   "description":"First edition of the book The Quiet and one of 10 limited edition prints of the photo Schnee (20x30cm, numbered and signed) / Erstausgabe des Buchs The Quiet und einen von 10 limitierten Fotodrucken des Bildes Schnee im Format 20 cm x 30 cm (nummeriert und signiert).",
                   "displayName":"BOOK + PRINT (Schnee) (€50)",
                   "endsAt":null,
                   "estimatedDeliveryOn":"2021-11-01",
                   "id":"UmV3YXJkLTgzNDExODg=",
                   "isMaxPledge":false,
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
                           "id": "UmV3YXJkSXRlbS0xMjYxMTQ2",
                           "name": "SPECIAL EDITION PRINT (20cmx30cm)"
                         }
                       }
                     ]
                   },
                   "limit":10,
                   "limitPerBacker":1,
                   "name":"BOOK + PRINT (Schnee)",
                   "project":{
                      "id":"UHJvamVjdC05MDQ3MDIxMTY=",
                      "story": "",
                      "risks": "",
                      "environmentalCommitments": [],
                      "faqs": {
                        "__typename": "ProjectFaqConnection",
                        "nodes": []
                     }
                   },
                   "remainingQuantity":7,
                   "shippingPreference":"unrestricted",
                   "shippingSummary": "Ships worldwide",
                   "shippingRules":[
                      {
                         "cost":{
                            "amount":"10.0",
                            "currency":"EUR",
                            "symbol":"€"
                         },
                         "id":"U2hpcHBpbmdSdWxlLTExNjk5NDY0",
                         "location":{
                            "country":"ZZ",
                            "countryName":null,
                            "displayableName":"Earth",
                            "id":"TG9jYXRpb24tMQ==",
                            "name":"Rest of World"
                         }
                      },
                      {
                         "cost":{
                            "amount":"5.0",
                            "currency":"EUR",
                            "symbol":"€"
                         },
                         "id":"U2hpcHBpbmdSdWxlLTExNjk5NDY1",
                         "location":{
                            "country":"DE",
                            "countryName":"Germany",
                            "displayableName":"Germany",
                            "id":"TG9jYXRpb24tMjM0MjQ4Mjk=",
                            "name":"Germany"
                         }
                      }
                   ],
                   "startsAt":null
                },
                {
                   "amount":{
                      "amount":"100.0",
                      "currency":"EUR",
                      "symbol":"€"
                   },
                   "localReceiptLocation": null,
                   "allowedAddons": {
                     "__typename": "RewardConnection",
                     "pageInfo": {
                       "__typename": "PageInfo",
                       "startCursor": null
                     }
                   },
                   "backersCount":4,
                   "convertedAmount":{
                      "amount":"150.0",
                      "currency":"CAD",
                      "symbol":"$"
                   },
                   "description":"First edition of the book The Quiet and one of 10 limited edition prints of the photo Spalte im Eis (30x45cm, numbered and signed) / Erstausgabe des Buchs The Quiet und einen von 10 limitierten Fotodrucken des Bildes Spalte im Eis im Format 30x45cm (nummeriert und signiert).",
                   "displayName":"BOOK + PRINT (Spalte im Eis) (€100)",
                   "endsAt":null,
                   "estimatedDeliveryOn":"2021-11-01",
                   "id":"UmV3YXJkLTgzMzQyNDI=",
                   "isMaxPledge":false,
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
                           "id": "UmV3YXJkSXRlbS0xMjY1MjY2",
                           "name": "SPECIAL EDITION PRINT (30cmx45cm)"
                         }
                       }
                     ]
                   },
                   "limit":10,
                   "limitPerBacker":1,
                   "name":"BOOK + PRINT (Spalte im Eis)",
                   "project":{
                      "id":"UHJvamVjdC05MDQ3MDIxMTY=",
                      "story": "",
                      "risks": "",
                      "environmentalCommitments": [],
                      "faqs": {
                        "__typename": "ProjectFaqConnection",
                        "nodes": []
                     }
                   },
                   "remainingQuantity":6,
                   "shippingPreference":"unrestricted",
                   "shippingSummary": "Ships worldwide",
                   "shippingRules":[
                      {
                         "cost":{
                            "amount":"10.0",
                            "currency":"EUR",
                            "symbol":"€"
                         },
                         "id":"U2hpcHBpbmdSdWxlLTExNjgxOTg1",
                         "location":{
                            "country":"ZZ",
                            "countryName":null,
                            "displayableName":"Earth",
                            "id":"TG9jYXRpb24tMQ==",
                            "name":"Rest of World"
                         }
                      },
                      {
                         "cost":{
                            "amount":"5.0",
                            "currency":"EUR",
                            "symbol":"€"
                         },
                         "id":"U2hpcHBpbmdSdWxlLTExNjgxOTg2",
                         "location":{
                            "country":"DE",
                            "countryName":"Germany",
                            "displayableName":"Germany",
                            "id":"TG9jYXRpb24tMjM0MjQ4Mjk=",
                            "name":"Germany"
                         }
                      }
                   ],
                   "startsAt":null
                },
                {
                   "amount":{
                      "amount":"100.0",
                      "currency":"EUR",
                      "symbol":"€"
                   },
                   "localReceiptLocation": null,
                   "allowedAddons": {
                     "__typename": "RewardConnection",
                     "pageInfo": {
                       "__typename": "PageInfo",
                       "startCursor": null
                     }
                   },
                   "backersCount":6,
                   "convertedAmount":{
                      "amount":"150.0",
                      "currency":"CAD",
                      "symbol":"$"
                   },
                   "description":"First edition of the book The Quiet and one of 10 limited edition prints of the photo Meereis (30x45cm, numbered and signed) / Erstausgabe des Buchs The Quiet und einen von 10 limitierten Fotodrucken des Bildes Meereis im Format 30x45cm (nummeriert und signiert).",
                   "displayName":"BOOK + PRINT (Meereis) (€100)",
                   "endsAt":null,
                   "estimatedDeliveryOn":"2021-11-01",
                   "id":"UmV3YXJkLTgzMzQyNTY=",
                   "isMaxPledge":false,
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
                           "id": "UmV3YXJkSXRlbS0xMjY1MjY2",
                           "name": "SPECIAL EDITION PRINT (30cmx45cm)"
                         }
                       }
                     ]
                   },
                   "limit":10,
                   "limitPerBacker":1,
                   "name":"BOOK + PRINT (Meereis)",
                   "project":{
                      "id":"UHJvamVjdC05MDQ3MDIxMTY=",
                      "story": "",
                      "risks": "",
                      "environmentalCommitments": [],
                      "faqs": {
                        "__typename": "ProjectFaqConnection",
                        "nodes": []
                     }
                   },
                   "remainingQuantity":4,
                   "shippingPreference":"unrestricted",
                   "shippingSummary": "Ships worldwide",
                   "shippingRules":[
                      {
                         "cost":{
                            "amount":"10.0",
                            "currency":"EUR",
                            "symbol":"€"
                         },
                         "id":"U2hpcHBpbmdSdWxlLTExNjgyMDE3",
                         "location":{
                            "country":"ZZ",
                            "countryName":null,
                            "displayableName":"Earth",
                            "id":"TG9jYXRpb24tMQ==",
                            "name":"Rest of World"
                         }
                      },
                      {
                         "cost":{
                            "amount":"5.0",
                            "currency":"EUR",
                            "symbol":"€"
                         },
                         "id":"U2hpcHBpbmdSdWxlLTExNjgyMDE4",
                         "location":{
                            "country":"DE",
                            "countryName":"Germany",
                            "displayableName":"Germany",
                            "id":"TG9jYXRpb24tMjM0MjQ4Mjk=",
                            "name":"Germany"
                         }
                      }
                   ],
                   "startsAt":null
                },
                {
                   "amount":{
                      "amount":"250.0",
                      "currency":"EUR",
                      "symbol":"€"
                   },
                   "localReceiptLocation": null,
                   "allowedAddons": {
                     "__typename": "RewardConnection",
                     "pageInfo": {
                       "__typename": "PageInfo",
                       "startCursor": null
                     }
                   },
                   "backersCount":3,
                   "convertedAmount":{
                      "amount":"374.0",
                      "currency":"CAD",
                      "symbol":"$"
                   },
                   "description":"First edition of the book The Quiet and one of 10 limited edition prints of the photo Arktisches Licht (50x75cm, numbered and signed) / Erstausgabe des Buchs The Quiet und einen von 10 limitierten Fotodrucken des Bildes Arktisches Licht im Format 50x75cm (nummeriert und signiert).",
                   "displayName":"BOOK + PRINT (Arktisches Licht) (€250)",
                   "endsAt":null,
                   "estimatedDeliveryOn":"2021-11-01",
                   "id":"UmV3YXJkLTgzNDExODM=",
                   "isMaxPledge":false,
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
                           "id": "UmV3YXJkSXRlbS0xMjY1ODIz",
                           "name": "SPECIAL EDITION PRINT (50cmx75cm)"
                         }
                       }
                     ]
                   },
                   "limit":10,
                   "limitPerBacker":1,
                   "name":"BOOK + PRINT (Arktisches Licht)",
                   "project":{
                      "id":"UHJvamVjdC05MDQ3MDIxMTY=",
                      "story": "",
                      "risks": "",
                      "environmentalCommitments": [],
                      "faqs": {
                        "__typename": "ProjectFaqConnection",
                        "nodes": []
                     }
                   },
                   "remainingQuantity":7,
                   "shippingPreference":"unrestricted",
                   "shippingSummary": "Ships worldwide",
                   "shippingRules":[
                      {
                         "cost":{
                            "amount":"10.0",
                            "currency":"EUR",
                            "symbol":"€"
                         },
                         "id":"U2hpcHBpbmdSdWxlLTExNjk5NDUz",
                         "location":{
                            "country":"ZZ",
                            "countryName":null,
                            "displayableName":"Earth",
                            "id":"TG9jYXRpb24tMQ==",
                            "name":"Rest of World"
                         }
                      },
                      {
                         "cost":{
                            "amount":"5.0",
                            "currency":"EUR",
                            "symbol":"€"
                         },
                         "id":"U2hpcHBpbmdSdWxlLTExNjk5NDU0",
                         "location":{
                            "country":"DE",
                            "countryName":"Germany",
                            "displayableName":"Germany",
                            "id":"TG9jYXRpb24tMjM0MjQ4Mjk=",
                            "name":"Germany"
                         }
                      }
                   ],
                   "startsAt":null
                },
                {
                   "amount":{
                      "amount":"250.0",
                      "currency":"EUR",
                      "symbol":"€"
                   },
                   "localReceiptLocation": null,
                   "allowedAddons": {
                     "__typename": "RewardConnection",
                     "pageInfo": {
                       "__typename": "PageInfo",
                       "startCursor": null
                     }
                   },
                   "backersCount":1,
                   "convertedAmount":{
                      "amount":"374.0",
                      "currency":"CAD",
                      "symbol":"$"
                   },
                   "description":"First edition of the book The Quiet and one of 10 limited edition prints of the photo Das erste Eis (50x75cm, numbered and signed) / Erstausgabe des Buchs The Quiet und einen von 10 limitierten Fotodrucken des Bildes Das erste Eis im Format 50x75cm (nummeriert und signiert).",
                   "displayName":"BOOK + PRINT (Das erste Eis) (€250)",
                   "endsAt":null,
                   "estimatedDeliveryOn":"2021-11-01",
                   "id":"UmV3YXJkLTgzNDExODU=",
                   "isMaxPledge":false,
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
                           "id": "UmV3YXJkSXRlbS0xMjY1ODIz",
                           "name": "SPECIAL EDITION PRINT (50cmx75cm)"
                         }
                       }
                     ]
                   },
                   "limit":10,
                   "limitPerBacker":1,
                   "name":"BOOK + PRINT (Das erste Eis)",
                   "project":{
                      "id":"UHJvamVjdC05MDQ3MDIxMTY=",
                      "story": "",
                      "risks": "",
                      "environmentalCommitments": [],
                      "faqs": {
                        "__typename": "ProjectFaqConnection",
                        "nodes": []
                     }
                   },
                   "remainingQuantity":9,
                   "shippingPreference":"unrestricted",
                   "shippingSummary": "Ships worldwide",
                   "shippingRules":[
                      {
                         "cost":{
                            "amount":"10.0",
                            "currency":"EUR",
                            "symbol":"€"
                         },
                         "id":"U2hpcHBpbmdSdWxlLTExNjk5NDU4",
                         "location":{
                            "country":"ZZ",
                            "countryName":null,
                            "displayableName":"Earth",
                            "id":"TG9jYXRpb24tMQ==",
                            "name":"Rest of World"
                         }
                      },
                      {
                         "cost":{
                            "amount":"5.0",
                            "currency":"EUR",
                            "symbol":"€"
                         },
                         "id":"U2hpcHBpbmdSdWxlLTExNjk5NDU5",
                         "location":{
                            "country":"DE",
                            "countryName":"Germany",
                            "displayableName":"Germany",
                            "id":"TG9jYXRpb24tMjM0MjQ4Mjk=",
                            "name":"Germany"
                         }
                      }
                   ],
                   "startsAt":null
                },
                {
                   "amount":{
                      "amount":"400.0",
                      "currency":"EUR",
                      "symbol":"€"
                   },
                   "localReceiptLocation": {
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
                   "backersCount":1,
                   "convertedAmount":{
                      "amount":"599.0",
                      "currency":"CAD",
                      "symbol":"$"
                   },
                   "description":"Signed first edition of the book The Quiet with a personal inscription and one of 10 limited edition gallery prints (numbered and signed) on Aluminium Dibond of a photo of your choice from the book (Format: 30x45cm) / Signierte Erstausgabe des Buchs The Quiet mit einer persönlichen WIdmung und einem von 10 limitierten Alu-Dibond Galleryprint (nummeriert und signiert) eines Fotos deiner Wahl aus dem Buch im Format 30 cm x 45 cm.",
                   "displayName":"SIGNED BOOK + GALLERY PRINT (30x45cm) (€400)",
                   "endsAt":null,
                   "estimatedDeliveryOn":"2021-11-01",
                   "id":"UmV3YXJkLTgzNDExODA=",
                   "isMaxPledge":false,
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
                   "limit":10,
                   "limitPerBacker":1,
                   "name":"SIGNED BOOK + GALLERY PRINT (30x45cm)",
                   "project":{
                      "id":"UHJvamVjdC05MDQ3MDIxMTY=",
                      "story": "",
                      "risks": "",
                      "environmentalCommitments": [],
                      "faqs": {
                        "__typename": "ProjectFaqConnection",
                        "nodes": []
                     }
                   },
                   "remainingQuantity":9,
                   "shippingPreference":"restricted",
                   "shippingSummary": "Ships worldwide",
                   "shippingRules":[
                      {
                         "cost":{
                            "amount":"6.0",
                            "currency":"EUR",
                            "symbol":"€"
                         },
                         "id":"U2hpcHBpbmdSdWxlLTExNjk5NDQ4",
                         "location":{
                            "country":"DE",
                            "countryName":"Germany",
                            "displayableName":"Germany",
                            "id":"TG9jYXRpb24tMjM0MjQ4Mjk=",
                            "name":"Germany"
                         }
                      },
                      {
                         "cost":{
                            "amount":"15.0",
                            "currency":"EUR",
                            "symbol":"€"
                         },
                         "id":"U2hpcHBpbmdSdWxlLTExNjk5NDUy",
                         "location":{
                            "country":"CH",
                            "countryName":"Switzerland",
                            "displayableName":"Switzerland",
                            "id":"TG9jYXRpb24tMjM0MjQ5NTc=",
                            "name":"Switzerland"
                         }
                      },
                      {
                         "cost":{
                            "amount":"15.0",
                            "currency":"EUR",
                            "symbol":"€"
                         },
                         "id":"U2hpcHBpbmdSdWxlLTExNjk5NDUx",
                         "location":{
                            "country":"GB",
                            "countryName":"United Kingdom",
                            "displayableName":"United Kingdom",
                            "id":"TG9jYXRpb24tMjM0MjQ5NzU=",
                            "name":"United Kingdom"
                         }
                      },
                      {
                         "cost":{
                            "amount":"10.0",
                            "currency":"EUR",
                            "symbol":"€"
                         },
                         "id":"U2hpcHBpbmdSdWxlLTExNjk5NDQ5",
                         "location":{
                            "country":"ZZ",
                            "countryName":null,
                            "displayableName":"European Union",
                            "id":"TG9jYXRpb24tNTU5NDkwNjg=",
                            "name":"European Union"
                         }
                      }
                   ],
                   "startsAt":null
                }
             ]
          },
          "__typename":"Project"
       }
    }
    """

    let data = Data(json.utf8)
    var resultMap = (try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) ?? [:]

    return resultMap
  }

  private var erroredResultMap: [String: Any?] {
    return [:]
  }
}
