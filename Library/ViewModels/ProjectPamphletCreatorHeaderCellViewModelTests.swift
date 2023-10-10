import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers

final class ProjectPamphletCreatorHeaderCellViewModelTests: TestCase {
  private let vm: ProjectPamphletCreatorHeaderCellViewModelType = ProjectPamphletCreatorHeaderCellViewModel()

  private let launchDateLabelAttributedText = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.launchDateLabelAttributedText.map { $0.string }
      .observe(self.launchDateLabelAttributedText.observer)
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
}
