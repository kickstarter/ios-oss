import Foundation
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class CreateBackingInputConstructorTests: XCTestCase {
  func testCreateBackingInput_NoShipping() {
    let project = Project.template
    let reward = Reward.noReward

    let input = CreateBackingInput.input(
      from: project,
      reward: reward,
      pledgeAmount: 10,
      selectedShippingRule: nil,
      refTag: RefTag.projectPage,
      paymentSourceId: "123"
    )

    XCTAssertEqual(input.amount, "10.00")
    XCTAssertNil(input.locationId)
    XCTAssertEqual(input.projectId, project.graphID)
    XCTAssertEqual(input.rewardId, "UmV3YXJkLTA=")
    XCTAssertEqual(input.refParam, "project_page")
    XCTAssertEqual(input.paymentSourceId, "123")
  }

  func testCreateBackingInput_WithShipping_RefTagNil() {
    let project = Project.template
    let reward = Reward.template
    let shippingRule = ShippingRule.template
      |> ShippingRule.lens.location .. Location.lens.id .~ 1
      |> ShippingRule.lens.cost .~ 5

    let input = CreateBackingInput.input(
      from: project,
      reward: reward,
      pledgeAmount: 10,
      selectedShippingRule: shippingRule,
      refTag: nil,
      paymentSourceId: "123"
    )

    XCTAssertEqual(input.amount, "15.00")
    XCTAssertEqual(input.locationId, "1")
    XCTAssertEqual(input.projectId, project.graphID)
    XCTAssertEqual(input.rewardId, reward.graphID)
    XCTAssertEqual(input.paymentSourceId, "123")
    XCTAssertNil(input.refParam)
  }
}
