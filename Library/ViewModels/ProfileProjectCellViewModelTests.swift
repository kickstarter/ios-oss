import Foundation
import Result
import XCTest
@testable import Library
@testable import ReactiveExtensions_TestHelpers
@testable import KsApi
@testable import KsApi
import Prelude

internal final class ProfileProjectCellViewModelTests: TestCase {
  let cellAccessibilityLabel = TestObserver<String, NoError>()
  let vm = ProfileProjectCellViewModel()
  let metadataIsHidden = TestObserver<Bool, NoError>()
  let metadataText = TestObserver<String, NoError>()
  let projectName = TestObserver<String, NoError>()
  let photoURL = TestObserver<URL?, NoError>()
  let progress = TestObserver<Float, NoError>()
  let progressHidden = TestObserver<Bool, NoError>()
  let stateLabelText = TestObserver<String, NoError>()
  let stateBackgroundColor = TestObserver<UIColor, NoError>()
  let stateHidden = TestObserver<Bool, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.cellAccessibilityLabel.observe(cellAccessibilityLabel.observer)
    self.vm.outputs.metadataIsHidden.observe(metadataIsHidden.observer)
    self.vm.outputs.metadataText.observe(metadataText.observer)
    self.vm.outputs.projectName.observe(projectName.observer)
    self.vm.outputs.photoURL.observe(photoURL.observer)
    self.vm.outputs.progress.observe(progress.observer)
    self.vm.outputs.progressHidden.observe(progressHidden.observer)
    self.vm.outputs.stateLabelText.observe(stateLabelText.observer)
    self.vm.outputs.stateBackgroundColor.observe(stateBackgroundColor.observer)
    self.vm.outputs.stateHidden.observe(stateHidden.observer)
  }

  func testProjectProgressUI() {
    let liveProject = Project.template |> Project.lens.dates.deadline .~
      (self.dateType.init().timeIntervalSince1970 + 60 * 60 * 24 * 10)

    self.vm.inputs.project(liveProject)

    self.metadataIsHidden.assertValues([false])
    self.metadataText.assertValues(["10 days to go"])
    self.progressHidden.assertValues([false], "Progress bar is not hidden for live project.")
    self.progress.assertValues([liveProject.stats.fundingProgress])
    self.stateLabelText.assertValues([""], "No state label emits for live project.")
    self.stateBackgroundColor.assertValues([.ksr_navy_600], "Default background color is gray.")
    self.stateHidden.assertValues([true], "Project state is hidden.")
  }

  func testProjectFailedBanner() {
    let failedProject = Project.template |> Project.lens.state .~ .failed

    self.vm.inputs.project(failedProject)

    self.metadataIsHidden.assertValues([true])
    self.metadataText.assertValues([])
    self.progressHidden.assertValues([true], "Progress bar is hidden for failed project.")
    self.stateLabelText.assertValues([Strings.profile_projects_status_unsuccessful()])
    self.stateBackgroundColor.assertValues([.ksr_navy_600])
    self.stateHidden.assertValues([false])
  }

  func testProjectSuccessfulBanner() {
    let successfulProject = Project.template |> Project.lens.state .~ .successful

    self.vm.inputs.project(successfulProject)

    self.metadataIsHidden.assertValues([true])
    self.metadataText.assertValues([])
    self.progressHidden.assertValues([true], "Progress bar is hidden for successful project.")
    self.stateLabelText.assertValues([Strings.profile_projects_status_successful()])
    self.stateBackgroundColor.assertValues([.ksr_green_400])
    self.stateHidden.assertValues([false])
  }

  func testProjectDataEmits() {
    let project = Project.template

    self.vm.inputs.project(project)

    self.projectName.assertValues([project.name], "Project name emitted.")
    self.cellAccessibilityLabel.assertValues(["\(project.name) \(project.state.rawValue)"])
    self.photoURL.assertValues([URL(string: project.photo.full)], "Project photo emitted.")
  }
}
