@testable import KsApi
import XCTest

final class ManagePledgeViewBackingEnvelopeTests: XCTestCase {
  func testJSONParsing_WithCompleteData() {
    let dictionary: [String: Any] = [
      "project": [
        "id": "UHJvamVjdC00NDc0NzM2MTM=",
        "name": "The Keyboardio Atreus",
        "state": "LIVE",
        "backing": [
          "id": "UHJvamVjdC00NDc0NzMM=",
          "status": "pledged",
          "errorReason": "This just isn't your day.",
          "pledgedOn": 1_587_502_131,
          "amount": [
            "amount": "146.0",
            "currency": "USD",
            "symbol": "$"
          ],
          "bankAccount": [
            "bankName": "Chase",
            "id": "60922339",
            "lastFour": "1234"
          ],
          "creditCard": [
            "id": "60981339",
            "lastFour": "1234",
            "expirationDate": "2023-04-01",
            "paymentType": "CREDIT_CARD",
            "type": "VISA"
          ],
          "shippingAmount": [
            "amount": "17.0",
            "currency": "USD",
            "symbol": "$"
          ],
          "reward": [
            "name": "Everyday Carry",
            "backersCount": 593,
            "description": "For the typist who takes their keyboard everywhere.",
            "estimatedDeliveryOn": "2020-08-01",
            "items": [
              "nodes": [
                [
                  "id": "UmV3YXJkSXRlbS03OTczNTM=",
                  "name": "Keyboardio Atreus (Choose switches after campaign)"
                ],
                [
                  "id": "UmV3YXJkSXRlbS04NzMzMDY=",
                  "name": "Travel case"
                ]
              ]
            ],
            "amount": [
              "amount": "129.0",
              "currency": "USD",
              "symbol": "$"
            ]
          ],
          "backer": [
            "id": "VXNlci0xMTA4OTI0NjQw",
            "name": "Backer McGee"
          ]
        ]
      ]
    ]

    guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
      XCTFail("Should have data")
      return
    }

    do {
      let value = try JSONDecoder().decode(ManagePledgeViewBackingEnvelope.self, from: data)

      XCTAssertEqual(value.project.id, "UHJvamVjdC00NDc0NzM2MTM=")
      XCTAssertEqual(value.project.name, "The Keyboardio Atreus")
      XCTAssertEqual(value.project.state, .live)

      XCTAssertEqual(value.backing?.id, "UHJvamVjdC00NDc0NzMM=")
      XCTAssertEqual(value.backing?.status, .pledged)
      XCTAssertEqual(value.backing?.errorReason, "This just isn't your day.")
      XCTAssertEqual(value.backing?.pledgedOn, 1_587_502_131)
      XCTAssertEqual(value.backing?.amount, Money(amount: "146.0", currency: .usd, symbol: "$"))

      XCTAssertEqual(value.backing?.bankAccount?.bankName, "Chase")
      XCTAssertEqual(value.backing?.bankAccount?.id, "60922339")
      XCTAssertEqual(value.backing?.bankAccount?.lastFour, "1234")

      XCTAssertEqual(value.backing?.creditCard?.id, "60981339")
      XCTAssertEqual(value.backing?.creditCard?.lastFour, "1234")
      XCTAssertEqual(value.backing?.creditCard?.expirationDate, "2023-04-01")
      XCTAssertEqual(value.backing?.creditCard?.paymentType, .creditCard)
      XCTAssertEqual(value.backing?.creditCard?.type, .visa)

      XCTAssertEqual(value.backing?.shippingAmount, Money(amount: "17.0", currency: .usd, symbol: "$"))

      XCTAssertEqual(value.backing?.reward?.name, "Everyday Carry")
      XCTAssertEqual(value.backing?.reward?.backersCount, 593)
      XCTAssertEqual(
        value.backing?.reward?.description,
        "For the typist who takes their keyboard everywhere."
      )
      XCTAssertEqual(value.backing?.reward?.estimatedDeliveryOn, "2020-08-01")
      XCTAssertEqual(value.backing?.reward?.items?[0].id, "UmV3YXJkSXRlbS03OTczNTM=")
      XCTAssertEqual(
        value.backing?.reward?.items?[0].name,
        "Keyboardio Atreus (Choose switches after campaign)"
      )
      XCTAssertEqual(value.backing?.reward?.items?[1].id, "UmV3YXJkSXRlbS04NzMzMDY=")
      XCTAssertEqual(value.backing?.reward?.items?[1].name, "Travel case")

      XCTAssertEqual(value.backing?.reward?.amount, Money(amount: "129.0", currency: .usd, symbol: "$"))

      XCTAssertEqual(value.backing?.backer?.id, "VXNlci0xMTA4OTI0NjQw")
      XCTAssertEqual(value.backing?.backer?.name, "Backer McGee")
    } catch {
      XCTFail((error as NSError).description)
    }
  }

  func testJSONParsing_WithPartialData() {
    let dictionary: [String: Any] = [
      "project": [
        "projectSummary": [
          [
            "question": "WHAT_IS_THE_PROJECT",
            "response": "A cool project."
          ],
          [
            "question": "WHO_ARE_YOU",
            "response": "I am a writer."
          ]
        ]
      ]
    ]

    guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
      XCTFail("Should have data")
      return
    }

    let value = try? JSONDecoder().decode(ProjectSummaryEnvelope.self, from: data)

    XCTAssertNotNil(value, "Should deserialize with only some values.")
  }

  func testJSONParsing_WithUnknownQuestion() {
    let dictionary: [String: Any] = [
      "project": [
        "id": "UHJvamVjdC00NDc0NzM2MTM=",
        "name": "The Keyboardio Atreus",
        "state": "LIVE",
        "backing": [
          "id": "UHJvamVjdC00NDc0NzMM=",
          "status": "pledged",
          "errorReason": nil,
          "pledgedOn": 1_587_502_131,
          "amount": [
            "amount": "146.0",
            "currency": "USD",
            "symbol": "$"
          ],
          "bankAccount": [
            "bankName": "Chase",
            "id": "60922339",
            "lastFour": "1234"
          ],
          "creditCard": [
            "id": "60981339",
            "lastFour": "1234",
            "expirationDate": "2023-04-01",
            "paymentType": "CREDIT_CARD",
            "type": "VISA"
          ],
          "shippingAmount": nil,
          "reward": [
            "name": "Everyday Carry",
            "backersCount": 593,
            "description": "For the typist who takes their keyboard everywhere.",
            "estimatedDeliveryOn": "2020-08-01",
            "items": [
              "nodes": [
                [
                  "id": "UmV3YXJkSXRlbS03OTczNTM=",
                  "name": "Keyboardio Atreus (Choose switches after campaign)"
                ],
                [
                  "id": "UmV3YXJkSXRlbS04NzMzMDY=",
                  "name": "Travel case"
                ]
              ]
            ],
            "amount": [
              "amount": "129.0",
              "currency": "USD",
              "symbol": "$"
            ]
          ],
          "backer": [
            "id": "VXNlci0xMTA4OTI0NjQw",
            "name": "Backer McGee"
          ]
        ]
      ]
    ]

    guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
      XCTFail("Should have data")
      return
    }

    do {
      let value = try JSONDecoder().decode(ManagePledgeViewBackingEnvelope.self, from: data)

      XCTAssertEqual(value.project.id, "UHJvamVjdC00NDc0NzM2MTM=")
      XCTAssertEqual(value.project.name, "The Keyboardio Atreus")
      XCTAssertEqual(value.project.state, .live)

      XCTAssertEqual(value.backing?.id, "UHJvamVjdC00NDc0NzMM=")
      XCTAssertEqual(value.backing?.status, .pledged)
      XCTAssertNil(value.backing?.errorReason)
      XCTAssertEqual(value.backing?.pledgedOn, 1_587_502_131)
      XCTAssertEqual(value.backing?.amount, Money(amount: "146.0", currency: .usd, symbol: "$"))

      XCTAssertEqual(value.backing?.bankAccount?.bankName, "Chase")
      XCTAssertEqual(value.backing?.bankAccount?.id, "60922339")
      XCTAssertEqual(value.backing?.bankAccount?.lastFour, "1234")

      XCTAssertEqual(value.backing?.creditCard?.id, "60981339")
      XCTAssertEqual(value.backing?.creditCard?.lastFour, "1234")
      XCTAssertEqual(value.backing?.creditCard?.expirationDate, "2023-04-01")
      XCTAssertEqual(value.backing?.creditCard?.paymentType, .creditCard)
      XCTAssertEqual(value.backing?.creditCard?.type, .visa)

      XCTAssertNil(value.backing?.shippingAmount)

      XCTAssertEqual(value.backing?.reward?.name, "Everyday Carry")
      XCTAssertEqual(value.backing?.reward?.backersCount, 593)
      XCTAssertEqual(
        value.backing?.reward?.description,
        "For the typist who takes their keyboard everywhere."
      )
      XCTAssertEqual(value.backing?.reward?.estimatedDeliveryOn, "2020-08-01")
      XCTAssertEqual(value.backing?.reward?.items?[0].id, "UmV3YXJkSXRlbS03OTczNTM=")
      XCTAssertEqual(
        value.backing?.reward?.items?[0].name,
        "Keyboardio Atreus (Choose switches after campaign)"
      )
      XCTAssertEqual(value.backing?.reward?.items?[1].id, "UmV3YXJkSXRlbS04NzMzMDY=")
      XCTAssertEqual(value.backing?.reward?.items?[1].name, "Travel case")

      XCTAssertEqual(value.backing?.reward?.amount, Money(amount: "129.0", currency: .usd, symbol: "$"))

      XCTAssertEqual(value.backing?.backer?.id, "VXNlci0xMTA4OTI0NjQw")
      XCTAssertEqual(value.backing?.backer?.name, "Backer McGee")
    } catch {
      XCTFail((error as NSError).description)
    }
  }
}
