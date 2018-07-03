import Foundation
import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol SettingsNotificationsViewModelInputs {

  func emailFriendActivityTapped(selected: Bool)
  func emailNewFollowersTapped(selected: Bool)
  func emailProjectUpdates(selected: Bool)
  func findFriendsTapped()
  func manageProjectNotificationsTapped()
  func mobileFriendsActivityTapped(selected: Bool)
  func mobileNewFollowersTapped(selected: Bool)
  func mobileProjectUpdatesTapped(selected: Bool)
  func viewDidLoad()
}

public protocol SettingsNotificationsViewModelOutputs {
  var emailNewFollowersSelected: Signal<Bool, NoError> { get }
  var emailFriendActivitySelected: Signal<Bool, NoError> { get }
  var emailProjectUpdatesSelected: Signal<Bool, NoError> { get }
  var goToFindFriends: Signal<Void, NoError> { get }
  var goToManageProjectNotifications: Signal<Void, NoError> { get }
  var manageProjectNotificationsButtonAccessibilityHint: Signal<String, NoError> { get }
  var mobileFriendsActivitySelected: Signal<Bool, NoError> { get }
  var mobileNewFollowersSelected: Signal<Bool, NoError> { get }
  var mobileProjectUpdatesSelected: Signal<Bool, NoError> { get }
  var projectNotificationsCount: Signal<String, NoError> { get }
}

public protocol SettingsNotificationsViewModelType {
  var inputs: SettingsViewModelInputs { get }
  var outputs: SettingsViewModelOutputs { get }
}

final internal class SettingsNotificationsViewModel: SettingsNotificationsViewModelType,
SettingsNotificationsViewModelInputs, SettingsNotificationsViewModelOutputs {

  public init() {

    let initialUser = viewDidLoadProperty.signal
      .flatMap {
        AppEnviroment.current.apiService.fetchUserSelf()
        .wrapInOptional()
        .prefix(value: AppEnvironment.current.currentUser)
        .demoteErrors()
    }
    .skipNil()


  }

  fileprivate let emailFriendActivityProperty = MutableProperty(false)
  public func emailFriendActivityTapped(selected: Bool) {
    self.emailFriendActivityProperty.value = selected
  }

  fileprivate let emailNewFollowersProperty = MutableProperty(false)
  public func emailNewFollowersTapped(selected: Bool) {
    self.emailNewFollowersProperty.value = selected
  }

  fileprivate let emailProjectUpdatesProperty = MutableProperty(false)
  public func emailProjectUpdates(selected: Bool) {
    self.emailProjectUpdatesProperty.value = selected
  }

  fileprivate let findFriendsTappedProperty = MutableProperty(())
  public func findFriendsTapped() {
    self.findFriendsTappedProperty.value = ()
  }

  fileprivate let manageProjectNotificationsProperty = MutableProperty(())
  public func manageProjectNotificationsTapped() {
    self.manageProjectNotificationsProperty.value = ()
  }

  fileprivate let mobileFriendsActivityProperty = MutableProperty(false)
  public func mobileFriendsActivityTapped(selected: Bool) {
    self.mobileFriendsActivityProperty.value = selected
  }

  fileprivate let mobileNewFollowersProperty = MutableProperty(false)
  public func mobileNewFollowersTapped(selected: Bool) {
    self.mobileNewFollowersProperty.value = selected
  }

  fileprivate let mobileProjectUpdatesProperty = MutableProperty(false)
  public func mobileProjectUpdatesTapped(selected: Bool) {
    self.mobileProjectUpdatesProperty.value = selected
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let emailFrequencyButtonEnabled: Signal<Bool, NoError>
  public let emailNewFollowerSelected: Signal<Bool, NoError>
  public let emailFriendActivitySelected: Signal<Bool, NoError>
  public let goToFindFriends: Signal<Void, NoError>
  public let goToManageProjectNotifications: Signal<Void, NoError>
  public let manageProjectNotificationsButtonAccessibilityHint: Signal<String, NoError>
  public let mobileNewFollowersSelected: Signal<Bool, NoError>
  public let mobileFriendActivitySelected: Signal<Bool, NoError>
  public let mobileProjectUpdatesSelected: Signal<Bool, NoError>
  public let projectNotificationsCount: Signal<String, NoError>
  public let emailUpdatesSelected: Signal<Bool, NoError>
}
