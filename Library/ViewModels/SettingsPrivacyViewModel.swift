import Foundation
import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol SettingsPrivacyViewModelInputs {
  func followingSwitchTapped(on: Bool, didShowPrompt: Bool)
  func viewDidLoad()
}

public protocol SettingsPrivacyViewModelOutputs {
  var refreshFollowingSection: Signal<Void, NoError> { get }
  var reloadData: Signal<User, NoError> { get }
  var unableToSaveError: Signal<String, NoError> { get }
  var updateCurrentUser: Signal<User, NoError> { get }
}

public protocol SettingsPrivacyViewModelType {
  var inputs: SettingsPrivacyViewModelInputs { get }
  var outputs: SettingsPrivacyViewModelOutputs { get }
}

public final class SettingsPrivacyViewModel: SettingsPrivacyViewModelType,
SettingsPrivacyViewModelInputs, SettingsPrivacyViewModelOutputs {

  public init() {
    let initialUser = self.viewDidLoadProperty.signal
      .flatMap {
        AppEnvironment.current.apiService.fetchUserSelf()
          .wrapInOptional()
          .prefix(value: AppEnvironment.current.currentUser)
          .demoteErrors()
    }
    .skipNil()

    self.reloadData = initialUser

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

    let updatedFetchedUser = updateEvent.values()

    self.unableToSaveError = updateEvent.errors()
      .map { env in
        env.errorMessages.first ?? Strings.profile_settings_error()
    }

    let previousUserOnError = Signal.merge(initialUser, updatedUser)
      .combinePrevious()
      .takeWhen(self.unableToSaveError)
      .map { previous, _ in previous }

   self.updateCurrentUser = Signal.merge(updatedFetchedUser, previousUserOnError)

   self.refreshFollowingSection = self.updateCurrentUser.ignoreValues()
    .takeWhen(self.followingSwitchTappedProperty.signal.ignoreValues())
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let updateUserProperty = MutableProperty<User?>(nil)
  public func update(user: User) {
    self.updateUserProperty.value = user
  }

  fileprivate let followingSwitchTappedProperty = MutableProperty((false, false))
  public func followingSwitchTapped(on: Bool, didShowPrompt: Bool) {
    self.followingSwitchTappedProperty.value = (on, didShowPrompt)
  }

  public let refreshFollowingSection: Signal<Void, NoError>
  public let reloadData: Signal<User, NoError>
  public let unableToSaveError: Signal<String, NoError>
  public let updateCurrentUser: Signal<User, NoError>

  public var inputs: SettingsPrivacyViewModelInputs { return self }
  public var outputs: SettingsPrivacyViewModelOutputs { return self }
}
