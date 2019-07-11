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
  let buttonTitleTextColor = TestObserver<UIColor, Never>()
  let spacerIsHidden = TestObserver<Bool, Never>()
  let stackViewIsHidden = TestObserver<Bool, Never>()
  let subtitleText = TestObserver<String, Never>()
  let titleText = TestObserver<String, Never>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.buttonBackgroundColor.observe(self.buttonBackgroundColor.observer)
    self.vm.outputs.buttonTitleText.observe(self.buttonTitleText.observer)
    self.vm.outputs.buttonTitleTextColor.observe(self.buttonTitleTextColor.observer)
    self.vm.outputs.spacerIsHidden.observe(self.spacerIsHidden.observer)
    self.vm.outputs.stackViewIsHidden.observe(self.stackViewIsHidden.observer)
    self.vm.outputs.subtitleText.observe(self.subtitleText.observer)
    self.vm.outputs.titleText.observe(self.titleText.observer)
  }

  func testPledgeCTA_Backer_LiveProject() {
    let manageCTAColor: UIColor = .ksr_blue_500
    let reward = .template
      |> Reward.lens.title .~ "Magic Lamp"
    let backing = .template
      |> Backing.lens.reward .~ reward
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ backing
      |> Project.lens.stats.currentCurrency .~ "USD"

    self.vm.inputs.configureWith(project: project)
    self.buttonBackgroundColor.assertValues([manageCTAColor])
    self.buttonTitleText.assertValues([Strings.Manage()])
    self.titleText.assertValues([Strings.Youre_a_backer()])
    self.subtitleText.assertValues(["$8 • Magic Lamp"])
    self.spacerIsHidden.assertValues([false])
    self.stackViewIsHidden.assertValues([false])
  }

  func testPledgeCTA_Backer_NonLiveProject() {
    let viewPledgeCTAColor: UIColor = .ksr_soft_black
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ Backing.template
      |> Project.lens.state .~ .successful

    self.vm.inputs.configureWith(project: project)
    self.buttonBackgroundColor.assertValues([viewPledgeCTAColor])
    self.buttonTitleText.assertValues([Strings.View_your_pledge()])
    self.spacerIsHidden.assertValues([true])
    self.stackViewIsHidden.assertValues([true])
  }

  func testPledgeCTA_NonBacker_LiveProject_loggedOut() {
    let pledgeCTAColor: UIColor = .ksr_green_500
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ nil
      |> Project.lens.state .~ .live

    self.vm.inputs.configureWith(project: project)
    self.buttonBackgroundColor.assertValues([pledgeCTAColor])
    self.buttonTitleText.assertValues([Strings.Back_this_project()])
    self.spacerIsHidden.assertValues([true])
    self.stackViewIsHidden.assertValues([true])
  }

  func testPledgeCTA_NonBacker_NonLiveProject_loggedOut() {
    let viewRewardsCTAColor: UIColor = .ksr_soft_black
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ nil
      |> Project.lens.state .~ .successful

    self.vm.inputs.configureWith(project: project)
    self.buttonBackgroundColor.assertValues([viewRewardsCTAColor])
    self.buttonTitleText.assertValues([Strings.View_rewards()])
    self.spacerIsHidden.assertValues([true])
    self.stackViewIsHidden.assertValues([true])
  }

  func testPledgeCTA_Backer_LiveProject_Error() {
    let viewPledgeCTAColor: UIColor = .ksr_apricot_600
    let backing = Backing.template
      |> Backing.lens.status .~ .errored
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.backing .~ backing

    self.vm.inputs.configureWith(project: project)
    self.buttonBackgroundColor.assertValues([viewPledgeCTAColor])
    self.buttonTitleText.assertValues([Strings.Fix()])
    self.titleText.assertValues([Strings.Check_your_payment_details()])
    self.subtitleText.assertValues([Strings.We_couldnt_process_your_pledge()])
    self.spacerIsHidden.assertValues([false])
    self.stackViewIsHidden.assertValues([false])
  }

  func testPledgeCTA_NonBacker_LiveProject_loggedIn() {
    let pledgeCTAColor: UIColor = .ksr_green_500
    let project = Project.template
      |> Project.lens.personalization.backing .~ nil
      |> Project.lens.personalization.isBacking .~ false

    self.vm.inputs.configureWith(project: project)
    self.buttonBackgroundColor.assertValues([pledgeCTAColor])
    self.buttonTitleText.assertValues([Strings.Back_this_project()])
    self.spacerIsHidden.assertValues([true])
    self.stackViewIsHidden.assertValues([true])
  }

  func testPledgeCTA_NonBacker_NonLiveProject_loggedIn() {
    let viewRewardsCTAColor: UIColor = .ksr_soft_black
    let project = Project.template
      |> Project.lens.state .~ .successful
      |> Project.lens.personalization.isBacking .~ false

    self.vm.inputs.configureWith(project: project)
    self.buttonBackgroundColor.assertValues([viewRewardsCTAColor])
    self.buttonTitleText.assertValues([Strings.View_rewards()])
    self.spacerIsHidden.assertValues([true])
    self.stackViewIsHidden.assertValues([true])
  }
}
