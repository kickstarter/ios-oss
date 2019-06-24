import Foundation
import Prelude
import ReactiveExtensions
import ReactiveSwift
import XCTest

@testable import KsApi
@testable import Library
import ReactiveExtensions_TestHelpers

final class PledgeViewModelTests: TestCase {
  private let vm: PledgeViewModelType = PledgeViewModel()

  private let project = TestObserver<Project, Never>()
  private let reward = TestObserver<Reward, Never>()
  private let isLoggedIn = TestObserver<Bool, Never>()
  private let total = TestObserver<Double, Never>()

  private let reloadWithData = TestObserver<PledgeViewData, Never>()
  private let updateWithData = TestObserver<PledgeViewData, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.reloadWithData.observe(self.reloadWithData.observer)
    self.vm.outputs.reloadWithData.map { $0.0 }.observe(self.project.observer)
    self.vm.outputs.reloadWithData.map { $0.1 }.observe(self.reward.observer)
    self.vm.outputs.reloadWithData.map { $0.2 }.observe(self.isLoggedIn.observer)
    self.vm.outputs.reloadWithData.map { $0.3 }.observe(self.total.observer)

    self.vm.outputs.updateWithData.observe(self.updateWithData.observer)
    self.vm.outputs.updateWithData.map { $0.0 }.observe(self.project.observer)
    self.vm.outputs.updateWithData.map { $0.1 }.observe(self.reward.observer)
    self.vm.outputs.updateWithData.map { $0.2 }.observe(self.isLoggedIn.observer)
    self.vm.outputs.updateWithData.map { $0.3 }.observe(self.total.observer)
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
      self.total.assertValues([reward.minimum])
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
      self.total.assertValues([reward.minimum])
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
      self.reloadWithData.assertValueCount(1)
      self.updateWithData.assertValueCount(0)

      let shippingRule = .template
        |> ShippingRule.lens.cost .~ 20.0

      self.vm.inputs.shippingRuleDidUpdate(to: shippingRule)

      self.project.assertValues([project, project])
      self.reward.assertValues([reward, reward])
      self.total.assertValues([reward.minimum, reward.minimum + shippingRule.cost])
      self.reloadWithData.assertValueCount(1)
      self.updateWithData.assertValueCount(1)
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
      self.reloadWithData.assertValueCount(1)
      self.updateWithData.assertValueCount(0)

      let shippingRule = .template
        |> ShippingRule.lens.cost .~ 20.0

      self.vm.inputs.shippingRuleDidUpdate(to: shippingRule)

      self.project.assertValues([project, project])
      self.reward.assertValues([reward, reward])
      self.total.assertValues([reward.minimum, reward.minimum + shippingRule.cost])
      self.reloadWithData.assertValueCount(1)
      self.updateWithData.assertValueCount(1)

      let amountUpdate1 = 30.0
      self.vm.inputs.pledgeAmountDidUpdate(to: amountUpdate1)

      self.project.assertValues([project, project, project])
      self.reward.assertValues([reward, reward, reward])
      self.total.assertValues([
        reward.minimum,
        reward.minimum + shippingRule.cost,
        amountUpdate1 + shippingRule.cost
      ])
      self.reloadWithData.assertValueCount(1)
      self.updateWithData.assertValueCount(2)

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
      self.reloadWithData.assertValueCount(1)
      self.updateWithData.assertValueCount(3)
    }
  }
}
