import ReactiveSwift
import Result
import Library

protocol SettingsNotificationCellViewModelInputs {
  func didTapPushNotificationsButton()
  func didTapEmailNotificationsButton()
  func configure(with cellValue: SettingsNotificationCellValue)
}

protocol SettingsNotificationCellViewModelOutputs {
  var pushNotificationsEnabled: Signal<Bool, NoError> { get }
  var pushNotificationsSettingToggled: Signal<Bool, NoError> { get }
  var emailNotificationsEnabled: Signal<Bool, NoError> { get }
  var emailNotificationsSettingToggled: Signal<Bool, NoError> { get }
  var hideNotificationButtons: Signal<Bool, NoError> { get }
}

protocol SettingsNotificationCellViewModelType {
  var inputs: SettingsNotificationCellViewModelInputs { get }
  var outputs: SettingsNotificationCellViewModelOutputs { get }
}

final class SettingsNotificationCellViewModel: SettingsNotificationCellViewModelInputs,
SettingsNotificationCellViewModelOutputs,
SettingsNotificationCellViewModelType {
  public init() {
    self.pushNotificationsSettingToggled = pushNotificationsEnabledProperty.signal
      .skip(first: 1) // Skip the first signal because that's just the configuration of the button
      .logEvents(identifier: "push toggled")
    self.pushNotificationsEnabled = pushNotificationsEnabledProperty.signal

    self.emailNotificationsSettingToggled = emailNotificationsEnabledProperty.signal
      .skip(first: 1) // Skip the first signal because that's just the configuration of the button
      .logEvents(identifier: "emmail toggled")
    self.emailNotificationsEnabled = emailNotificationsEnabledProperty.signal
    
    self.hideNotificationButtons = notificationButtonsShouldHideProperty.signal.negate()
  }

  fileprivate let pushNotificationsEnabledProperty = MutableProperty(false)
  func didTapPushNotificationsButton() {
    // Toggle value
    self.pushNotificationsEnabledProperty.value = self.pushNotificationsEnabledProperty.negate().value
  }

  fileprivate let emailNotificationsEnabledProperty = MutableProperty(false)
  func didTapEmailNotificationsButton() {
    // Toggle value
    self.emailNotificationsEnabledProperty.value = self.emailNotificationsEnabledProperty.negate().value
  }

  fileprivate let notificationButtonsShouldHideProperty = MutableProperty(false)
  func configure(with cellValue: SettingsNotificationCellValue) {
    self.pushNotificationsEnabledProperty.value = cellValue.pushNotificationsEnabled ?? false
    self.emailNotificationsEnabledProperty.value = cellValue.emailNotificationsEnabled ?? false
    self.notificationButtonsShouldHideProperty.value = cellValue.cellType.shouldShowNotificationButtons
  }

  public let emailNotificationsEnabled: Signal<Bool, NoError>
  public let emailNotificationsSettingToggled: Signal<Bool, NoError>
  public let hideNotificationButtons: Signal<Bool, NoError>
  public let pushNotificationsEnabled: Signal<Bool, NoError>
  public let pushNotificationsSettingToggled: Signal<Bool, NoError>

  public var inputs: SettingsNotificationCellViewModelInputs { return self }
  public var outputs: SettingsNotificationCellViewModelOutputs { return self }
}
