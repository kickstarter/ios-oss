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
    "available": false,
                   "items": {
                     "__typename": "RewardItemsConnection",
                     "edges": []
                   },
                  "latePledgeAmount": {
                      "amount":"5.0",
                      "currency":"EUR",
                      "symbol":"€"
                   },
                   "limit":null,
                   "limitPerBacker":1,
                   "name":"PERSONAL THANK YOU + SURPRISE GIF",
                   "pledgeAmount": {
                      "amount":"5.0",
                      "currency":"EUR",
                      "symbol":"€"
                   },
                   "postCampaignPledgingEnabled":false,
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
                   "startsAt":null,
                   "audienceData": {
                     "__typename": "ResourceAudience",
                     "secret": false
                   }
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
    "available": false,
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
                   "latePledgeAmount": {
                      "amount":"5.0",
                      "currency":"EUR",
                      "symbol":"€"
                   },
                   "limit":50,
                   "limitPerBacker":1,
                   "name":"SET OF 5 POSTCARDS",
                   "pledgeAmount": {
                      "amount":"5.0",
                      "currency":"EUR",
                      "symbol":"€"
                   },
                   "postCampaignPledgingEnabled": false,
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
                   "startsAt":null,
                   "audienceData": {
                     "__typename": "ResourceAudience",
                     "secret": false
                   }
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
                           "name":"BOOK The Quiet"
                         }
                       }
                     ]
                   },
                   "latePledgeAmount": {
                      "amount":"5.0",
                      "currency":"EUR",
                      "symbol":"€"
                   },
                   "limit":10,
                   "limitPerBacker":1,
                   "name":"SPECIAL OFFER FOR PUPILS",
                   "pledgeAmount": {
                      "amount":"5.0",
                      "currency":"EUR",
                      "symbol":"€"
                   },
                   "postCampaignPledgingEnabled": false,
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
                   "startsAt":null,
                   "audienceData": {
                     "__typename": "ResourceAudience",
                     "secret": false
                   }
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
                           "name":"BOOK The Quiet"
                         }
                       }
                     ]
                   },
                   "latePledgeAmount": {
                      "amount":"5.0",
                      "currency":"EUR",
                      "symbol":"€"
                   },
                   "limit":null,
                   "limitPerBacker":1,
                   "name":"FIRST EDITON BOOK / ERSTAUSGABE",
                   "pledgeAmount": {
                      "amount":"5.0",
                      "currency":"EUR",
                      "symbol":"€"
                   },
                   "postCampaignPledgingEnabled": false,
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
                   "startsAt":null,
                   "audienceData": {
                     "__typename": "ResourceAudience",
                     "secret": false
                   }
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
                           "name":"BOOK The Quiet"
                         }
                       }
                     ]
                   },
                   "latePledgeAmount": {
                      "amount":"5.0",
                      "currency":"EUR",
                      "symbol":"€"
                   },
                   "limit":10,
                   "limitPerBacker":1,
                   "name":"SIGNED BOOK + PUPIL SUPPORT",
                   "pledgeAmount": {
                      "amount":"5.0",
                      "currency":"EUR",
                      "symbol":"€"
                   },
                   "postCampaignPledgingEnabled": false,
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
                   "startsAt":null,
                   "audienceData": {
                     "__typename": "ResourceAudience",
                     "secret": false
                   }
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
                           "name":"BOOK The Quiet"
                         }
                       }
                     ]
                   },
                   "latePledgeAmount": {
                      "amount":"5.0",
                      "currency":"EUR",
                      "symbol":"€"
                   },
                   "limit":null,
                   "limitPerBacker":1,
                   "name":"2 SIGNED BOOKS / 2 SIGNIERTE BÜCHER",
                   "pledgeAmount": {
                      "amount":"5.0",
                      "currency":"EUR",
                      "symbol":"€"
                   },
                   "postCampaignPledgingEnabled": false,
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
                   "startsAt":null,
                   "audienceData": {
                     "__typename": "ResourceAudience",
                     "secret": false
                   }
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
                           "id": "UmV3YXJkSXRlbS0xMjYxMTQ2",
                           "name": "SPECIAL EDITION PRINT (20cmx30cm)"
                         }
                       }
                     ]
                   },
                       "latePledgeAmount": {
                          "amount":"5.0",
                          "currency":"EUR",
                          "symbol":"€"
                       },
                   "limit":10,
                   "limitPerBacker":1,
                   "name":"BOOK + PRINT (Eisbären)",
                       "pledgeAmount": {
                          "amount":"5.0",
                          "currency":"EUR",
                          "symbol":"€"
                       },
                   "postCampaignPledgingEnabled": false,
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
                   "startsAt":null,
                   "audienceData": {
                     "__typename": "ResourceAudience",
                     "secret": false
                   }
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
                           "id": "UmV3YXJkSXRlbS0xMjYxMTQ2",
                           "name": "SPECIAL EDITION PRINT (20cmx30cm)"
                         }
                       }
                     ]
                   },
                       "latePledgeAmount": {
                          "amount":"5.0",
                          "currency":"EUR",
                          "symbol":"€"
                       },
                   "limit":10,
                   "limitPerBacker":1,
                   "name":"BOOK + PRINT (Aurora Borealis)",
                       "pledgeAmount": {
                          "amount":"5.0",
                          "currency":"EUR",
                          "symbol":"€"
                       },
                   "postCampaignPledgingEnabled": false,
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
                   "startsAt":null,
                   "audienceData": {
                     "__typename": "ResourceAudience",
                     "secret": false
                   }
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
                           "id": "UmV3YXJkSXRlbS0xMjYxMTQ2",
                           "name": "SPECIAL EDITION PRINT (20cmx30cm)"
                         }
                       }
                     ]
                   },
                       "latePledgeAmount": {
                          "amount":"5.0",
                          "currency":"EUR",
                          "symbol":"€"
                       },
                   "limit":10,
                   "limitPerBacker":1,
                   "name":"BOOK + PRINT (Schnee)",
                       "pledgeAmount": {
                          "amount":"5.0",
                          "currency":"EUR",
                          "symbol":"€"
                       },
                   "postCampaignPledgingEnabled": false,
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
                   "startsAt":null,
                   "audienceData": {
                     "__typename": "ResourceAudience",
                     "secret": false
                   }
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
                           "id": "UmV3YXJkSXRlbS0xMjY1MjY2",
                           "name": "SPECIAL EDITION PRINT (30cmx45cm)"
                         }
                       }
                     ]
                   },
                       "latePledgeAmount": {
                          "amount":"5.0",
                          "currency":"EUR",
                          "symbol":"€"
                       },
                   "limit":10,
                   "limitPerBacker":1,
                   "name":"BOOK + PRINT (Spalte im Eis)",
                       "pledgeAmount": {
                          "amount":"5.0",
                          "currency":"EUR",
                          "symbol":"€"
                       },
                   "postCampaignPledgingEnabled": false,
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
                   "startsAt":null,
                   "audienceData": {
                     "__typename": "ResourceAudience",
                     "secret": false
                   }
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
                           "id": "UmV3YXJkSXRlbS0xMjY1MjY2",
                           "name": "SPECIAL EDITION PRINT (30cmx45cm)"
                         }
                       }
                     ]
                   },
                       "latePledgeAmount": {
                          "amount":"5.0",
                          "currency":"EUR",
                          "symbol":"€"
                       },
                   "limit":10,
                   "limitPerBacker":1,
                   "name":"BOOK + PRINT (Meereis)",
                       "pledgeAmount": {
                          "amount":"5.0",
                          "currency":"EUR",
                          "symbol":"€"
                       },
                   "postCampaignPledgingEnabled": false,
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
                   "startsAt":null,
                   "audienceData": {
                     "__typename": "ResourceAudience",
                     "secret": false
                   }
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
                           "id": "UmV3YXJkSXRlbS0xMjY1ODIz",
                           "name": "SPECIAL EDITION PRINT (50cmx75cm)"
                         }
                       }
                     ]
                   },
                       "latePledgeAmount": {
                          "amount":"5.0",
                          "currency":"EUR",
                          "symbol":"€"
                       },
                   "limit":10,
                   "limitPerBacker":1,
                   "name":"BOOK + PRINT (Arktisches Licht)",
                       "pledgeAmount": {
                          "amount":"5.0",
                          "currency":"EUR",
                          "symbol":"€"
                       },
                   "postCampaignPledgingEnabled": false,
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
                   "startsAt":null,
                   "audienceData": {
                     "__typename": "ResourceAudience",
                     "secret": false
                   }
                },
                {
                  "available" : true,
                  "project" : {
                    "__typename" : "Project",
                    "id" : "UHJvamVjdC0xMTg3NjM3ODg3"
                  },
                  "latePledgeAmount" : {
                    "__typename" : "Money",
                    "currency" : "USD",
                    "symbol" : "$",
                    "amount" : "5.0"
                  },
                  "pledgeAmount" : {
                    "amount" : "1.0",
                    "currency" : "USD",
                    "symbol" : "$",
                    "__typename" : "Money"
                  },
                  "endsAt" : null,
                  "items" : {
                    "edges" : [
                      {
                        "node" : {
                          "__typename" : "RewardItem",
                          "id" : "UmV3YXJkSXRlbS0yNTcyODA4",
                          "name" : "T-Shirt 2"
                        },
                        "quantity" : 1,
                        "__typename" : "RewardItemEdge"
                      }
                    ],
                    "__typename" : "RewardItemsConnection"
                  },
                  "convertedAmount" : {
                    "symbol" : "$",
                    "amount" : "5.0",
                    "currency" : "USD",
                    "__typename" : "Money"
                  },
                  "localReceiptLocation" : null,
                  "shippingRules" : [
                    {
                      "estimatedMax" : null,
                      "location" : {
                        "name" : "European Union",
                        "id" : "TG9jYXRpb24tNTU5NDkwNjg=",
                        "country" : "ZZ",
                        "__typename" : "Location",
                        "countryName" : null,
                        "displayableName" : "European Union"
                      },
                      "estimatedMin" : null,
                      "__typename" : "ShippingRule",
                      "id" : "U2hpcHBpbmdSdWxlLTE1NjMwMjA2",
                      "cost" : {
                        "amount" : "5.0",
                        "symbol" : "$",
                        "currency" : "USD",
                        "__typename" : "Money"
                      }
                    }
                  ],
                  "limitPerBacker" : 1,
                  "description" : "Charging shipping to EU $5",
                  "id" : "UmV3YXJkLTEwMDU0MTI1",
                  "remainingQuantity" : null,
                  "amount" : {
                    "amount" : "5.0",
                    "symbol" : "$",
                    "__typename" : "Money",
                    "currency" : "USD"
                  },
                  "shippingSummary" : "Only European Union",
                  "displayName" : "Testing charge shipping just EU ($1)",
                  "simpleShippingRulesExpanded" : [
                    {
                      "country" : "AT",
                      "locationId" : "TG9jYXRpb24tMjM0MjQ3NTA=",
                      "estimatedMin" : "2",
                      "cost" : "5.0",
                      "estimatedMax" : "10",
                      "locationName" : "Austria",
                      "__typename" : "SimpleShippingRule",
                      "currency" : "USD"
                    },
                    {
                      "locationName" : "Belgium",
                      "__typename" : "SimpleShippingRule",
                      "estimatedMax" : null,
                      "cost" : "5.0",
                      "estimatedMin" : null,
                      "locationId" : "TG9jYXRpb24tMjM0MjQ3NTc=",
                      "currency" : "USD",
                      "country" : "BE"
                    },
                    {
                      "__typename" : "SimpleShippingRule",
                      "locationName" : "Bulgaria",
                      "estimatedMax" : null,
                      "estimatedMin" : null,
                      "country" : "BG",
                      "currency" : "USD",
                      "cost" : "5.0",
                      "locationId" : "TG9jYXRpb24tMjM0MjQ3NzE="
                    },
                    {
                      "estimatedMax" : null,
                      "country" : "HR",
                      "locationId" : "TG9jYXRpb24tMjM0MjQ4NDM=",
                      "__typename" : "SimpleShippingRule",
                      "cost" : "5.0",
                      "currency" : "USD",
                      "estimatedMin" : null,
                      "locationName" : "Croatia"
                    },
                    {
                      "locationName" : "Cyprus",
                      "estimatedMax" : null,
                      "__typename" : "SimpleShippingRule",
                      "country" : "CY",
                      "cost" : "5.0",
                      "currency" : "USD",
                      "locationId" : "TG9jYXRpb24tMjY4MTIzNDY=",
                      "estimatedMin" : null
                    },
                    {
                      "locationName" : "Czech Republic",
                      "currency" : "USD",
                      "estimatedMin" : null,
                      "estimatedMax" : null,
                      "__typename" : "SimpleShippingRule",
                      "locationId" : "TG9jYXRpb24tMjM0MjQ4MTA=",
                      "cost" : "5.0",
                      "country" : "CZ"
                    },
                    {
                      "cost" : "5.0",
                      "estimatedMin" : null,
                      "locationId" : "TG9jYXRpb24tMjM0MjQ3OTY=",
                      "__typename" : "SimpleShippingRule",
                      "country" : "DK",
                      "currency" : "USD",
                      "estimatedMax" : null,
                      "locationName" : "Denmark"
                    },
                    {
                      "locationId" : "TG9jYXRpb24tMjM0MjQ4MDU=",
                      "cost" : "5.0",
                      "estimatedMax" : null,
                      "currency" : "USD",
                      "estimatedMin" : null,
                      "locationName" : "Estonia",
                      "country" : "EE",
                      "__typename" : "SimpleShippingRule"
                    },
                    {
                      "locationName" : "Finland",
                      "estimatedMin" : null,
                      "estimatedMax" : null,
                      "currency" : "USD",
                      "cost" : "5.0",
                      "country" : "FI",
                      "locationId" : "TG9jYXRpb24tMjM0MjQ4MTI=",
                      "__typename" : "SimpleShippingRule"
                    },
                    {
                      "estimatedMax" : null,
                      "__typename" : "SimpleShippingRule",
                      "locationId" : "TG9jYXRpb24tMjM0MjQ4MTk=",
                      "locationName" : "France",
                      "cost" : "5.0",
                      "estimatedMin" : null,
                      "currency" : "USD",
                      "country" : "FR"
                    },
                    {
                      "estimatedMin" : null,
                      "locationName" : "Germany",
                      "cost" : "5.0",
                      "estimatedMax" : null,
                      "currency" : "USD",
                      "country" : "DE",
                      "locationId" : "TG9jYXRpb24tMjM0MjQ4Mjk=",
                      "__typename" : "SimpleShippingRule"
                    },
                    {
                      "locationName" : "Greece",
                      "currency" : "USD",
                      "locationId" : "TG9jYXRpb24tMjM0MjQ4MzM=",
                      "estimatedMax" : null,
                      "cost" : "5.0",
                      "__typename" : "SimpleShippingRule",
                      "estimatedMin" : null,
                      "country" : "GR"
                    },
                    {
                      "currency" : "USD",
                      "estimatedMax" : null,
                      "country" : "HU",
                      "__typename" : "SimpleShippingRule",
                      "locationName" : "Hungary",
                      "estimatedMin" : null,
                      "cost" : "5.0",
                      "locationId" : "TG9jYXRpb24tMjM0MjQ4NDQ="
                    },
                    {
                      "locationId" : "TG9jYXRpb24tMjM0MjQ4MDM=",
                      "cost" : "5.0",
                      "country" : "IE",
                      "locationName" : "Ireland",
                      "estimatedMax" : null,
                      "currency" : "USD",
                      "__typename" : "SimpleShippingRule",
                      "estimatedMin" : null
                    },
                    {
                      "estimatedMax" : null,
                      "__typename" : "SimpleShippingRule",
                      "country" : "IT",
                      "estimatedMin" : null,
                      "locationName" : "Italy",
                      "cost" : "5.0",
                      "locationId" : "TG9jYXRpb24tMjM0MjQ4NTM=",
                      "currency" : "USD"
                    },
                    {
                      "locationName" : "Latvia",
                      "__typename" : "SimpleShippingRule",
                      "locationId" : "TG9jYXRpb24tMjM0MjQ4NzQ=",
                      "cost" : "5.0",
                      "country" : "LV",
                      "estimatedMin" : null,
                      "estimatedMax" : null,
                      "currency" : "USD"
                    },
                    {
                      "currency" : "USD",
                      "estimatedMax" : null,
                      "locationId" : "TG9jYXRpb24tMjM0MjQ4NzU=",
                      "__typename" : "SimpleShippingRule",
                      "estimatedMin" : null,
                      "locationName" : "Lithuania",
                      "country" : "LT",
                      "cost" : "5.0"
                    },
                    {
                      "locationName" : "Luxembourg",
                      "country" : "LU",
                      "estimatedMin" : null,
                      "locationId" : "TG9jYXRpb24tMjM0MjQ4ODE=",
                      "__typename" : "SimpleShippingRule",
                      "cost" : "5.0",
                      "estimatedMax" : null,
                      "currency" : "USD"
                    },
                    {
                      "estimatedMax" : null,
                      "locationName" : "Malta",
                      "cost" : "5.0",
                      "estimatedMin" : null,
                      "locationId" : "TG9jYXRpb24tMjM0MjQ4OTc=",
                      "country" : "MT",
                      "currency" : "USD",
                      "__typename" : "SimpleShippingRule"
                    },
                    {
                      "estimatedMin" : null,
                      "country" : "NL",
                      "currency" : "USD",
                      "cost" : "5.0",
                      "locationId" : "TG9jYXRpb24tMjM0MjQ5MDk=",
                      "locationName" : "Netherlands",
                      "estimatedMax" : null,
                      "__typename" : "SimpleShippingRule"
                    },
                    {
                      "estimatedMin" : null,
                      "currency" : "USD",
                      "locationId" : "TG9jYXRpb24tMjM0MjQ5MjM=",
                      "estimatedMax" : null,
                      "cost" : "5.0",
                      "country" : "PL",
                      "__typename" : "SimpleShippingRule",
                      "locationName" : "Poland"
                    },
                    {
                      "locationName" : "Portugal",
                      "cost" : "5.0",
                      "estimatedMin" : null,
                      "__typename" : "SimpleShippingRule",
                      "estimatedMax" : null,
                      "country" : "PT",
                      "locationId" : "TG9jYXRpb24tMjM0MjQ5MjU=",
                      "currency" : "USD"
                    },
                    {
                      "locationName" : "Romania",
                      "__typename" : "SimpleShippingRule",
                      "estimatedMin" : null,
                      "cost" : "5.0",
                      "estimatedMax" : null,
                      "country" : "RO",
                      "currency" : "USD",
                      "locationId" : "TG9jYXRpb24tMjM0MjQ5MzM="
                    },
                    {
                      "currency" : "USD",
                      "__typename" : "SimpleShippingRule",
                      "locationId" : "TG9jYXRpb24tMjM0MjQ4Nzc=",
                      "estimatedMax" : null,
                      "country" : "SK",
                      "estimatedMin" : null,
                      "locationName" : "Slovakia",
                      "cost" : "5.0"
                    },
                    {
                      "country" : "SI",
                      "__typename" : "SimpleShippingRule",
                      "estimatedMin" : null,
                      "locationName" : "Slovenia",
                      "estimatedMax" : null,
                      "locationId" : "TG9jYXRpb24tMjM0MjQ5NDU=",
                      "cost" : "5.0",
                      "currency" : "USD"
                    },
                    {
                      "estimatedMax" : null,
                      "locationName" : "Spain",
                      "locationId" : "TG9jYXRpb24tMjM0MjQ5NTA=",
                      "cost" : "5.0",
                      "__typename" : "SimpleShippingRule",
                      "country" : "ES",
                      "currency" : "USD",
                      "estimatedMin" : null
                    },
                    {
                      "estimatedMax" : null,
                      "locationName" : "Sweden",
                      "currency" : "USD",
                      "country" : "SE",
                      "__typename" : "SimpleShippingRule",
                      "cost" : "5.0",
                      "locationId" : "TG9jYXRpb24tMjM0MjQ5NTQ=",
                      "estimatedMin" : null
                    }
                  ],
                  "__typename" : "Reward",
                  "backersCount" : 0,
                  "name" : "Testing charge shipping just EU",
                  "postCampaignPledgingEnabled" : true,
                  "allowedAddons" : {
                    "__typename" : "RewardConnection",
                    "pageInfo" : {
                      "__typename" : "PageInfo",
                      "startCursor" : "MQ=="
                    }
                  },
                  "estimatedDeliveryOn" : "2028-12-01",
                  "limit" : null,
                  "isMaxPledge" : false,
                  "shippingPreference" : "restricted",
                  "startsAt" : null,
                  "audienceData": {
                    "__typename": "ResourceAudience",
                    "secret": false
                  }
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
                           "id": "UmV3YXJkSXRlbS0xMjY1ODIz",
                           "name": "SPECIAL EDITION PRINT (50cmx75cm)"
                         }
                       }
                     ]
                   },
                   "latePledgeAmount": {
                      "amount":"5.0",
                      "currency":"EUR",
                      "symbol":"€"
                   },
                   "limit":10,
                   "limitPerBacker":1,
                   "name":"BOOK + PRINT (Das erste Eis)",
                   "pledgeAmount": {
                      "amount":"5.0",
                      "currency":"EUR",
                      "symbol":"€"
                   },
                   "postCampaignPledgingEnabled": false,
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
                   "startsAt":null,
                   "audienceData": {
                     "__typename": "ResourceAudience",
                     "secret": false
                   }
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
                      "amount":"5.0",
                      "currency":"EUR",
                      "symbol":"€"
                   },
                   "limit":10,
                   "limitPerBacker":1,
                   "name":"SIGNED BOOK + GALLERY PRINT (30x45cm)",
                   "pledgeAmount": {
                      "amount":"5.0",
                      "currency":"EUR",
                      "symbol":"€"
                   },
                   "postCampaignPledgingEnabled": false,
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
                   "startsAt":null,
                   "audienceData": {
                     "__typename": "ResourceAudience",
                     "secret": false
                   }
                },
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
