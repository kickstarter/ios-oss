import Foundation
@testable import KsApi
@testable import Library
import PassKit
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class UpdatePledgeViewModelTests: TestCase {
  private let vm: UpdatePledgeViewModelType = UpdatePledgeViewModel()

  private let configureSummaryCellWithDataPledgeTotal = TestObserver<Double, Never>()
  private let configureSummaryCellWithDataProject = TestObserver<Project, Never>()
  private let configureWithPledgeViewDataProject = TestObserver<Project, Never>()
  private let configureWithPledgeViewDataReward = TestObserver<Reward, Never>()
  private let confirmationLabelAttributedText = TestObserver<NSAttributedString, Never>()
  private let shippingLocationViewHidden = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.configureSummaryViewControllerWithData.map(second)
      .observe(self.configureSummaryCellWithDataPledgeTotal.observer)
    self.vm.outputs.configureSummaryViewControllerWithData.map(first)
      .observe(self.configureSummaryCellWithDataProject.observer)

    self.vm.outputs.configureWithData.map { $0.project }
      .observe(self.configureWithPledgeViewDataProject.observer)
    self.vm.outputs.configureWithData.map { $0.reward }
      .observe(self.configureWithPledgeViewDataReward.observer)

    self.vm.outputs.confirmationLabelAttributedText.observe(self.confirmationLabelAttributedText.observer)

    self.vm.outputs.shippingLocationViewHidden.observe(self.shippingLocationViewHidden.observer)
  }

  func testShipping_Disabled() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ false

    self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage)
    self.vm.inputs.viewDidLoad()

    self.configureWithPledgeViewDataProject.assertValues([project])
    self.configureWithPledgeViewDataReward.assertValues([reward])

    self.shippingLocationViewHidden.assertValues([true])
    self.configureSummaryCellWithDataPledgeTotal.assertValues([reward.minimum])
    self.configureSummaryCellWithDataProject.assertValues([project])
  }

  func testShipping_Enabled() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true

    self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage)
    self.vm.inputs.viewDidLoad()

    self.configureWithPledgeViewDataProject.assertValues([project])
    self.configureWithPledgeViewDataReward.assertValues([reward])

    self.shippingLocationViewHidden.assertValues([false])
    self.configureSummaryCellWithDataPledgeTotal.assertValues([reward.minimum])
    self.configureSummaryCellWithDataProject.assertValues([project])
  }

  func testShippingRuleSelectedDefaultShippingRule() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.shipping .~ (.template |> Reward.Shipping.lens.enabled .~ true)

    self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage)
    self.vm.inputs.viewDidLoad()

    self.configureWithPledgeViewDataProject.assertValues([project])
    self.configureWithPledgeViewDataReward.assertValues([reward])

    self.shippingLocationViewHidden.assertValues([false])
    self.configureSummaryCellWithDataPledgeTotal.assertValues([reward.minimum])
    self.configureSummaryCellWithDataProject.assertValues([project])

    let defaultShippingRule = ShippingRule.template
      |> ShippingRule.lens.cost .~ 5

    self.vm.inputs.shippingRuleSelected(defaultShippingRule)

    self.configureSummaryCellWithDataPledgeTotal
      .assertValues([reward.minimum, reward.minimum + defaultShippingRule.cost])
    self.configureSummaryCellWithDataProject.assertValues([project, project])
  }

  func testShippingRuleSelectedUpdatedShippingRule() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.shipping .~ (.template |> Reward.Shipping.lens.enabled .~ true)

    self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage)
    self.vm.inputs.viewDidLoad()

    self.configureWithPledgeViewDataProject.assertValues([project])
    self.configureWithPledgeViewDataReward.assertValues([reward])

    self.shippingLocationViewHidden.assertValues([false])
    self.configureSummaryCellWithDataPledgeTotal.assertValues([reward.minimum])
    self.configureSummaryCellWithDataProject.assertValues([project])

    let defaultShippingRule = ShippingRule.template
      |> ShippingRule.lens.cost .~ 5

    self.vm.inputs.shippingRuleSelected(defaultShippingRule)

    self.configureSummaryCellWithDataPledgeTotal
      .assertValues([reward.minimum, reward.minimum + defaultShippingRule.cost])
    self.configureSummaryCellWithDataProject.assertValues([project, project])

    let selectedShippingRule = ShippingRule.template
      |> ShippingRule.lens.cost .~ 5
      |> ShippingRule.lens.location .~ .australia

    self.vm.inputs.shippingRuleSelected(selectedShippingRule)

    self.configureSummaryCellWithDataPledgeTotal.assertValues([
      reward.minimum,
      reward.minimum + defaultShippingRule.cost,
      reward.minimum + selectedShippingRule.cost
    ])
    self.configureSummaryCellWithDataProject.assertValues([project, project, project])
  }

  func testPledgeAmountUpdates() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true

    self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage)
    self.vm.inputs.viewDidLoad()

    self.configureWithPledgeViewDataProject.assertValues([project])
    self.configureWithPledgeViewDataReward.assertValues([reward])

    self.shippingLocationViewHidden.assertValues([false])

    self.configureSummaryCellWithDataPledgeTotal.assertValues([reward.minimum])
    self.configureSummaryCellWithDataProject.assertValues([project])

    let amount1 = 66.0

    self.vm.inputs.pledgeAmountDidUpdate(to: amount1)

    self.configureWithPledgeViewDataProject.assertValues([project])
    self.configureWithPledgeViewDataReward.assertValues([reward])

    self.configureSummaryCellWithDataPledgeTotal.assertValues([reward.minimum, amount1])
    self.configureSummaryCellWithDataProject.assertValues([project, project])

    let amount2 = 99.0

    self.vm.inputs.pledgeAmountDidUpdate(to: amount2)

    self.configureWithPledgeViewDataProject.assertValues([project])
    self.configureWithPledgeViewDataReward.assertValues([reward])

    self.configureSummaryCellWithDataPledgeTotal.assertValues([reward.minimum, amount1, amount2])
    self.configureSummaryCellWithDataProject.assertValues([project, project, project])
  }

  func testSelectedShippingRuleAndPledgeAmountUpdates() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.shipping .~ (.template |> Reward.Shipping.lens.enabled .~ true)

    self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage)
    self.vm.inputs.viewDidLoad()

    self.configureWithPledgeViewDataProject.assertValues([project])
    self.configureWithPledgeViewDataReward.assertValues([reward])

    self.shippingLocationViewHidden.assertValues([false])

    self.configureSummaryCellWithDataPledgeTotal.assertValues([reward.minimum])
    self.configureSummaryCellWithDataProject.assertValues([project])

    let shippingRule1 = ShippingRule.template
      |> ShippingRule.lens.cost .~ 20.0

    self.vm.inputs.shippingRuleSelected(shippingRule1)

    self.configureWithPledgeViewDataProject.assertValues([project])
    self.configureWithPledgeViewDataReward.assertValues([reward])

    self.configureSummaryCellWithDataPledgeTotal.assertValues([
      reward.minimum,
      reward.minimum + shippingRule1.cost
    ])
    self.configureSummaryCellWithDataProject.assertValues([project, project])

    let amount1 = 200.0

    self.vm.inputs.pledgeAmountDidUpdate(to: amount1)

    self.configureWithPledgeViewDataProject.assertValues([project])
    self.configureWithPledgeViewDataReward.assertValues([reward])

    self.configureSummaryCellWithDataPledgeTotal.assertValues(
      [reward.minimum, reward.minimum + shippingRule1.cost, shippingRule1.cost + amount1]
    )
    self.configureSummaryCellWithDataProject.assertValues([project, project, project])

    let shippingRule2 = ShippingRule.template
      |> ShippingRule.lens.cost .~ 123.0

    self.vm.inputs.shippingRuleSelected(shippingRule2)

    self.configureWithPledgeViewDataProject.assertValues([project])
    self.configureWithPledgeViewDataReward.assertValues([reward])

    self.configureSummaryCellWithDataPledgeTotal.assertValues(
      [
        reward.minimum,
        reward.minimum + shippingRule1.cost,
        shippingRule1.cost + amount1,
        shippingRule2.cost + amount1
      ]
    )
    self.configureSummaryCellWithDataProject.assertValues([project, project, project, project])

    let amount2 = 1_999.0

    self.vm.inputs.pledgeAmountDidUpdate(to: amount2)

    self.configureWithPledgeViewDataProject.assertValues([project])
    self.configureWithPledgeViewDataReward.assertValues([reward])

    self.configureSummaryCellWithDataPledgeTotal.assertValues(
      [
        reward.minimum,
        reward.minimum + shippingRule1.cost,
        shippingRule1.cost + amount1,
        shippingRule2.cost + amount1,
        shippingRule2.cost + amount2
      ]
    )
    self.configureSummaryCellWithDataProject.assertValues([project, project, project, project, project])
  }

  func testConfirmationLabelAttributedText() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ false

    self.confirmationLabelAttributedText.assertDidNotEmitValue()

    self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage)
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual(
      self.confirmationLabelAttributedText.values.map { $0.string },
      ["If the project reaches its funding goal, you will be charged on October 16, 2016."]
    )

    self.vm.inputs.traitCollectionDidChange()

    XCTAssertEqual(
      self.confirmationLabelAttributedText.values.map { $0.string },
      [
        "If the project reaches its funding goal, you will be charged on October 16, 2016.",
        "If the project reaches its funding goal, you will be charged on October 16, 2016."
      ]
    )
  }
}
