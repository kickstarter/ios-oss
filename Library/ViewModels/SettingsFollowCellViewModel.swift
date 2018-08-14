import Foundation
import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol SettingsFollowCellViewModelInputs {
  func configureWith(user: User)
  func followTapped()
}

public protocol SettingsFollowCellViewModelOutputs {
  var followingPrivacyOn: Signal<Bool, NoError> { get }
  var followingPrivacySwitchIsEnabled: Signal<Bool, NoError> { get }
  var showPrivacyFollowingPrompt: Signal<(), NoError> { get }
}

public protocol SettingsFollowCellViewModelType {
  var inputs: SettingsFollowCellViewModelInputs { get }
  var outputs: SettingsFollowCellViewModelOutputs { get }
}

public final class SettingsFollowCellViewModel: SettingsFollowCellViewModelType,
SettingsFollowCellViewModelInputs, SettingsFollowCellViewModelOutputs {
  public init() {
    let initialUser = configureWithProperty.signal
      .skipNil()

    self.showPrivacyFollowingPrompt = initialUser
      .takeWhen(self.followTappedProperty.signal)
      .filter { $0.social ?? true }
      .ignoreValues()

    self.followingPrivacyOn = initialUser.map { $0.social ?? true }.skipRepeats()

    self.followingPrivacySwitchIsEnabled = initialUser.map { $0.social ?? false }
  }

  fileprivate let configureWithProperty = MutableProperty<User?>(nil)
  public func configureWith(user: User) {
    self.configureWithProperty.value = user
  }

  fileprivate let followTappedProperty = MutableProperty(())
  public func followTapped() {
    self.followTappedProperty.value = ()
  }

  public let followingPrivacyOn: Signal<Bool, NoError>
  public var followingPrivacySwitchIsEnabled: Signal<Bool, NoError>
  public let showPrivacyFollowingPrompt: Signal<(), NoError>

  public var inputs: SettingsFollowCellViewModelInputs { return self }
  public var outputs: SettingsFollowCellViewModelOutputs { return self }
}
