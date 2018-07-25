import Foundation
import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol SettingsNotificationsViewModelInputs {
  func emailNotificationsTogged(cellType: SettingsNotificationCellType, enabled: Bool)
  func mobileNotificationsToggled(cellType: SettingsNotificationCellType, enabled: Bool)
  func didSelectRow(cellType: SettingsNotificationCellType)
  func viewDidLoad()
}

public protocol SettingsNotificationsViewModelOutputs {
  var reloadData: Signal<Bool, NoError> { get }

  var emailFrequencyButtonEnabled: Signal<Bool, NoError> { get }
  var goToEmailFrequency: Signal<User, NoError> { get }
  var goToFindFriends: Signal<Void, NoError> { get }
  var goToManageProjectNotifications: Signal<Void, NoError> { get }
  var manageProjectNotificationsButtonAccessibilityHint: Signal<String, NoError> { get }
  var projectNotificationsCount: Signal<String, NoError> { get }
  var unableToSaveError: Signal<String, NoError> { get }
  var updateCurrentUser: Signal<User, NoError> { get }
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

    self.reloadData = initialUser.signal.map { $0.isCreator }

//    let userAttributeChanged: Signal<(UserAttribute, Bool), NoError> = Signal.merge(
//      self.emailCreatorTipsProperty.signal.map {
//        (UserAttribute.notification(UserAttribute.Notification.creatorTips), $0)
//      },
//      self.emailFriendActivityProperty.signal.map {
//        (UserAttribute.notification(UserAttribute.Notification.friendActivity), $0)
//      },
//      self.emailMessagesProperty.signal.map {
//        (UserAttribute.notification(UserAttribute.Notification.messages), $0)
//      },
//      self.emailNewCommentsProperty.signal.map {
//        (UserAttribute.notification(UserAttribute.Notification.comments), $0)
//      },
//      self.emailNewFollowersProperty.signal.map {
//        (UserAttribute.notification(UserAttribute.Notification.follower), $0)
//      },
//      self.emailNewLikesProperty.signal.map {
//        (UserAttribute.notification(UserAttribute.Notification.postLikes), $0)
//      },
//      self.emailNewPledgeProperty.signal.map {
//        (UserAttribute.notification(UserAttribute.Notification.backings), $0)
//      },
//      self.mobileFriendsActivityProperty.signal.map {
//        (UserAttribute.notification(UserAttribute.Notification.mobileFriendActivity), $0)
//      },
//      self.mobileMessagesProperty.signal.map {
//        (UserAttribute.notification(UserAttribute.Notification.mobileMessages), $0)
//      },
//      self.mobileNewCommentsProperty.signal.map {
//        (UserAttribute.notification(UserAttribute.Notification.mobileComments), $0)
//      },
//      self.mobileNewFollowersProperty.signal.map {
//        (UserAttribute.notification(UserAttribute.Notification.mobileFollower), $0)
//      },
//      self.mobileNewLikesProperty.signal.map {
//        (UserAttribute.notification(UserAttribute.Notification.mobilePostLikes), $0)
//      },
//      self.mobileNewPledgeProperty.signal.map {
//        (UserAttribute.notification(UserAttribute.Notification.mobileBackings), $0)
//      },
//      self.mobileProjectUpdatesProperty.signal.map {
//        (UserAttribute.notification(UserAttribute.Notification.mobileUpdates), $0)
//      },
//      self.emailProjectUpdatesProperty.signal.map {
//        (UserAttribute.notification(UserAttribute.Notification.updates), $0)
//      }
//    )
//
//    let updatedUser = initialUser
//      .switchMap { user in
//        userAttributeChanged.scan(user) { user, attributeAndOn in
//          let (attribute, on) = attributeAndOn
//          return user |> attribute.lens .~ on
//        }
//    }

    let updatedUser = initialUser

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

    let findFriendsTapped = self.selectedCellType.signal
      .skipNil()
      .filter { $0 == .findFacebookFriends }

    self.goToFindFriends = findFriendsTapped.signal.ignoreValues()

    let manageProjectNotificationsSelected = self.selectedCellType.signal
      .skipNil()
      .filter { $0 == .projectNotifications }

    self.goToManageProjectNotifications = manageProjectNotificationsSelected.signal
      .ignoreValues()

    self.manageProjectNotificationsButtonAccessibilityHint = self.updateCurrentUser
      .map { Strings.profile_project_count_projects_backed(project_count: $0.stats.backedProjectsCount ?? 0) }

    self.projectNotificationsCount = self.updateCurrentUser
      .map { Format.wholeNumber($0.stats.backedProjectsCount ?? 0) }
      .skipRepeats()

    self.emailFrequencyButtonEnabled = self.updateCurrentUser
      .map { $0.notifications.updates }
      .skipNil()
      .skipRepeats()

    let emailFrequencySelected = self.selectedCellType.signal
      .skipNil()
      .filter { $0 == .emailFrequency }

    self.goToEmailFrequency = self.updateCurrentUser
      .takeWhen(emailFrequencySelected)

    // Koala
//    userAttributeChanged
//      .observeValues { attribute, on in
//        switch attribute {
//        case let .newsletter(newsletter):
//          AppEnvironment.current.koala.trackChangeNewsletter(
//            newsletterType: newsletter, sendNewsletter: on, project: nil, context: .settings
//          )
//        case let .notification(notification):
//          switch notification {
//          case
//          .mobileBackings,
//          .mobileComments, .mobileFollower, .mobileFriendActivity, .mobilePostLikes, .mobileMessages,
//          .mobileUpdates:
//            AppEnvironment.current.koala.trackChangePushNotification(type: notification.trackingString,
//                                                                     on: on)
//          case .backings,
//               .comments, .follower, .friendActivity, .messages, .postLikes, .creatorTips, .updates:
//            AppEnvironment.current.koala.trackChangeEmailNotification(type: notification.trackingString,
//                                                                      on: on)
//          default: break
//          }
//        case let .privacy(privacy):
//          switch privacy {
//          case .recommendations: AppEnvironment.current.koala.trackRecommendationsOptIn()
//          default: break
//          }
//        }
//    }

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

  public func emailNotificationsTogged(cellType: SettingsNotificationCellType, enabled: Bool) {

  }

  fileprivate let userAttributeChangedProperty = MutableProperty<(UserAttribute, Bool)?>(nil)
  public func mobileNotificationsToggled(cellType: SettingsNotificationCellType, enabled: Bool) {

  }

  fileprivate let selectedCellType = MutableProperty<SettingsNotificationCellType?>(nil)
  public func didSelectRow(cellType: SettingsNotificationCellType) {
    self.selectedCellType.value = cellType
  }

  public let emailFrequencyButtonEnabled: Signal<Bool, NoError>
  public let goToEmailFrequency: Signal<User, NoError>
  public let goToFindFriends: Signal<Void, NoError>
  public let goToManageProjectNotifications: Signal<Void, NoError>
  public let manageProjectNotificationsButtonAccessibilityHint: Signal<String, NoError>
  public let projectNotificationsCount: Signal<String, NoError>
  public let unableToSaveError: Signal<String, NoError>
  public let updateCurrentUser: Signal<User, NoError>

  public let reloadData: Signal<Bool, NoError>

  public var inputs: SettingsNotificationsViewModelInputs { return self }
  public var outputs: SettingsNotificationsViewModelOutputs { return self }
}
