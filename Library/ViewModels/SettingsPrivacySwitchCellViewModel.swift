import Foundation
import KsApi
import Prelude
import ReactiveSwift

public protocol SettingsPrivacySwitchCellViewModelOutputs {
  var privacySwitchIsOn: Signal<Bool, Never> { get }
  var privacySwitchToggledOn: Signal<Bool, Never> { get }
}

public protocol SettingsPrivacySwitchCellViewModelInputs {
  func configure(with user: User)
  func switchToggled(on: Bool)
}

public protocol SettingsPrivacySwitchCellViewModelType {
  var inputs: SettingsPrivacySwitchCellViewModelInputs { get }
  var outputs: SettingsPrivacySwitchCellViewModelOutputs { get }
}

public final class SettingsPrivacySwitchCellViewModel: SettingsPrivacySwitchCellViewModelType,
  SettingsPrivacySwitchCellViewModelInputs, SettingsPrivacySwitchCellViewModelOutputs {
  public init() {
    self.privacySwitchIsOn = self.userProperty.signal
      .skipNil()
      .map { ($0 |> (\User.showPublicProfile).view) ?? false }
      .negate()

    self.privacySwitchToggledOn = self.switchToggledProperty.signal
  }

  private let userProperty = MutableProperty<User?>(nil)
  public func configure(with user: User) {
    self.userProperty.value = user
  }

  private let switchToggledProperty = MutableProperty<Bool>(false)
  public func switchToggled(on: Bool) {
    self.switchToggledProperty.value = on
  }

  public let privacySwitchIsOn: Signal<Bool, Never>
  public let privacySwitchToggledOn: Signal<Bool, Never>

  public var inputs: SettingsPrivacySwitchCellViewModelInputs {
    return self
  }

  public var outputs: SettingsPrivacySwitchCellViewModelOutputs {
    return self
  }
}
