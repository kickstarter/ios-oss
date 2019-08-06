@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class RewardCardContainerViewModelTests: TestCase {
  fileprivate let vm: RewardCardContainerViewModelType = RewardCardContainerViewModel()

  private let pledgeButtonEnabled = TestObserver<Bool, Never>()
  private let pledgeButtonTitleText = TestObserver<String, Never>()
  private let rewardSelected = TestObserver<Int, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.pledgeButtonEnabled.observe(self.pledgeButtonEnabled.observer)
    self.vm.outputs.pledgeButtonTitleText.observe(self.pledgeButtonTitleText.observer)
    self.vm.outputs.rewardSelected.observe(self.rewardSelected.observer)
  }

  // MARK: - Pledge Button

  func testPledgeButtonTitle_Reward_NotAllGone() {
    let project = Project.template
      |> Project.lens.country .~ .us

    let reward = Reward.template
      |> Reward.lens.remaining .~ 10
      |> Reward.lens.minimum .~ 1_000

    withEnvironment(locale: Locale(identifier: "en")) {
      self.vm.inputs.configureWith(project: project, rewardOrBacking: .left(reward))

      self.pledgeButtonTitleText.assertValues(["Pledge $1,000 or more"])
    }
  }

  func testPledgeButtonEnabled_Reward_NotAllGone() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.remaining .~ 10
      |> Reward.lens.minimum .~ 1_000

    self.vm.inputs.configureWith(project: project, rewardOrBacking: .left(reward))

    self.pledgeButtonEnabled.assertValues([true])
  }

  func testPledgeButtonEnabled_Reward_AllGone() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.remaining .~ 0
      |> Reward.lens.minimum .~ 1_000

    self.vm.inputs.configureWith(project: project, rewardOrBacking: .left(reward))

    self.pledgeButtonEnabled.assertValues([false])
  }

  func testPledgeButtonTapped() {
    self.vm.inputs.configureWith(project: .template, rewardOrBacking: .left(.template))

    self.vm.inputs.pledgeButtonTapped()

    self.rewardSelected.assertValues([Reward.template.id])
  }
}
