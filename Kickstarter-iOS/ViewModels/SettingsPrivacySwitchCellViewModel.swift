import Foundation
import KsApi
import Prelude
import Result
import ReactiveSwift

protocol SettingsPrivacySwitchCellViewModelOutputs {
  var privacySwitchEnabled: Signal<Bool, NoError> { get }
  var privacySwitchToggledOn: Signal<Bool, NoError> { get }
}

protocol SettingsPrivacySwitchCellViewModelInputs {
  func configure(with user: User)
  func switchToggled(on: Bool)
}

protocol SettingsPrivacySwitchCellViewModelType {
  var inputs: SettingsPrivacySwitchCellViewModelInputs { get }
  var outputs: SettingsPrivacySwitchCellViewModelOutputs { get }
}

final class SettingsPrivacySwitchCellViewModel: SettingsPrivacySwitchCellViewModelType,
SettingsPrivacySwitchCellViewModelInputs, SettingsPrivacySwitchCellViewModelOutputs {
  public init() {
    self.privacySwitchEnabled = userProperty.signal
      .skipNil()
      .map { ($0 |> User.lens.showPublicProfile.view) ?? false }
      .negate()

    self.privacySwitchToggledOn = switchToggledProperty.signal
  }

  private let userProperty = MutableProperty<User?>(nil)
  func configure(with user: User) {
    self.userProperty.value = user
  }

  private let switchToggledProperty = MutableProperty<Bool>(false)
  func switchToggled(on: Bool) {
    self.switchToggledProperty.value = on
  }

  public let privacySwitchEnabled: Signal<Bool, NoError>
  public let privacySwitchToggledOn: Signal<Bool, NoError>

  var inputs: SettingsPrivacySwitchCellViewModelInputs {
    return self
  }

  var outputs: SettingsPrivacySwitchCellViewModelOutputs {
    return self
  }
}
