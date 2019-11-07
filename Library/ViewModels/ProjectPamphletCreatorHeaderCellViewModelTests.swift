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
    let dateComponents = DateComponents()
      |> \.month .~ 11
      |> \.day .~ 7
      |> \.year .~ 2_019
      |> \.timeZone .~ TimeZone.init(secondsFromGMT: 0)

    let calendar = Calendar(identifier: .gregorian)
      |> \.timeZone .~ TimeZone.init(secondsFromGMT: 0)!

    withEnvironment(calendar: calendar, locale: Locale(identifier: "en")) {
      let date = AppEnvironment.current.calendar.date(from: dateComponents)

      let project = Project.template
        |> \.dates.launchedAt .~ date!.timeIntervalSince1970

      self.launchDateLabelAttributedText.assertDidNotEmitValue()

      self.vm.inputs.configure(with: project)

      self.launchDateLabelAttributedText.assertValue("You launched this project on November 7, 2019.")
    }
  }

  func testNotifyDelegateViewProgressButtonTapped() {
    let project = Project.template
    self.vm.inputs.configure(with: project)

    self.notifyDelegateViewProgressButtonTapped.assertDidNotEmitValue()

    self.vm.inputs.viewProgressButtonTapped()

    self.notifyDelegateViewProgressButtonTapped.assertValue(project)
  }
}
