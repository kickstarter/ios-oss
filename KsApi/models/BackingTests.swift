@testable import KsApi
import Prelude
import XCTest

final class BackingTests: XCTestCase {
  func testJSONDecoding_WithCompleteData() {
    let backing = Backing.decodeJSONDictionary([
      "amount": 1.0,
      "backer_id": 1,
      "cancelable": true,
      "id": 1,
      "location_id": 1,
      "location_name": "United States",
      "payment_source": [
        "expiration_date": "2019-09-23",
        "id": "20",
        "last_four": "1234",
        "payment_type": "CREDIT_CARD",
        "state": "ACTIVE",
        "type": "VISA"
      ],
      "pledged_at": 1_000,
      "project_country": "US",
      "project_id": 1,
      "sequence": 1,
      "status": "pledged"
    ])

    XCTAssertNil(backing.error)
    XCTAssertEqual(1.0, backing.value?.amount)
    XCTAssertEqual(1, backing.value?.backerId)
    XCTAssertEqual(true, backing.value?.cancelable)
    XCTAssertEqual(1, backing.value?.id)
    XCTAssertEqual("2019-09-23", backing.value?.paymentSource?.expirationDate)
    XCTAssertEqual("20", backing.value?.paymentSource?.id)
    XCTAssertEqual("1234", backing.value?.paymentSource?.lastFour)
    XCTAssertEqual("CREDIT_CARD", backing.value?.paymentSource?.paymentType.rawValue)
    XCTAssertEqual("ACTIVE", backing.value?.paymentSource?.state)
    XCTAssertEqual(CreditCardType.visa, backing.value?.paymentSource?.type)
    XCTAssertEqual(1, backing.value?.locationId)
    XCTAssertEqual("United States", backing.value?.locationName)
    XCTAssertEqual(1_000, backing.value?.pledgedAt)
    XCTAssertEqual("US", backing.value?.projectCountry)
    XCTAssertEqual(1, backing.value?.projectId)
    XCTAssertEqual(1, backing.value?.sequence)
    XCTAssertEqual(Backing.Status.pledged, backing.value?.status)
  }

  func testJSONDecoding_IncompletePaymentSource() {
    let backing = Backing.decodeJSONDictionary([
      "amount": 1.0,
      "backer_id": 1,
      "cancelable": true,
      "id": 1,
      "location_id": 1,
      "location_name": "United States",
      "payment_source": [],
      "pledged_at": 1_000,
      "project_country": "US",
      "project_id": 1,
      "sequence": 1,
      "status": "pledged"
    ])

    XCTAssertNil(backing.error)
    XCTAssertEqual(1.0, backing.value?.amount)
    XCTAssertEqual(1, backing.value?.backerId)
    XCTAssertEqual(1, backing.value?.id)

    XCTAssertNil(backing.value?.paymentSource)

    XCTAssertEqual(1, backing.value?.locationId)
    XCTAssertEqual("United States", backing.value?.locationName)
    XCTAssertEqual(1_000, backing.value?.pledgedAt)
    XCTAssertEqual("US", backing.value?.projectCountry)
    XCTAssertEqual(1, backing.value?.projectId)
    XCTAssertEqual(1, backing.value?.sequence)
    XCTAssertEqual(Backing.Status.pledged, backing.value?.status)
  }
}
