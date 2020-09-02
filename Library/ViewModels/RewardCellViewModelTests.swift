import Foundation
@testable import KsApi
import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers

final class RewardCellViewModelTests: TestCase {
  private let vm = RewardCellViewModel()

  private let backerLabelHidden = TestObserver<Bool, Never>()
  private let scrollScrollViewToTop = TestObserver<Void, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.backerLabelHidden.observe(self.backerLabelHidden.observer)
    self.vm.outputs.scrollScrollViewToTop.observe(self.scrollScrollViewToTop.observer)
  }

  func testPrepareForReuse() {
    self.scrollScrollViewToTop.assertDidNotEmitValue()

    self.vm.inputs.prepareForReuse()

    self.scrollScrollViewToTop.assertValueCount(1)

    self.vm.inputs.prepareForReuse()

    self.scrollScrollViewToTop.assertValueCount(2)
  }

  func testBackerLabelHidden_IsBacked() {
    self.backerLabelHidden.assertDidNotEmitValue()

    let reward = Reward.template

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.amount .~ 700.0
      )

    self.vm.inputs.configure(with: (project, reward, .manage))

    self.backerLabelHidden.assertValues([false])
  }

  func testBackerLabelHidden_IsNotBacked() {
    self.backerLabelHidden.assertDidNotEmitValue()

    let reward = Reward.template

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ Reward.noReward
          |> Backing.lens.rewardId .~ Reward.noReward.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.amount .~ 700.0
      )

    self.vm.inputs.configure(with: (project, reward, .manage))

    self.backerLabelHidden.assertValues([true])
  }
}
