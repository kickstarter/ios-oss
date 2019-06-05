import Foundation
import Prelude
import ReactiveExtensions
import ReactiveSwift
import Result
import XCTest

@testable import KsApi
@testable import Library
import ReactiveExtensions_TestHelpers

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
      |> ShippingRule.lens.cost .~ Double(idx + 1)
  } ||> ShippingRule.lens.location .. Location.lens.localizedName %~ { "Local " + $0 }

final class PledgeViewModelTests: TestCase {
  private let vm: PledgeViewModelType = PledgeViewModel()

  private let amount = TestObserver<Double, Never>()
  private let currencySymbol = TestObserver<String, Never>()
  private let estimatedDelivery = TestObserver<String, Never>()
  private let isLoggedIn = TestObserver<Bool, Never>()
  private let project = TestObserver<Project, Never>()
  private let requiresShippingRules = TestObserver<Bool, Never>()
  private let selectedShippingRuleLocation = TestObserver<String, Never>()
  private let selectedShippingCost = TestObserver<Double, Never>()
  private let selectedShippingRuleProject = TestObserver<Project, Never>()
  private let shippingCost = TestObserver<Double, Never>()
  private let shippingIsLoading = TestObserver<Bool, Never>()
  private let shippingLocation = TestObserver<String, Never>()
  private let shippingRulesError = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.reloadWithData.map { $0.amount }.observe(self.amount.observer)
    self.vm.outputs.reloadWithData.map { $0.currencySymbol }.observe(self.currencySymbol.observer)
    self.vm.outputs.reloadWithData.map { $0.estimatedDelivery }.observe(self.estimatedDelivery.observer)
    self.vm.outputs.reloadWithData.map { $0.shippingLocation }.observe(self.shippingLocation.observer)
    self.vm.outputs.reloadWithData.map { $0.shippingCost }.observe(self.shippingCost.observer)
    self.vm.outputs.reloadWithData.map { $0.project }.observe(self.project.observer)
    self.vm.outputs.reloadWithData.map { $0.isLoggedIn }.observe(self.isLoggedIn.observer)
    self.vm.outputs.reloadWithData.map { $0.requiresShippingRules }
      .observe(self.requiresShippingRules.observer)
    self.vm.outputs.selectedShippingRuleData.map { $0.location }
      .observe(self.selectedShippingRuleLocation.observer)
    self.vm.outputs.selectedShippingRuleData.map { $0.shippingCost }
      .observe(self.selectedShippingCost.observer)
    self.vm.outputs.selectedShippingRuleData.map { $0.project }
      .observe(self.selectedShippingRuleProject.observer)
    self.vm.outputs.shippingRulesError.observe(self.shippingRulesError.observer)

    self.vm.outputs.shippingIsLoading.observe(self.shippingIsLoading.observer)
  }

  func testReloadWithData_loggedOut() {
    let estimatedDelivery = 1_468_527_587.32843
    let project = Project.template
    let reward = Reward.template |> Reward.lens.estimatedDeliveryOn .~ estimatedDelivery

    withEnvironment(currentUser: nil) {
      self.vm.inputs.configureWith(project: project, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.amount.assertValues([10])
      self.currencySymbol.assertValues(["$"])
      self.estimatedDelivery.assertValues(
        [Format.date(secondsInUTC: estimatedDelivery, template: "MMMMyyyy", timeZone: UTCTimeZone)]
      )
      self.shippingLocation.assertValues([""])
      self.shippingCost.assertValues([0.0], "Initial shipping cost value")
      self.project.assertValues([project])
      self.isLoggedIn.assertValues([false])
      self.requiresShippingRules.assertValues([false])
    }
  }

  func testReloadWithData_loggedIn() {
    let estimatedDelivery = 1_468_527_587.32843
    let project = Project.template
    let reward = Reward.template |> Reward.lens.estimatedDeliveryOn .~ estimatedDelivery
    let user = User.template

    withEnvironment(currentUser: user) {
      self.vm.inputs.configureWith(project: project, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.amount.assertValues([10])
      self.currencySymbol.assertValues(["$"])
      self.estimatedDelivery.assertValues(
        [Format.date(secondsInUTC: estimatedDelivery, template: "MMMMyyyy", timeZone: UTCTimeZone)]
      )
      self.shippingLocation.assertValues([""])
      self.shippingCost.assertValues([0.0], "Initial shipping cost value")
      self.project.assertValues([project])
      self.isLoggedIn.assertValues([true])
      self.requiresShippingRules.assertValues([false])
    }
  }

  func testReloadData_requiresShippingRules() {
    let estimatedDelivery = 1_468_527_587.32843
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.estimatedDeliveryOn .~ estimatedDelivery
      |> Reward.lens.shipping.enabled .~ true

    let user = User.template

    withEnvironment(currentUser: user) {
      self.vm.inputs.configureWith(project: project, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.amount.assertValues([10])
      self.currencySymbol.assertValues(["$"])
      self.estimatedDelivery.assertValues(
        [Format.date(secondsInUTC: estimatedDelivery, template: "MMMMyyyy", timeZone: UTCTimeZone)]
      )
      self.shippingLocation.assertValues([""])
      self.shippingCost.assertValues([0.0], "Initial shipping cost value")
      self.project.assertValues([project])
      self.isLoggedIn.assertValues([true])
      self.requiresShippingRules.assertValues([true])
    }
  }

  func testSelectedShippingInfo_shippingDisabled() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ false

    self.vm.inputs.configureWith(project: project, reward: reward)
    self.vm.inputs.viewDidLoad()

    self.requiresShippingRules.assertValues([false])

    self.vm.inputs.didReloadData()

    self.selectedShippingRuleLocation.assertDidNotEmitValue()
    self.selectedShippingCost.assertDidNotEmitValue()
    self.selectedShippingRuleProject.assertDidNotEmitValue()
    self.shippingIsLoading.assertDidNotEmitValue()
  }

  func testSelectedShippingRule_shippingEnabled_recognizedCountry() {
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
    // swiftlint:disable:next force_unwrapping
    let defaultShippingRule = shippingRules.first(where: { $0.location == .australia })!
    let project = Project.template

    withEnvironment(
      apiService: MockService(fetchShippingRulesResult: .success(shippingRules)),
      config: .template |> Config.lens.countryCode .~ "AU"
    ) {
      self.vm.inputs.configureWith(project: project, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.selectedShippingRuleLocation.assertDidNotEmitValue()
      self.selectedShippingCost.assertDidNotEmitValue()
      self.selectedShippingRuleProject.assertDidNotEmitValue()
      self.shippingIsLoading.assertDidNotEmitValue()

      self.vm.inputs.didReloadData()

      self.shippingIsLoading.assertValues([true])

      self.scheduler.run()

      self.selectedShippingRuleLocation.assertValues(["Local Australia"])
      self.selectedShippingCost.assertValues([defaultShippingRule.cost])
      self.selectedShippingRuleProject.assertValues([project])
      self.shippingIsLoading.assertValues([true, false])
    }
  }

  func testSelectedShippingRule_shippingEnabled_unrecognizedCountry() {
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
    // swiftlint:disable:next force_unwrapping
    let defaultShippingRule = shippingRules.first(where: { $0.location == .usa })!
    let project = Project.template

    withEnvironment(
      apiService: MockService(fetchShippingRulesResult: .success(shippingRules)),
      config: .template |> Config.lens.countryCode .~ "XYZ"
    ) {
      self.vm.inputs.configureWith(project: project, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.selectedShippingRuleLocation.assertDidNotEmitValue()
      self.selectedShippingCost.assertDidNotEmitValue()
      self.selectedShippingRuleProject.assertDidNotEmitValue()
      self.shippingIsLoading.assertDidNotEmitValue()

      self.vm.inputs.didReloadData()

      self.shippingIsLoading.assertValues([true])

      self.scheduler.run()

      self.selectedShippingRuleLocation.assertValues(["Local United States"])
      self.selectedShippingCost.assertValues([defaultShippingRule.cost])
      self.selectedShippingRuleProject.assertValues([project])
      self.shippingIsLoading.assertValues([true, false])
    }
  }

  func testShippingRulesErrored() {
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true

    let error = ErrorEnvelope(
      errorMessages: ["Something went wrong."],
      ksrCode: .UnknownCode,
      httpCode: 500,
      exception: nil
    )

    // swiftlint:disable:next force_unwrapping
    let defaultShippingRule = shippingRules.last!

    withEnvironment(
      apiService: MockService(fetchShippingRulesResult: .failure(error)),
      config: .template |> Config.lens.countryCode .~ defaultShippingRule.location.country
    ) {
      self.vm.inputs.configureWith(project: .template, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.selectedShippingRuleLocation.assertDidNotEmitValue()
      self.selectedShippingCost.assertDidNotEmitValue()
      self.selectedShippingRuleProject.assertDidNotEmitValue()
      self.shippingIsLoading.assertDidNotEmitValue()

      self.vm.inputs.didReloadData()

      self.shippingIsLoading.assertValues([true])

      self.scheduler.run()

      self.shippingIsLoading.assertValues([true, false])
      self.shippingRulesError.assertValues([Strings.We_were_unable_to_load_the_shipping_destinations()])

      self.selectedShippingRuleLocation.assertDidNotEmitValue()
      self.selectedShippingCost.assertDidNotEmitValue()
      self.selectedShippingRuleProject.assertDidNotEmitValue()
    }
  }
}
