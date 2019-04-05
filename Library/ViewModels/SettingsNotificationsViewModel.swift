import Foundation
import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol SettingsNotificationsViewModelInputs {
  func didSelectRow(cellType: SettingsNotificationCellType)
  func didSelectEmailFrequency(frequency: EmailFrequency)
  func dismissPickerTap()
  func failedToUpdateUser(error: String)
  func updateUser(user: User)
  func viewDidLoad()
}

public protocol SettingsNotificationsViewModelOutputs {
  var goToManageProjectNotifications: Signal<Void, NoError> { get }
  var pickerViewIsHidden: Signal<Bool, NoError> { get }
  var pickerViewSelectedRow: Signal<EmailFrequency, NoError> { get }
  var updateCurrentUser: Signal<User, NoError> { get }
  var unableToSaveError: Signal<String, NoError> { get }
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
        let digestValue = frequency == .dailySummary ? true : false

        return (UserAttribute.notification(.creatorDigest), digestValue)
    }

//    let projectActivityNotificationChanged: Signal<(UserAttribute, Bool), NoError> =
//      updatedUserProperty.signal.skipNil()
//          .map { user in
//            return  (UserAttribute.notification(.pledgeActivity), user.notifications.backings ?? false)
//    }

   // let creatorDigestNotificationChanged =

//    let userAttributeChanged = Signal.merge(
//      projectActivityNotificationChanged.signal,
//      creatorDigestNotificationChanged.signal
//    )

    let updatedUser = initialUser.signal
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

    let emailFrequencyCellSelected = self.selectedCellType.signal
      .skipNil()
      .filter { $0 == .emailFrequency }

//    let projectActivityEmailFrequencyDisabled = projectActivityNotificationChanged.signal
//      .map(second)
//      .filter(isFalse)

    self.pickerViewIsHidden = Signal.merge(
      emailFrequencyCellSelected.signal.mapConst(false),
      emailFrequencyProperty.signal.mapConst(true)//,
      //dismissPickerTapProperty.signal.mapConst(true),
     // projectActivityEmailFrequencyDisabled.signal.mapConst(true)
    ).skipRepeats()

    self.pickerViewSelectedRow = self.updateCurrentUser.signal
      .map { $0 |> UserAttribute.notification(.creatorDigest).keyPath.view }
      .skipNil()
      .map { creatorDigest -> EmailFrequency in
        return creatorDigest ? EmailFrequency.dailySummary : EmailFrequency.twiceADaySummary
    }

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

  fileprivate let dismissPickerTapProperty = MutableProperty(())
  public func dismissPickerTap() {
    self.dismissPickerTapProperty.value = ()
  }

  public func shouldSelectRow(for cellType: SettingsNotificationCellType) -> Bool {
    switch cellType {
    case .projectNotifications, .emailFrequency: return true
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

  fileprivate let updatedUserProperty = MutableProperty<User?>(nil)
  public func updateUser(user: User) {
    self.updatedUserProperty.value = user
  }

  fileprivate let updateUserErrorProperty = MutableProperty<String?>(nil)
  public func failedToUpdateUser(error: String) {
    self.updateUserErrorProperty.value = error
  }

  public let goToManageProjectNotifications: Signal<Void, NoError>
  public let pickerViewIsHidden: Signal<Bool, NoError>
  public let pickerViewSelectedRow: Signal<EmailFrequency, NoError>
  public let unableToSaveError: Signal<String, NoError>
  public let updateCurrentUser: Signal<User, NoError>

  public var inputs: SettingsNotificationsViewModelInputs { return self }
  public var outputs: SettingsNotificationsViewModelOutputs { return self }
}
