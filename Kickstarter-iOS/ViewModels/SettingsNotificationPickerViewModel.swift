import KsApi
import Library
import Prelude
import ReactiveSwift
import Result

protocol SettingsNotificationPickerViewModelOutputs {
  var didTapFrequencyPickerButton: Signal<Void, NoError> { get }
  var frequencyValueText: Signal<String, NoError> { get }
}

protocol SettingsNotificationPickerViewModelInputs {
  func configure(with cellValue: SettingsNotificationCellValue)
  func frequencyPickerButtonTapped()
}

protocol SettingsNotificationPickerViewModelType {
  var inputs: SettingsNotificationPickerViewModelInputs { get }
  var outputs: SettingsNotificationPickerViewModelOutputs { get }
}

final class SettingsNotificationPickerViewModel: SettingsNotificationPickerViewModelOutputs,
  SettingsNotificationPickerViewModelInputs, SettingsNotificationPickerViewModelType {

  init() {
    let initialUser = initialUserProperty.signal.skipNil()

    let userDefinedEmailFrequency = initialUser.signal
      .map { user in
        user |> UserAttribute.notification(.creatorDigest).lens.view
      }.skipNil()
      .map { creatorDigestEnabled in
        return creatorDigestEnabled ? EmailFrequency.daily : EmailFrequency.individualEmails
      }

    self.frequencyValueText = userDefinedEmailFrequency.signal
      .map { $0.descriptionText }

    self.didTapFrequencyPickerButton = frequencyPickerButtonTappedProperty.signal
  }

  fileprivate var initialUserProperty = MutableProperty<User?>(nil)
  func configure(with cellValue: SettingsNotificationCellValue) {
    self.initialUserProperty.value = cellValue.user
  }

  fileprivate var frequencyPickerButtonTappedProperty = MutableProperty(())
  func frequencyPickerButtonTapped() {
    self.frequencyPickerButtonTappedProperty.value = ()
  }

  public let frequencyValueText: Signal<String, NoError>
  public let didTapFrequencyPickerButton: Signal<Void, NoError>

  var outputs: SettingsNotificationPickerViewModelOutputs {
    return self
  }

  var inputs: SettingsNotificationPickerViewModelInputs {
    return self
  }
}
