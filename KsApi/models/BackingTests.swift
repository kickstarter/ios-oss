@testable import KsApi
import Prelude
import XCTest

final class BackingTests: XCTestCase {
  func testJSONDecoding_WithCompleteData() {
    let backing = Backing.decodeJSONDictionary([
      "amount": 1.0,
      "backer_id": 1,
      "id": 1,
      "location_id": 1,
      "location_name": "United States",
      "payment_source": [
        "expiration_date": "2019-09-23",
        "id": 20,
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
    XCTAssertEqual(1, backing.value?.id)
    XCTAssertEqual("2019-09-23", backing.value?.paymentSource?.expirationDate)
    // id is converted to a base64 encoded string to keep graphQL compatibility (used in other API calls).
    XCTAssertEqual("VXNlci0yMA==", backing.value?.paymentSource?.id)
    XCTAssertEqual("1234", backing.value?.paymentSource?.lastFour)
    XCTAssertEqual("CREDIT_CARD", backing.value?.paymentSource?.paymentType)
    XCTAssertEqual("ACTIVE", backing.value?.paymentSource?.state)
    XCTAssertEqual(GraphUserCreditCard.CreditCardType.visa, backing.value?.paymentSource?.type)
    XCTAssertEqual(1, backing.value?.locationId)
    XCTAssertEqual("United States", backing.value?.locationName)
    XCTAssertEqual(1_000, backing.value?.pledgedAt)
    XCTAssertEqual("US", backing.value?.projectCountry)
    XCTAssertEqual(1, backing.value?.projectId)
    XCTAssertEqual(1, backing.value?.sequence)
    XCTAssertEqual(Backing.Status.pledged, backing.value?.status)
  }

  func testPledgeAmount() {
    let backing = Backing.template
      |> Backing.lens.reward .~ Reward.postcards
      |> Backing.lens.rewardId .~ Reward.postcards.id
      |> Backing.lens.shippingAmount .~ 100
      |> Backing.lens.amount .~ 700.50

    XCTAssertEqual(backing.amount, 700.50)
    XCTAssertEqual(backing.pledgeAmount, 600.50)
  }
}
