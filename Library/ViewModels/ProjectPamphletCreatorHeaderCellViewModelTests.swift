import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers

final class ProjectPamphletCreatorHeaderCellViewModelTests: TestCase {
  private let vm: ProjectPamphletCreatorHeaderCellViewModelType = ProjectPamphletCreatorHeaderCellViewModel()

  private let buttonTitle = TestObserver<String, Never>()
  private let launchDateLabelAttributedText = TestObserver<String, Never>()
  private let notifyDelegateViewProgressButtonTapped = TestObserver<Project, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.buttonTitle.observe(self.buttonTitle.observer)
    self.vm.outputs.launchDateLabelAttributedText.map { $0.string }
      .observe(self.launchDateLabelAttributedText.observer)
    self.vm.outputs.notifyDelegateViewProgressButtonTapped.observe(
      self.notifyDelegateViewProgressButtonTapped.observer
    )
  }

  func testButtonTitle_LiveProject() {
    let project = Project.template
      |> \.state .~ .live

    self.buttonTitle.assertDidNotEmitValue()

    self.vm.inputs.configure(with: project)

    self.buttonTitle.assertValue("View progress")
  }

  func testButtonTitle_NonLiveProject() {
    let project = Project.template
      |> \.state .~ .successful

    self.buttonTitle.assertDidNotEmitValue()

    self.vm.inputs.configure(with: project)

    self.buttonTitle.assertValue("View dashboard")
  }

  func testLaunchDateLabelAttributedText() {
    let project = Project.template

    self.launchDateLabelAttributedText.assertDidNotEmitValue()

    self.vm.inputs.configure(with: project)

    self.launchDateLabelAttributedText.assertValue("You launched this project on September 16, 2016.")
  }

  func testNotifyDelegateViewProgressButtonTapped() {
    let project = Project.template
    self.vm.inputs.configure(with: project)

    self.notifyDelegateViewProgressButtonTapped.assertDidNotEmitValue()

    self.vm.inputs.viewProgressButtonTapped()

    self.notifyDelegateViewProgressButtonTapped.assertValue(project)
  }
}
