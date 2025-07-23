import Apollo
@testable import KsApi
import XCTest

final class Project_FetchAddOnsQueryDataTests: XCTestCase {
  func testFetchAddOnsQueryData_Success() {
    let data = FetchAddsOnsQueryTemplate.valid.data
    let producer = Project.projectProducer(from: data)
    guard let envelope = MockGraphQLClient.shared.client.data(from: producer) else {
      XCTFail()

      return
    }

    XCTAssertEqual(envelope.name, "Peppermint Fox Press: Notebooks & Stationery")
    XCTAssertEqual(envelope.id, 1_606_532_881)
    XCTAssertEqual(envelope.slug, "peppermint-fox-press-notebooks-and-stationery")
    XCTAssertEqual(envelope.state, KsApi.Project.State.live)
    XCTAssertEqual(envelope.location.name, "Launceston")

    XCTAssertTrue(envelope.hasAddOns)
    XCTAssertEqual(envelope.addOns?.count, 1)

    guard let addOn = envelope.addOns?.first else {
      XCTFail()

      return
    }

    XCTAssertEqual(addOn.backersCount, 9)
    XCTAssertEqual(addOn.convertedMinimum, 4.0)
    XCTAssertEqual(addOn.description, "Translucent Sticker Sheet")
    XCTAssertEqual(addOn.estimatedDeliveryOn, 1_622_505_600.0)
    XCTAssertEqual(addOn.graphID, "UmV3YXJkLTgxOTAzMjA=")
    XCTAssertEqual(addOn.rewardsItems.count, 1)
    XCTAssertEqual(addOn.limitPerBacker, 10)
    XCTAssertEqual(addOn.title, "Paper Sticker Sheet")
    XCTAssertEqual(addOn.shippingRules?.count, 2)
    XCTAssertNil(addOn.endsAt)
    XCTAssertFalse(addOn.hasAddOns)
    XCTAssertEqual(addOn.id, decompose(id: "UmV3YXJkLTgxOTAzMjA="))
    XCTAssertEqual(addOn.minimum, 4.0)
    XCTAssertEqual(addOn.shipping.enabled, true)
    XCTAssertEqual(addOn.shipping.preference!, .unrestricted)
    XCTAssertEqual(addOn.shipping.summary, "Ships worldwide")
    XCTAssertNil(addOn.limit)
    XCTAssertNil(addOn.remaining)
    XCTAssertNil(addOn.startsAt)
    XCTAssertNil(addOn.shipping.location)
    XCTAssertNil(addOn.shipping.type)

    if let expandedShippingRule = addOn.shippingRulesExpanded?.first {
      XCTAssertEqual(expandedShippingRule.cost, 2.0)
      XCTAssertNotNil(expandedShippingRule.location)
    } else {
      XCTFail("Expected expanded shipping rule")
    }

    if let localPickup = addOn.localPickup {
      XCTAssertEqual(localPickup.localizedName, "San Jose")
      XCTAssertEqual(localPickup.id, decompose(id: "TG9jYXRpb24tMjQ4ODA0Mg=="))
      XCTAssertEqual(localPickup.name, "San Jose")
      XCTAssertEqual(localPickup.country, "US")
      XCTAssertEqual(localPickup.displayableName, "San Jose, CA")

    } else {
      XCTFail("Expected local pickup option")
    }
  }
}
