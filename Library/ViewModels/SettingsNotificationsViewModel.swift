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
  var emailFriendsActivitySelected: Signal<Bool, NoError> { get }
  var emailProjectUpdatesSelected: Signal<Bool, NoError> { get }
  var goToFindFriends: Signal<Void, NoError> { get }
  var goToManageProjectNotifications: Signal<Void, NoError> { get }
  var manageProjectNotificationsButtonAccessibilityHint: Signal<String, NoError> { get }
  var mobileFriendsActivitySelected: Signal<Bool, NoError> { get }
  var mobileNewFollowersSelected: Signal<Bool, NoError> { get }
  var mobileProjectUpdatesSelected: Signal<Bool, NoError> { get }
  var projectNotificationsCount: Signal<String, NoError> { get }
  var unableToSaveError: Signal<String, NoError> { get }
  var updatesSelected: Signal<Bool, NoError> { get }
  var updateCurrentUser: Signal<User, NoError> { get }
}

public protocol SettingsNotificationsViewModelType {
  var inputs: SettingsNotificationsViewModelInputs { get }
  var outputs: SettingsNotificationsViewModelOutputs { get }
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

    let userAttributeChanged: Signal<(UserAttribute, Bool), NoError> = Signal.merge(

      self.emailNewFollowersProperty.signal.map {
        (UserAttribute.notification(Notification.follower), $0)
      },
      self.emailFriendActivityProperty.signal.map {
        (UserAttribute.notification(Notification.friendActivity), $0)
      },
      self.mobileNewFollowersProperty.signal.map {
        (UserAttribute.notification(Notification.mobileFollower), $0)
      },
      self.mobileFriendsActivityProperty.signal.map {
        (UserAttribute.notification(Notification.mobileFriendActivity), $0)
      },
      self.mobileProjectUpdatesProperty.signal.map {
        (UserAttribute.notification(Notification.mobileUpdates), $0)
      },
      self.emailProjectUpdatesProperty.signal.map {
        (UserAttribute.notification(Notification.updates), $0)
      }
    )

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

    self.updatesSelected = self.updateCurrentUser
      .map { $0.notifications.updates }.skipNil().skipRepeats()

    self.emailNewFollowersSelected = .empty
    self.emailFriendsActivitySelected = .empty
    self.emailProjectUpdatesSelected = .empty
    self.goToFindFriends = .empty
    self.goToManageProjectNotifications = .empty
    self.manageProjectNotificationsButtonAccessibilityHint = .empty
    self.mobileFriendsActivitySelected = .empty
    self.mobileNewFollowersSelected = .empty
    self.mobileProjectUpdatesSelected = .empty
    self.projectNotificationsCount = .empty
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

  public let emailFriendsActivitySelected: Signal<Bool, NoError>
  public let emailNewFollowersSelected: Signal<Bool, NoError>
  public let emailProjectUpdatesSelected: Signal<Bool, NoError>
  public let goToFindFriends: Signal<Void, NoError>
  public let goToManageProjectNotifications: Signal<Void, NoError>
  public let manageProjectNotificationsButtonAccessibilityHint: Signal<String, NoError>
  public let mobileNewFollowersSelected: Signal<Bool, NoError>
  public let mobileFriendsActivitySelected: Signal<Bool, NoError>
  public let mobileProjectUpdatesSelected: Signal<Bool, NoError>
  public let projectNotificationsCount: Signal<String, NoError>
  public let unableToSaveError: Signal<String, NoError>
  public let updatesSelected: Signal<Bool, NoError>
  public let updateCurrentUser: Signal<User, NoError>

  public var inputs: SettingsNotificationsViewModelInputs { return self }
  public var outputs: SettingsNotificationsViewModelOutputs { return self }
}

private enum UserAttribute {
  case newsletter(Newsletter)
  case notification(Notification)
  case privacy(Privacy)

  fileprivate var lens: Lens<User, Bool?> {
    switch self {
    case let .newsletter(newsletter):
      switch newsletter {
      case .arts:       return User.lens.newsletters.arts
      case .games:      return User.lens.newsletters.games
      case .happening:  return User.lens.newsletters.happening
      case .invent:     return User.lens.newsletters.invent
      case .promo:      return User.lens.newsletters.promo
      case .weekly:     return User.lens.newsletters.weekly
      }
    case let .notification(notification):
      switch notification {
      case .backings:             return User.lens.notifications.backings
      case .comments:             return User.lens.notifications.comments
      case .creatorTips:          return User.lens.notifications.creatorTips
      case .follower:             return User.lens.notifications.follower
      case .friendActivity:       return User.lens.notifications.friendActivity
      case .messages:             return User.lens.notifications.messages
      case .mobileBackings:       return User.lens.notifications.mobileBackings
      case .mobileComments:       return User.lens.notifications.mobileComments
      case .mobileFollower:       return User.lens.notifications.mobileFollower
      case .mobileFriendActivity: return User.lens.notifications.mobileFriendActivity
      case .mobileMessages:       return User.lens.notifications.mobileMessages
      case .mobilePostLikes:      return User.lens.notifications.mobilePostLikes
      case .mobileUpdates:        return User.lens.notifications.mobileUpdates
      case .postLikes:            return User.lens.notifications.postLikes
      case .updates:              return User.lens.notifications.updates
      }
    case let .privacy(privacy):
      switch privacy {
      case .following:          return User.lens.social
      case .recommendations:    return User.lens.optedOutOfRecommendations
      case .showPublicProfile:  return User.lens.showPublicProfile
      }
    }
  }
}

private enum Notification {
  case backings
  case comments
  case creatorTips
  case follower
  case friendActivity
  case messages
  case mobileBackings
  case mobileComments
  case mobileFollower
  case mobileFriendActivity
  case mobileMessages
  case mobilePostLikes
  case mobileUpdates
  case postLikes
  case updates

  fileprivate var trackingString: String {
    switch self {
    case .backings, .mobileBackings:                return "New pledges"
    case .comments, .mobileComments:                return "New comments"
    case .creatorTips:                              return "Creator tips"
    case .follower, .mobileFollower:                return "New followers"
    case .friendActivity, .mobileFriendActivity:    return "Friend backs a project"
    case .messages, .mobileMessages:                return "New messages"
    case .postLikes, .mobilePostLikes:              return "New likes"
    case .updates, .mobileUpdates:                  return "Project updates"
    }
  }
}

private enum Privacy {
  case following
  case recommendations
  case showPublicProfile

  fileprivate var trackingString: String {
    switch self {
    case .following: return Strings.Following()
    case .recommendations: return Strings.Recommendations()
    default: return ""
    }
  }
}
