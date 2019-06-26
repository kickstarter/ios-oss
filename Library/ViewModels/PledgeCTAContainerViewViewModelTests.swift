import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class PledgeCTAContainerViewViewModelTests: TestCase {
  let vm: PledgeCTAContainerViewViewModelType = PledgeCTAContainerViewViewModel()

  let buttonBackgroundColor = TestObserver<UIColor, Never>()
  let buttonTitleText = TestObserver<String, Never>()
  let rewardTitle = TestObserver<String, Never>()
  let spacerIsHidden = TestObserver<Bool, Never>()
  let stackViewIsHidden = TestObserver<Bool, Never>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.buttonBackgroundColor.observe(self.buttonBackgroundColor.observer)
    self.vm.outputs.buttonTitleText.observe(self.buttonTitleText.observer)
    self.vm.outputs.rewardTitle.observe(self.rewardTitle.observer)
    self.vm.outputs.spacerIsHidden.observe(self.spacerIsHidden.observer)
    self.vm.outputs.stackViewIsHidden.observe(self.stackViewIsHidden.observer)
  }

  func testPledgeCTA_Backer_LiveProject() {
    let manageCTAColor: UIColor = .ksr_blue_500
    let reward = .template
      |> Reward.lens.title .~ "Magic Lamp"
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.stats.currentCurrency .~ "USD"
    let backing = .template
      |> Backing.lens.reward .~ reward
    let user = User.template

    withEnvironment(
      apiService: MockService(fetchBackingResponse: backing),
      currentUser: user
    ) {
      self.vm.inputs.configureWith(project: project, user: user)
      self.buttonBackgroundColor.assertValues([manageCTAColor])
      self.buttonTitleText.assertValues(["Manage"])
      self.rewardTitle.assertValues(["$8 • Magic Lamp"])
      self.spacerIsHidden.assertValues([false])
      self.stackViewIsHidden.assertValues([false])
    }
  }

  func testPledgeCTA_Backer_NonLiveProject() {
    let viewPledgeCTAColor: UIColor = .ksr_soft_black

    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.state .~ .successful
    let user = User.template

    self.vm.inputs.configureWith(project: project, user: user)
    self.buttonBackgroundColor.assertValues([viewPledgeCTAColor])
    self.buttonTitleText.assertValues([Strings.View_your_pledge()])
    self.spacerIsHidden.assertValues([true])
    self.stackViewIsHidden.assertValues([true])
  }

  func testPledgeCTA_NonBacker_LiveProject() {
    let pledgeCTAColor: UIColor = .ksr_green_500
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ false
    let user = User.template

    self.vm.inputs.configureWith(project: project, user: user)
    self.buttonBackgroundColor.assertValues([pledgeCTAColor])
    self.buttonTitleText.assertValues([Strings.Back_this_project()])
    self.spacerIsHidden.assertValues([true])
    self.stackViewIsHidden.assertValues([true])
  }

  func testPledgeCTA_NonBacker_NonLiveProject() {
    let viewRewardsCTAColor: UIColor = .ksr_soft_black
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.state .~ .successful
    let user = User.template

    self.vm.inputs.configureWith(project: project, user: user)
    self.buttonBackgroundColor.assertValues([viewRewardsCTAColor])
    self.buttonTitleText.assertValues([Strings.View_rewards()])
    self.spacerIsHidden.assertValues([true])
    self.stackViewIsHidden.assertValues([true])
  }
}
