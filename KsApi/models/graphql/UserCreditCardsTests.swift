@testable import KsApi
import XCTest

final class UserCreditCardsTests: XCTestCase {
  func testCreditCardsDecoding_noCards() {
    let jsonString = """
    {
      "storedCards": [],
      "totalCount": 0
    }
    """
    let data = jsonString.data(using: .utf8)

    do {
      let cards = try JSONDecoder().decode(UserCreditCards.self, from: data!)

      XCTAssertEqual(cards.storedCards.count, 0)
    } catch {
      XCTFail("Failed to decode UserCreditCards")
    }
  }

  func testCreditCardsDecoding_hasCards() {
    let jsonString = """
    {
      "storedCards": [
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
      "totalCount": 2
    }
    """

    let data = jsonString.data(using: .utf8)

    do {
      let cards = try JSONDecoder().decode(UserCreditCards.self, from: data!)

      XCTAssertEqual(cards.storedCards.count, 2)

      guard let firstCard = cards.storedCards.first else {
        XCTFail("Failed to decode UserCreditCards")
        return
      }

      XCTAssertEqual(firstCard.type, CreditCardType.visa)
      XCTAssertEqual(firstCard.lastFour, "4242")
      XCTAssertEqual(firstCard.expirationDate, "2023-02-01")
      XCTAssertEqual(firstCard.id, "3021")
    } catch {
      XCTFail("Failed to decode UserCreditCards")
    }
  }

  func testCreditCardsDecoding_nilCardType() {
    let jsonString = """
    {
      "storedCards": [
          {
            "expirationDate": "2020-02-01",
            "lastFour": "1111",
            "id": "2768"
          }
      ],
      "totalCount": 1
    }
    """

    let data = jsonString.data(using: .utf8)

    do {
      let cards = try JSONDecoder().decode(UserCreditCards.self, from: data!)

      guard let card = cards.storedCards.first else {
        XCTFail("Failed to decode UserCreditCards")
        return
      }

      XCTAssertNil(card.type)
      XCTAssertEqual(card.lastFour, "1111")
      XCTAssertEqual(card.expirationDate, "2020-02-01")
      XCTAssertEqual(card.id, "2768")
    } catch {
      XCTFail("Failed to decode UserCreditCards")
    }
  }

  func testCreditCardsDecoding_unrecognizedCardType() {
    let jsonString = """
    {
      "storedCards": [
          {
            "expirationDate": "2020-02-01",
            "lastFour": "1111",
            "type": "UNKNOWN",
            "id": "2768"
          }
      ],
      "totalCount": 1
    }
    """

    let data = jsonString.data(using: .utf8)

    do {
      let cards = try JSONDecoder().decode(UserCreditCards.self, from: data!)

      guard let card = cards.storedCards.first else {
        XCTFail("Failed to decode UserCreditCards")
        return
      }

      XCTAssertEqual(CreditCardType.generic, card.type)
      XCTAssertEqual(card.lastFour, "1111")
      XCTAssertEqual(card.expirationDate, "2020-02-01")
      XCTAssertEqual(card.id, "2768")
    } catch {
      XCTFail("Failed to decode UserCreditCards")
    }
  }
}
