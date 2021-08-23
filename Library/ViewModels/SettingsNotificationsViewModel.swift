import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol SettingsNotificationsViewModelInputs {
  func didSelectRow(cellType: SettingsNotificationCellType)
  func didSelectEmailFrequency(frequency: EmailFrequency)
  func dismissPickerTap()
  func failedToUpdateUser(error: String)
  func updateUser(user: User)
  func viewDidLoad()
}

public protocol SettingsNotificationsViewModelOutputs {
  var goToManageProjectNotifications: Signal<Void, Never> { get }
  var pickerViewIsHidden: Signal<Bool, Never> { get }
  var pickerViewSelectedRow: Signal<EmailFrequency, Never> { get }
  var updateCurrentUser: Signal<User, Never> { get }
  var unableToSaveError: Signal<String, Never> { get }
}

public protocol SettingsNotificationsViewModelType {
  var inputs: SettingsNotificationsViewModelInputs { get }
  var outputs: SettingsNotificationsViewModelOutputs { get }

  func shouldSelectRow(for cellType: SettingsNotificationCellType) -> Bool
}

public final class SettingsNotificationsViewModel: SettingsNotificationsViewModelType,
  SettingsNotificationsViewModelInputs, SettingsNotificationsViewModelOutputs {
  public init() {
    let initialUser = self.viewDidLoadProperty.signal
      .flatMap {
        AppEnvironment.current.apiService.fetchUserSelf()
          .wrapInOptional()
          .prefix(value: AppEnvironment.current.currentUser)
          .demoteErrors()
      }.skipNil()

    let userAttributeChanged = self.emailFrequencyProperty.signal
      .map { frequency -> (UserAttribute, Bool) in
        let digestValue = frequency == .dailySummary ? true : false

        return (UserAttribute.notification(.creatorDigest), digestValue)
      }

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
      self.updateUserErrorProperty.signal.skipNil(),
      updateEmailFrequencyError.signal
    )

    self.updateCurrentUser = Signal.merge(
      initialUser,
      self.updatedUserProperty.signal.skipNil(),
      emailFrequencyUpdated
    )

    let emailFrequencyCellSelected = self.selectedCellType.signal
      .skipNil()
      .filter { $0 == .emailFrequency }

    let projectActivityEmailFrequencyDisabled = self.updateCurrentUser.signal
      .map(isNil)

    self.pickerViewIsHidden = Signal.merge(
      emailFrequencyCellSelected.signal.mapConst(false),
      self.emailFrequencyProperty.signal.mapConst(true),
      self.dismissPickerTapProperty.signal.mapConst(true),
      projectActivityEmailFrequencyDisabled.signal.mapConst(true)
    ).skipRepeats()

    self.pickerViewSelectedRow = self.updateCurrentUser.signal
      .map { $0 |> UserAttribute.notification(.creatorDigest).keyPath.view }
      .skipNil()
      .map { creatorDigest -> EmailFrequency in
        creatorDigest ? EmailFrequency.dailySummary : EmailFrequency.twiceADaySummary
      }

    let manageProjectNotificationsSelected = self.selectedCellType.signal
      .skipNil()
      .filter { $0 == .projectNotifications }

    self.goToManageProjectNotifications = manageProjectNotificationsSelected.signal
      .ignoreValues()

    // MARK: - Tracking

    self.updatedUserProperty.signal.observeValues { user in
      AppEnvironment.current.ksrAnalytics.identify(newUser: user)
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

  public let goToManageProjectNotifications: Signal<Void, Never>
  public let pickerViewIsHidden: Signal<Bool, Never>
  public let pickerViewSelectedRow: Signal<EmailFrequency, Never>
  public let unableToSaveError: Signal<String, Never>
  public let updateCurrentUser: Signal<User, Never>

  public var inputs: SettingsNotificationsViewModelInputs { return self }
  public var outputs: SettingsNotificationsViewModelOutputs { return self }
}
