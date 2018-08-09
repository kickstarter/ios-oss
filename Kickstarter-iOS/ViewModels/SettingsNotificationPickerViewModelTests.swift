import Library
import Prelude
import Result
import XCTest
@testable import Kickstarter_Framework
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers

final class SettingsNotificationPickerViewModelTests: TestCase {
  private let vm = SettingsNotificationPickerViewModel()

  let didTapFrequencyPickerButtonObserver = TestObserver<Void, NoError>()
  let frequencyValueTextObserver = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.notifyDelegateDidTapFrequencyButton.observe(didTapFrequencyPickerButtonObserver.observer)
    self.vm.outputs.frequencyValueText.observe(frequencyValueTextObserver.observer)
  }

  func testConfigure_userCreatorDigest_enabled() {
    let user = User.template
      |> UserAttribute.notification(.creatorDigest).lens .~ true

    let cellValue = SettingsNotificationCellValue(cellType: .emailFrequency,
                                                  user: user)

    self.vm.configure(with: cellValue)

    self.frequencyValueTextObserver.assertValue(EmailFrequency.daily.descriptionText)
  }

  func testConfigure_userCreatorDigest_disabled() {
    let user = User.template
      |> UserAttribute.notification(.creatorDigest).lens .~ false

    let cellValue = SettingsNotificationCellValue(cellType: .emailFrequency,
                                                  user: user)

    self.vm.configure(with: cellValue)

    self.frequencyValueTextObserver.assertValue(EmailFrequency.individualEmails.descriptionText)
  }

  func testFrequencyPickerButtonTapped() {
    let user = User.template
      |> UserAttribute.notification(.creatorDigest).lens .~ false

    let cellValue = SettingsNotificationCellValue(cellType: .emailFrequency,
                                                  user: user)

    self.vm.configure(with: cellValue)
    self.vm.inputs.frequencyPickerButtonTapped()

    self.didTapFrequencyPickerButtonObserver.assertValueCount(1)
  }
}
