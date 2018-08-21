import Foundation
import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol SettingsRecommendationsCellViewModelInputs {
  func configureWith(user: User)
  func recommendationsTapped(on: Bool)
}

public protocol SettingsRecommendationsCellViewModelOutputs {
  var recommendationsOn: Signal<Bool, NoError> { get }
  var unableToSaveError: Signal<String, NoError> { get }
  var updateCurrentUser: Signal<User, NoError> { get }
}

public protocol SettingsRecommendationsCellViewModelType {
  var inputs: SettingsRecommendationsCellViewModelInputs { get }
  var outputs: SettingsRecommendationsCellViewModelOutputs { get }
}

public final class SettingsRecommendationsCellViewModel: SettingsRecommendationsCellViewModelType,
SettingsRecommendationsCellViewModelInputs, SettingsRecommendationsCellViewModelOutputs {
  public init() {
    let initialUser = configureWithProperty.signal
      .skipNil()

    let userAttributeChanged: Signal<(UserAttribute, Bool), NoError> =
      self.recommendationsTappedProperty.signal.map {
      (UserAttribute.privacy(UserAttribute.Privacy.recommendations), !$0)
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

    self.recommendationsOn = self.updateCurrentUser
      .map { $0.optedOutOfRecommendations }.skipNil().map { $0 ? false : true }.skipRepeats()

    self.recommendationsTappedProperty.signal
      .observeValues { _ in  AppEnvironment.current.koala.trackRecommendationsOptIn() }
  }

  fileprivate let configureWithProperty = MutableProperty<User?>(nil)
  public func configureWith(user: User) {
    self.configureWithProperty.value = user
  }

  fileprivate let recommendationsTappedProperty = MutableProperty(false)
  public func recommendationsTapped(on: Bool) {
    self.recommendationsTappedProperty.value = on
  }

  public let recommendationsOn: Signal<Bool, NoError>
  public let unableToSaveError: Signal<String, NoError>
  public let updateCurrentUser: Signal<User, NoError>

  public var inputs: SettingsRecommendationsCellViewModelInputs { return self }
  public var outputs: SettingsRecommendationsCellViewModelOutputs { return self }
}
