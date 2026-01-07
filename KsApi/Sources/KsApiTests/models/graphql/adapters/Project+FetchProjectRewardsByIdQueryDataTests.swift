import Apollo
@testable import KsApi
import ReactiveSwift
import XCTest

final class Project_FetchProjectRewardsByIdQueryDataTests: XCTestCase {
  func testProjectRewardsProperties_Success() {
    let rewardsProducer = Project
      .projectRewardsProducer(from: FetchProjectRewardsByIdQueryTemplate.validRewardWithAllFields.data)

    guard let rewards = MockGraphQLClient.shared.client.data(from: rewardsProducer),
          let reward = rewards.first else {
      XCTFail()
      return
    }

    XCTAssertEqual(reward.backersCount, 1)
    XCTAssertEqual(reward.convertedMinimum, 599.0)
    XCTAssertEqual(
      reward.description,
      "Signed first edition of the book The Quiet with a personal inscription and one of 10 limited edition gallery prints (numbered and signed) on Aluminium Dibond of a photo of your choice from the book (Format: 30x45cm) / Signierte Erstausgabe des Buchs The Quiet mit einer persönlichen WIdmung und einem von 10 limitierten Alu-Dibond Galleryprint (nummeriert und signiert) eines Fotos deiner Wahl aus dem Buch im Format 30 cm x 45 cm."
    )
    XCTAssertNil(reward.endsAt)
    XCTAssertFalse(reward.hasAddOns)

    let date2: String? = "2021-11-01"
    let formattedDate2 = date2.flatMap(DateFormatter.isoDateFormatter.date(from:))
    let timeInterval2 = formattedDate2?.timeIntervalSince1970
    XCTAssertEqual(reward.estimatedDeliveryOn, timeInterval2)

    XCTAssertEqual(reward.id, decompose(id: "UmV3YXJkLTgzNDExODA="))
    XCTAssertEqual(reward.limit, 10)
    XCTAssertEqual(reward.limitPerBacker, 1)
    XCTAssertEqual(reward.minimum, 400.0)
    XCTAssertEqual(reward.remaining, 9)
    XCTAssertNil(reward.startsAt)
    XCTAssertEqual(reward.title, "SIGNED BOOK + GALLERY PRINT (30x45cm)")
    XCTAssertEqual(reward.shippingRules?.count, 4)
    XCTAssertEqual(reward.shippingRules?[1].cost, 15.0)
    XCTAssertEqual(reward.shippingRules?[1].location.country, "CH")
    XCTAssertEqual(reward.shippingRules?[1].location.displayableName, "Switzerland")
    XCTAssertEqual(reward.shippingRules?[1].location.localizedName, "Switzerland")
    XCTAssertEqual(reward.shippingRules?[1].location.name, "Switzerland")
    XCTAssertEqual(reward.shippingRules?[1].location.id, decompose(id: "TG9jYXRpb24tMjM0MjQ5NTc="))
    XCTAssertTrue(reward.shipping.enabled)
    XCTAssertEqual(reward.shipping.preference!, .restricted)
    XCTAssertEqual(reward.shipping.summary, "Ships worldwide")
    XCTAssertNotNil(reward.shippingRulesExpanded)
    XCTAssertNil(reward.shipping.location)
    XCTAssertNil(reward.shipping.type)

    guard let localPickup = reward.localPickup else {
      XCTFail("project should contain at least 1 local pickup location.")

      return
    }

    XCTAssertEqual(localPickup.localizedName, "San Jose")
    XCTAssertEqual(localPickup.id, decompose(id: "TG9jYXRpb24tMjQ4ODA0Mg=="))
    XCTAssertEqual(localPickup.name, "San Jose")
    XCTAssertEqual(localPickup.country, "US")
    XCTAssertEqual(localPickup.displayableName, "San Jose, CA")
  }

  func test_expandedShippingProperties() {
    // Test on reward that has restricted shipping; only to the EU.
    let rewardsProducer = Project
      .projectRewardsProducer(from: FetchProjectRewardsByIdQueryTemplate.expandedShippingReward.data)

    guard let rewards = MockGraphQLClient.shared.client.data(from: rewardsProducer),
          let reward = rewards.first else {
      XCTFail()

      return
    }

    XCTAssertEqual(reward.shippingRules?.count, 1)
    XCTAssertEqual(reward.shippingRules?[0].location.name, "European Union")
    XCTAssertEqual(reward.shippingRulesExpanded?.count, 27)
    XCTAssertEqual(reward.shippingRulesExpanded?[0].cost, 5.0)
    XCTAssertEqual(reward.shippingRulesExpanded?[0].estimatedMin, Money(amount: 2.0, currency: .usd))
    XCTAssertEqual(reward.shippingRulesExpanded?[0].estimatedMax, Money(amount: 10.0, currency: .usd))
    XCTAssertEqual(reward.shippingRulesExpanded?[0].location.country, "AT")
    XCTAssertEqual(reward.shippingRulesExpanded?[0].location.displayableName, "Austria")
    XCTAssertEqual(reward.shippingRulesExpanded?[0].location.localizedName, "Austria")
    XCTAssertEqual(reward.shippingRulesExpanded?[0].location.name, "Austria")
    XCTAssertEqual(reward.shippingRulesExpanded?[0].location.id, decompose(id: "TG9jYXRpb24tMjM0MjQ3NTA="))
  }
}
