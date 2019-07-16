import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import XCTest

private let shippingRules = [
  ShippingRule.template
    |> ShippingRule.lens.location .~ .brooklyn,
  ShippingRule.template
    |> ShippingRule.lens.location .~ .canada,
  ShippingRule.template
    |> ShippingRule.lens.location .~ .australia
]

final class PledgeShippingLocationViewModelTests: TestCase {
  private let vm: PledgeShippingLocationViewModelType = PledgeShippingLocationViewModel()

  private let amountAttributedText = TestObserver<NSAttributedString, Never>()
  private let dismissShippingRules = TestObserver<Void, Never>()
  private let isLoading = TestObserver<Bool, Never>()
  private let presentShippingRulesProject = TestObserver<Project, Never>()
  private let presentShippingRulesAllRules = TestObserver<[ShippingRule], Never>()
  private let presentShippingRulesSelectedRule = TestObserver<ShippingRule, Never>()
  private let notifyDelegateOfSelectedShippingRule = TestObserver<ShippingRule, Never>()
  private let shippingLocationButtonTitle = TestObserver<String, Never>()
  private let shippingRulesError = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.amountAttributedText.observe(self.amountAttributedText.observer)
    self.vm.outputs.dismissShippingRules.observe(self.dismissShippingRules.observer)
    self.vm.outputs.isLoading.observe(self.isLoading.observer)
    self.vm.outputs.presentShippingRules.map { $0.0 }.observe(self.presentShippingRulesProject.observer)
    self.vm.outputs.presentShippingRules.map { $0.1 }.observe(self.presentShippingRulesAllRules.observer)
    self.vm.outputs.presentShippingRules.map { $0.2 }.observe(self.presentShippingRulesSelectedRule.observer)
    self.vm.outputs.notifyDelegateOfSelectedShippingRule
      .observe(self.notifyDelegateOfSelectedShippingRule.observer)
    self.vm.outputs.shippingLocationButtonTitle.observe(self.shippingLocationButtonTitle.observer)
    self.vm.outputs.shippingRulesError.observe(self.shippingRulesError.observer)
  }

  func testDefaultShippingLocation() {
    let mockService = MockService(fetchShippingRulesResult: Result.success(shippingRules))

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true

    withEnvironment(apiService: mockService, countryCode: "US") {
      self.vm.inputs.configureWith(project: .template, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.isLoading.assertValues([true])
      XCTAssertEqual(self.amountAttributedText.values.last?.string, "+$0.00")
      self.shippingLocationButtonTitle.assertValues([])
      self.notifyDelegateOfSelectedShippingRule.assertDidNotEmitValue()

      self.scheduler.run()

      let defaultShippingRule = shippingRules.first(where: { $0.location == .brooklyn })

      XCTAssertEqual(self.amountAttributedText.values.last?.string, "+$5.00")
      self.isLoading.assertValues([true, false])
      self.notifyDelegateOfSelectedShippingRule.assertValues([defaultShippingRule!])
      self.shippingLocationButtonTitle.assertValues(["Brooklyn, NY"])
      self.shippingRulesError.assertDidNotEmitValue()
    }
  }

  func testSelectShippingLocation() {
    let mockService = MockService(fetchShippingRulesResult: Result.success(shippingRules))
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true

    withEnvironment(apiService: mockService, countryCode: "US") {
      self.vm.inputs.configureWith(project: .template, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.notifyDelegateOfSelectedShippingRule.assertDidNotEmitValue()

      let selectedShippingRule = shippingRules.first(where: { $0.location == .australia })
      let defaultShippingRule = shippingRules.first(where: { $0.location == .brooklyn })

      self.scheduler.advance()

      self.notifyDelegateOfSelectedShippingRule.assertValues([defaultShippingRule!])

      self.vm.inputs.shippingLocationButtonTapped()

      self.presentShippingRulesProject.assertValues([.template])
      self.presentShippingRulesAllRules.assertValues([shippingRules])
      self.presentShippingRulesSelectedRule.assertValues([defaultShippingRule!])

      self.vm.inputs.shippingRuleUpdated(to: selectedShippingRule!)

      self.notifyDelegateOfSelectedShippingRule.assertValues([defaultShippingRule!, selectedShippingRule!])

      self.dismissShippingRules.assertValueCount(0)
      self.vm.inputs.dismissShippingRulesButtonTapped()
      self.dismissShippingRules.assertValueCount(1)
    }
  }

  func testShippingRulesError() {
    let error = ErrorEnvelope(errorMessages: [], ksrCode: nil, httpCode: 404, exception: nil)
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true

    withEnvironment(apiService: MockService(fetchShippingRulesResult: Result(failure: error))) {
      self.vm.inputs.configureWith(project: .template, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.notifyDelegateOfSelectedShippingRule.assertDidNotEmitValue()

      self.shippingRulesError.assertValues([])

      self.scheduler.advance()

      XCTAssertEqual(self.amountAttributedText.values.last?.string, "+$0.00")
      self.isLoading.assertValues([true, false])
      self.notifyDelegateOfSelectedShippingRule.assertDidNotEmitValue()
      self.shippingLocationButtonTitle.assertValues([])
      self.shippingRulesError.assertValues([Strings.We_were_unable_to_load_the_shipping_destinations()])
    }
  }
}
