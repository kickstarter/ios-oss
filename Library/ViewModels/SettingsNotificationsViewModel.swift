import Foundation
import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol SettingsNotificationsViewModelInputs {
  func didSelectRow(cellType: SettingsNotificationCellType)
  func failedToUpdateUser(error: String)
  func updateUser(user: User)
  func viewDidLoad()
}

public protocol SettingsNotificationsViewModelOutputs {
  var goToEmailFrequency: Signal<User, NoError> { get }
  var goToFindFriends: Signal<Void, NoError> { get }
  var goToManageProjectNotifications: Signal<Void, NoError> { get }
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
    }
    .skipNil()

    self.unableToSaveError = updateUserErrorProperty.signal.skipNil()

    self.updateCurrentUser = Signal.merge(
      initialUser,
      updatedUserProperty.signal.skipNil())

    let findFriendsTapped = self.selectedCellType.signal
      .skipNil()
      .filter { $0 == .findFacebookFriends }

    self.goToFindFriends = findFriendsTapped.signal.ignoreValues()

    let manageProjectNotificationsSelected = self.selectedCellType.signal
      .skipNil()
      .filter { $0 == .projectNotifications }

    self.goToManageProjectNotifications = manageProjectNotificationsSelected.signal
      .ignoreValues()

    let emailFrequencySelected = self.selectedCellType.signal
      .skipNil()
      .filter { $0 == .emailFrequency }

    self.goToEmailFrequency = self.updateCurrentUser
      .takeWhen(emailFrequencySelected)

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
    case .projectNotifications, .emailFrequency, .findFacebookFriends: return true
    default: return false
    }
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

  public let goToEmailFrequency: Signal<User, NoError>
  public let goToFindFriends: Signal<Void, NoError>
  public let goToManageProjectNotifications: Signal<Void, NoError>
  public let unableToSaveError: Signal<String, NoError>
  public let updateCurrentUser: Signal<User, NoError>

  public var inputs: SettingsNotificationsViewModelInputs { return self }
  public var outputs: SettingsNotificationsViewModelOutputs { return self }
}
