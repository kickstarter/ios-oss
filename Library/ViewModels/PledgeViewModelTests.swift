import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import Result
import XCTest

// swiftlint:disable line_length
final class PledgeViewModelTests: TestCase {
  private var vm: PledgeViewModelType!

  private let configureShippingLocationCellWithDataIsShippingRulesLoading = TestObserver<Bool, Never>()
  private let configureShippingLocationCellWithDataProject = TestObserver<Project, Never>()
  private let configureShippingLocationCellWithDataSelectedShippingRule = TestObserver<ShippingRule?, Never>()

  private let configureSummaryCellWithDataPledgeTotal = TestObserver<Double, Never>()
  private let configureSummaryCellWithDataProject = TestObserver<Project, Never>()

  /**
   Given the noise of `pledgeViewDataAndReload` signal and its frequent emissions and also the fact that
   what we really care about is the final emission from this signal, we mostly test its last value.
   */
  private let pledgeViewDataAndReloadIsLoggedIn = TestObserver<Bool, Never>()
  private let pledgeViewDataAndReloadIsShippingEnabled = TestObserver<Bool, Never>()
  private let pledgeViewDataAndReloadIsShippingRulesLoading = TestObserver<Bool, Never>()
  private let pledgeViewDataAndReloadProject = TestObserver<Project, Never>()
  private let pledgeViewDataAndReloadReload = TestObserver<Bool, Never>()
  private let pledgeViewDataAndReloadReward = TestObserver<Reward, Never>()
  private let pledgeViewDataAndReloadSelectedShippingRule = TestObserver<ShippingRule?, Never>()
  private let pledgeViewDataAndReloadTotal = TestObserver<Double, Never>()

  private let presentShippingRules = TestObserver<[ShippingRule], Never>()
  private let shippingRulesError = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm = PledgeViewModel()

    self.vm.outputs.configureShippingLocationCellWithData.map { $0.0 }.observe(self.configureShippingLocationCellWithDataIsShippingRulesLoading.observer)
    self.vm.outputs.configureShippingLocationCellWithData.map { $0.1 }.observe(self.configureShippingLocationCellWithDataProject.observer)
    self.vm.outputs.configureShippingLocationCellWithData.map { $0.2 }.observe(self.configureShippingLocationCellWithDataSelectedShippingRule.observer)

    self.vm.outputs.configureSummaryCellWithData.map(second).observe(self.configureSummaryCellWithDataPledgeTotal.observer)
    self.vm.outputs.configureSummaryCellWithData.map(first).observe(self.configureSummaryCellWithDataProject.observer)

    self.vm.outputs.pledgeViewDataAndReload.map(first).map { $0.2 }.observe(self.pledgeViewDataAndReloadIsLoggedIn.observer)
    self.vm.outputs.pledgeViewDataAndReload.map(first).map { $0.3 }.map { $0.0 }.observe(self.pledgeViewDataAndReloadIsShippingEnabled.observer)
    self.vm.outputs.pledgeViewDataAndReload.map(first).map { $0.3 }.map { $0.1 }.observe(self.pledgeViewDataAndReloadIsShippingRulesLoading.observer)
    self.vm.outputs.pledgeViewDataAndReload.map(first).map { $0.0 }.observe(self.pledgeViewDataAndReloadProject.observer)
    self.vm.outputs.pledgeViewDataAndReload.map(second).observe(self.pledgeViewDataAndReloadReload.observer)
    self.vm.outputs.pledgeViewDataAndReload.map(first).map { $0.1 }.observe(self.pledgeViewDataAndReloadReward.observer)
    self.vm.outputs.pledgeViewDataAndReload.map(first).map { $0.3 }.map { $0.2 }.observe(self.pledgeViewDataAndReloadSelectedShippingRule.observer)
    self.vm.outputs.pledgeViewDataAndReload.map(first).map { $0.4 }.observe(self.pledgeViewDataAndReloadTotal.observer)

    self.vm.outputs.presentShippingRules.observe(self.presentShippingRules.observer)
    self.vm.outputs.shippingRulesError.observe(self.shippingRulesError.observer)
  }

  func testReload_Logged_Out() {
    withEnvironment(currentUser: nil) {
      let project = Project.template
      let reward = Reward.template

      self.vm.inputs.configureWith(project: project, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.pledgeViewDataAndReloadIsLoggedIn.assertValues([false])
      self.pledgeViewDataAndReloadIsShippingEnabled.assertValues([false])
      self.pledgeViewDataAndReloadProject.assertValues([project])
      self.pledgeViewDataAndReloadReload.assertValue(true)
      self.pledgeViewDataAndReloadReward.assertValues([reward])
      self.pledgeViewDataAndReloadSelectedShippingRule.assertValue(nil)
      self.pledgeViewDataAndReloadTotal.assertValues([reward.minimum])

      self.configureShippingLocationCellWithDataIsShippingRulesLoading.assertDidNotEmitValue()
      self.configureShippingLocationCellWithDataProject.assertDidNotEmitValue()
      self.configureShippingLocationCellWithDataSelectedShippingRule.assertDidNotEmitValue()

      self.configureSummaryCellWithDataPledgeTotal.assertDidNotEmitValue()
      self.configureSummaryCellWithDataProject.assertDidNotEmitValue()
    }
  }

  func testReload_Logged_In() {
    let project = Project.template
    let reward = Reward.template

    withEnvironment(currentUser: .template) {
      self.vm.inputs.configureWith(project: project, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.pledgeViewDataAndReloadIsLoggedIn.assertValues([true])
      self.pledgeViewDataAndReloadIsShippingEnabled.assertValues([false])
      self.pledgeViewDataAndReloadProject.assertValues([project])
      self.pledgeViewDataAndReloadReload.assertValue(true)
      self.pledgeViewDataAndReloadReward.assertValues([reward])
      self.pledgeViewDataAndReloadSelectedShippingRule.assertValue(nil)
      self.pledgeViewDataAndReloadTotal.assertValues([reward.minimum])

      self.configureShippingLocationCellWithDataIsShippingRulesLoading.assertDidNotEmitValue()
      self.configureShippingLocationCellWithDataProject.assertDidNotEmitValue()
      self.configureShippingLocationCellWithDataSelectedShippingRule.assertDidNotEmitValue()

      self.configureSummaryCellWithDataPledgeTotal.assertDidNotEmitValue()
      self.configureSummaryCellWithDataProject.assertDidNotEmitValue()
    }
  }

  func testSelectedShippingRule() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.shipping .~ (.template |> Reward.Shipping.lens.enabled .~ true)

    withEnvironment {
      self.vm.inputs.configureWith(project: project, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.pledgeViewDataAndReloadIsLoggedIn.assertValues([false, false])
      self.pledgeViewDataAndReloadIsShippingEnabled.assertValues([true, true])
      self.pledgeViewDataAndReloadProject.assertValues([project, project])
      self.pledgeViewDataAndReloadReload.assertValues([true, false])
      self.pledgeViewDataAndReloadReward.assertValues([reward, reward])
      self.pledgeViewDataAndReloadSelectedShippingRule.assertValues([nil, nil])
      self.pledgeViewDataAndReloadTotal.assertValues([reward.minimum, reward.minimum])

      self.configureShippingLocationCellWithDataIsShippingRulesLoading.assertValues([true])
      self.configureShippingLocationCellWithDataProject.assertValues([project])
      self.configureShippingLocationCellWithDataSelectedShippingRule.assertValues([nil])

      self.configureSummaryCellWithDataPledgeTotal.assertDidNotEmitValue()
      self.configureSummaryCellWithDataProject.assertDidNotEmitValue()

      self.scheduler.advance()

      let defaultShippingRule = ShippingRule.template

      self.pledgeViewDataAndReloadIsLoggedIn.assertLastValue(false)
      self.pledgeViewDataAndReloadIsShippingEnabled.assertLastValue(true)
      self.pledgeViewDataAndReloadProject.assertLastValue(project)
      self.pledgeViewDataAndReloadReload.assertValueCount(5)
      self.pledgeViewDataAndReloadReload.assertLastValue(false)
      self.pledgeViewDataAndReloadReward.assertLastValue(reward)
      self.pledgeViewDataAndReloadSelectedShippingRule.assertLastValue(defaultShippingRule)
      self.pledgeViewDataAndReloadTotal.assertLastValue(reward.minimum + defaultShippingRule.cost)

      self.configureShippingLocationCellWithDataIsShippingRulesLoading.assertValues([true, true, false])
      self.configureShippingLocationCellWithDataProject.assertValues([project, project, project])
      self.configureShippingLocationCellWithDataSelectedShippingRule.assertValues(
        [nil, defaultShippingRule, defaultShippingRule]
      )

      self.configureSummaryCellWithDataPledgeTotal.assertValues([reward.minimum + defaultShippingRule.cost])
      self.configureSummaryCellWithDataProject.assertValues([project])
    }
  }

  func testSelectedShippingRuleUpdates() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.shipping .~ (.template |> Reward.Shipping.lens.enabled .~ true)

    withEnvironment {
      self.vm.inputs.configureWith(project: project, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.pledgeViewDataAndReloadIsLoggedIn.assertValues([false, false])
      self.pledgeViewDataAndReloadIsShippingEnabled.assertValues([true, true])
      self.pledgeViewDataAndReloadProject.assertValues([project, project])
      self.pledgeViewDataAndReloadReload.assertValues([true, false])
      self.pledgeViewDataAndReloadReward.assertValues([reward, reward])
      self.pledgeViewDataAndReloadSelectedShippingRule.assertValues([nil, nil])
      self.pledgeViewDataAndReloadTotal.assertValues([reward.minimum, reward.minimum])

      self.configureShippingLocationCellWithDataIsShippingRulesLoading.assertValues([true])
      self.configureShippingLocationCellWithDataProject.assertValues([project])
      self.configureShippingLocationCellWithDataSelectedShippingRule.assertValues([nil])

      self.configureSummaryCellWithDataPledgeTotal.assertDidNotEmitValue()
      self.configureSummaryCellWithDataProject.assertDidNotEmitValue()

      let shippingRule1 = ShippingRule.template
        |> ShippingRule.lens.cost .~ 20.0

      self.vm.inputs.shippingRuleDidUpdate(to: shippingRule1)

      self.pledgeViewDataAndReloadIsLoggedIn.assertLastValue(false)
      self.pledgeViewDataAndReloadIsShippingEnabled.assertLastValue(true)
      self.pledgeViewDataAndReloadProject.assertLastValue(project)
      self.pledgeViewDataAndReloadReload.assertValueCount(3)
      self.pledgeViewDataAndReloadReload.assertLastValue(false)
      self.pledgeViewDataAndReloadReward.assertLastValue(reward)
      self.pledgeViewDataAndReloadSelectedShippingRule.assertLastValue(nil)
      self.pledgeViewDataAndReloadTotal.assertLastValue(reward.minimum + shippingRule1.cost)

      self.configureShippingLocationCellWithDataIsShippingRulesLoading.assertValues([true])
      self.configureShippingLocationCellWithDataProject.assertValues([project])
      self.configureShippingLocationCellWithDataSelectedShippingRule.assertValues([nil])

      self.configureSummaryCellWithDataPledgeTotal.assertValues([reward.minimum + shippingRule1.cost])
      self.configureSummaryCellWithDataProject.assertValues([project])

      let shippingRule2 = ShippingRule.template
        |> ShippingRule.lens.cost .~ 123.0

      self.vm.inputs.shippingRuleDidUpdate(to: shippingRule2)

      self.pledgeViewDataAndReloadIsLoggedIn.assertLastValue(false)
      self.pledgeViewDataAndReloadIsShippingEnabled.assertLastValue(true)
      self.pledgeViewDataAndReloadProject.assertLastValue(project)
      self.pledgeViewDataAndReloadReload.assertValueCount(4)
      self.pledgeViewDataAndReloadReload.assertLastValue(false)
      self.pledgeViewDataAndReloadReward.assertLastValue(reward)
      self.pledgeViewDataAndReloadSelectedShippingRule.assertLastValue(nil)
      self.pledgeViewDataAndReloadTotal.assertLastValue(reward.minimum + shippingRule2.cost)

      self.configureShippingLocationCellWithDataIsShippingRulesLoading.assertValues([true])
      self.configureShippingLocationCellWithDataProject.assertValues([project])
      self.configureShippingLocationCellWithDataSelectedShippingRule.assertValues([nil])

      self.configureSummaryCellWithDataPledgeTotal.assertValues(
        [reward.minimum + shippingRule1.cost, reward.minimum + shippingRule2.cost]
      )
      self.configureSummaryCellWithDataProject.assertValues([project, project])
    }
  }

  func testPledgeAmountUpdates() {
    let project = Project.template
    let reward = Reward.template

    self.vm.inputs.configureWith(project: project, reward: reward)
    self.vm.inputs.viewDidLoad()

    self.pledgeViewDataAndReloadIsLoggedIn.assertValues([false])
    self.pledgeViewDataAndReloadIsShippingEnabled.assertValues([false])
    self.pledgeViewDataAndReloadProject.assertValues([project])
    self.pledgeViewDataAndReloadReload.assertValues([true])
    self.pledgeViewDataAndReloadReward.assertValues([reward])
    self.pledgeViewDataAndReloadSelectedShippingRule.assertValues([nil])
    self.pledgeViewDataAndReloadTotal.assertValues([reward.minimum])

    self.configureShippingLocationCellWithDataIsShippingRulesLoading.assertDidNotEmitValue()
    self.configureShippingLocationCellWithDataProject.assertDidNotEmitValue()
    self.configureShippingLocationCellWithDataSelectedShippingRule.assertDidNotEmitValue()

    self.configureSummaryCellWithDataPledgeTotal.assertDidNotEmitValue()
    self.configureSummaryCellWithDataProject.assertDidNotEmitValue()

    let amount1 = 66.0

    self.vm.inputs.pledgeAmountDidUpdate(to: amount1)

    self.pledgeViewDataAndReloadIsLoggedIn.assertLastValue(false)
    self.pledgeViewDataAndReloadIsShippingEnabled.assertLastValue(false)
    self.pledgeViewDataAndReloadProject.assertLastValue(project)
    self.pledgeViewDataAndReloadReload.assertValueCount(2)
    self.pledgeViewDataAndReloadReload.assertLastValue(false)
    self.pledgeViewDataAndReloadReward.assertLastValue(reward)
    self.pledgeViewDataAndReloadSelectedShippingRule.assertLastValue(nil)
    self.pledgeViewDataAndReloadTotal.assertLastValue(amount1)

    self.configureShippingLocationCellWithDataIsShippingRulesLoading.assertDidNotEmitValue()
    self.configureShippingLocationCellWithDataProject.assertDidNotEmitValue()
    self.configureShippingLocationCellWithDataSelectedShippingRule.assertDidNotEmitValue()

    self.configureSummaryCellWithDataPledgeTotal.assertValues([amount1])
    self.configureSummaryCellWithDataProject.assertValues([project])

    let amount2 = 99.0

    self.vm.inputs.pledgeAmountDidUpdate(to: amount2)

    self.pledgeViewDataAndReloadIsLoggedIn.assertLastValue(false)
    self.pledgeViewDataAndReloadIsShippingEnabled.assertLastValue(false)
    self.pledgeViewDataAndReloadProject.assertLastValue(project)
    self.pledgeViewDataAndReloadReload.assertValueCount(3)
    self.pledgeViewDataAndReloadReload.assertLastValue(false)
    self.pledgeViewDataAndReloadReward.assertLastValue(reward)
    self.pledgeViewDataAndReloadSelectedShippingRule.assertLastValue(nil)
    self.pledgeViewDataAndReloadTotal.assertLastValue(amount2)

    self.configureShippingLocationCellWithDataIsShippingRulesLoading.assertDidNotEmitValue()
    self.configureShippingLocationCellWithDataProject.assertDidNotEmitValue()
    self.configureShippingLocationCellWithDataSelectedShippingRule.assertDidNotEmitValue()

    self.configureSummaryCellWithDataPledgeTotal.assertValues([amount1, amount2])
    self.configureSummaryCellWithDataProject.assertValues([project, project])
  }

  func testSelectedShippingRuleAndPledgeAmountUpdates() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.shipping .~ (.template |> Reward.Shipping.lens.enabled .~ true)

    withEnvironment {
      self.vm.inputs.configureWith(project: project, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.pledgeViewDataAndReloadIsLoggedIn.assertValues([false, false])
      self.pledgeViewDataAndReloadIsShippingEnabled.assertValues([true, true])
      self.pledgeViewDataAndReloadProject.assertValues([project, project])
      self.pledgeViewDataAndReloadReload.assertValues([true, false])
      self.pledgeViewDataAndReloadReward.assertValues([reward, reward])
      self.pledgeViewDataAndReloadSelectedShippingRule.assertValues([nil, nil])
      self.pledgeViewDataAndReloadTotal.assertValues([reward.minimum, reward.minimum])

      self.configureShippingLocationCellWithDataIsShippingRulesLoading.assertValues([true])
      self.configureShippingLocationCellWithDataProject.assertValues([project])
      self.configureShippingLocationCellWithDataSelectedShippingRule.assertValues([nil])

      self.configureSummaryCellWithDataPledgeTotal.assertDidNotEmitValue()
      self.configureSummaryCellWithDataProject.assertDidNotEmitValue()

      let shippingRule1 = ShippingRule.template
        |> ShippingRule.lens.cost .~ 20.0

      self.vm.inputs.shippingRuleDidUpdate(to: shippingRule1)

      self.pledgeViewDataAndReloadIsLoggedIn.assertLastValue(false)
      self.pledgeViewDataAndReloadIsShippingEnabled.assertLastValue(true)
      self.pledgeViewDataAndReloadProject.assertLastValue(project)
      self.pledgeViewDataAndReloadReload.assertValueCount(3)
      self.pledgeViewDataAndReloadReload.assertLastValue(false)
      self.pledgeViewDataAndReloadReward.assertLastValue(reward)
      self.pledgeViewDataAndReloadSelectedShippingRule.assertLastValue(nil)
      self.pledgeViewDataAndReloadTotal.assertLastValue(reward.minimum + shippingRule1.cost)

      self.configureShippingLocationCellWithDataIsShippingRulesLoading.assertValues([true])
      self.configureShippingLocationCellWithDataProject.assertValues([project])
      self.configureShippingLocationCellWithDataSelectedShippingRule.assertValues([nil])

      self.configureSummaryCellWithDataPledgeTotal.assertValues([reward.minimum + shippingRule1.cost])
      self.configureSummaryCellWithDataProject.assertValues([project])

      let amount1 = 200.0

      self.vm.inputs.pledgeAmountDidUpdate(to: amount1)

      self.pledgeViewDataAndReloadIsLoggedIn.assertLastValue(false)
      self.pledgeViewDataAndReloadIsShippingEnabled.assertLastValue(true)
      self.pledgeViewDataAndReloadProject.assertLastValue(project)
      self.pledgeViewDataAndReloadReload.assertValueCount(4)
      self.pledgeViewDataAndReloadReload.assertLastValue(false)
      self.pledgeViewDataAndReloadReward.assertLastValue(reward)
      self.pledgeViewDataAndReloadSelectedShippingRule.assertLastValue(nil)
      self.pledgeViewDataAndReloadTotal.assertLastValue(shippingRule1.cost + amount1)

      self.configureShippingLocationCellWithDataIsShippingRulesLoading.assertValues([true])
      self.configureShippingLocationCellWithDataProject.assertValues([project])
      self.configureShippingLocationCellWithDataSelectedShippingRule.assertValues([nil])

      self.configureSummaryCellWithDataPledgeTotal.assertValues(
        [reward.minimum + shippingRule1.cost, shippingRule1.cost + amount1]
      )
      self.configureSummaryCellWithDataProject.assertValues([project, project])

      let shippingRule2 = ShippingRule.template
        |> ShippingRule.lens.cost .~ 123.0

      self.vm.inputs.shippingRuleDidUpdate(to: shippingRule2)

      self.pledgeViewDataAndReloadIsLoggedIn.assertLastValue(false)
      self.pledgeViewDataAndReloadIsShippingEnabled.assertLastValue(true)
      self.pledgeViewDataAndReloadProject.assertLastValue(project)
      self.pledgeViewDataAndReloadReload.assertValueCount(5)
      self.pledgeViewDataAndReloadReload.assertLastValue(false)
      self.pledgeViewDataAndReloadReward.assertLastValue(reward)
      self.pledgeViewDataAndReloadSelectedShippingRule.assertLastValue(nil)
      self.pledgeViewDataAndReloadTotal.assertLastValue(amount1 + shippingRule2.cost)

      self.configureShippingLocationCellWithDataIsShippingRulesLoading.assertValues([true])
      self.configureShippingLocationCellWithDataProject.assertValues([project])
      self.configureShippingLocationCellWithDataSelectedShippingRule.assertValues([nil])

      self.configureSummaryCellWithDataPledgeTotal.assertValues(
        [reward.minimum + shippingRule1.cost, shippingRule1.cost + amount1, shippingRule2.cost + amount1]
      )
      self.configureSummaryCellWithDataProject.assertValues([project, project, project])

      let amount2 = 1_999.0

      self.vm.inputs.pledgeAmountDidUpdate(to: amount2)

      self.pledgeViewDataAndReloadIsLoggedIn.assertLastValue(false)
      self.pledgeViewDataAndReloadIsShippingEnabled.assertLastValue(true)
      self.pledgeViewDataAndReloadProject.assertLastValue(project)
      self.pledgeViewDataAndReloadReload.assertValueCount(6)
      self.pledgeViewDataAndReloadReload.assertLastValue(false)
      self.pledgeViewDataAndReloadReward.assertLastValue(reward)
      self.pledgeViewDataAndReloadSelectedShippingRule.assertLastValue(nil)
      self.pledgeViewDataAndReloadTotal.assertLastValue(shippingRule2.cost + amount2)

      self.configureShippingLocationCellWithDataIsShippingRulesLoading.assertValues([true])
      self.configureShippingLocationCellWithDataProject.assertValues([project])
      self.configureShippingLocationCellWithDataSelectedShippingRule.assertValues([nil])

      self.configureSummaryCellWithDataPledgeTotal.assertValues(
        [reward.minimum + shippingRule1.cost, shippingRule1.cost + amount1, shippingRule2.cost + amount1, shippingRule2.cost + amount2]
      )
      self.configureSummaryCellWithDataProject.assertValues([project, project, project, project])
    }
  }

  func testPresentShippingRules() {
    let shippingRules = [.usa, .canada, .greatBritain, .australia]
      .enumerated()
      .map { idx, location in
        .template
          |> ShippingRule.lens.location .~ location
          |> ShippingRule.lens.cost .~ Double(idx + 1 * 10)
      }

    withEnvironment(apiService: MockService(fetchShippingRulesResult: .success(shippingRules))) {
      let reward = Reward.template
        |> Reward.lens.shipping.enabled .~ true

      self.vm.inputs.viewDidLoad()
      self.vm.inputs.configureWith(project: .template, reward: reward)

      self.presentShippingRules.assertValues([[]])

      self.scheduler.advance()

      self.presentShippingRules.assertValues([[], shippingRules])
    }
  }

  func testShippingRulesError() {
    let error = ErrorEnvelope(errorMessages: [], ksrCode: nil, httpCode: 404, exception: nil)

    withEnvironment(apiService: MockService(fetchShippingRulesResult: Result(failure: error))) {
      let reward = Reward.template
        |> Reward.lens.shipping.enabled .~ true

      self.vm.inputs.viewDidLoad()
      self.vm.inputs.configureWith(project: .template, reward: reward)

      self.shippingRulesError.assertValues([])

      self.scheduler.advance()

      self.shippingRulesError.assertValues([Strings.We_were_unable_to_load_the_shipping_destinations()])
    }
  }
}
