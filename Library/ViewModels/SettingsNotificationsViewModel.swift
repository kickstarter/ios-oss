import Foundation
import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol SettingsNotificationsViewModelInputs {

  func emailCreatorTipsTapped(selected: Bool)
  func emailFrequencyTapped()
  func emailFriendActivityTapped(selected: Bool)
  func emailMessagesTapped(selected: Bool)
  func emailNewCommentsTapped(selected: Bool)
  func emailNewFollowersTapped(selected: Bool)
  func emailNewLikesTapped(selected: Bool)
  func emailNewPledgeTapped(selected: Bool)
  func emailProjectUpdatesTapped(selected: Bool)
  func findFriendsTapped()
  func manageProjectNotificationsTapped()
  func mobileFriendsActivityTapped(selected: Bool)
  func mobileMessagesTapped(selected: Bool)
  func mobileNewCommentsTapped(selected: Bool)
  func mobileNewFollowersTapped(selected: Bool)
  func mobileNewLikesTapped(selected: Bool)
  func mobileNewPledgeTapped(selected: Bool)
  func mobileProjectUpdatesTapped(selected: Bool)
  func viewDidLoad()
}

public protocol SettingsNotificationsViewModelOutputs {

  var creatorNotificationsHidden: Signal<Bool, NoError> { get }
  var emailCreatorTipsSelected: Signal<Bool, NoError> { get }
  var emailFrequencyButtonEnabled: Signal<Bool, NoError> { get }
  var emailFriendsActivitySelected: Signal<Bool, NoError> { get }
  var emailMessagesSelected: Signal<Bool, NoError> { get }
  var emailNewCommentsSelected: Signal<Bool, NoError> { get }
  var emailNewFollowersSelected: Signal<Bool, NoError> { get }
  var emailNewLikesSelected: Signal<Bool, NoError> { get }
  var emailNewPledgesSelected: Signal<Bool, NoError> { get }
  var emailProjectUpdatesSelected: Signal<Bool, NoError> { get }
  var goToEmailFrequency: Signal<User, NoError> { get }
  var goToFindFriends: Signal<Void, NoError> { get }
  var goToManageProjectNotifications: Signal<Void, NoError> { get }
  var manageProjectNotificationsButtonAccessibilityHint: Signal<String, NoError> { get }
  var mobileFriendsActivitySelected: Signal<Bool, NoError> { get }
  var mobileMessagesSelected: Signal<Bool, NoError> { get }
  var mobileNewCommentsSelected: Signal<Bool, NoError> { get }
  var mobileNewFollowersSelected: Signal<Bool, NoError> { get }
  var mobileNewLikesSelected: Signal<Bool, NoError> { get }
  var mobileNewPledgesSelected: Signal<Bool, NoError> { get }
  var mobileProjectUpdatesSelected: Signal<Bool, NoError> { get }
  var projectNotificationsCount: Signal<String, NoError> { get }
  var unableToSaveError: Signal<String, NoError> { get }
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
      self.emailCreatorTipsProperty.signal.map {
        (UserAttribute.notification(Notification.creatorTips), $0)
      },
      self.emailFriendActivityProperty.signal.map {
        (UserAttribute.notification(Notification.friendActivity), $0)
      },
      self.emailMessagesProperty.signal.map {
        (UserAttribute.notification(Notification.messages), $0)
      },
      self.emailNewCommentsProperty.signal.map {
        (UserAttribute.notification(Notification.comments), $0)
      },
      self.emailNewFollowersProperty.signal.map {
        (UserAttribute.notification(Notification.follower), $0)
      },
      self.emailNewLikesProperty.signal.map {
        (UserAttribute.notification(Notification.postLikes), $0)
      },
      self.emailNewPledgeProperty.signal.map {
        (UserAttribute.notification(Notification.backings), $0)
      },
      self.mobileFriendsActivityProperty.signal.map {
        (UserAttribute.notification(Notification.mobileFriendActivity), $0)
      },
      self.mobileMessagesProperty.signal.map {
        (UserAttribute.notification(Notification.mobileMessages), $0)
      },
      self.mobileNewCommentsProperty.signal.map {
        (UserAttribute.notification(Notification.mobileComments), $0)
      },
      self.mobileNewFollowersProperty.signal.map {
        (UserAttribute.notification(Notification.mobileFollower), $0)
      },
      self.mobileNewLikesProperty.signal.map {
        (UserAttribute.notification(Notification.mobilePostLikes), $0)
      },
      self.mobileNewPledgeProperty.signal.map {
        (UserAttribute.notification(Notification.mobileBackings), $0)
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

    self.creatorNotificationsHidden = self.updateCurrentUser.map { !$0.isCreator }.skipRepeats()

    self.emailCreatorTipsSelected = self.updateCurrentUser
      .map { $0.notifications.creatorTips }.skipNil().skipRepeats()

    self.emailFriendsActivitySelected = self.updateCurrentUser
      .map { $0.notifications.friendActivity }.skipNil().skipRepeats()

    self.emailMessagesSelected = self.updateCurrentUser
      .map { $0.notifications.messages }.skipNil().skipRepeats()

    self.emailNewCommentsSelected = self.updateCurrentUser
      .map { $0.notifications.comments }.skipNil().skipRepeats()

    self.emailNewFollowersSelected = self.updateCurrentUser
      .map { $0.notifications.follower }.skipNil().skipRepeats()

    self.emailNewLikesSelected = self.updateCurrentUser
      .map { $0.notifications.postLikes }.skipNil().skipRepeats()

    self.emailNewPledgesSelected = self.updateCurrentUser
                                    .map { $0.notifications.backings }
                                    .skipNil()
                                    .skipRepeats()

    self.emailProjectUpdatesSelected = self.updateCurrentUser
      .map { $0.notifications.updates }.skipNil().skipRepeats()

    self.goToFindFriends = self.findFriendsTappedProperty.signal

    self.goToManageProjectNotifications = self.manageProjectNotificationsProperty.signal

    self.manageProjectNotificationsButtonAccessibilityHint = self.updateCurrentUser
      .map { Strings.profile_project_count_projects_backed(project_count: $0.stats.backedProjectsCount ?? 0) }

    self.mobileFriendsActivitySelected = self.updateCurrentUser
      .map { $0.notifications.mobileFriendActivity }.skipNil().skipRepeats()

    self.mobileMessagesSelected = self.updateCurrentUser
      .map { $0.notifications.mobileMessages }.skipNil().skipRepeats()

    self.mobileNewCommentsSelected = self.updateCurrentUser
      .map { $0.notifications.mobileComments }.skipNil().skipRepeats()

    self.mobileNewFollowersSelected = self.updateCurrentUser
      .map { $0.notifications.mobileFollower }.skipNil().skipRepeats()

    self.mobileNewLikesSelected = self.updateCurrentUser
      .map { $0.notifications.mobilePostLikes }.skipNil().skipRepeats()

    self.mobileNewPledgesSelected = self.updateCurrentUser
      .map { $0.notifications.mobileBackings }.skipNil().skipRepeats()

    self.mobileProjectUpdatesSelected = self.updateCurrentUser
      .map { $0.notifications.mobileUpdates }.skipNil().skipRepeats()

    self.projectNotificationsCount = self.updateCurrentUser
      .map { Format.wholeNumber($0.stats.backedProjectsCount ?? 0) }
      .skipRepeats()

    self.emailFrequencyButtonEnabled = self.emailNewPledgesSelected

    self.goToEmailFrequency = self.updateCurrentUser
      .takeWhen(self.emailFrequencyTappedProperty.signal)

    // Koala
    userAttributeChanged
      .observeValues { attribute, on in
        switch attribute {
        case let .newsletter(newsletter):
          AppEnvironment.current.koala.trackChangeNewsletter(
            newsletterType: newsletter, sendNewsletter: on, project: nil, context: .settings
          )
        case let .notification(notification):
          switch notification {
          case
          .mobileBackings,
          .mobileComments, .mobileFollower, .mobileFriendActivity, .mobilePostLikes, .mobileMessages,
          .mobileUpdates:
            AppEnvironment.current.koala.trackChangePushNotification(type: notification.trackingString,
                                                                     on: on)
          case .backings,
               .comments, .follower, .friendActivity, .messages, .postLikes, .creatorTips, .updates:
            AppEnvironment.current.koala.trackChangeEmailNotification(type: notification.trackingString,
                                                                      on: on)
          }
        case let .privacy(privacy):
          switch privacy {
          case .recommendations: AppEnvironment.current.koala.trackRecommendationsOptIn()
          default: break
          }
        }
    }

    self.viewDidLoadProperty.signal.observeValues { _ in
      AppEnvironment.current.koala.trackSettingsView()
    }
  }

  fileprivate let emailCreatorTipsProperty = MutableProperty(false)
  public func emailCreatorTipsTapped(selected: Bool) {
    self.emailCreatorTipsProperty.value = selected
  }

  fileprivate let emailFrequencyTappedProperty = MutableProperty(())
  public func emailFrequencyTapped() {
    self.emailFrequencyTappedProperty.value = ()
  }

  fileprivate let emailFriendActivityProperty = MutableProperty(false)
  public func emailFriendActivityTapped(selected: Bool) {
    self.emailFriendActivityProperty.value = selected
  }

  fileprivate let emailMessagesProperty = MutableProperty(false)
  public func emailMessagesTapped(selected: Bool) {
    self.emailMessagesProperty.value = selected
  }

  fileprivate let emailNewCommentsProperty = MutableProperty(false)
  public func emailNewCommentsTapped(selected: Bool) {
    self.emailNewCommentsProperty.value = selected
  }

  fileprivate let emailNewFollowersProperty = MutableProperty(false)
  public func emailNewFollowersTapped(selected: Bool) {
    self.emailNewFollowersProperty.value = selected
  }

  fileprivate let emailNewLikesProperty = MutableProperty(false)
  public func emailNewLikesTapped(selected: Bool) {
    self.emailNewLikesProperty.value = selected
  }

  fileprivate let emailNewPledgeProperty = MutableProperty(false)
  public func emailNewPledgeTapped(selected: Bool) {
    self.emailNewPledgeProperty.value = selected
  }

  fileprivate let emailProjectUpdatesProperty = MutableProperty(false)
  public func emailProjectUpdatesTapped(selected: Bool) {
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

  fileprivate let mobileMessagesProperty = MutableProperty(false)
  public func mobileMessagesTapped(selected: Bool) {
    self.mobileMessagesProperty.value = selected
  }

  fileprivate let mobileNewCommentsProperty = MutableProperty(false)
  public func mobileNewCommentsTapped(selected: Bool) {
    self.mobileNewCommentsProperty.value = selected
  }

  fileprivate let mobileNewFollowersProperty = MutableProperty(false)
  public func mobileNewFollowersTapped(selected: Bool) {
    self.mobileNewFollowersProperty.value = selected
  }

  fileprivate let mobileNewLikesProperty = MutableProperty(false)
  public func mobileNewLikesTapped(selected: Bool) {
    self.mobileNewLikesProperty.value = selected
  }

  fileprivate let mobileNewPledgeProperty = MutableProperty(false)
  public func mobileNewPledgeTapped(selected: Bool) {
    self.mobileNewPledgeProperty.value = selected
  }

  fileprivate let mobileProjectUpdatesProperty = MutableProperty(false)
  public func mobileProjectUpdatesTapped(selected: Bool) {
    self.mobileProjectUpdatesProperty.value = selected
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let creatorNotificationsHidden: Signal<Bool, NoError>
  public let emailCreatorTipsSelected: Signal<Bool, NoError>
  public let emailFrequencyButtonEnabled: Signal<Bool, NoError>
  public let emailFriendsActivitySelected: Signal<Bool, NoError>
  public let emailMessagesSelected: Signal<Bool, NoError>
  public let emailNewCommentsSelected: Signal<Bool, NoError>
  public let emailNewFollowersSelected: Signal<Bool, NoError>
  public let emailNewLikesSelected: Signal<Bool, NoError>
  public let emailNewPledgesSelected: Signal<Bool, NoError>
  public let emailProjectUpdatesSelected: Signal<Bool, NoError>
  public let goToEmailFrequency: Signal<User, NoError>
  public let goToFindFriends: Signal<Void, NoError>
  public let goToManageProjectNotifications: Signal<Void, NoError>
  public let manageProjectNotificationsButtonAccessibilityHint: Signal<String, NoError>
  public let mobileFriendsActivitySelected: Signal<Bool, NoError>
  public let mobileMessagesSelected: Signal<Bool, NoError>
  public let mobileNewCommentsSelected: Signal<Bool, NoError>
  public let mobileNewFollowersSelected: Signal<Bool, NoError>
  public let mobileNewLikesSelected: Signal<Bool, NoError>
  public let mobileNewPledgesSelected: Signal<Bool, NoError>
  public let mobileProjectUpdatesSelected: Signal<Bool, NoError>
  public let projectNotificationsCount: Signal<String, NoError>
  public let unableToSaveError: Signal<String, NoError>
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
