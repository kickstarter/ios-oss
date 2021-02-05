import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol SettingsRecommendationsCellViewModelInputs {
  func configureWith(user: User)
  func recommendationsTapped(on: Bool)
}

public protocol SettingsRecommendationsCellViewModelOutputs {
  var postNotification: Signal<Notification, Never> { get }
  var recommendationsOn: Signal<Bool, Never> { get }
  var unableToSaveError: Signal<String, Never> { get }
  var updateCurrentUser: Signal<User, Never> { get }
}

public protocol SettingsRecommendationsCellViewModelType {
  var inputs: SettingsRecommendationsCellViewModelInputs { get }
  var outputs: SettingsRecommendationsCellViewModelOutputs { get }
}

public final class SettingsRecommendationsCellViewModel: SettingsRecommendationsCellViewModelType,
  SettingsRecommendationsCellViewModelInputs, SettingsRecommendationsCellViewModelOutputs {
  public init() {
    let initialUser = self.configureWithProperty.signal
      .skipNil()

    let userAttributeChanged: Signal<(UserAttribute, Bool), Never> =
      self.recommendationsTappedProperty.signal.map {
        (UserAttribute.privacy(UserAttribute.Privacy.recommendations), !$0)
      }

    let updatedUser = initialUser
      .switchMap { user in
        userAttributeChanged.scan(user) { user, attributeAndOn in
          let (attribute, on) = attributeAndOn
          return user |> attribute.keyPath .~ on
        }
      }

    let updateEvent = updatedUser
      .switchMap {
        AppEnvironment.current.apiService.updateUserSelf($0)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
      }

    self.postNotification = updateEvent.values()
      .map { _ in
        Notification(
          name: .ksr_recommendationsSettingChanged,
          userInfo: nil
        )
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

    self.recommendationsOn = self.updateCurrentUser
      .map { $0.optedOutOfRecommendations }.skipNil().map { $0 ? false : true }.skipRepeats()
  }

  fileprivate let configureWithProperty = MutableProperty<User?>(nil)
  public func configureWith(user: User) {
    self.configureWithProperty.value = user
  }

  fileprivate let recommendationsTappedProperty = MutableProperty(false)
  public func recommendationsTapped(on: Bool) {
    self.recommendationsTappedProperty.value = on
  }

  public let postNotification: Signal<Notification, Never>
  public let recommendationsOn: Signal<Bool, Never>
  public let unableToSaveError: Signal<String, Never>
  public let updateCurrentUser: Signal<User, Never>

  public var inputs: SettingsRecommendationsCellViewModelInputs { return self }
  public var outputs: SettingsRecommendationsCellViewModelOutputs { return self }
}
