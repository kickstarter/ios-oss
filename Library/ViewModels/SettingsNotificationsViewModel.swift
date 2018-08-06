import Foundation
import KsApi
import Library
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol SettingsNotificationsViewModelInputs {
  func didSelectRow(cellType: SettingsNotificationCellType)
  func didSelectEmailFrequency(frequency: EmailFrequency)
  func failedToUpdateUser(error: String)
  func showPickerView(show: Bool)
  func updateUser(user: User)
  func viewDidLoad()
}

public protocol SettingsNotificationsViewModelOutputs {
  var goToFindFriends: Signal<Void, NoError> { get }
  var goToManageProjectNotifications: Signal<Void, NoError> { get }
  var pickerViewIsHidden: Signal<Bool, NoError> { get }
  var pickerViewSelectedRow: Signal<EmailFrequency, NoError> { get }
  var updateCurrentUser: Signal<User, NoError> { get }
  var unableToSaveError: Signal<String, NoError> { get }
  var removeEmailFrequencyCell: Signal<User, NoError> { get }
  var showEmailFrequencyCell: Signal<User, NoError> { get }
}

public protocol SettingsNotificationsViewModelType {
  var inputs: SettingsNotificationsViewModelInputs { get }
  var outputs: SettingsNotificationsViewModelOutputs { get }

  func shouldSelectRow(for cellType: SettingsNotificationCellType) -> Bool
}

public final class SettingsNotificationsViewModel: SettingsNotificationsViewModelType,
SettingsNotificationsViewModelInputs, SettingsNotificationsViewModelOutputs {
  public init() {

    let initialUser = viewDidLoadProperty.signal
      .flatMap {
        AppEnvironment.current.apiService.fetchUserSelf()
        .wrapInOptional()
        .prefix(value: AppEnvironment.current.currentUser)
        .demoteErrors()
    }.skipNil()

    let userAttributeChanged = emailFrequencyProperty.signal
      .map { frequency -> (UserAttribute, Bool) in
        let digestValue = frequency == .daily ? true : false

        return (UserAttribute.notification(.creatorDigest), digestValue)
    }

    let updatedUser = initialUser.signal
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

    let updateEmailFrequencyError = updateEvent.errors()
      .map { env in
        env.errorMessages.first ?? Strings.profile_settings_error()
    }

    let emailFrequencyUpdated = updateEvent.values()

    self.unableToSaveError = Signal.merge(
      updateUserErrorProperty.signal.skipNil(),
      updateEmailFrequencyError.signal)

    self.updateCurrentUser = Signal.merge(
      initialUser,
      updatedUserProperty.signal.skipNil(),
      emailFrequencyUpdated
    )

    self.showEmailFrequencyCell = updatedUserProperty.signal
      .skipNil()
      .filter { user -> Bool in
        let pledgeActivityEnabled = user |> UserAttribute.notification(.pledgeActivity).lens.view
        return pledgeActivityEnabled ?? false
      }

    self.removeEmailFrequencyCell = updatedUserProperty.signal
      .skipNil()
      .filter { user -> Bool in
        guard let pledgeActivityEnabled = user
          |> UserAttribute.notification(.pledgeActivity).lens.view else {
          return false
        }

        return !pledgeActivityEnabled
    }

    self.pickerViewIsHidden = Signal.merge(
      showPickerViewProperty.signal.negate(),
      emailFrequencyProperty.signal.mapConst(true))

    self.pickerViewSelectedRow = self.updateCurrentUser.signal
      .map { $0 |> UserAttribute.notification(.creatorDigest).lens.view }
      .skipNil()
      .map { creatorDigest -> EmailFrequency in
        return creatorDigest ? EmailFrequency.daily : EmailFrequency.individualEmails
    }

    let findFriendsTapped = self.selectedCellType.signal
      .skipNil()
      .filter { $0 == .findFacebookFriends }

    self.goToFindFriends = findFriendsTapped.signal.ignoreValues()

    let manageProjectNotificationsSelected = self.selectedCellType.signal
      .skipNil()
      .filter { $0 == .projectNotifications }

    self.goToManageProjectNotifications = manageProjectNotificationsSelected.signal
      .ignoreValues()

    self.viewDidLoadProperty.signal.observeValues { _ in
      AppEnvironment.current.koala.trackSettingsView()
    }
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public func shouldSelectRow(for cellType: SettingsNotificationCellType) -> Bool {
    switch cellType {
    case .projectNotifications, .findFacebookFriends: return true
    default: return false
    }
  }

  fileprivate let emailFrequencyProperty = MutableProperty<EmailFrequency?>(nil)
  public func didSelectEmailFrequency(frequency: EmailFrequency) {
    self.emailFrequencyProperty.value = frequency
  }

  fileprivate let selectedCellType = MutableProperty<SettingsNotificationCellType?>(nil)
  public func didSelectRow(cellType: SettingsNotificationCellType) {
    self.selectedCellType.value = cellType
  }

  fileprivate let showPickerViewProperty = MutableProperty(false)
  public func showPickerView(show: Bool) {
    self.showPickerViewProperty.value = show
  }

  fileprivate let updatedUserProperty = MutableProperty<User?>(nil)
  public func updateUser(user: User) {
    self.updatedUserProperty.value = user
  }

  fileprivate let updateUserErrorProperty = MutableProperty<String?>(nil)
  public func failedToUpdateUser(error: String) {
    self.updateUserErrorProperty.value = error
  }

  public let goToFindFriends: Signal<Void, NoError>
  public let goToManageProjectNotifications: Signal<Void, NoError>
  public let pickerViewIsHidden: Signal<Bool, NoError>
  public let pickerViewSelectedRow: Signal<EmailFrequency, NoError>
  public let unableToSaveError: Signal<String, NoError>
  public let updateCurrentUser: Signal<User, NoError>
  public let removeEmailFrequencyCell: Signal<User, NoError>
  public let showEmailFrequencyCell: Signal<User, NoError>

  public var inputs: SettingsNotificationsViewModelInputs { return self }
  public var outputs: SettingsNotificationsViewModelOutputs { return self }
}
