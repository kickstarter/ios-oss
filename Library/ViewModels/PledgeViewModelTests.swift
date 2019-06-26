import Foundation
import Prelude
import ReactiveExtensions
import ReactiveSwift
import Result
import XCTest

@testable import KsApi
@testable import Library
import ReactiveExtensions_TestHelpers

final class PledgeViewModelTests: TestCase {
  private let vm: PledgeViewModelType = PledgeViewModel()

  private let configureSummaryCellWithProject = TestObserver<Project, Never>()
  private let configureSummaryCellWithPledgeTotal = TestObserver<Double, Never>()
  private let project = TestObserver<Project, Never>()
  private let reward = TestObserver<Reward, Never>()
  private let isLoggedIn = TestObserver<Bool, Never>()
  private let isShippingEnabled = TestObserver<Bool, Never>()
  private let total = TestObserver<Double, Never>()

  private let reload = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.configureSummaryCellWithProjectAndPledgeTotal.map(first)
      .observe(self.configureSummaryCellWithProject.observer)
    self.vm.outputs.configureSummaryCellWithProjectAndPledgeTotal.map(second)
      .observe(self.configureSummaryCellWithPledgeTotal.observer)
    self.vm.outputs.pledgeViewDataAndReload.map(second).observe(self.reload.observer)
    self.vm.outputs.pledgeViewDataAndReload.map(first).map { $0.0 }.observe(self.project.observer)
    self.vm.outputs.pledgeViewDataAndReload.map(first).map { $0.1 }.observe(self.reward.observer)
    self.vm.outputs.pledgeViewDataAndReload.map(first).map { $0.2 }.observe(self.isLoggedIn.observer)
    self.vm.outputs.pledgeViewDataAndReload.map(first).map { $0.3 }.observe(self.isShippingEnabled.observer)
    self.vm.outputs.pledgeViewDataAndReload.map(first).map { $0.4 }.observe(self.total.observer)
  }

  func testReloadWithData_loggedOut() {
    withEnvironment(currentUser: nil) {
      let project = Project.template
      let reward = Reward.template

      self.vm.inputs.configureWith(project: project, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.project.assertValues([project])
      self.reward.assertValues([reward])
      self.isLoggedIn.assertValues([false])
      self.isShippingEnabled.assertValues([false])
      self.total.assertValues([reward.minimum])
      self.configureSummaryCellWithProject.assertValues([])
      self.configureSummaryCellWithPledgeTotal.assertValues([])
    }
  }

  func testReloadWithData_loggedIn() {
    let project = Project.template
    let reward = Reward.template
    let user = User.template

    withEnvironment(currentUser: user) {
      self.vm.inputs.configureWith(project: project, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.project.assertValues([project])
      self.reward.assertValues([reward])
      self.isLoggedIn.assertValues([true])
      self.isShippingEnabled.assertValues([false])
      self.total.assertValues([reward.minimum])
      self.configureSummaryCellWithProject.assertValues([])
      self.configureSummaryCellWithPledgeTotal.assertValues([])
    }
  }

  func testReloadWithData_ShippingEnabled() {
    let reward = Reward.template
      |> Reward.lens.shipping .~ (.template |> Reward.Shipping.lens.enabled .~ true)

    let project = Project.template

    withEnvironment {
      self.vm.inputs.configureWith(project: project, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.project.assertValues([project])
      self.reward.assertValues([reward])
      self.total.assertValues([reward.minimum])
      self.isShippingEnabled.assertValues([true])
      self.reload.assertValues([true])
      self.configureSummaryCellWithProject.assertValues([])
      self.configureSummaryCellWithPledgeTotal.assertValues([])

      let shippingRule = .template
        |> ShippingRule.lens.cost .~ 20.0

      self.vm.inputs.shippingRuleDidUpdate(to: shippingRule)

      self.project.assertValues([project, project])
      self.reward.assertValues([reward, reward])
      self.total.assertValues([reward.minimum, reward.minimum + shippingRule.cost])
      self.isShippingEnabled.assertValues([true, true])
      self.reload.assertValues([true, false])
      self.configureSummaryCellWithProject.assertValues([project])
      self.configureSummaryCellWithPledgeTotal.assertValues([reward.minimum + shippingRule.cost])
    }
  }

  func testReloadWithData_ShippingEnabled_Amount_Updates() {
    let reward = Reward.template
      |> Reward.lens.shipping .~ (.template |> Reward.Shipping.lens.enabled .~ true)

    let project = Project.template

    withEnvironment {
      self.vm.inputs.configureWith(project: project, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.project.assertValues([project])
      self.reward.assertValues([reward])
      self.total.assertValues([reward.minimum])
      self.isShippingEnabled.assertValues([true])
      self.reload.assertValues([true])
      self.configureSummaryCellWithProject.assertValues([])
      self.configureSummaryCellWithPledgeTotal.assertValues([])

      let shippingRule = .template
        |> ShippingRule.lens.cost .~ 20.0

      self.vm.inputs.shippingRuleDidUpdate(to: shippingRule)

      self.project.assertValues([project, project])
      self.reward.assertValues([reward, reward])
      self.total.assertValues([reward.minimum, reward.minimum + shippingRule.cost])
      self.isShippingEnabled.assertValues([true, true])
      self.reload.assertValues([true, false])
      self.configureSummaryCellWithProject.assertValues([project])
      self.configureSummaryCellWithPledgeTotal.assertValues([reward.minimum + shippingRule.cost])

      let amountUpdate1 = 30.0
      self.vm.inputs.pledgeAmountDidUpdate(to: amountUpdate1)

      self.project.assertValues([project, project, project])
      self.reward.assertValues([reward, reward, reward])
      self.total.assertValues([
        reward.minimum,
        reward.minimum + shippingRule.cost,
        amountUpdate1 + shippingRule.cost
      ])
      self.isShippingEnabled.assertValues([true, true, true])
      self.reload.assertValues([true, false, false])
      self.configureSummaryCellWithProject.assertValues([project, project])
      self.configureSummaryCellWithPledgeTotal.assertValues([
        reward.minimum + shippingRule.cost,
        amountUpdate1 + shippingRule.cost
      ])

      let amountUpdate2 = 25.0
      self.vm.inputs.pledgeAmountDidUpdate(to: amountUpdate2)

      self.project.assertValues([project, project, project, project])
      self.reward.assertValues([reward, reward, reward, reward])
      self.total.assertValues([
        reward.minimum,
        reward.minimum + shippingRule.cost,
        amountUpdate1 + shippingRule.cost,
        amountUpdate2 + shippingRule.cost
      ])
      self.isShippingEnabled.assertValues([true, true, true, true])
      self.reload.assertValues([true, false, false, false])
      self.configureSummaryCellWithProject.assertValues([project, project, project])
      self.configureSummaryCellWithPledgeTotal.assertValues([
        reward.minimum + shippingRule.cost,
        amountUpdate1 + shippingRule.cost,
        amountUpdate2 + shippingRule.cost
      ])
    }
  }
}
