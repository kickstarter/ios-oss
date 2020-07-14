@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class RewardAddOnSelectionViewModelTests: TestCase {
  private let vm: RewardAddOnSelectionViewModelType = RewardAddOnSelectionViewModel()

  private let configurePledgeShippingLocationViewControllerWithDataProject = TestObserver<Project, Never>()
  private let configurePledgeShippingLocationViewControllerWithDataReward = TestObserver<Reward, Never>()
  private let configurePledgeShippingLocationViewControllerWithDataShowAmount = TestObserver<Bool, Never>()
  private let loadAddOnRewardsIntoDataSource = TestObserver<[RewardAddOnCellData], Never>()
  private let shippingLocationViewIsHidden = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.configurePledgeShippingLocationViewControllerWithData.map(first)
      .observe(self.configurePledgeShippingLocationViewControllerWithDataProject.observer)
    self.vm.outputs.configurePledgeShippingLocationViewControllerWithData.map(second)
      .observe(self.configurePledgeShippingLocationViewControllerWithDataReward.observer)
    self.vm.outputs.configurePledgeShippingLocationViewControllerWithData.map(third)
      .observe(self.configurePledgeShippingLocationViewControllerWithDataShowAmount.observer)
    self.vm.outputs.loadAddOnRewardsIntoDataSource.observe(self.loadAddOnRewardsIntoDataSource.observer)
    self.vm.outputs.shippingLocationViewIsHidden.observe(self.shippingLocationViewIsHidden.observer)
  }

  func testConfigurePledgeShippingLocationViewControllerWithData() {
    self.configurePledgeShippingLocationViewControllerWithDataProject.assertDidNotEmitValue()
    self.configurePledgeShippingLocationViewControllerWithDataReward.assertDidNotEmitValue()
    self.configurePledgeShippingLocationViewControllerWithDataShowAmount.assertDidNotEmitValue()

    let reward = Reward.template
    let project = Project.template

    self.vm.inputs.configureWith(project: project, reward: reward, refTag: nil, context: .pledge)
    self.vm.inputs.viewDidLoad()

    self.configurePledgeShippingLocationViewControllerWithDataProject.assertValues([project])
    self.configurePledgeShippingLocationViewControllerWithDataReward.assertValues([reward])
    self.configurePledgeShippingLocationViewControllerWithDataShowAmount.assertValues([false])
  }

  func testLoadAddOnRewardsIntoDataSource() {
    self.loadAddOnRewardsIntoDataSource.assertDidNotEmitValue()

    let reward = Reward.template
    let project = Project.template
    let env = RewardAddOnSelectionViewEnvelope.template

    guard
      let addOn = env.project.addOns?.nodes.first,
      let addOnReward = Reward.addOnReward(
        from: addOn,
        project: project,
        selectedAddOnQuantities: [:],
        dateFormatter: DateFormatter()
      ) else {
      XCTFail("Should have an add-on")
      return
    }

    let expected = RewardAddOnCellData(
      project: project,
      reward: addOnReward,
      shippingRule: nil
    )

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .success(env))

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith(project: project, reward: reward, refTag: nil, context: .pledge)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.loadAddOnRewardsIntoDataSource.assertValues([[expected]])
    }
  }

  func testShippingLocationViewIsHidden_RewardHasShipping() {
    self.shippingLocationViewIsHidden.assertDidNotEmitValue()

    let reward = Reward.template
      |> Reward.lens.shipping .~ (
        .template |> Reward.Shipping.lens.enabled .~ true
      )
    let project = Project.template

    self.vm.inputs.configureWith(project: project, reward: reward, refTag: nil, context: .pledge)
    self.vm.inputs.viewDidLoad()

    self.shippingLocationViewIsHidden.assertValues([false])
  }

  func testShippingLocationViewIsHidden_NoShipping() {
    self.shippingLocationViewIsHidden.assertDidNotEmitValue()

    let reward = Reward.template
      |> Reward.lens.shipping .~ (
        .template |> Reward.Shipping.lens.enabled .~ false
      )
    let project = Project.template

    self.vm.inputs.configureWith(project: project, reward: reward, refTag: nil, context: .pledge)
    self.vm.inputs.viewDidLoad()

    self.shippingLocationViewIsHidden.assertValues([true])
  }
}
