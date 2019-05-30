import KsApi
import Prelude
import ReactiveSwift

public protocol SettingsNotificationPickerViewModelOutputs {
  var frequencyValueText: Signal<String, Never> { get }
}

public protocol SettingsNotificationPickerViewModelInputs {
  func configure(with cellValue: SettingsNotificationCellValue)
}

public protocol SettingsNotificationPickerViewModelType {
  var inputs: SettingsNotificationPickerViewModelInputs { get }
  var outputs: SettingsNotificationPickerViewModelOutputs { get }
}

public final class SettingsNotificationPickerViewModel: SettingsNotificationPickerViewModelOutputs,
  SettingsNotificationPickerViewModelInputs, SettingsNotificationPickerViewModelType {
  public init() {
    let initialUser = self.initialUserProperty.signal.skipNil()

    let userDefinedEmailFrequency = initialUser.signal
      .map { user in
        user |> UserAttribute.notification(.creatorDigest).keyPath.view
      }.skipNil()
      .map { creatorDigestEnabled in
        creatorDigestEnabled ? EmailFrequency.dailySummary : EmailFrequency.twiceADaySummary
      }

    self.frequencyValueText = userDefinedEmailFrequency.signal
      .map { $0.descriptionText }
  }

  fileprivate var initialUserProperty = MutableProperty<User?>(nil)
  public func configure(with cellValue: SettingsNotificationCellValue) {
    self.initialUserProperty.value = cellValue.user
  }

  public let frequencyValueText: Signal<String, Never>

  public var outputs: SettingsNotificationPickerViewModelOutputs {
    return self
  }

  public var inputs: SettingsNotificationPickerViewModelInputs {
    return self
  }
}
