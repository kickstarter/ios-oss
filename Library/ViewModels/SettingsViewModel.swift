import Foundation
import KsApi
import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result

// swiftlint:disable file_length
public protocol SettingsViewModelInputs {
  func backingsTapped(selected selected: Bool)
  func betaFeedbackButtonTapped()
  func commentsTapped(selected selected: Bool)
  func findFriendsTapped()
  func followerTapped(selected selected: Bool)
  func friendActivityTapped(selected selected: Bool)
  func gamesNewsletterTapped(on on: Bool)
  func happeningNewsletterTapped(on on: Bool)
  func logoutCanceled()
  func logoutConfirmed()
  func logoutTapped()
  func manageProjectNotificationsTapped()
  func mobileBackingsTapped(selected selected: Bool)
  func mobileCommentsTapped(selected selected: Bool)
  func mobileFollowerTapped(selected selected: Bool)
  func mobileFriendActivityTapped(selected selected: Bool)
  func mobilePostLikesTapped(selected selected: Bool)
  func mobileUpdatesTapped(selected selected: Bool)
  func postLikesTapped(selected selected: Bool)
  func promoNewsletterTapped(on on: Bool)
  func rateUsTapped()
  func updatesTapped(selected selected: Bool)
  func viewDidLoad()
  func weeklyNewsletterTapped(on on: Bool)
}

public protocol SettingsViewModelOutputs {
  var backingsSelected: Signal<Bool, NoError> { get }
  var betaFeedbackButtonHidden: Signal<Bool, NoError> { get }
  var commentsSelected: Signal<Bool, NoError> { get }
  var creatorNotificationsHidden: Signal<Bool, NoError> { get }
  var followerSelected: Signal<Bool, NoError> { get }
  var friendActivitySelected: Signal<Bool, NoError> { get }
  var gamesNewsletterOn: Signal<Bool, NoError> { get }
  var goToAppStoreRating: Signal<String, NoError> { get }
  var goToBetaFeedback: Signal<(), NoError> { get }
  var goToFindFriends: Signal<Void, NoError> { get }
  var goToManageProjectNotifications: Signal<Void, NoError> { get }
  var happeningNewsletterOn: Signal<Bool, NoError> { get }
  var logout: Signal<Void, NoError> { get }
  var mobileBackingsSelected: Signal<Bool, NoError> { get }
  var mobileCommentsSelected: Signal<Bool, NoError> { get }
  var mobileFollowerSelected: Signal<Bool, NoError> { get }
  var mobileFriendActivitySelected: Signal<Bool, NoError> { get }
  var mobilePostLikesSelected: Signal<Bool, NoError> { get }
  var mobileUpdatesSelected: Signal<Bool, NoError> { get }
  var postLikesSelected: Signal<Bool, NoError> { get }
  var projectNotificationsCount: Signal<String, NoError> { get }
  var promoNewsletterOn: Signal<Bool, NoError> { get }
  var showConfirmLogoutPrompt: Signal<(message: String, cancel: String, confirm: String), NoError> { get }
  var showOptInPrompt: Signal<String, NoError> { get }
  var unableToSaveError: Signal<String, NoError> { get }
  var updatesSelected: Signal<Bool, NoError> { get }
  var updateCurrentUser: Signal<User, NoError> { get }
  var versionText: Signal<String, NoError> { get }
  var weeklyNewsletterOn: Signal<Bool, NoError> { get }
}

public protocol SettingsViewModelType {
  var inputs: SettingsViewModelInputs { get }
  var outputs: SettingsViewModelOutputs { get }
}

public final class SettingsViewModel: SettingsViewModelType, SettingsViewModelInputs,
  SettingsViewModelOutputs {
  // swiftlint:disable function_body_length
  // swiftlint:disable cyclomatic_complexity
  public init() {
    let initialUser = viewDidLoadProperty.signal
      .flatMap {
        AppEnvironment.current.apiService.fetchUserSelf()
          .wrapInOptional()
          .prefix(value: AppEnvironment.current.currentUser)
          .demoteErrors()
      }
      .ignoreNil()

    let newsletterOn: Signal<(Newsletter, Bool), NoError> = .merge(
      self.gamesNewsletterTappedProperty.signal.map { (.games, $0) },
      self.happeningNewsletterTappedProperty.signal.map { (.happening, $0) },
      self.promoNewsletterTappedProperty.signal.map { (.promo, $0) },
      self.weeklyNewsletterTappedProperty.signal.map { (.weekly, $0) }
    )

    let userAttributeChanged: Signal<(UserAttribute, Bool), NoError> = .merge([
      self.gamesNewsletterTappedProperty.signal.map { (.newsletter(.games), $0) },
      self.happeningNewsletterTappedProperty.signal.map { (.newsletter(.happening), $0) },
      self.promoNewsletterTappedProperty.signal.map { (.newsletter(.promo), $0) },
      self.weeklyNewsletterTappedProperty.signal.map { (.newsletter(.weekly), $0)},

      self.backingsTappedProperty.signal.map { (.notification(.backings), $0) },
      self.commentsTappedProperty.signal.map { (.notification(.comments), $0) },
      self.followerTappedProperty.signal.map { (.notification(.follower), $0) },
      self.friendActivityTappedProperty.signal.map { (.notification(.friendActivity), $0) },
      self.mobileBackingsTappedProperty.signal.map { (.notification(.mobileBackings), $0) },
      self.mobileCommentsTappedProperty.signal.map { (.notification(.mobileComments), $0) },
      self.mobileFollowerTappedProperty.signal.map { (.notification(.mobileFollower), $0) },
      self.mobileFriendActivityTappedProperty.signal.map { (.notification(.mobileFriendActivity), $0) },
      self.mobilePostLikesTappedProperty.signal.map { (.notification(.mobilePostLikes), $0) },
      self.mobileUpdatesTappedProperty.signal.map { (.notification(.mobileUpdates), $0) },
      self.postLikesTappedProperty.signal.map { (.notification(.postLikes), $0) },
      self.updatesTappedProperty.signal.map { (.notification(.updates), $0) }
    ])

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
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
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

    self.projectNotificationsCount = self.updateCurrentUser
      .map { Format.wholeNumber($0.stats.backedProjectsCount ?? 0) }
      .skipRepeats()

    self.goToAppStoreRating = self.rateUsTappedProperty.signal
      .map { AppEnvironment.current.config?.iTunesLink ?? "" }

    self.goToBetaFeedback = self.betaFeedbackButtonTappedProperty.signal

    self.goToFindFriends = self.findFriendsTappedProperty.signal

    self.goToManageProjectNotifications = self.manageProjectNotificationsTappedProperty.signal

    self.showConfirmLogoutPrompt = self.logoutTappedProperty.signal
      .map {
        (message: Strings.profile_settings_logout_alert_message(),
        cancel: Strings.profile_settings_logout_alert_cancel_button(),
        confirm: Strings.profile_settings_logout_alert_confirm_button()
        )
    }

    self.logout = self.logoutConfirmedProperty.signal

    self.showOptInPrompt = newsletterOn
      .filter { _, on in AppEnvironment.current.config?.countryCode == "DE" && on }
      .map { newsletter, _ in newsletter.displayableName }

    self.gamesNewsletterOn = self.updateCurrentUser.map { $0.newsletters.games }.ignoreNil().skipRepeats()
    self.happeningNewsletterOn = self.updateCurrentUser
      .map { $0.newsletters.happening }.ignoreNil().skipRepeats()
    self.promoNewsletterOn = self.updateCurrentUser.map { $0.newsletters.promo }.ignoreNil().skipRepeats()
    self.weeklyNewsletterOn = self.updateCurrentUser.map { $0.newsletters.weekly }.ignoreNil().skipRepeats()

    self.backingsSelected = self.updateCurrentUser.map { $0.notifications.backings }.ignoreNil().skipRepeats()
    self.commentsSelected = self.updateCurrentUser
      .map { $0.notifications.comments }.ignoreNil().skipRepeats()
    self.followerSelected = self.updateCurrentUser
      .map { $0.notifications.follower }.ignoreNil().skipRepeats()
    self.friendActivitySelected = self.updateCurrentUser
      .map { $0.notifications.friendActivity }.ignoreNil().skipRepeats()
    self.mobileBackingsSelected = self.updateCurrentUser
      .map { $0.notifications.mobileBackings }.ignoreNil().skipRepeats()
    self.mobileCommentsSelected = self.updateCurrentUser
      .map { $0.notifications.mobileComments }.ignoreNil().skipRepeats()
    self.mobileFollowerSelected = self.updateCurrentUser
      .map { $0.notifications.mobileFollower }.ignoreNil().skipRepeats()
    self.mobileFriendActivitySelected = self.updateCurrentUser
      .map { $0.notifications.mobileFriendActivity }.ignoreNil().skipRepeats()
    self.mobilePostLikesSelected = self.updateCurrentUser
      .map { $0.notifications.mobilePostLikes }.ignoreNil().skipRepeats()
    self.mobileUpdatesSelected = self.updateCurrentUser
      .map { $0.notifications.mobileUpdates }.ignoreNil().skipRepeats()
    self.postLikesSelected = self.updateCurrentUser
      .map { $0.notifications.postLikes }.ignoreNil().skipRepeats()
    self.updatesSelected = self.updateCurrentUser
      .map { $0.notifications.updates }.ignoreNil().skipRepeats()

    self.versionText = viewDidLoadProperty.signal
      .map {
        Strings.profile_settings_version_number(
            version_number: AppEnvironment.current.mainBundle.shortVersionString
        )
    }

    self.betaFeedbackButtonHidden = self.viewDidLoadProperty.signal.mapConst(false)

    // Tracking Events
    Signal.merge(
      self.backingsTappedProperty.signal.mapConst(Notification.backings.type),
      self.commentsTappedProperty.signal.mapConst(Notification.comments.type),
      self.followerTappedProperty.signal.mapConst(Notification.follower.type),
      self.friendActivityTappedProperty.signal.mapConst(Notification.friendActivity.type),
      self.postLikesTappedProperty.signal.mapConst(Notification.postLikes.type),
      self.updatesTappedProperty.signal.mapConst(Notification.updates.type)
    )
      .observeNext {
        AppEnvironment.current.koala.trackChangeEmailNotification(type: $0)
    }

    Signal.merge(
      self.gamesNewsletterTappedProperty.signal.mapConst(Newsletter.games.rawValue),
      self.happeningNewsletterTappedProperty.signal.mapConst(Newsletter.happening.rawValue),
      self.promoNewsletterTappedProperty.signal.mapConst(Newsletter.promo.rawValue),
      self.weeklyNewsletterTappedProperty.signal.mapConst(Newsletter.weekly.rawValue)
      )
      .observeNext {
        AppEnvironment.current.koala.trackChangeNewsletter(type: $0)
    }

    Signal.merge(
      self.mobileBackingsTappedProperty.signal.mapConst(Notification.mobileBackings.type),
      self.mobileCommentsTappedProperty.signal.mapConst(Notification.mobileComments.type),
      self.mobileFollowerTappedProperty.signal.mapConst(Notification.mobileFollower.type),
      self.mobileFriendActivityTappedProperty.signal.mapConst(Notification.mobileFriendActivity.type),
      self.mobilePostLikesTappedProperty.signal.mapConst(Notification.mobilePostLikes.type),
      self.mobileUpdatesTappedProperty.signal.mapConst(Notification.mobileUpdates.type)
      )
      .observeNext {
        AppEnvironment.current.koala.trackChangePushNotification(type: $0)
    }

    self.logoutCanceledProperty.signal
      .observeNext { _ in AppEnvironment.current.koala.trackCancelLogoutModal() }

    self.logoutConfirmedProperty.signal
      .observeNext { _ in AppEnvironment.current.koala.trackConfirmLogoutModal() }

    self.goToAppStoreRating
      .observeNext { _ in AppEnvironment.current.koala.trackAppStoreRatingOpen() }

    self.showConfirmLogoutPrompt
      .observeNext { _ in AppEnvironment.current.koala.trackLogoutModal() }

    self.viewDidLoadProperty.signal.observeNext { _ in AppEnvironment.current.koala.trackSettingsView() }
  }
  // swiftlint:enable function_body_length
  // swiftlint:enable cyclomatic_complexity

  private let backingsTappedProperty = MutableProperty(false)
  public func backingsTapped(selected selected: Bool) {
    self.backingsTappedProperty.value = selected
  }
  private let betaFeedbackButtonTappedProperty = MutableProperty()
  public func betaFeedbackButtonTapped() {
    self.betaFeedbackButtonTappedProperty.value = ()
  }
  private let commentsTappedProperty = MutableProperty(false)
  public func commentsTapped(selected selected: Bool) {
    self.commentsTappedProperty.value = selected
  }
  private let findFriendsTappedProperty = MutableProperty()
  public func findFriendsTapped() {
    self.findFriendsTappedProperty.value = ()
  }
  private let followerTappedProperty = MutableProperty(false)
  public func followerTapped(selected selected: Bool) {
    self.followerTappedProperty.value = selected
  }
  private let friendActivityTappedProperty = MutableProperty(false)
  public func friendActivityTapped(selected selected: Bool) {
    self.friendActivityTappedProperty.value = selected
  }
  private let gamesNewsletterTappedProperty = MutableProperty(false)
  public func gamesNewsletterTapped(on on: Bool) {
    self.gamesNewsletterTappedProperty.value = on
  }
  private let happeningNewsletterTappedProperty = MutableProperty(false)
  public func happeningNewsletterTapped(on on: Bool) {
    self.happeningNewsletterTappedProperty.value = on
  }
  private let logoutCanceledProperty = MutableProperty()
  public func logoutCanceled() {
    self.logoutCanceledProperty.value = ()
  }
  private let logoutConfirmedProperty = MutableProperty()
  public func logoutConfirmed() {
    self.logoutConfirmedProperty.value = ()
  }
  private let logoutTappedProperty = MutableProperty()
  public func logoutTapped() {
    self.logoutTappedProperty.value = ()
  }
  private let manageProjectNotificationsTappedProperty = MutableProperty()
  public func manageProjectNotificationsTapped() {
    self.manageProjectNotificationsTappedProperty.value = ()
  }
  private let mobileBackingsTappedProperty = MutableProperty(false)
  public func mobileBackingsTapped(selected selected: Bool) {
    self.mobileBackingsTappedProperty.value = selected
  }
  private let mobileCommentsTappedProperty = MutableProperty(false)
  public func mobileCommentsTapped(selected selected: Bool) {
    self.mobileCommentsTappedProperty.value = selected
  }
  private let mobileFollowerTappedProperty = MutableProperty(false)
  public func mobileFollowerTapped(selected selected: Bool) {
    self.mobileFollowerTappedProperty.value = selected
  }
  private let mobileFriendActivityTappedProperty = MutableProperty(false)
  public func mobileFriendActivityTapped(selected selected: Bool) {
    self.mobileFriendActivityTappedProperty.value = selected
  }
  private let mobilePostLikesTappedProperty = MutableProperty(false)
  public func mobilePostLikesTapped(selected selected: Bool) {
    self.mobilePostLikesTappedProperty.value = selected
  }
  private let mobileUpdatesTappedProperty = MutableProperty(false)
  public func mobileUpdatesTapped(selected selected: Bool) {
    self.mobileUpdatesTappedProperty.value = selected
  }
  private let postLikesTappedProperty = MutableProperty(false)
  public func postLikesTapped(selected selected: Bool) {
    self.postLikesTappedProperty.value = selected
  }
  private let promoNewsletterTappedProperty = MutableProperty(false)
  public func promoNewsletterTapped(on on: Bool) {
    self.promoNewsletterTappedProperty.value = on
  }
  private let rateUsTappedProperty = MutableProperty()
  public func rateUsTapped() {
    self.rateUsTappedProperty.value = ()
  }
  private let updatesTappedProperty = MutableProperty(false)
  public func updatesTapped(selected selected: Bool) {
    self.updatesTappedProperty.value = selected
  }
  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }
  private let weeklyNewsletterTappedProperty = MutableProperty(false)
  public func weeklyNewsletterTapped(on on: Bool) {
    self.weeklyNewsletterTappedProperty.value = on
  }

  public let backingsSelected: Signal<Bool, NoError>
  public let betaFeedbackButtonHidden: Signal<Bool, NoError>
  public let commentsSelected: Signal<Bool, NoError>
  public let creatorNotificationsHidden: Signal<Bool, NoError>
  public let followerSelected: Signal<Bool, NoError>
  public let friendActivitySelected: Signal<Bool, NoError>
  public let gamesNewsletterOn: Signal<Bool, NoError>
  public let goToAppStoreRating: Signal<String, NoError>
  public let goToBetaFeedback: Signal<(), NoError>
  public let goToFindFriends: Signal<Void, NoError>
  public let goToManageProjectNotifications: Signal<Void, NoError>
  public let happeningNewsletterOn: Signal<Bool, NoError>
  public let logout: Signal<Void, NoError>
  public let mobileBackingsSelected: Signal<Bool, NoError>
  public let mobileCommentsSelected: Signal<Bool, NoError>
  public let mobileFollowerSelected: Signal<Bool, NoError>
  public let mobileFriendActivitySelected: Signal<Bool, NoError>
  public let mobilePostLikesSelected: Signal<Bool, NoError>
  public let mobileUpdatesSelected: Signal<Bool, NoError>
  public let postLikesSelected: Signal<Bool, NoError>
  public let projectNotificationsCount: Signal<String, NoError>
  public let promoNewsletterOn: Signal<Bool, NoError>
  public let showConfirmLogoutPrompt: Signal<(message: String, cancel: String, confirm: String), NoError>
  public let showOptInPrompt: Signal<String, NoError>
  public let unableToSaveError: Signal<String, NoError>
  public let updatesSelected: Signal<Bool, NoError>
  public let updateCurrentUser: Signal<User, NoError>
  public let weeklyNewsletterOn: Signal<Bool, NoError>
  public let versionText: Signal<String, NoError>

  public var inputs: SettingsViewModelInputs { return self }
  public var outputs: SettingsViewModelOutputs { return self }
}

private enum UserAttribute {
  case newsletter(Newsletter)
  case notification(Notification)

  private var lens: Lens<User, Bool?> {
    switch self {
    case let .newsletter(newsletter):
      switch newsletter {
      case .games:      return User.lens.newsletters.games
      case .happening:  return User.lens.newsletters.happening
      case .promo:      return User.lens.newsletters.promo
      case .weekly:     return User.lens.newsletters.weekly
      }
    case let .notification(notification):
      switch notification {
      case .backings:             return User.lens.notifications.backings
      case .comments:             return User.lens.notifications.comments
      case .follower:             return User.lens.notifications.follower
      case .friendActivity:       return User.lens.notifications.friendActivity
      case .mobileBackings:       return User.lens.notifications.mobileBackings
      case .mobileComments:       return User.lens.notifications.mobileComments
      case .mobileFollower:       return User.lens.notifications.mobileFollower
      case .mobileFriendActivity: return User.lens.notifications.mobileFriendActivity
      case .mobilePostLikes:      return User.lens.notifications.mobilePostLikes
      case .mobileUpdates:        return User.lens.notifications.mobileUpdates
      case .postLikes:            return User.lens.notifications.postLikes
      case .updates:              return User.lens.notifications.updates
      }
    }
  }
}

private enum Newsletter: String {
  case games
  case happening
  case promo
  case weekly

  private var displayableName: String {
    switch self {
    case .games:
      return Strings.profile_settings_newsletter_games()
    case .happening:
      return Strings.profile_settings_newsletter_happening()
    case .promo:
      return Strings.profile_settings_newsletter_promo()
    case .weekly:
      return Strings.profile_settings_newsletter_weekly()
    }
  }
}

private enum Notification {
  case backings
  case comments
  case follower
  case friendActivity
  case mobileBackings
  case mobileComments
  case mobileFollower
  case mobileFriendActivity
  case mobilePostLikes
  case mobileUpdates
  case postLikes
  case updates

  // Notification types for event tracking.
  private var type: String {
    switch self {
    case .backings, .mobileBackings:                return "New pledges"
    case .comments, .mobileComments:                return "New comments"
    case .follower, .mobileFollower:                return "New followers"
    case .friendActivity, .mobileFriendActivity:    return "Friend backs a project"
    case .postLikes, .mobilePostLikes:              return "New likes"
    case .updates, .mobileUpdates:                  return "Project updates"
    }
  }
}
// swiftlint:enable file_length
