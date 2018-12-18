import Library
import Prelude
import Result
import XCTest
@testable import Kickstarter_Framework
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers

final class SettingsNotificationPickerViewModelTests: TestCase {
  private let vm = SettingsNotificationPickerViewModel()

  let frequencyValueText = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.frequencyValueText.observe(frequencyValueText.observer)
  }

  func testConfigure_userCreatorDigest_enabled() {
    let user = User.template
      |> UserAttribute.notification(.creatorDigest).keyPath .~ true

    let cellValue = SettingsNotificationCellValue(cellType: .emailFrequency,
                                                  user: user)

    self.vm.configure(with: cellValue)

    self.frequencyValueText.assertValue(EmailFrequency.daily.descriptionText)
  }

  func testConfigure_userCreatorDigest_disabled() {
    let user = User.template
      |> UserAttribute.notification(.creatorDigest).keyPath .~ false

    let cellValue = SettingsNotificationCellValue(cellType: .emailFrequency,
                                                  user: user)

    self.vm.configure(with: cellValue)

    self.frequencyValueText.assertValue(EmailFrequency.individualEmails.descriptionText)
  }
}
