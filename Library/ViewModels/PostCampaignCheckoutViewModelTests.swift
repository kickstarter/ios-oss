@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class PostCampaignCheckoutViewModelTests: XCTestCase {
  fileprivate let vm = PostCampaignCheckoutViewModel()
  fileprivate let goToApplePayPaymentAuthorization = TestObserver<
    PostCampaignPaymentAuthorizationData,
    Never
  >()

  override func setUp() {
    self.vm.goToApplePayPaymentAuthorization.observe(self.goToApplePayPaymentAuthorization.observer)
  }

  func testApplePayAuthorization_noReward_isCorrect() {
    let project = Project.cosmicSurgery
    let reward = Reward.noReward |> Reward.lens.minimum .~ 5

    let data = PostCampaignCheckoutData(
      project: project,
      rewards: [reward],
      selectedQuantities: [:],
      bonusAmount: 0,
      total: 5,
      shipping: nil,
      refTag: nil,
      context: .pledge,
      checkoutId: "0"
    )

    self.vm.configure(with: data)
    self.vm.inputs.applePayButtonTapped()

    self.goToApplePayPaymentAuthorization.assertValueCount(1)
    let output = self.goToApplePayPaymentAuthorization.lastValue!

    XCTAssertEqual(output.project, project)
    XCTAssertEqual(output.hasNoReward, true)
    XCTAssertEqual(output.subtotal, 5)
    XCTAssertEqual(output.bonus, 0)
    XCTAssertEqual(output.shipping, 0)
    XCTAssertEqual(output.total, 5)
  }

  func testApplePayAuthorization_reward_isCorrect() {
    let project = Project.cosmicSurgery
    let reward = project.rewards.first!

    XCTAssertEqual(reward.minimum, 6)

    let data = PostCampaignCheckoutData(
      project: project,
      rewards: [reward],
      selectedQuantities: [reward.id: 3],
      bonusAmount: 0,
      total: 18,
      shipping: nil,
      refTag: nil,
      context: .pledge,
      checkoutId: "0"
    )

    self.vm.configure(with: data)
    self.vm.inputs.applePayButtonTapped()

    self.goToApplePayPaymentAuthorization.assertValueCount(1)
    let output = self.goToApplePayPaymentAuthorization.lastValue!

    XCTAssertEqual(output.project, project)
    XCTAssertEqual(output.hasNoReward, false)
    XCTAssertEqual(output.subtotal, 18)
    XCTAssertEqual(output.bonus, 0)
    XCTAssertEqual(output.shipping, 0)
    XCTAssertEqual(output.total, 18)
  }

  func testApplePayAuthorization_rewardAndShipping_isCorrect() {
    let project = Project.cosmicSurgery
    let reward = project.rewards.first!

    XCTAssertEqual(reward.minimum, 6)

    let data = PostCampaignCheckoutData(
      project: project,
      rewards: [reward],
      selectedQuantities: [reward.id: 3],
      bonusAmount: 0,
      total: 90,
      shipping: PledgeShippingSummaryViewData(
        locationName: "Somewhere",
        omitUSCurrencyCode: false,
        projectCountry: project.country,
        total: 72
      ),
      refTag: nil,
      context: .pledge,
      checkoutId: "0"
    )

    self.vm.configure(with: data)
    self.vm.inputs.applePayButtonTapped()

    self.goToApplePayPaymentAuthorization.assertValueCount(1)
    let output = self.goToApplePayPaymentAuthorization.lastValue!

    XCTAssertEqual(output.project, project)
    XCTAssertEqual(output.hasNoReward, false)
    XCTAssertEqual(output.subtotal, 18)
    XCTAssertEqual(output.bonus, 0)
    XCTAssertEqual(output.shipping, 72)
    XCTAssertEqual(output.total, 90)
  }

  func testApplePayAuthorization_rewardAndShippingAndBonus_isCorrect() {
    let project = Project.cosmicSurgery
    let reward1 = project.rewards[0]
    let reward2 = project.rewards[1]

    XCTAssertEqual(reward1.minimum, 6)
    XCTAssertEqual(reward2.minimum, 25)

    let data = PostCampaignCheckoutData(
      project: project,
      rewards: [reward1, reward2],
      selectedQuantities: [reward1.id: 1, reward2.id: 2],
      bonusAmount: 5,
      total: 133,
      shipping: PledgeShippingSummaryViewData(
        locationName: "Somewhere",
        omitUSCurrencyCode: false,
        projectCountry: project.country,
        total: 72
      ),
      refTag: nil,
      context: .pledge,
      checkoutId: "0"
    )

    self.vm.configure(with: data)
    self.vm.inputs.applePayButtonTapped()

    self.goToApplePayPaymentAuthorization.assertValueCount(1)
    let output = self.goToApplePayPaymentAuthorization.lastValue!

    XCTAssertEqual(output.project, project)
    XCTAssertEqual(output.hasNoReward, false)
    XCTAssertEqual(output.subtotal, 56)
    XCTAssertEqual(output.bonus, 5)
    XCTAssertEqual(output.shipping, 72)
    XCTAssertEqual(output.total, 133)
  }
}
