import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol SettingsNewslettersCellViewModelInputs {

  func awakeFromNib()
  func configureWith(value: Newsletter)
  func newslettersSwitchTapped(on: Bool)
}

public protocol SettingsNewslettersCellViewModelOutputs {

  var showOptInPrompt: Signal<String, NoError> { get }
  var switchIsOn: Signal<Bool, NoError> { get }
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

    let initialUser = self.awakeFromNibProperty.signal
      .flatMap {
        AppEnvironment.current.apiService.fetchUserSelf()
          .wrapInOptional()
          .prefix(value: AppEnvironment.current.currentUser)
          .demoteErrors()
      }
      .skipNil()

    let newsletterOn: Signal<(Newsletter, Bool), NoError> = newsletter
      .takePairWhen(self.newslettersSwitchTappedProperty.signal.skipNil())
      .map { newsletter, isOn in (newsletter, isOn) }

    self.showOptInPrompt = newsletterOn
      .filter { _, on in AppEnvironment.current.config?.countryCode == "DE" && on }
      .map { newsletter, _ in newsletter.displayableName }

    let userAttributeChanged: Signal<(UserAttribute, Bool), NoError> = Signal.combineLatest(
        newsletter,
        self.newslettersSwitchTappedProperty.signal.skipNil()
    ).map { newsletter, isOn in
      (UserAttribute.newsletter(newsletter), isOn)
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

    self.switchIsOn = self.updateCurrentUser
      .map { $0.newsletters.arts }.skipNil().skipRepeats()
  }

  fileprivate let awakeFromNibProperty = MutableProperty(())
  public func awakeFromNib() {
    self.awakeFromNibProperty.value = ()
  }

  fileprivate let newsletterProperty = MutableProperty<Newsletter?>(nil)
  public func configureWith(value: Newsletter) {
    self.newsletterProperty.value = value
  }

  fileprivate let newslettersSwitchTappedProperty = MutableProperty<Bool?>(nil)
  public func newslettersSwitchTapped(on: Bool) {
    self.newslettersSwitchTappedProperty.value = on
  }

  public let showOptInPrompt: Signal<String, NoError>
  public let switchIsOn: Signal<Bool, NoError>
  public let unableToSaveError: Signal<String, NoError>
  public let updateCurrentUser: Signal<User, NoError>

  public var inputs: SettingsNewslettersCellViewModelInputs { return self }
  public var outputs: SettingsNewslettersCellViewModelOutputs { return self }
}
