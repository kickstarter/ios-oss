import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

private let locations: [Location] = [
  .usa,
  .canada,
  .greatBritain,
  .australia
]

private let shippingRules = locations
  .enumerated()
  .map { idx, location in
    .template
      |> ShippingRule.lens.location .~ location
      |> ShippingRule.lens.cost .~ Double(idx + 1 * 10)
  }

final class PledgeShippingLocationCellViewModelTests: TestCase {
  private let vm: PledgeShippingLocationCellViewModelType = PledgeShippingLocationCellViewModel()

  private let amount = TestObserver<NSAttributedString, Never>()
  private let selectedShippingRule = TestObserver<ShippingRule, Never>()
  private let location = TestObserver<String, Never>()
  private let shippingIsLoading = TestObserver<Bool, Never>()
  private let shippingRulesError = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.amount.observe(self.amount.observer)
    self.vm.outputs.selectedShippingRule.observe(self.selectedShippingRule.observer)
    self.vm.outputs.location.observe(self.location.observer)
    self.vm.outputs.shippingIsLoading.observe(self.shippingIsLoading.observer)
    self.vm.outputs.shippingRulesError.observe(self.shippingRulesError.observer)
  }

  func testAmount() {
    withEnvironment(apiService: MockService(fetchShippingRulesResult: .success(shippingRules))) {
      let expectedAttributedString = NSMutableAttributedString(
        string: "+$10.00", attributes: checkoutCurrencyDefaultAttributes()
      )
      expectedAttributedString.addAttributes(
        checkoutCurrencySuperscriptAttributes(), range: NSRange(location: 0, length: 2)
      )
      expectedAttributedString.addAttributes(
        checkoutCurrencySuperscriptAttributes(), range: NSRange(location: 4, length: 3)
      )

      let reward = Reward.template
        |> Reward.lens.shipping.enabled .~ true

      self.vm.inputs.configureWith(project: .template, reward: reward)

      self.amount.assertValues([])
      self.selectedShippingRule.assertValues([])

      self.scheduler.run()

      self.amount.assertValues([expectedAttributedString])
      XCTAssertEqual(self.selectedShippingRule.values.map { $0.cost }, [10])
    }
  }

  func testLocation() {
    withEnvironment(apiService: MockService(fetchShippingRulesResult: .success(shippingRules))) {
      let reward = Reward.template
        |> Reward.lens.shipping.enabled .~ true

      self.vm.inputs.configureWith(project: .template, reward: reward)

      self.location.assertValues([])

      self.scheduler.run()

      self.location.assertValues(["United States"])
    }
  }

  func testShippingIsLoading() {
    withEnvironment(apiService: MockService(fetchShippingRulesResult: .success(shippingRules))) {
      let reward = Reward.template
        |> Reward.lens.shipping.enabled .~ true

      self.vm.inputs.configureWith(project: .template, reward: reward)

      self.shippingIsLoading.assertValues([true])

      self.scheduler.run()

      self.shippingIsLoading.assertValues([true, false])
    }
  }

  func testShippingRulesError() {
    let error = ErrorEnvelope(errorMessages: [], ksrCode: nil, httpCode: 404, exception: nil)

    withEnvironment(apiService: MockService(fetchShippingRulesResult: .failure(error))) {
      let reward = Reward.template
        |> Reward.lens.shipping.enabled .~ true

      self.vm.inputs.configureWith(project: .template, reward: reward)

      self.shippingRulesError.assertValues([])

      self.scheduler.run()

      self.shippingRulesError.assertValues([Strings.We_were_unable_to_load_the_shipping_destinations()])
    }
  }
}
