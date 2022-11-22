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

  private let adaptableStackViewIsHidden = TestObserver<Bool, Never>()
  private let amountText = TestObserver<String, Never>()
  private let amountLabelIsHidden = TestObserver<Bool, Never>()
  private let dismissShippingRules = TestObserver<Void, Never>()
  private let presentShippingRulesProject = TestObserver<Project, Never>()
  private let presentShippingRulesAllRules = TestObserver<[ShippingRule], Never>()
  private let presentShippingRulesSelectedRule = TestObserver<ShippingRule, Never>()
  private let notifyDelegateOfSelectedShippingRule = TestObserver<ShippingRule, Never>()
  private let shimmerLoadingViewIsHidden = TestObserver<Bool, Never>()
  private let shippingLocationButtonTitle = TestObserver<String, Never>()
  private let shippingRulesError = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.adaptableStackViewIsHidden.observe(self.adaptableStackViewIsHidden.observer)
    self.vm.outputs.amountAttributedText.map { $0.string }.observe(self.amountText.observer)
    self.vm.outputs.amountLabelIsHidden.observe(self.amountLabelIsHidden.observer)
    self.vm.outputs.dismissShippingRules.observe(self.dismissShippingRules.observer)
    self.vm.outputs.shimmerLoadingViewIsHidden.observe(self.shimmerLoadingViewIsHidden.observer)
    self.vm.outputs.presentShippingRules.map { $0.0 }.observe(self.presentShippingRulesProject.observer)
    self.vm.outputs.presentShippingRules.map { $0.1 }.observe(self.presentShippingRulesAllRules.observer)
    self.vm.outputs.presentShippingRules.map { $0.2 }.observe(self.presentShippingRulesSelectedRule.observer)
    self.vm.outputs.notifyDelegateOfSelectedShippingRule
      .observe(self.notifyDelegateOfSelectedShippingRule.observer)
    self.vm.outputs.shippingLocationButtonTitle.observe(self.shippingLocationButtonTitle.observer)
    self.vm.outputs.shippingRulesError.observe(self.shippingRulesError.observer)
  }

  func testDefaultShippingRule_ProjectCountryEqualsProjectCurrencyCountry_US() {
    let mockService = MockService(fetchShippingRulesResult: Result.success(shippingRules))

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true

    withEnvironment(apiService: mockService, countryCode: "US") {
      self.vm.inputs.configureWith(data: (project: .template, reward: reward, true, nil))
      self.vm.inputs.viewDidLoad()

      self.amountText.assertValues(["+$0.00"])
      self.adaptableStackViewIsHidden.assertValues([true])
      self.shimmerLoadingViewIsHidden.assertValues([false])
      self.notifyDelegateOfSelectedShippingRule.assertDidNotEmitValue()
      self.shippingLocationButtonTitle.assertValues([])
      self.amountLabelIsHidden.assertValues([false])

      self.scheduler.advance()

      guard let defaultShippingRule = shippingRules.first(where: { $0.location == .brooklyn }) else {
        XCTFail("Default shipping rule should exist")
        return
      }

      self.amountText.assertValues(["+$0.00", "+$5.00"])
      self.adaptableStackViewIsHidden.assertValues([true])
      self.shimmerLoadingViewIsHidden.assertValues([false])
      self.notifyDelegateOfSelectedShippingRule.assertValues([defaultShippingRule])
      self.shippingLocationButtonTitle.assertValues(["Brooklyn, NY"])
      self.shippingRulesError.assertDidNotEmitValue()
      self.amountLabelIsHidden.assertValues([false])

      self.scheduler.advance(by: .seconds(1))

      self.adaptableStackViewIsHidden.assertValues([true, false])
      self.shimmerLoadingViewIsHidden.assertValues([false, true])
    }
  }

  func testDefaultShippingRule_US_ProjectCountry_NonUSProjectCurrencyCountry_US_UserLocation() {
    let mockService = MockService(fetchShippingRulesResult: Result.success(shippingRules))

    let project = Project.template
      |> Project.lens.stats.currency .~ Project.Country.mx.currencyCode
      |> Project.lens.country .~ Project.Country.us

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true

    withEnvironment(apiService: mockService, countryCode: "US") {
      self.vm.inputs.configureWith(data: (project: project, reward: reward, true, nil))
      self.vm.inputs.viewDidLoad()

      self.amountText.assertValues(["+ MX$ 0.00"])
      self.adaptableStackViewIsHidden.assertValues([true])
      self.shimmerLoadingViewIsHidden.assertValues([false])
      self.notifyDelegateOfSelectedShippingRule.assertDidNotEmitValue()
      self.shippingLocationButtonTitle.assertValues([])
      self.amountLabelIsHidden.assertValues([false])

      self.scheduler.advance()

      guard let defaultShippingRule = shippingRules.first(where: { $0.location == .brooklyn }) else {
        XCTFail("Default shipping rule should exist")
        return
      }

      self.amountText.assertValues(["+ MX$ 0.00", "+ MX$ 5.00"])
      self.adaptableStackViewIsHidden.assertValues([true])
      self.shimmerLoadingViewIsHidden.assertValues([false])
      self.notifyDelegateOfSelectedShippingRule.assertValues([defaultShippingRule])
      self.shippingLocationButtonTitle.assertValues(["Brooklyn, NY"])
      self.shippingRulesError.assertDidNotEmitValue()
      self.amountLabelIsHidden.assertValues([false])

      self.scheduler.advance(by: .seconds(1))

      self.adaptableStackViewIsHidden.assertValues([true, false])
      self.shimmerLoadingViewIsHidden.assertValues([false, true])
    }
  }

  func testDefaultShippingRule_ProjectCountryEqualsProjectCurrencyCountry_US_DefaultsToPreselected() {
    let mockService = MockService(fetchShippingRulesResult: Result.success(shippingRules))

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true

    withEnvironment(apiService: mockService, countryCode: "US") {
      self.vm.inputs.configureWith(data: (project: .template, reward: reward, true, Location.australia.id))
      self.vm.inputs.viewDidLoad()

      self.amountText.assertValues(["+$0.00"])
      self.adaptableStackViewIsHidden.assertValues([true])
      self.shimmerLoadingViewIsHidden.assertValues([false])
      self.notifyDelegateOfSelectedShippingRule.assertDidNotEmitValue()
      self.shippingLocationButtonTitle.assertValues([])
      self.amountLabelIsHidden.assertValues([false])

      self.scheduler.advance()

      guard let defaultShippingRule = shippingRules.first(where: { $0.location == .australia }) else {
        XCTFail("Default shipping rule should exist")
        return
      }

      self.amountText.assertValues(["+$0.00", "+$5.00"])
      self.adaptableStackViewIsHidden.assertValues([true])
      self.shimmerLoadingViewIsHidden.assertValues([false])
      self.notifyDelegateOfSelectedShippingRule.assertValues([defaultShippingRule])
      self.shippingLocationButtonTitle.assertValues(["Australia"])
      self.shippingRulesError.assertDidNotEmitValue()
      self.amountLabelIsHidden.assertValues([false])

      self.scheduler.advance(by: .seconds(1))

      self.adaptableStackViewIsHidden.assertValues([true, false])
      self.shimmerLoadingViewIsHidden.assertValues([false, true])
    }
  }

  func testAmountLabelIsHidden_IsHidden() {
    self.amountLabelIsHidden.assertDidNotEmitValue()

    self.vm.inputs.configureWith(data: (project: .template, reward: .template, showAmount: false, nil))
    self.vm.inputs.viewDidLoad()

    self.amountLabelIsHidden.assertValues([true])
  }

  func testAmountLabelIsHidden_IsNotHidden() {
    self.amountLabelIsHidden.assertDidNotEmitValue()

    self.vm.inputs.configureWith(data: (project: .template, reward: .template, showAmount: true, nil))
    self.vm.inputs.viewDidLoad()

    self.amountLabelIsHidden.assertValues([false])
  }

  func testShippingRulesSelection() {
    let mockService = MockService(fetchShippingRulesResult: Result.success(shippingRules))
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true

    withEnvironment(apiService: mockService, countryCode: "US") {
      self.vm.inputs.configureWith(data: (project: .template, reward: reward, false, nil))
      self.vm.inputs.viewDidLoad()

      guard let defaultShippingRule = shippingRules.first(where: { $0.location == .brooklyn }) else {
        XCTFail("Default shipping rule should exist")
        return
      }

      guard let selectedShippingRule = shippingRules.first(where: { $0.location == .australia }) else {
        XCTFail("Selected shipping rule should exist")
        return
      }

      self.notifyDelegateOfSelectedShippingRule.assertDidNotEmitValue()

      self.scheduler.advance()

      self.notifyDelegateOfSelectedShippingRule.assertValues([defaultShippingRule])

      self.vm.inputs.shippingLocationButtonTapped()

      self.dismissShippingRules.assertDidNotEmitValue()
      self.presentShippingRulesProject.assertValues([.template])
      self.presentShippingRulesAllRules.assertValues([shippingRules])
      self.presentShippingRulesSelectedRule.assertValues([defaultShippingRule])

      self.vm.inputs.shippingRuleUpdated(to: selectedShippingRule)

      self.scheduler.advance(by: .milliseconds(300))

      self.dismissShippingRules.assertValueCount(1)
      self.notifyDelegateOfSelectedShippingRule.assertValues([defaultShippingRule, selectedShippingRule])
    }
  }

  func testShippingRulesCancelation() {
    let mockService = MockService(fetchShippingRulesResult: Result.success(shippingRules))
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true

    withEnvironment(apiService: mockService, countryCode: "US") {
      self.vm.inputs.configureWith(data: (project: .template, reward: reward, false, nil))
      self.vm.inputs.viewDidLoad()

      guard let defaultShippingRule = shippingRules.first(where: { $0.location == .brooklyn }) else {
        XCTFail("Default shipping rule should exist")
        return
      }

      self.notifyDelegateOfSelectedShippingRule.assertDidNotEmitValue()

      self.scheduler.advance()

      self.notifyDelegateOfSelectedShippingRule.assertValues([defaultShippingRule])

      self.vm.inputs.shippingLocationButtonTapped()

      self.presentShippingRulesProject.assertValues([.template])
      self.presentShippingRulesAllRules.assertValues([shippingRules])
      self.presentShippingRulesSelectedRule.assertValues([defaultShippingRule])

      self.dismissShippingRules.assertDidNotEmitValue()
      self.vm.inputs.shippingRulesCancelButtonTapped()
      self.dismissShippingRules.assertValueCount(1)
    }
  }

  func testShippingRulesError_ProjectCountryEqualsProjectCurrencyCountry_US() {
    let error = ErrorEnvelope(errorMessages: [], ksrCode: nil, httpCode: 404, exception: nil)
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true

    withEnvironment(apiService: MockService(fetchShippingRulesResult: Result.failure(error))) {
      self.vm.inputs.configureWith(data: (project: .template, reward: reward, false, nil))
      self.vm.inputs.viewDidLoad()

      self.shippingRulesError.assertValues([])

      self.scheduler.advance()

      self.amountText.assertValues(["+$0.00"])
      self.adaptableStackViewIsHidden.assertValues([true])
      self.shimmerLoadingViewIsHidden.assertValues([false])
      self.notifyDelegateOfSelectedShippingRule.assertDidNotEmitValue()
      self.shippingLocationButtonTitle.assertValues([])
      self.shippingRulesError.assertValues([Strings.We_were_unable_to_load_the_shipping_destinations()])

      self.scheduler.advance(by: .seconds(1))

      self.adaptableStackViewIsHidden.assertValues([true, false])
      self.shimmerLoadingViewIsHidden.assertValues([false, true])
    }
  }

  func testShippingLocationFromBackingIsDefault_ProjectCountryEqualsProjectCurrencyCountry_US() {
    let mockService = MockService(fetchShippingRulesResult: Result.success(shippingRules))

    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ Reward.postcards
          |> Backing.lens.rewardId .~ Reward.postcards.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.amount .~ 700.0
          |> Backing.lens.locationId .~ Location.canada.id
          |> Backing.lens.locationName .~ Location.canada.name
      )

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true

    withEnvironment(apiService: mockService, countryCode: "US") {
      self.vm.inputs.configureWith(data: (project: project, reward: reward, false, nil))
      self.vm.inputs.viewDidLoad()

      self.amountText.assertValues(["+$0.00"])
      self.adaptableStackViewIsHidden.assertValues([true])
      self.shimmerLoadingViewIsHidden.assertValues([false])
      self.notifyDelegateOfSelectedShippingRule.assertDidNotEmitValue()
      self.shippingLocationButtonTitle.assertValues([])

      self.scheduler.advance()

      guard let defaultShippingRule = shippingRules.first(where: { $0.location == .canada }) else {
        XCTFail("Default shipping rule should exist")
        return
      }

      self.amountText.assertValues(["+$0.00", "+$5.00"])
      self.adaptableStackViewIsHidden.assertValues([true])
      self.shimmerLoadingViewIsHidden.assertValues([false])
      self.notifyDelegateOfSelectedShippingRule.assertValues([defaultShippingRule])
      self.shippingLocationButtonTitle.assertValues(["Canada"])
      self.shippingRulesError.assertDidNotEmitValue()

      self.scheduler.advance(by: .seconds(1))

      self.adaptableStackViewIsHidden.assertValues([true, false])
      self.shimmerLoadingViewIsHidden.assertValues([false, true])
    }
  }

  func testShippingLocationFromBackingIsDefault_ProjectCountryEqualsProjectCurrencyCountry_US_NewRewardDoesNotHaveSelectedRule() {
    let shippingRulesWithoutCanada = shippingRules.filter { $0.location != .canada }

    let mockService = MockService(fetchShippingRulesResult: Result.success(shippingRulesWithoutCanada))

    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ Reward.postcards
          |> Backing.lens.rewardId .~ Reward.postcards.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.amount .~ 700.0
          |> Backing.lens.locationId .~ Location.canada.id
          |> Backing.lens.locationName .~ Location.canada.name
      )

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true

    withEnvironment(apiService: mockService, countryCode: "US") {
      self.vm.inputs.configureWith(data: (project: project, reward: reward, false, nil))
      self.vm.inputs.viewDidLoad()

      self.amountText.assertValues(["+$0.00"])
      self.adaptableStackViewIsHidden.assertValues([true])
      self.shimmerLoadingViewIsHidden.assertValues([false])
      self.notifyDelegateOfSelectedShippingRule.assertDidNotEmitValue()
      self.shippingLocationButtonTitle.assertValues([])

      self.scheduler.advance()

      guard let defaultShippingRule = shippingRules.first(where: { $0.location == .brooklyn }) else {
        XCTFail("Default shipping rule should exist")
        return
      }

      self.amountText.assertValues(["+$0.00", "+$5.00"])
      self.adaptableStackViewIsHidden.assertValues([true])
      self.shimmerLoadingViewIsHidden.assertValues([false])
      self.notifyDelegateOfSelectedShippingRule.assertValues([defaultShippingRule])
      self.shippingLocationButtonTitle.assertValues(["Brooklyn, NY"])
      self.shippingRulesError.assertDidNotEmitValue()

      self.scheduler.advance(by: .seconds(1))

      self.adaptableStackViewIsHidden.assertValues([true, false])
      self.shimmerLoadingViewIsHidden.assertValues([false, true])
    }
  }
}
