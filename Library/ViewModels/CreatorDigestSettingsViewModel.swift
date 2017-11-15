import Foundation
import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol CreatorDigestSettingsViewModelInputs {
  func configureWith(user: User)
  func viewDidLoad()
  func dailyDigestTapped(on: Bool)
  func individualEmailsTapped(on: Bool)
}

public protocol CreatorDigestSettingsViewModelOutputs {
  var dailyDigestSelected: Signal<Bool, NoError> { get }
  var individualEmailSelected: Signal<Bool, NoError> { get }
  var unableToSaveError: Signal<String, NoError> { get }
  var updateCurrentUser: Signal<User, NoError> { get }
}

public protocol CreatorDigestSettingsViewModelType {
  var inputs: CreatorDigestSettingsViewModelInputs { get }
  var outputs: CreatorDigestSettingsViewModelOutputs { get }
}

public final class CreatorDigestSettingsViewModel: CreatorDigestSettingsViewModelType,
CreatorDigestSettingsViewModelInputs, CreatorDigestSettingsViewModelOutputs {

  public init() {
    let initialUser = Signal.combineLatest(
      self.configureWithUserProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    )
    .map(first)

    let userAttributeChanged: Signal<(UserAttribute, Bool), NoError> = .merge([
      self.dailyDigestTappedProperty.signal.map { (.notification(.creatorDigest), $0) },
      self.individualEmailTappedProperty.signal.map { (.notification(.creatorDigest), !$0) }
    ])

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

    self.dailyDigestSelected = self.updateCurrentUser
      .map { $0.notifications.creatorDigest }.skipNil().skipRepeats()

    self.individualEmailSelected = self.dailyDigestSelected
      .map { !$0 }

    // Koala

    userAttributeChanged
      .observeValues { attribute, on in
        switch attribute {
        case let .notification(notification):
          switch notification {
          case .creatorDigest:
            AppEnvironment.current.koala.trackChangeEmailNotification(type: notification.trackingString,
                                                                                          on: on)
        }
      }
    }
  }

  fileprivate let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let dailyDigestTappedProperty = MutableProperty(false)
  public func dailyDigestTapped(on: Bool) {
    self.dailyDigestTappedProperty.value = on
  }

  fileprivate let individualEmailTappedProperty = MutableProperty(false)
  public func individualEmailsTapped(on: Bool) {
    self.individualEmailTappedProperty.value = on
  }

  fileprivate let configureWithUserProperty = MutableProperty<User?>(nil)
  public func configureWith(user: User) {
    self.configureWithUserProperty.value = user
  }

  public let dailyDigestSelected: Signal<Bool, NoError>
  public let individualEmailSelected: Signal<Bool, NoError>
  public let unableToSaveError: Signal<String, NoError>
  public let updateCurrentUser: Signal<User, NoError>

  public var inputs: CreatorDigestSettingsViewModelInputs { return self }
  public var outputs: CreatorDigestSettingsViewModelOutputs { return self }
}

private enum UserAttribute {
  case notification(Notification)

  fileprivate var lens: Lens<User, Bool?> {
    switch self {
    case let .notification(notification):
    switch notification {
    case .creatorDigest:  return User.lens.notifications.creatorDigest
      }
    }
  }
}

private enum Notification {
  case creatorDigest

  fileprivate var trackingString: String {
    switch self {
    case .creatorDigest:  return "Creator digest"
    }
  }
}
