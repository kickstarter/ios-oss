import Apollo
@testable import KsApi
import ReactiveSwift
import XCTest

final class Project_FetchProjectRewardsByIdQueryDataTests: XCTestCase {
  func testFetchProjectRewardsByIdQueryData_Success() {
    let rewardsProducer = Project
      .projectRewardsProducer(from: FetchProjectRewardsByIdQueryTemplate.valid.data)

    guard let rewards = MockGraphQLClient.shared.client.data(from: rewardsProducer) else {
      XCTFail()

      return
    }

    self.testProjectRewardsProperties_Success(rewards: rewards)
  }

  private func testProjectRewardsProperties_Success(rewards: [Reward]) {
    guard rewards.count > 1 else {
      XCTFail("project should have at least two rewards.")

      return
    }

    XCTAssertEqual(rewards.count, 14)

    guard let lastReward = rewards.last else {
      XCTFail("project should contain at least 1 reward.")

      return
    }

    XCTAssertEqual(lastReward.backersCount, 1)
    XCTAssertEqual(lastReward.convertedMinimum, 599.0)
    XCTAssertEqual(
      lastReward.description,
      "Signed first edition of the book The Quiet with a personal inscription and one of 10 limited edition gallery prints (numbered and signed) on Aluminium Dibond of a photo of your choice from the book (Format: 30x45cm) / Signierte Erstausgabe des Buchs The Quiet mit einer persönlichen WIdmung und einem von 10 limitierten Alu-Dibond Galleryprint (nummeriert und signiert) eines Fotos deiner Wahl aus dem Buch im Format 30 cm x 45 cm."
    )
    XCTAssertNil(lastReward.endsAt)
    XCTAssertFalse(lastReward.hasAddOns)

    let secondReward = rewards[1]

    XCTAssertTrue(secondReward.hasAddOns)

    let date2: String? = "2021-11-01"
    let formattedDate2 = date2.flatMap(DateFormatter.isoDateFormatter.date(from:))
    let timeInterval2 = formattedDate2?.timeIntervalSince1970
    XCTAssertEqual(lastReward.estimatedDeliveryOn, timeInterval2)

    XCTAssertEqual(lastReward.id, decompose(id: "UmV3YXJkLTgzNDExODA="))
    XCTAssertEqual(lastReward.limit, 10)
    XCTAssertEqual(lastReward.limitPerBacker, 1)
    XCTAssertEqual(lastReward.minimum, 400.0)
    XCTAssertEqual(lastReward.remaining, 9)
    XCTAssertNil(lastReward.startsAt)
    XCTAssertEqual(lastReward.title, "SIGNED BOOK + GALLERY PRINT (30x45cm)")
    XCTAssertEqual(lastReward.shippingRules?.count, 4)
    XCTAssertEqual(lastReward.shippingRules?[1].cost, 15.0)
    XCTAssertEqual(lastReward.shippingRules?[1].location.country, "CH")
    XCTAssertEqual(lastReward.shippingRules?[1].location.displayableName, "Switzerland")
    XCTAssertEqual(lastReward.shippingRules?[1].location.localizedName, "Switzerland")
    XCTAssertEqual(lastReward.shippingRules?[1].location.name, "Switzerland")
    XCTAssertEqual(lastReward.shippingRules?[1].location.id, decompose(id: "TG9jYXRpb24tMjM0MjQ5NTc="))
    XCTAssertFalse(lastReward.shipping.enabled)
    XCTAssertEqual(lastReward.shipping.preference!, .none)
    XCTAssertEqual(lastReward.shipping.summary, "Ships worldwide")
    XCTAssertNil(lastReward.shippingRulesExpanded)
    XCTAssertNil(lastReward.shipping.location)
    XCTAssertNil(lastReward.shipping.type)

    guard let localPickup = rewards.last?.localPickup else {
      XCTFail("project should contain at least 1 local pickup location.")

      return
    }

    XCTAssertEqual(localPickup.localizedName, "San Jose")
    XCTAssertEqual(localPickup.id, decompose(id: "TG9jYXRpb24tMjQ4ODA0Mg=="))
    XCTAssertEqual(localPickup.name, "San Jose")
    XCTAssertEqual(localPickup.country, "US")
    XCTAssertEqual(localPickup.displayableName, "San Jose, CA")
    XCTAssertNil(rewards.first?.localPickup)
  }
}
