import Foundation
import KsApi
import Models
import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result

// swiftlint:disable file_length
public protocol SettingsViewModelInputs {
  func backingsTapped(selected selected: Bool)
  func commentsTapped(selected selected: Bool)
  func findFriendsTapped()
  func followerTapped(selected selected: Bool)
  func friendActivityTapped(selected selected: Bool)
  func gamesNewsletterTapped(on on: Bool)
  func happeningNewsletterTapped(on on: Bool)
  func helpTypeTapped(helpType helpType: HelpType)
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
  var commentsSelected: Signal<Bool, NoError> { get }
  var creatorNotificationsHidden: Signal<Bool, NoError> { get }
  var followerSelected: Signal<Bool, NoError> { get }
  var friendActivitySelected: Signal<Bool, NoError> { get }
  var gamesNewsletterOn: Signal<Bool, NoError> { get }
  var goToAppStoreRating: Signal<String, NoError> { get }
  var goToFindFriends: Signal<Void, NoError> { get }
  var goToHelpType: Signal<HelpType, NoError> { get }
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
      gamesNewsletterTappedProperty.signal.map { (.games, $0) },
      happeningNewsletterTappedProperty.signal.map { (.happening, $0) },
      promoNewsletterTappedProperty.signal.map { (.promo, $0) },
      weeklyNewsletterTappedProperty.signal.map { (.weekly, $0) }
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
        env.errorMessages.first ??
          localizedString(key: "profile.settings.error", defaultValue: "Unable to save.")
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

    self.goToAppStoreRating = rateUsTappedProperty.signal
      .map { AppEnvironment.current.config?.iTunesLink ?? "" }

    self.goToFindFriends = findFriendsTappedProperty.signal
    self.goToHelpType = helpTypeTappedProperty.signal.ignoreNil()
    self.goToManageProjectNotifications = manageProjectNotificationsTappedProperty.signal

    self.showConfirmLogoutPrompt = logoutTappedProperty.signal
      .map {
        (message: localizedString(key: "profile.settings.logout_alert.message",
                                 defaultValue: "Are you sure you want to log out?"),
        cancel: localizedString(key: "profile.settings.logout_alert.cancel_button", defaultValue: "Cancel"),
        confirm: localizedString(key: "profile.settings.logout_alert.confirm_button", defaultValue: "Log out")
        )
    }

    self.logout = logoutConfirmedProperty.signal

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
        localizedString(
          key: "profile.settings.version_number",
          defaultValue: "Version %{version_number}",
          substitutions: ["version_number": AppEnvironment.current.mainBundle.bundleShortVersionString]
        )
    }

    newsletterOn.observeNext { _, on in AppEnvironment.current.koala.trackNewsletterToggle(on, project: nil) }

    self.helpTypeTappedProperty.signal
      .filter { $0 == HelpType.Contact }
      .observeNext { _ in AppEnvironment.current.koala.trackContactEmailOpen() }

    self.rateUsTappedProperty.signal
      .observeNext { _ in AppEnvironment.current.koala.trackAppStoreRatingOpen() }

    self.viewDidLoadProperty.signal.observeNext { _ in AppEnvironment.current.koala.trackSettingsView() }
  }
  // swiftlint:enable function_body_length
  // swiftlint:enable cyclomatic_complexity

  private let backingsTappedProperty = MutableProperty(false)
  public func backingsTapped(selected selected: Bool) {
    self.backingsTappedProperty.value = selected
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
  private let helpTypeTappedProperty = MutableProperty<HelpType?>(nil)
  public func helpTypeTapped(helpType helpType: HelpType) {
    self.helpTypeTappedProperty.value = helpType
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
  public let commentsSelected: Signal<Bool, NoError>
  public let creatorNotificationsHidden: Signal<Bool, NoError>
  public let followerSelected: Signal<Bool, NoError>
  public let friendActivitySelected: Signal<Bool, NoError>
  public let gamesNewsletterOn: Signal<Bool, NoError>
  public let goToAppStoreRating: Signal<String, NoError>
  public let goToFindFriends: Signal<Void, NoError>
  public let goToHelpType: Signal<HelpType, NoError>
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

// swiftlint:disable type_name
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

private enum Newsletter {
  case games
  case happening
  case promo
  case weekly

  private var displayableName: String {
    switch self {
    case .games:
      return localizedString(key: "profile.settings.newsletter.games",
                             defaultValue: "Kickstarter Loves Games")
    case .happening:
      return localizedString(key: "profile.settings.newsletter.happening",
                             defaultValue: "Happening Now")
    case .promo:
      return localizedString(key: "profile.settings.newsletter.promo",
                             defaultValue: "Kickstarter News and Events")
    case .weekly:
      return localizedString(key: "profile.settings.newsletter.weekly",
                             defaultValue: "Projects We Love")
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
}
// swiftlint:enable type_name
// swiftlint:enable file_length
