import Foundation
import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol SettingsViewModelInputs {
  func artsAndCultureNewsletterTapped(on: Bool)
  func backingsTapped(selected: Bool)
  func betaFeedbackButtonTapped()
  func commentsTapped(selected: Bool)
  func creatorTipsTapped(selected: Bool)
  func deleteAccountTapped()
  func emailFrequencyTapped()
  func exportDataTapped()
  func environmentSwitcherButtonTapped(environment: ServerConfigType)
  func findFriendsTapped()
  func followerTapped(selected: Bool)
  func followingSwitchTapped(on: Bool, didShowPrompt: Bool)
  func friendActivityTapped(selected: Bool)
  func gamesNewsletterTapped(on: Bool)
  func happeningNewsletterTapped(on: Bool)
  func inventNewsletterTapped(on: Bool)
  func logoutCanceled()
  func logoutConfirmed()
  func logoutTapped()
  func manageProjectNotificationsTapped()
  func messagesTapped(selected: Bool)
  func mobileBackingsTapped(selected: Bool)
  func mobileCommentsTapped(selected: Bool)
  func mobileFollowerTapped(selected: Bool)
  func mobileFriendActivityTapped(selected: Bool)
  func mobileMessagesTapped(selected: Bool)
  func mobilePostLikesTapped(selected: Bool)
  func mobileUpdatesTapped(selected: Bool)
  func postLikesTapped(selected: Bool)
  func privateProfileSwitchDidChange(isOn: Bool)
  func promoNewsletterTapped(on: Bool)
  func rateUsTapped()
  func recommendationsTapped(on: Bool)
  func setCurrentLanguage(_ language: Language)
  func updatesTapped(selected: Bool)
  func viewDidLoad()
  func weeklyNewsletterTapped(on: Bool)
}

public protocol SettingsViewModelOutputs {
  var artsAndCultureNewsletterOn: Signal<Bool, NoError> { get }
  var backingsSelected: Signal<Bool, NoError> { get }
  var betaToolsHidden: Signal<Bool, NoError> { get }
  var commentsSelected: Signal<Bool, NoError> { get }
  var creatorNotificationsHidden: Signal<Bool, NoError> { get }
  var creatorTipsSelected: Signal<Bool, NoError> { get }
  var currentLanguage: Signal<Language, NoError> { get }
  var emailFrequencyButtonEnabled: Signal<Bool, NoError> { get }
  var environmentSwitcherButtonTitle: Signal<String, NoError> { get }
  var followerSelected: Signal<Bool, NoError> { get }
  var followingPrivacyOn: Signal<Bool, NoError> { get }
  var friendActivitySelected: Signal<Bool, NoError> { get }
  var gamesNewsletterOn: Signal<Bool, NoError> { get }
  var goToAppStoreRating: Signal<String, NoError> { get }
  var goToBetaFeedback: Signal<(), NoError> { get }
  var goToDeleteAccountBrowser: Signal<URL, NoError> { get }
  var goToEmailFrequency: Signal<User, NoError> { get }
  var goToFindFriends: Signal<Void, NoError> { get }
  var goToManageProjectNotifications: Signal<Void, NoError> { get }
  var happeningNewsletterOn: Signal<Bool, NoError> { get }
  var inventNewsletterOn: Signal<Bool, NoError> { get }
  var logoutWithParams: Signal<DiscoveryParams, NoError> { get }
  var manageProjectNotificationsButtonAccessibilityHint: Signal<String, NoError> { get }
  var messagesSelected: Signal<Bool, NoError> { get }
  var mobileBackingsSelected: Signal<Bool, NoError> { get }
  var mobileCommentsSelected: Signal<Bool, NoError> { get }
  var mobileFollowerSelected: Signal<Bool, NoError> { get }
  var mobileFriendActivitySelected: Signal<Bool, NoError> { get }
  var mobileMessagesSelected: Signal<Bool, NoError> { get }
  var mobilePostLikesSelected: Signal<Bool, NoError> { get }
  var mobileUpdatesSelected: Signal<Bool, NoError> { get }
  var postLikesSelected: Signal<Bool, NoError> { get }
  var privateProfileEnabled: Signal<Bool, NoError> { get }
  var projectNotificationsCount: Signal<String, NoError> { get }
  var promoNewsletterOn: Signal<Bool, NoError> { get }
  var requestExportData: Signal<(), NoError> { get }
  var recommendationsOn: Signal<Bool, NoError> { get }
  var showConfirmLogoutPrompt: Signal<(message: String, cancel: String, confirm: String), NoError> { get }
  var showPrivacyFollowingPrompt: Signal<(), NoError> { get }
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

  public init() {
    let initialUser = viewDidLoadProperty.signal
      .flatMap {
        AppEnvironment.current.apiService.fetchUserSelf()
          .wrapInOptional()
          .prefix(value: AppEnvironment.current.currentUser)
          .demoteErrors()
      }
      .skipNil()

    self.followingPrivacyOn = Signal.merge(
      initialUser.map { $0.social ?? true }.skipRepeats(),
      self.followingSwitchTappedProperty.signal.map { $0.0 }
    )

    let newsletterOn: Signal<(Newsletter, Bool), NoError> = .merge(
      self.artsAndCultureNewsletterTappedProperty.signal.map { (.arts, $0) },
      self.gamesNewsletterTappedProperty.signal.map { (.games, $0) },
      self.happeningNewsletterTappedProperty.signal.map { (.happening, $0) },
      self.inventNewsletterTappedProperty.signal.map { (.invent, $0) },
      self.promoNewsletterTappedProperty.signal.map { (.promo, $0) },
      self.weeklyNewsletterTappedProperty.signal.map { (.weekly, $0) }
    )

    let userAttributeChanged: Signal<(UserAttribute, Bool), NoError> = Signal.merge(
      self.artsAndCultureNewsletterTappedProperty.signal.map {
        (UserAttribute.newsletter(Newsletter.arts), $0)
      },
      self.gamesNewsletterTappedProperty.signal.map {
        (UserAttribute.newsletter(Newsletter.games), $0)
      },
      self.happeningNewsletterTappedProperty.signal.map {
        (UserAttribute.newsletter(Newsletter.happening), $0)
      },
      self.inventNewsletterTappedProperty.signal.map {
        (UserAttribute.newsletter(Newsletter.invent), $0)
      },
      self.promoNewsletterTappedProperty.signal.map {
        (UserAttribute.newsletter(Newsletter.promo), $0)
      },
      self.weeklyNewsletterTappedProperty.signal.map {
        (UserAttribute.newsletter(Newsletter.weekly), $0)
      },
      self.backingsTappedProperty.signal.map {
        (UserAttribute.notification(Notification.backings), $0)
      },
      self.commentsTappedProperty.signal.map {
        (UserAttribute.notification(Notification.comments), $0)
      },
      self.followerTappedProperty.signal.map {
        (UserAttribute.notification(Notification.follower), $0)
      },
      self.friendActivityTappedProperty.signal.map {
        (UserAttribute.notification(Notification.friendActivity), $0)
      },
      self.messagesTappedProperty.signal.map {
        (UserAttribute.notification(Notification.messages), $0)
      },
      self.mobileBackingsTappedProperty.signal.map {
        (UserAttribute.notification(Notification.mobileBackings), $0)
      },
      self.mobileCommentsTappedProperty.signal.map {
        (UserAttribute.notification(Notification.mobileComments), $0)
      },
      self.mobileFollowerTappedProperty.signal.map {
        (UserAttribute.notification(Notification.mobileFollower), $0)
      },
      self.mobileFriendActivityTappedProperty.signal.map {
        (UserAttribute.notification(Notification.mobileFriendActivity), $0)
      },
      self.mobileMessagesTappedProperty.signal.map {
        (UserAttribute.notification(Notification.mobileMessages), $0)
      },
      self.mobilePostLikesTappedProperty.signal.map {
        (UserAttribute.notification(Notification.mobilePostLikes), $0)
      },
      self.mobileUpdatesTappedProperty.signal.map {
        (UserAttribute.notification(Notification.mobileUpdates), $0)
      },
      self.postLikesTappedProperty.signal.map {
        (UserAttribute.notification(Notification.postLikes), $0)
      },
      self.privateProfileEnabledProperty.signal.negate().map {
        (UserAttribute.privacy(Privacy.showPublicProfile), $0)
      },
      self.creatorTipsProperty.signal.map {
        (UserAttribute.notification(Notification.creatorTips), $0)
      },
      self.updatesTappedProperty.signal.map {
        (UserAttribute.notification(Notification.updates), $0)
      },
      self.followingSwitchTappedProperty.signal
        .filter { (on, didShowPrompt) in
          didShowPrompt == true || (on == true && didShowPrompt == false)
        }
        .map {
        (UserAttribute.privacy(Privacy.following), $0.0)
      },
      self.recommendationsTappedProperty.signal.map {
        (UserAttribute.privacy(Privacy.recommendations), !$0)
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

    self.projectNotificationsCount = self.updateCurrentUser
      .map { Format.wholeNumber($0.stats.backedProjectsCount ?? 0) }
      .skipRepeats()

    self.goToAppStoreRating = self.rateUsTappedProperty.signal
      .map { AppEnvironment.current.config?.iTunesLink ?? "" }

    self.goToDeleteAccountBrowser = self.deleteAccountTappedProperty.signal
      .map {
        AppEnvironment.current.apiService.serverConfig.webBaseUrl.appendingPathComponent("/profile/destroy")
      }

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

    self.showPrivacyFollowingPrompt = self.followingSwitchTappedProperty.signal
      .filter { $0.0 == false && $0.1 == false }
      .ignoreValues()

    self.logoutWithParams = Signal.merge (
      self.logoutConfirmedProperty.signal,
      self.environmentSwitcherButtonTappedProperty.signal.skipNil().ignoreValues()
    )
    .map { .defaults
      |> DiscoveryParams.lens.includePOTD .~ true
      |> DiscoveryParams.lens.sort .~ .magic
    }

    self.showOptInPrompt = newsletterOn
      .filter { _, on in AppEnvironment.current.config?.countryCode == "DE" && on }
      .map { newsletter, _ in newsletter.displayableName }

    self.gamesNewsletterOn = self.updateCurrentUser.map { $0.newsletters.games }.skipNil().skipRepeats()
    self.happeningNewsletterOn = self.updateCurrentUser
      .map { $0.newsletters.happening }.skipNil().skipRepeats()
    self.promoNewsletterOn = self.updateCurrentUser.map { $0.newsletters.promo }.skipNil().skipRepeats()
    self.weeklyNewsletterOn = self.updateCurrentUser.map { $0.newsletters.weekly }.skipNil().skipRepeats()
    self.inventNewsletterOn = self.updateCurrentUser.map { $0.newsletters.invent }.skipNil().skipRepeats()
    self.artsAndCultureNewsletterOn = self.updateCurrentUser
      .map { $0.newsletters.arts }.skipNil().skipRepeats()

    self.backingsSelected = self.updateCurrentUser.map { $0.notifications.backings }.skipNil().skipRepeats()
    self.creatorTipsSelected = self.updateCurrentUser
      .map { $0.notifications.creatorTips }.skipNil().skipRepeats()
    self.commentsSelected = self.updateCurrentUser
      .map { $0.notifications.comments }.skipNil().skipRepeats()
    self.followerSelected = self.updateCurrentUser
      .map { $0.notifications.follower }.skipNil().skipRepeats()
    self.friendActivitySelected = self.updateCurrentUser
      .map { $0.notifications.friendActivity }.skipNil().skipRepeats()
    self.messagesSelected = self.updateCurrentUser
      .map { $0.notifications.messages }.skipNil().skipRepeats()
    self.mobileBackingsSelected = self.updateCurrentUser
      .map { $0.notifications.mobileBackings }.skipNil().skipRepeats()
    self.mobileCommentsSelected = self.updateCurrentUser
      .map { $0.notifications.mobileComments }.skipNil().skipRepeats()
    self.mobileFollowerSelected = self.updateCurrentUser
      .map { $0.notifications.mobileFollower }.skipNil().skipRepeats()
    self.mobileFriendActivitySelected = self.updateCurrentUser
      .map { $0.notifications.mobileFriendActivity }.skipNil().skipRepeats()
    self.mobileMessagesSelected = self.updateCurrentUser
      .map { $0.notifications.mobileMessages }.skipNil().skipRepeats()
    self.mobilePostLikesSelected = self.updateCurrentUser
      .map { $0.notifications.mobilePostLikes }.skipNil().skipRepeats()
    self.mobileUpdatesSelected = self.updateCurrentUser
      .map { $0.notifications.mobileUpdates }.skipNil().skipRepeats()
    self.privateProfileEnabled = self.updateCurrentUser
      .map { $0.showPublicProfile }.skipNil().negate().skipRepeats()
    self.postLikesSelected = self.updateCurrentUser
      .map { $0.notifications.postLikes }.skipNil().skipRepeats()
    self.updatesSelected = self.updateCurrentUser
      .map { $0.notifications.updates }.skipNil().skipRepeats()
    self.recommendationsOn = self.updateCurrentUser
      .map { $0.optedOutOfRecommendations }.skipNil().map { $0 ? false : true }.skipRepeats()

    self.emailFrequencyButtonEnabled = self.backingsSelected

    self.currentLanguage = self.currentLanguageProperty.signal
      .skipRepeats()
      .filter { AppEnvironment.current.language != $0 }

    self.environmentSwitcherButtonTappedProperty.signal.skipNil().observeValues { config in
        AppEnvironment.updateServerConfig(config)
    }

    self.environmentSwitcherButtonTitle = viewDidLoadProperty.signal
      .takeWhen(self.environmentSwitcherButtonTappedProperty.signal)
      .map {
        "Change Environment - \(AppEnvironment.current.apiService.serverConfig.environmentName)"
    }.skipRepeats()

    self.goToEmailFrequency = self.updateCurrentUser
      .takeWhen(self.emailFrequencyTappedProperty.signal)

    self.versionText = viewDidLoadProperty.signal
      .map {
        let versionString = Strings.profile_settings_version_number(
          version_number: AppEnvironment.current.mainBundle.shortVersionString
          )
        let build = AppEnvironment.current.mainBundle.isRelease
          ? ""
          : " #\(AppEnvironment.current.mainBundle.version)"
        return "\(versionString)\(build)"
    }

    self.requestExportData = self.exportDataTappedProperty.signal
      .switchMap {
        AppEnvironment.current.apiService.exportData()
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .demoteErrors()
      }
      .ignoreValues()

    self.betaToolsHidden = self.viewDidLoadProperty.signal
      .map {
        !AppEnvironment.current.mainBundle.isDebug
        && !AppEnvironment.current.mainBundle.isAlpha
        && !AppEnvironment.current.mainBundle.isBeta
    }

    // a11y
    self.manageProjectNotificationsButtonAccessibilityHint = self.updateCurrentUser
      .map { Strings.profile_project_count_projects_backed(project_count: $0.stats.backedProjectsCount ?? 0) }

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

    self.logoutCanceledProperty.signal
      .observeValues { _ in AppEnvironment.current.koala.trackCancelLogoutModal() }

    self.logoutConfirmedProperty.signal
      .observeValues { _ in AppEnvironment.current.koala.trackConfirmLogoutModal() }

    self.goToAppStoreRating
      .observeValues { _ in AppEnvironment.current.koala.trackAppStoreRatingOpen() }

    self.showConfirmLogoutPrompt
      .observeValues { _ in AppEnvironment.current.koala.trackLogoutModal() }

    self.viewDidLoadProperty.signal.observeValues { _ in AppEnvironment.current.koala.trackSettingsView() }
  }

  fileprivate let artsAndCultureNewsletterTappedProperty = MutableProperty(false)
  public func artsAndCultureNewsletterTapped(on: Bool) {
    self.artsAndCultureNewsletterTappedProperty.value = on
  }
  fileprivate let backingsTappedProperty = MutableProperty(false)
  public func backingsTapped(selected: Bool) {
    self.backingsTappedProperty.value = selected
  }
  fileprivate let betaFeedbackButtonTappedProperty = MutableProperty(())
  public func betaFeedbackButtonTapped() {
    self.betaFeedbackButtonTappedProperty.value = ()
  }
  fileprivate let commentsTappedProperty = MutableProperty(false)
  public func commentsTapped(selected: Bool) {
    self.commentsTappedProperty.value = selected
  }
  fileprivate let creatorTipsProperty = MutableProperty(false)
  public func creatorTipsTapped(selected: Bool) {
    self.creatorTipsProperty.value = selected
  }
  fileprivate let creatorDigestTappedProperty = MutableProperty(false)
  public func creatorDigestTapped(on: Bool) {
    self.creatorDigestTappedProperty.value = on
  }
  fileprivate let deleteAccountTappedProperty = MutableProperty(())
  public func deleteAccountTapped() {
    self.deleteAccountTappedProperty.value = ()
  }
  fileprivate let individualEmailTappedProperty = MutableProperty(false)
  public func individualEmailTapped(on: Bool) {
    self.individualEmailTappedProperty.value = on
  }
  fileprivate let emailFrequencyTappedProperty = MutableProperty(())
  public func emailFrequencyTapped() {
    self.emailFrequencyTappedProperty.value = ()
  }

  fileprivate let exportDataTappedProperty = MutableProperty(())
  public func exportDataTapped() {
    self.exportDataTappedProperty.value = ()
  }

  fileprivate let environmentSwitcherButtonTappedProperty = MutableProperty<ServerConfig?>(nil)
  public func environmentSwitcherButtonTapped(environment: ServerConfigType) {
    self.environmentSwitcherButtonTappedProperty.value = environment as? ServerConfig
  }
  fileprivate let findFriendsTappedProperty = MutableProperty(())
  public func findFriendsTapped() {
    self.findFriendsTappedProperty.value = ()
  }
  fileprivate let followerTappedProperty = MutableProperty(false)
  public func followerTapped(selected: Bool) {
    self.followerTappedProperty.value = selected
  }
  fileprivate let followingSwitchTappedProperty = MutableProperty((false, false))
  public func followingSwitchTapped(on: Bool, didShowPrompt: Bool) {
    self.followingSwitchTappedProperty.value = (on, didShowPrompt)
  }
  fileprivate let friendActivityTappedProperty = MutableProperty(false)
  public func friendActivityTapped(selected: Bool) {
    self.friendActivityTappedProperty.value = selected
  }
  fileprivate let gamesNewsletterTappedProperty = MutableProperty(false)
  public func gamesNewsletterTapped(on: Bool) {
    self.gamesNewsletterTappedProperty.value = on
  }
  fileprivate let happeningNewsletterTappedProperty = MutableProperty(false)
  public func happeningNewsletterTapped(on: Bool) {
    self.happeningNewsletterTappedProperty.value = on
  }
  fileprivate let inventNewsletterTappedProperty = MutableProperty(false)
  public func inventNewsletterTapped(on: Bool) {
    self.inventNewsletterTappedProperty.value = on
  }

  fileprivate let currentLanguageProperty = MutableProperty(AppEnvironment.current.language)
  public func setCurrentLanguage(_ language: Language) {
    self.currentLanguageProperty.value = language
  }

  fileprivate let logoutCanceledProperty = MutableProperty(())
  public func logoutCanceled() {
    self.logoutCanceledProperty.value = ()
  }
  fileprivate let logoutConfirmedProperty = MutableProperty(())
  public func logoutConfirmed() {
    self.logoutConfirmedProperty.value = ()
  }
  fileprivate let logoutTappedProperty = MutableProperty(())
  public func logoutTapped() {
    self.logoutTappedProperty.value = ()
  }
  fileprivate let manageProjectNotificationsTappedProperty = MutableProperty(())
  public func manageProjectNotificationsTapped() {
    self.manageProjectNotificationsTappedProperty.value = ()
  }
  fileprivate let messagesTappedProperty = MutableProperty(false)
  public func messagesTapped(selected: Bool) {
    self.messagesTappedProperty.value = selected
  }
  fileprivate let mobileBackingsTappedProperty = MutableProperty(false)
  public func mobileBackingsTapped(selected: Bool) {
    self.mobileBackingsTappedProperty.value = selected
  }
  fileprivate let mobileCommentsTappedProperty = MutableProperty(false)
  public func mobileCommentsTapped(selected: Bool) {
    self.mobileCommentsTappedProperty.value = selected
  }
  fileprivate let mobileFollowerTappedProperty = MutableProperty(false)
  public func mobileFollowerTapped(selected: Bool) {
    self.mobileFollowerTappedProperty.value = selected
  }
  fileprivate let mobileFriendActivityTappedProperty = MutableProperty(false)
  public func mobileFriendActivityTapped(selected: Bool) {
    self.mobileFriendActivityTappedProperty.value = selected
  }
  fileprivate let mobileMessagesTappedProperty = MutableProperty(false)
  public func mobileMessagesTapped(selected: Bool) {
    self.mobileMessagesTappedProperty.value = selected
  }
  fileprivate let mobilePostLikesTappedProperty = MutableProperty(false)
  public func mobilePostLikesTapped(selected: Bool) {
    self.mobilePostLikesTappedProperty.value = selected
  }
  fileprivate let mobileUpdatesTappedProperty = MutableProperty(false)
  public func mobileUpdatesTapped(selected: Bool) {
    self.mobileUpdatesTappedProperty.value = selected
  }
  fileprivate let postLikesTappedProperty = MutableProperty(false)
  public func postLikesTapped(selected: Bool) {
    self.postLikesTappedProperty.value = selected
  }

  fileprivate let privateProfileEnabledProperty = MutableProperty(true)
  public func privateProfileSwitchDidChange(isOn: Bool) {
    self.privateProfileEnabledProperty.value = isOn
  }

  fileprivate let promoNewsletterTappedProperty = MutableProperty(false)
  public func promoNewsletterTapped(on: Bool) {
    self.promoNewsletterTappedProperty.value = on
  }
  fileprivate let recommendationsTappedProperty = MutableProperty(false)
  public func recommendationsTapped(on: Bool) {
    self.recommendationsTappedProperty.value = on
  }
  fileprivate let rateUsTappedProperty = MutableProperty(())
  public func rateUsTapped() {
    self.rateUsTappedProperty.value = ()
  }

  fileprivate let updatesTappedProperty = MutableProperty(false)
  public func updatesTapped(selected: Bool) {
    self.updatesTappedProperty.value = selected
  }
  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }
  fileprivate let weeklyNewsletterTappedProperty = MutableProperty(false)
  public func weeklyNewsletterTapped(on: Bool) {
    self.weeklyNewsletterTappedProperty.value = on
  }

  public let artsAndCultureNewsletterOn: Signal<Bool, NoError>
  public let backingsSelected: Signal<Bool, NoError>
  public let betaToolsHidden: Signal<Bool, NoError>
  public let commentsSelected: Signal<Bool, NoError>
  public let creatorNotificationsHidden: Signal<Bool, NoError>
  public let creatorTipsSelected: Signal<Bool, NoError>
  public let currentLanguage: Signal<Language, NoError>
  public let emailFrequencyButtonEnabled: Signal<Bool, NoError>
  public let environmentSwitcherButtonTitle: Signal<String, NoError>
  public let followerSelected: Signal<Bool, NoError>
  public let followingPrivacyOn: Signal<Bool, NoError>
  public let friendActivitySelected: Signal<Bool, NoError>
  public let gamesNewsletterOn: Signal<Bool, NoError>
  public let goToAppStoreRating: Signal<String, NoError>
  public let goToBetaFeedback: Signal<(), NoError>
  public let goToDeleteAccountBrowser: Signal<URL, NoError>
  public let goToEmailFrequency: Signal<User, NoError>
  public let goToFindFriends: Signal<Void, NoError>
  public let goToManageProjectNotifications: Signal<Void, NoError>
  public let happeningNewsletterOn: Signal<Bool, NoError>
  public let inventNewsletterOn: Signal<Bool, NoError>
  public let logoutWithParams: Signal<DiscoveryParams, NoError>
  public var manageProjectNotificationsButtonAccessibilityHint: Signal<String, NoError>
  public let messagesSelected: Signal<Bool, NoError>
  public let mobileBackingsSelected: Signal<Bool, NoError>
  public let mobileCommentsSelected: Signal<Bool, NoError>
  public let mobileFollowerSelected: Signal<Bool, NoError>
  public let mobileFriendActivitySelected: Signal<Bool, NoError>
  public let mobileMessagesSelected: Signal<Bool, NoError>
  public let mobilePostLikesSelected: Signal<Bool, NoError>
  public let mobileUpdatesSelected: Signal<Bool, NoError>
  public let postLikesSelected: Signal<Bool, NoError>
  public let privateProfileEnabled: Signal<Bool, NoError>
  public let projectNotificationsCount: Signal<String, NoError>
  public let promoNewsletterOn: Signal<Bool, NoError>
  public let requestExportData: Signal<(), NoError>
  public let recommendationsOn: Signal<Bool, NoError>
  public let showConfirmLogoutPrompt: Signal<(message: String, cancel: String, confirm: String), NoError>
  public let showOptInPrompt: Signal<String, NoError>
  public let showPrivacyFollowingPrompt: Signal<(), NoError>
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
