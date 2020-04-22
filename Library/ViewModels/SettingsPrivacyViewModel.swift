import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol SettingsPrivacyViewModelInputs {
  func didCancelSocialOptOut()
  func didConfirmSocialOptOut()
  func didUpdate(user: User)
  func privateProfileToggled(on: Bool)
  func viewDidLoad()
}

public protocol SettingsPrivacyViewModelOutputs {
  var focusScreenReaderOnFollowingCell: Signal<Void, Never> { get }
  var reloadData: Signal<User, Never> { get }
  var resetFollowingSection: Signal<Void, Never> { get }
  var unableToSaveError: Signal<String, Never> { get }
  var updateCurrentUser: Signal<User, Never> { get }
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

    let privateProfileAttributeChanged: Signal<(UserAttribute, Bool), Never> =
      self.privateProfileProperty.signal.negate()
        .map { (UserAttribute.privacy(UserAttribute.Privacy.showPublicProfile), $0) }

    let followingAttributeChanged = self.didConfirmSocialOptOutProperty.signal
      .map {
        (UserAttribute.privacy(UserAttribute.Privacy.following), false)
      }

    let userAttributeChanged = Signal.merge(privateProfileAttributeChanged, followingAttributeChanged)

    let updatedUser = initialUser
      .switchMap { user in
        userAttributeChanged.scan(user) { user, attributeAndOn in
          let (attribute, on) = attributeAndOn
          return user |> attribute.keyPath .~ on
        }
      }

    let updateEvent = Signal.merge(updatedUser, self.updateUserProperty.signal.skipNil())
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

    self.resetFollowingSection = self.didCancelSocialOptOutProperty.signal

    self.focusScreenReaderOnFollowingCell = Signal.merge(
      self.didCancelSocialOptOutProperty.signal,
      self.didConfirmSocialOptOutProperty.signal
    )
    .filter { _ in AppEnvironment.current.isVoiceOverRunning() }
  }

  fileprivate let didCancelSocialOptOutProperty = MutableProperty(())
  public func didCancelSocialOptOut() {
    self.didCancelSocialOptOutProperty.value = ()
  }

  fileprivate let didConfirmSocialOptOutProperty = MutableProperty(())
  public func didConfirmSocialOptOut() {
    self.didConfirmSocialOptOutProperty.value = ()
  }

  fileprivate let privateProfileProperty = MutableProperty<Bool>(true)
  public func privateProfileToggled(on: Bool) {
    self.privateProfileProperty.value = on
  }

  fileprivate let updateUserProperty = MutableProperty<User?>(nil)
  public func didUpdate(user: User) {
    self.updateUserProperty.value = user
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let focusScreenReaderOnFollowingCell: Signal<Void, Never>
  public let reloadData: Signal<User, Never>
  public let resetFollowingSection: Signal<Void, Never>
  public let unableToSaveError: Signal<String, Never>
  public let updateCurrentUser: Signal<User, Never>

  public var inputs: SettingsPrivacyViewModelInputs { return self }
  public var outputs: SettingsPrivacyViewModelOutputs { return self }
}
