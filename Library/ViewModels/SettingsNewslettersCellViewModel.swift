import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol SettingsNewslettersCellViewModelInputs {
  func allNewslettersSwitchTapped(on: Bool)
  func configureWith(value: User)
  func configureWith(value: (newsletter: Newsletter, user: User))
  func newslettersSwitchTapped(on: Bool)
}

public protocol SettingsNewslettersCellViewModelOutputs {
  var showOptInPrompt: Signal<String, NoError> { get }
  var subscribeToAllSwitchIsOn: Signal<Bool?, NoError> { get }
  var switchIsOn: Signal<Bool?, NoError> { get }
  var unableToSaveError: Signal<String, NoError> { get }
  var updateCurrentUser: Signal<User, NoError> { get }
}

public protocol SettingsNewslettersCellViewModelType {
  var inputs: SettingsNewslettersCellViewModelInputs { get }
  var outputs: SettingsNewslettersCellViewModelOutputs { get }
}

public final class SettingsNewsletterCellViewModel: SettingsNewslettersCellViewModelType,
SettingsNewslettersCellViewModelInputs, SettingsNewslettersCellViewModelOutputs {

  public init() {

    let newsletter = self.newsletterProperty.signal.skipNil()

    let initialUser = self.initialUserProperty.signal.skipNil()

    let newsletterOn: Signal<(Newsletter, Bool), NoError> = newsletter
      .takePairWhen(self.newslettersSwitchTappedProperty.signal.skipNil())
      .map { newsletter, isOn in (newsletter, isOn) }

    self.showOptInPrompt = newsletterOn
      .filter { _, on in AppEnvironment.current.config?.countryCode == "DE" && on }
      .map { newsletter, _ in newsletter.displayableName }

    let userAttributeChanged = newsletter
      .takePairWhen(self.newslettersSwitchTappedProperty.signal.skipNil())
      .map { newsletter, isOn in
        (UserAttribute.newsletter(newsletter), isOn)
      }

    let updatedUser = initialUser
      .switchMap { user in
        userAttributeChanged.scan(user) { user, attributeAndOn in
          let (attribute, on) = attributeAndOn
          return user |> attribute.keyPath .~ on
        }
    }

    let updateUserAllOn = initialUser
      .takePairWhen(self.allNewslettersSwitchProperty.signal.skipNil())
      .map { user, on in
        return user
          |> \.newsletters .~ User.NewsletterSubscriptions.all(on: on)
    }

    let updateEvent = Signal.merge(updatedUser, updateUserAllOn)
      .switchMap { user in
        AppEnvironment.current.apiService.updateUserSelf(user)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
    }

    self.unableToSaveError = updateEvent.errors()
      .map { env in
        env.errorMessages.first ?? Strings.profile_settings_error()
      }

    let initialUserOnError = initialUser
      .takeWhen(self.unableToSaveError)

    self.updateCurrentUser = Signal.merge(initialUser,
                                          updatedUser,
                                          updateUserAllOn,
                                          initialUserOnError)
      .takeWhen(updateEvent.values().ignoreValues())

    self.subscribeToAllSwitchIsOn = initialUser
      .map(userIsSubscribedToAll(user:))

    self.switchIsOn = initialUser
      .combineLatest(with: newsletter)
      .map(userIsSubscribed(user:newsletter:))

    // Koala
    userAttributeChanged
      .observeValues { attribute, on in
        switch attribute {
        case let .newsletter(newsletter):
          AppEnvironment.current.koala.trackChangeNewsletter(
            newsletterType: newsletter, sendNewsletter: on, project: nil, context: .settings
          )
        default: break
      }
    }
  }

  fileprivate let initialUserProperty = MutableProperty<User?>(nil)
  fileprivate let newsletterProperty = MutableProperty<Newsletter?>(nil)
  public func configureWith(value: (newsletter: Newsletter, user: User)) {
    self.newsletterProperty.value = value.newsletter
    self.initialUserProperty.value = value.user
  }
  public func configureWith(value: User) {
    self.initialUserProperty.value = value
  }

  fileprivate let newslettersSwitchTappedProperty = MutableProperty<Bool?>(nil)
  public func newslettersSwitchTapped(on: Bool) {
    self.newslettersSwitchTappedProperty.value = on
  }

  fileprivate let allNewslettersSwitchProperty = MutableProperty<Bool?>(nil)
  public func allNewslettersSwitchTapped(on: Bool) {
    self.allNewslettersSwitchProperty.value = on
  }

  public let showOptInPrompt: Signal<String, NoError>
  public let subscribeToAllSwitchIsOn: Signal<Bool?, NoError>
  public let switchIsOn: Signal<Bool?, NoError>
  public let unableToSaveError: Signal<String, NoError>
  public let updateCurrentUser: Signal<User, NoError>

  public var inputs: SettingsNewslettersCellViewModelInputs { return self }
  public var outputs: SettingsNewslettersCellViewModelOutputs { return self }
}

private func userIsSubscribedToAll(user: User) -> Bool? {

  return user.newsletters.arts == true
    && user.newsletters.games == true
    && user.newsletters.happening == true
    && user.newsletters.invent == true
    && user.newsletters.promo == true
    && user.newsletters.weekly == true
    && user.newsletters.films == true
    && user.newsletters.publishing == true
    && user.newsletters.alumni == true
}

private func userIsSubscribed(user: User, newsletter: Newsletter) -> Bool? {

  return user |> UserAttribute.newsletter(newsletter).keyPath.view
}
