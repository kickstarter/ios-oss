import Foundation
import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class ProjectStatesContainerViewViewModelTests: TestCase {
  let vm = ProjectStatesContainerViewViewModel()

  let buttonBackgroundColor = TestObserver<UIColor, NoError>()
  let buttonTitleText = TestObserver<String, NoError>()
  let rewardTitle = TestObserver<String, NoError>()
  let stackViewIsHidden = TestObserver<Bool, NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.buttonBackgroundColor.observe(buttonBackgroundColor.observer)
    self.vm.outputs.buttonTitleText.observe(buttonTitleText.observer)
    self.vm.outputs.rewardTitle.observe(rewardTitle.observer)
    self.vm.outputs.stackViewIsHidden.observe(stackViewIsHidden.observer)
  }

  func testProjectCTA_Backer_LiveProject() {
    let manageCTAColor: UIColor = .ksr_blue
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
    let user = User.template

    self.vm.inputs.configureWith(project: project, user: user)
    self.buttonBackgroundColor.assertValues([manageCTAColor])
    self.buttonTitleText.assertValues(["Manage"])
    self.rewardTitle.assertValues(["Title for unavailable reward"])
    self.stackViewIsHidden.assertValues([false])
  }

  func testProjectCTA_Backer_NonLiveProject() {
    let viewPledgeCTAColor: UIColor = .ksr_soft_black

    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.state .~ .successful
    let user = User.template

    self.vm.inputs.configureWith(project: project, user: user)
    self.buttonBackgroundColor.assertValues([viewPledgeCTAColor])
    self.buttonTitleText.assertValues(["View your pledge"])
    self.rewardTitle.assertValues(["Title for unavailable reward"])
    self.stackViewIsHidden.assertValues([true])
  }

  func testProjectCTA_NonBacker_LiveProject() {
    let pledgeCTAColor: UIColor = .ksr_green_500
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ false
    let user = User.template

    self.vm.inputs.configureWith(project: project, user: user)
    self.buttonBackgroundColor.assertValues([pledgeCTAColor])
    self.buttonTitleText.assertValues(["Back this project"])
    self.rewardTitle.assertValues(["Title for unavailable reward"])
    self.stackViewIsHidden.assertValues([true])
  }

  func testProjectCTA_NonBacker_NonLiveProject() {
    let viewRewardsCTAColor: UIColor = .ksr_soft_black
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.state .~ .successful
    let user = User.template

    self.vm.inputs.configureWith(project: project, user: user)
    self.buttonBackgroundColor.assertValues([viewRewardsCTAColor])
    self.buttonTitleText.assertValues(["View rewards"])
    self.rewardTitle.assertValues(["Title for unavailable reward"])
    self.stackViewIsHidden.assertValues([true])
  }
}

