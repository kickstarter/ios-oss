@testable import KsApi
import XCTest

final class GraphUserCreditCardTests: XCTestCase {
  func testCreditCardsDecoding_noCards() {
    let jsonString = """
    {
      "storedCards": {
          "nodes": [],
          "totalCount": 0
      }
    }
    """
    let data = jsonString.data(using: .utf8)

    do {
      // swiftlint:disable:next force_unwrapping
      let cards = try JSONDecoder().decode(GraphUserCreditCard.self, from: data!)

      XCTAssertEqual(cards.storedCards.nodes.count, 0)
    } catch {
      XCTFail("Failed to decode GraphUserCreditCard")
    }
  }

  func testCreditCardsDecoding_hasCards() {
    let jsonString = """
    {
      "storedCards": {
        "nodes": [
           {
              "expirationDate": "2023-02-01",
              "lastFour": "4242",
              "id": "3021",
              "type": "VISA"
            },
            {
              "expirationDate": "2020-02-01",
              "lastFour": "1111",
              "id": "2768",
              "type": "VISA"
            }
        ],
        "totalCount": 0
        }
    }
    """

    let data = jsonString.data(using: .utf8)

    do {
      // swiftlint:disable:next force_unwrapping
      let cards = try JSONDecoder().decode(GraphUserCreditCard.self, from: data!)

      XCTAssertEqual(cards.storedCards.nodes.count, 2)

      guard let firstCard = cards.storedCards.nodes.first else {
        XCTFail("Failed to decode GraphUserCreditCard")
        return
      }

      XCTAssertEqual(firstCard.type, GraphUserCreditCard.CreditCardType.visa)
      XCTAssertEqual(firstCard.lastFour, "4242")
      XCTAssertEqual(firstCard.expirationDate, "2023-02-01")
      XCTAssertEqual(firstCard.id, "3021")
    } catch {
      XCTFail("Failed to decode GraphUserCreditCard")
    }
  }

  func testCreditCardsDecoding_nilCardType() {
    let jsonString = """
    {
      "storedCards": {
        "nodes": [
            {
              "expirationDate": "2020-02-01",
              "lastFour": "1111",
              "id": "2768"
            }
        ],
        "totalCount": 0
      }
    }
    """

    let data = jsonString.data(using: .utf8)

    do {
      // swiftlint:disable:next force_unwrapping
      let cards = try JSONDecoder().decode(GraphUserCreditCard.self, from: data!)

      guard let card = cards.storedCards.nodes.first else {
        XCTFail("Failed to decode GraphUserCreditCard")
        return
      }

      XCTAssertNil(card.type)
      XCTAssertEqual(card.lastFour, "1111")
      XCTAssertEqual(card.expirationDate, "2020-02-01")
      XCTAssertEqual(card.id, "2768")
    } catch {
      XCTFail("Failed to decode GraphUserCreditCard")
    }
  }

  func testCreditCardsDecoding_unrecognizedCardType() {
    let jsonString = """
    {
      "storedCards": {
        "nodes": [
            {
              "expirationDate": "2020-02-01",
              "lastFour": "1111",
              "type": "UNKNOWN",
              "id": "2768"
            }
        ],
        "totalCount": 0
      }
    }
    """

    let data = jsonString.data(using: .utf8)

    do {
      // swiftlint:disable:next force_unwrapping
      let cards = try JSONDecoder().decode(GraphUserCreditCard.self, from: data!)

      guard let card = cards.storedCards.nodes.first else {
        XCTFail("Failed to decode GraphUserCreditCard")
        return
      }

      XCTAssertEqual(GraphUserCreditCard.CreditCardType.generic, card.type)
      XCTAssertEqual(card.lastFour, "1111")
      XCTAssertEqual(card.expirationDate, "2020-02-01")
      XCTAssertEqual(card.id, "2768")
    } catch {
      XCTFail("Failed to decode GraphUserCreditCard")
    }
  }

  func testJSONDecoding_WithStringID() {
    let card = GraphUserCreditCard.CreditCard.decodeJSONDictionary([
      "expiration_date": "2019-09-23",
      "id": "VXNlci0yMA==",
      "last_four": "1234",
      "payment_type": "CREDIT_CARD",
      "state": "ACTIVE",
      "type": "VISA"
    ])

    XCTAssertNil(card.error)
    XCTAssertEqual("2019-09-23", card.value?.expirationDate)
    XCTAssertEqual("VXNlci0yMA==", card.value?.id)
    XCTAssertEqual("1234", card.value?.lastFour)
    XCTAssertEqual("CREDIT_CARD", card.value?.paymentType?.rawValue)
    XCTAssertEqual("ACTIVE", card.value?.state)
    XCTAssertEqual(GraphUserCreditCard.CreditCardType.visa, card.value?.type)
  }

  func testJSONDecoding_WithIntID() {
    let card = GraphUserCreditCard.CreditCard.decodeJSONDictionary([
      "expiration_date": "2019-09-23",
      "id": 20,
      "last_four": "1234",
      "payment_type": "CREDIT_CARD",
      "state": "ACTIVE",
      "type": "VISA"
    ])

    XCTAssertEqual("VXNlci0yMA==", card.value?.id)
  }
}
