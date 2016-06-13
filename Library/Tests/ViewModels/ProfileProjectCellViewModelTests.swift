import Foundation
import KsApi
import Result
import XCTest
@testable import Library
@testable import ReactiveExtensions_TestHelpers
@testable import KsApi_TestHelpers
@testable import KsApi
import Prelude

internal final class ProfileProjectCellViewModelTests: TestCase {
  let vm = ProfileProjectCellViewModel()
  let projectName = TestObserver<String, NoError>()
  let photoURL = TestObserver<NSURL?, NoError>()
  let progress = TestObserver<Float, NoError>()
  let progressHidden = TestObserver<Bool, NoError>()
  let state = TestObserver<String, NoError>()
  let stateBackgroundColor = TestObserver<UIColor, NoError>()
  let stateHidden = TestObserver<Bool, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.projectName.observe(projectName.observer)
    self.vm.outputs.photoURL.observe(photoURL.observer)
    self.vm.outputs.progress.observe(progress.observer)
    self.vm.outputs.progressHidden.observe(progressHidden.observer)
    self.vm.outputs.state.observe(state.observer)
    self.vm.outputs.stateBackgroundColor.observe(stateBackgroundColor.observer)
    self.vm.outputs.stateHidden.observe(stateHidden.observer)
  }

  func testProjectProgressUI() {
    let liveProject = Project.template

    self.vm.inputs.project(liveProject)

    self.progressHidden.assertValues([false], "Progress bar is not hidden for live project.")
    self.progress.assertValues([liveProject.stats.fundingProgress])
    self.state.assertValues([String(liveProject.state)])
    self.stateBackgroundColor.assertValues([Color.GrayDark.toUIColor()], "Default background color is gray.")
    self.stateHidden.assertValues([true], "Project state is hidden.")
  }

  func testProjectFailedBanner() {
    let failedProject = Project.template |> Project.lens.state .~ .failed

    self.vm.inputs.project(failedProject)
    self.progressHidden.assertValues([true], "Progress bar is hidden for failed project.")
    self.state.assertValues([String(failedProject.state)])
    self.stateBackgroundColor.assertValues([Color.GrayDark.toUIColor()])
    self.stateHidden.assertValues([false])
  }

  func testProjectSuccessfulBanner() {
    let successfulProject = Project.template |> Project.lens.state .~ .successful

    self.vm.inputs.project(successfulProject)
    self.progressHidden.assertValues([true], "Progress bar is hidden for successful project.")
    self.state.assertValues([String(successfulProject.state)])
    self.stateBackgroundColor.assertValues([Color.Green.toUIColor()])
    self.stateHidden.assertValues([false])
  }

  func testProjectDataEmits() {
    let project = Project.template

    self.vm.inputs.project(project)

    self.projectName.assertValues([project.name], "Project name emitted.")
    self.photoURL.assertValues([NSURL(string: project.photo.full)], "Project photo emitted.")
  }
}
