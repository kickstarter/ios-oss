@testable import KsApi
import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class SettingsNotificationPickerViewModelTests: TestCase {
  private let vm = SettingsNotificationPickerViewModel()

  let frequencyValueText = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.frequencyValueText.observe(self.frequencyValueText.observer)
  }

  func testConfigure_userCreatorDigest_enabled() {
    let user = User.template
      |> UserAttribute.notification(.creatorDigest).keyPath .~ true

    let cellValue = SettingsNotificationCellValue(
      cellType: .emailFrequency,
      user: user
    )

    self.vm.configure(with: cellValue)

    self.frequencyValueText.assertValue(EmailFrequency.dailySummary.descriptionText)
  }

  func testConfigure_userCreatorDigest_disabled() {
    let user = User.template
      |> UserAttribute.notification(.creatorDigest).keyPath .~ false

    let cellValue = SettingsNotificationCellValue(
      cellType: .emailFrequency,
      user: user
    )

    self.vm.configure(with: cellValue)

    self.frequencyValueText.assertValue(EmailFrequency.twiceADaySummary.descriptionText)
  }
}
