import Foundation
import Prelude
import ReactiveSwift
import ReactiveExtensions
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
  } ||> ShippingRule.lens.location..Location.lens.localizedName %~ { "Local " + $0 }

final class PledgeViewModelTests: TestCase {
  private let vm: PledgeViewModelType = PledgeViewModel()

  private let amount = TestObserver<Double, NoError>()
  private let currency = TestObserver<String, NoError>()
  private let currencyCode = TestObserver<String, NoError>()
  private let isLoggedIn = TestObserver<Bool, NoError>()
  private let estimatedDelivery = TestObserver<String, NoError>()
  private let requiresShippingRules = TestObserver<Bool, NoError>()
  private let selectedShippingRuleLocation = TestObserver<String, NoError>()
  private let selectedShippingRuleAmount = TestObserver<Double, NoError>()
  private let selectedShippingRuleCurrency = TestObserver<String, NoError>()
  private let shippingIsLoading = TestObserver<Bool, NoError>()
  private let shippingRulesError = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.reloadWithData.map { $0.amount }.observe(self.amount.observer)
    self.vm.outputs.reloadWithData.map { $0.currency }.observe(self.currency.observer)
    self.vm.outputs.reloadWithData.map { $0.currencyCode }.observe(self.currencyCode.observer)
    self.vm.outputs.reloadWithData.map { $0.isLoggedIn }.observe(self.isLoggedIn.observer)
    self.vm.outputs.reloadWithData.map { $0.delivery }.observe(self.estimatedDelivery.observer)
    self.vm.outputs.reloadWithData.map { $0.requiresShippingRules }
      .observe(self.requiresShippingRules.observer)
    self.vm.outputs.selectedShippingRuleData.map { $0.location }
      .observe(self.selectedShippingRuleLocation.observer)
    self.vm.outputs.selectedShippingRuleData.map { $0.amount }
      .observe(self.selectedShippingRuleAmount.observer)
    self.vm.outputs.selectedShippingRuleData.map { $0.currencyCode }
      .observe(self.selectedShippingRuleCurrency.observer)
    self.vm.outputs.shippingRulesError.observe(self.shippingRulesError.observer)

    self.vm.outputs.shippingIsLoading.observe(self.shippingIsLoading.observer)
  }

  func testReloadWithData_loggedOut() {
    withEnvironment(currentUser: nil) {
      self.vm.inputs.configureWith(project: .template, reward: .template)
      self.vm.inputs.viewDidLoad()

      self.isLoggedIn.assertValues([false])
    }
  }

  func testReloadWithData_loggedIn() {
    let estimatedDelivery = 1468527587.32843
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.estimatedDeliveryOn .~ estimatedDelivery

    let user = User.template

    withEnvironment(currentUser: user) {
      self.vm.inputs.configureWith(project: project, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.amount.assertValues([10])
      self.currency.assertValues(["$"])
      self.isLoggedIn.assertValues([true])
      self.estimatedDelivery.assertValues(
        [Format.date(secondsInUTC: estimatedDelivery, template: "MMMMyyyy", timeZone: UTCTimeZone)]
      )
    }
  }

  func testReloadData_currencyCode() {
    let project = Project.template
      |> \.stats.currency .~ "CAD"

    self.vm.inputs.configureWith(project: project, reward: .template)
    self.vm.inputs.viewDidLoad()

    self.currencyCode.assertValues(["CAD"])
  }

  func testReloadData_requiresShippingRules() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true

    self.vm.inputs.configureWith(project: project, reward: reward)
    self.vm.inputs.viewDidLoad()

    self.requiresShippingRules.assertValues([true])
  }

  func testSelectedShippingInfo_shippingDisabled() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ false

    self.vm.inputs.configureWith(project: project, reward: reward)
    self.vm.inputs.viewDidLoad()

    self.requiresShippingRules.assertValues([false])

    self.vm.inputs.reloadData()

    self.selectedShippingRuleLocation.assertDidNotEmitValue()
    self.selectedShippingRuleCurrency.assertDidNotEmitValue()
    self.selectedShippingRuleAmount.assertDidNotEmitValue()
    self.shippingIsLoading.assertDidNotEmitValue()
  }

  func testSelectedShippingRule_shippingEnabled_recognizedCountry() {
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
    // swiftlint:disable:next force_unwrapping
    let defaultShippingRule = shippingRules.first(where: { $0.location == .australia })!
    let projectCurrency = Project.template.stats.currency

    withEnvironment(apiService: MockService(fetchShippingRulesResult: Result(shippingRules)),
                    config: .template |> Config.lens.countryCode .~ "AU") {

        self.vm.inputs.configureWith(project: .template, reward: reward)
        self.vm.inputs.viewDidLoad()

        self.selectedShippingRuleLocation.assertDidNotEmitValue()
        self.selectedShippingRuleCurrency.assertDidNotEmitValue()
        self.selectedShippingRuleAmount.assertDidNotEmitValue()
        self.shippingIsLoading.assertDidNotEmitValue()

        self.vm.inputs.reloadData()

        self.shippingIsLoading.assertValues([true])

        self.scheduler.run()

        self.selectedShippingRuleLocation.assertValues(["Local Australia"])
        self.selectedShippingRuleAmount.assertValues([defaultShippingRule.cost])
        self.selectedShippingRuleCurrency.assertValues([projectCurrency])
        self.shippingIsLoading.assertValues([true, false])
    }
  }

  func testSelectedShippingRule_shippingEnabled_unrecognizedCountry() {
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
    // swiftlint:disable:next force_unwrapping
    let defaultShippingRule = shippingRules.first(where: { $0.location == .usa })!
    let projectCurrency = Project.template.stats.currency

    withEnvironment(
      apiService: MockService(fetchShippingRulesResult: Result(shippingRules)),
      config: .template |> Config.lens.countryCode .~ "XYZ") {

        self.vm.inputs.configureWith(project: .template, reward: reward)
        self.vm.inputs.viewDidLoad()

        self.selectedShippingRuleLocation.assertDidNotEmitValue()
        self.selectedShippingRuleCurrency.assertDidNotEmitValue()
        self.selectedShippingRuleAmount.assertDidNotEmitValue()
        self.shippingIsLoading.assertDidNotEmitValue()

        self.vm.inputs.reloadData()

        self.shippingIsLoading.assertValues([true])

        self.scheduler.run()

        self.selectedShippingRuleLocation.assertValues(["Local United States"])
        self.selectedShippingRuleAmount.assertValues([defaultShippingRule.cost])
        self.selectedShippingRuleCurrency.assertValues([projectCurrency])
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
      apiService: MockService(fetchShippingRulesResult: Result(error: error)),
      config: .template |> Config.lens.countryCode .~ defaultShippingRule.location.country) {

        self.vm.inputs.configureWith(project: .template, reward: reward)
        self.vm.inputs.viewDidLoad()

        self.selectedShippingRuleLocation.assertDidNotEmitValue()
        self.selectedShippingRuleCurrency.assertDidNotEmitValue()
        self.selectedShippingRuleAmount.assertDidNotEmitValue()
        self.shippingIsLoading.assertDidNotEmitValue()

        self.vm.inputs.reloadData()

        self.shippingIsLoading.assertValues([true])

        self.scheduler.run()

        self.shippingIsLoading.assertValues([true, false])
        self.shippingRulesError.assertValues([Strings.We_were_unable_to_load_the_shipping_destinations()])
    }
  }
}
