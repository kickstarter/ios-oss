import XCTest
@testable import Library
@testable import Kickstarter_iOS
@testable import ReactiveExtensions_TestHelpers
@testable import Models
@testable import Models_TestHelpers
import ReactiveCocoa
import Result
import Prelude

final class ProjectRewardCellViewModelTest: TestCase {
  let vm: ProjectRewardCellViewModelType = ProjectRewardCellViewModel()

  let project = Project.template
  let disabledShipping = Reward.Shipping(enabled: false, preference: nil, summary: nil)
  let restrictedShipping = Reward.Shipping(enabled: true, preference: .restricted, summary: nil)
  let unrestrictedShipping = Reward.Shipping(enabled: true, preference: .unrestricted, summary: nil)

  let backersHidden = TestObserver<Bool, NoError>()
  let limitHidden = TestObserver<Bool, NoError>()
  let allGoneHidden = TestObserver<Bool, NoError>()
  let rewardDisabled = TestObserver<Bool, NoError>()
  let shippingHidden = TestObserver<Bool, NoError>()
  let shippingRestrictionsHidden = TestObserver<Bool, NoError>()
  let backerLabelHidden = TestObserver<Bool, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.backersHidden.observe(self.backersHidden.observer)
    self.vm.outputs.limitHidden.observe(self.limitHidden.observer)
    self.vm.outputs.allGoneHidden.observe(self.allGoneHidden.observer)
    self.vm.outputs.rewardDisabled.observe(self.rewardDisabled.observer)
    self.vm.outputs.shippingHidden.observe(self.shippingHidden.observer)
    self.vm.outputs.shippingRestrictionsHidden.observe(self.shippingRestrictionsHidden.observer)
    self.vm.outputs.backerLabelHidden.observe(self.backerLabelHidden.observer)
  }

  func testLimitedReward_SoldOut() {
    let reward = Reward.template
      |> Reward.lens.backersCount *~ 1
      <> Reward.lens.limit *~ 1
      <> Reward.lens.remaining *~ 0

    self.vm.inputs.project(project, reward: reward)

    self.limitHidden.assertValues([true])
    self.allGoneHidden.assertValues([false])
    self.rewardDisabled.assertValues([true])
  }

  func testLimitedReward_NotSoldOut() {
    let reward = Reward.template
      |> Reward.lens.backersCount *~ 1
      <> Reward.lens.limit *~ 2
      <> Reward.lens.remaining *~ 1

    self.vm.inputs.project(project, reward: reward)

    self.limitHidden.assertValues([false])
    self.allGoneHidden.assertValues([true])
    self.rewardDisabled.assertValues([false])
  }

  func testReward_NoShipping() {
    let reward = Reward.template
      |> Reward.lens.backersCount *~ 1
      <> Reward.lens.limit *~ 2
      <> Reward.lens.remaining *~ 1
      <> Reward.lens.shipping *~ disabledShipping

    self.vm.inputs.project(project, reward: reward)

    self.shippingHidden.assertValues([true])
    self.shippingRestrictionsHidden.assertValues([true])
  }

  func testReward_ShippingEnabled() {
    let reward = Reward.template
      |> Reward.lens.backersCount *~ 1
      <> Reward.lens.limit *~ 2
      <> Reward.lens.remaining *~ 1
      <> Reward.lens.shipping *~ restrictedShipping

    self.vm.inputs.project(project, reward: reward)

    self.shippingHidden.assertValues([false])
    self.shippingRestrictionsHidden.assertValues([false])
  }

  func testReward_Backing() {
    let backerReward = Reward.template
      |> Reward.lens.backersCount *~ 1
      <> Reward.lens.id *~ 42
      <> Reward.lens.limit *~ 2
      <> Reward.lens.remaining *~ 1
      <> Reward.lens.shipping *~ restrictedShipping
    let backing = Backing.template
      |> Backing.lens.reward *~ backerReward
      <> Backing.lens.rewardId *~ backerReward.id
    let backedProject = Project.template
      |> Project.lens.backing *~ backing
      <> Project.lens.rewards *~ [backerReward, Reward.template]

    self.vm.inputs.project(backedProject, reward: Reward.template)

    self.backerLabelHidden.assertValues([true])

    self.vm.inputs.project(backedProject, reward: backerReward)

    self.backerLabelHidden.assertValues([true, false])
  }
}
