import Foundation
import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol SettingsFollowCellViewModelInputs {
  func configureWith(user: User)
  func followingSwitchTapped(on: Bool)
  func followTapped()
}

public protocol SettingsFollowCellViewModelOutputs {
  var followingPrivacyOn: Signal<Bool, NoError> { get }
  var followingPrivacySwitchIsEnabled: Signal<Bool, NoError> { get }
  var showPrivacyFollowingPrompt: Signal<(), NoError> { get }
  var unableToSaveError: Signal<String, NoError> { get }
  var updateCurrentUser: Signal<User, NoError> { get }
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

    let userAttributeChanged: Signal<(UserAttribute, Bool), NoError> =
      self.followingSwitchTappedProperty.signal.map {
      (UserAttribute.privacy(UserAttribute.Privacy.following), !$0)
    }

    let updatedUser = initialUser
      .switchMap { user in
        userAttributeChanged.scan(user) { user, attributeAndOn in
          let (attribute, on) = attributeAndOn
          return user |> attribute.lens .~ on
        }
    }

    let updateEvent = updatedUser
      .switchMap {
        AppEnvironment.current.apiService.updateUserSelf($0)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
    }

    self.unableToSaveError = updateEvent.errors()
      .map { env in
        env.errorMessages.first ?? Strings.profile_settings_error()
    }

    let previousUserOnError = Signal.merge(initialUser, updatedUser)
      .combinePrevious()
      .takeWhen(self.unableToSaveError)
      .map { previous, _ in previous }

    self.updateCurrentUser = Signal.merge(initialUser, updatedUser, previousUserOnError)

    self.showPrivacyFollowingPrompt = self.updateCurrentUser
      .takeWhen(self.followTappedProperty.signal)
      .filter { $0.social ?? true }
      .ignoreValues()

    self.followingPrivacyOn = initialUser.map { $0.social ?? true }.skipRepeats()

    self.followingPrivacyOn.signal.observeValues { value in
        print("\(value)")
    }

    self.followingPrivacySwitchIsEnabled = self.updateCurrentUser.map { $0.social ?? false }
  }

  fileprivate let configureWithProperty = MutableProperty<User?>(nil)
  public func configureWith(user: User) {
    self.configureWithProperty.value = user
  }

  fileprivate let followTappedProperty = MutableProperty(())
  public func followTapped() {
    self.followTappedProperty.value = ()
  }

  fileprivate let followingSwitchTappedProperty = MutableProperty(false)
  public func followingSwitchTapped(on: Bool) {
    self.followingSwitchTappedProperty.value = on
  }

  public let followingPrivacyOn: Signal<Bool, NoError>
  public var followingPrivacySwitchIsEnabled: Signal<Bool, NoError>
  public let showPrivacyFollowingPrompt: Signal<(), NoError>
  public let unableToSaveError: Signal<String, NoError>
  public let updateCurrentUser: Signal<User, NoError>

  public var inputs: SettingsFollowCellViewModelInputs { return self }
  public var outputs: SettingsFollowCellViewModelOutputs { return self }
}
