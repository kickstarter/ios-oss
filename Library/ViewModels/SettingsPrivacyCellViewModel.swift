import Foundation
import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol SettingsPrivacyCellViewModelInputs {
  func configureWith(user: User)
  func followingSwitchTapped(on: Bool, didShowPrompt: Bool)
}

public protocol SettingsPrivacyCellViewModelOutputs {
  var followingPrivacyOn: Signal<Bool, NoError> { get }
  var showPrivacyFollowingPrompt: Signal<(), NoError> { get }
  var unableToSaveError: Signal<String, NoError> { get }
  var updateCurrentUser: Signal<User, NoError> { get }
  var notifyDelegateShowFollowPrivacyPrompt: Signal <(), NoError> { get }
}

public protocol SettingsPrivacyCellViewModelType {
  var inputs: SettingsPrivacyCellViewModelInputs { get }
  var outputs: SettingsPrivacyCellViewModelOutputs { get }
}

public final class SettingsPrivacyCellViewModel: SettingsPrivacyCellViewModelType,
SettingsPrivacyCellViewModelInputs, SettingsPrivacyCellViewModelOutputs {

  public init() {
    let initialUser = configureWithProperty.signal
      .skipNil()

    self.followingPrivacyOn = Signal.merge (
      initialUser.map { $0.social ?? true }.skipRepeats(),
      self.followingSwitchTappedProperty.signal.map  { $0.0 }
    )

    let userAttributeChanged: Signal<(UserAttribute, Bool), NoError> =
      self.followingSwitchTappedProperty.signal
        .filter { (on, didShowPrompt) in
          didShowPrompt == true || (on == true && didShowPrompt == false)
        }
        .map {
          (UserAttribute.privacy(UserAttribute.Privacy.following), $0.0)
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

    self.notifyDelegateShowFollowPrivacyPrompt = self.followingSwitchTappedProperty.signal
      .filter { $0.0 == false && $0.1 == false }
      .ignoreValues()

    self.showPrivacyFollowingPrompt = .empty
  }

  fileprivate let configureWithProperty = MutableProperty<User?>(nil)
  public func configureWith(user: User) {
    self.configureWithProperty.value = user
  }

  fileprivate let followingSwitchTappedProperty = MutableProperty((false, false))
  public func followingSwitchTapped(on: Bool, didShowPrompt: Bool) {
    self.followingSwitchTappedProperty.value = (on, didShowPrompt)
  }

  public let followingPrivacyOn: Signal<Bool, NoError>
  public let showPrivacyFollowingPrompt: Signal<(), NoError>
  public let unableToSaveError: Signal<String, NoError>
  public let updateCurrentUser: Signal<User, NoError>
  public let notifyDelegateShowFollowPrivacyPrompt: Signal <(), NoError>

  public var inputs: SettingsPrivacyCellViewModelInputs { return self }
  public var outputs: SettingsPrivacyCellViewModelOutputs { return self }
}
