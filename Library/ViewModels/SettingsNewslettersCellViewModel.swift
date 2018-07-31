import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol SettingsNewslettersCellViewModelInputs {

  func allNewslettersSwitchTapped(on: Bool)
  func awakeFromNib()
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
      }.logEvents(identifier: "user attribute changed")

    let updatedUser = initialUser
      .switchMap { user in
        userAttributeChanged.scan(user) { user, attributeAndOn in
          let (attribute, on) = attributeAndOn
          return user |> attribute.lens .~ on
        }
    }.logEvents(identifier: "updated user")

    let updateUserAllOn = initialUser
      .takePairWhen(self.allNewslettersSwitchProperty.signal.skipNil())
      .map { user, on in
        return user
          |> User.lens.newsletters .~ User.NewsletterSubscriptions.all(on: on)
    }.logEvents(identifier: "updated all")

    let updateEvent = Signal.merge(updatedUser, updateUserAllOn)
      .switchMap { user in
        AppEnvironment.current.apiService.updateUserSelf(user)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
    }
    .logEvents(identifier: "update event")

    self.unableToSaveError = updateEvent.errors()
      .map { env in
        env.errorMessages.first ?? Strings.profile_settings_error()
      }.logEvents(identifier: "Couldn't update user")

    let initialUserOnError = initialUser
      .takeWhen(self.unableToSaveError)
      .map { previous in previous }

    self.updateCurrentUser = Signal.merge(initialUser,
                                          updatedUser,
                                          updateUserAllOn,
                                          initialUserOnError)
      .takeWhen(updateEvent.values().ignoreValues())

    self.subscribeToAllSwitchIsOn = initialUser
      .map(userIsSubscribedToAll(user:))

    self.switchIsOn = initialUser
      .combineLatest(with: newsletter)
      .map(userIsSubscribed(user:newsletter:)).logEvents(identifier: "switchIsOn emitted")

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

  fileprivate let awakeFromNibProperty = MutableProperty(())
  public func awakeFromNib() {
    self.awakeFromNibProperty.value = ()
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
  
  switch newsletter {
  case .arts:
    return user.newsletters.arts
  case .games:
    return user.newsletters.games
  case .happening:
    return user.newsletters.happening
  case .invent:
    return user.newsletters.invent
  case .promo:
    return user.newsletters.promo
  case .weekly:
    return user.newsletters.weekly
  case .films:
    return user.newsletters.films
  case .publishing:
    return user.newsletters.publishing
  case .alumni:
    return user.newsletters.alumni
  }
}
