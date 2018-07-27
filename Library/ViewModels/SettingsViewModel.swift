import Foundation
import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol SettingsViewModelInputs {
  func artsAndCultureNewsletterTapped(on: Bool)
  func deleteAccountTapped()
  func exportDataTapped()
  func followingSwitchTapped(on: Bool, didShowPrompt: Bool)
  func gamesNewsletterTapped(on: Bool)
  func happeningNewsletterTapped(on: Bool)
  func inventNewsletterTapped(on: Bool)
  func logoutCanceled()
  func logoutConfirmed()
  func logoutTapped()
  func privateProfileSwitchDidChange(isOn: Bool)
  func promoNewsletterTapped(on: Bool)
  func rateUsTapped()
  func recommendationsTapped(on: Bool)
  func viewDidLoad()
  func weeklyNewsletterTapped(on: Bool)
}

public protocol SettingsViewModelOutputs {
  var artsAndCultureNewsletterOn: Signal<Bool, NoError> { get }
  var exportDataButtonEnabled: Signal<Bool, NoError> { get }
  var exportDataExpirationDate: Signal<String, NoError> { get }
  var exportDataLoadingIndicator: Signal<Bool, NoError> { get }
  var exportDataText: Signal<String, NoError> { get }
  var followingPrivacyOn: Signal<Bool, NoError> { get }
  var gamesNewsletterOn: Signal<Bool, NoError> { get }
  var goToAppStoreRating: Signal<String, NoError> { get }
  var goToDeleteAccountBrowser: Signal<URL, NoError> { get }
  var happeningNewsletterOn: Signal<Bool, NoError> { get }
  var inventNewsletterOn: Signal<Bool, NoError> { get }
  var logoutWithParams: Signal<DiscoveryParams, NoError> { get }
  var privateProfileEnabled: Signal<Bool, NoError> { get }
  var promoNewsletterOn: Signal<Bool, NoError> { get }
  var requestExportData: Signal<(), NoError> { get }
  var recommendationsOn: Signal<Bool, NoError> { get }
  var showConfirmLogoutPrompt: Signal<(message: String, cancel: String, confirm: String), NoError> { get }
  var showDataExpirationAndChevron: Signal<Bool, NoError> { get }
  var showPrivacyFollowingPrompt: Signal<(), NoError> { get }
  var showOptInPrompt: Signal<String, NoError> { get }
  var unableToSaveError: Signal<String, NoError> { get }
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
        (UserAttribute.notification(UserAttribute.Notification.pledgeActivity), $0)
      },
      self.commentsTappedProperty.signal.map {
        (UserAttribute.notification(UserAttribute.Notification.comments), $0)
      },
      self.followerTappedProperty.signal.map {
        (UserAttribute.notification(UserAttribute.Notification.follower), $0)
      },
      self.friendActivityTappedProperty.signal.map {
        (UserAttribute.notification(UserAttribute.Notification.friendActivity), $0)
      },
      self.messagesTappedProperty.signal.map {
        (UserAttribute.notification(UserAttribute.Notification.messages), $0)
      },
      self.mobileBackingsTappedProperty.signal.map {
        (UserAttribute.notification(UserAttribute.Notification.mobilePledgeActivity), $0)
      },
      self.mobileCommentsTappedProperty.signal.map {
        (UserAttribute.notification(UserAttribute.Notification.mobileComments), $0)
      },
      self.mobileFollowerTappedProperty.signal.map {
        (UserAttribute.notification(UserAttribute.Notification.mobileFollower), $0)
      },
      self.mobileFriendActivityTappedProperty.signal.map {
        (UserAttribute.notification(UserAttribute.Notification.mobileFriendActivity), $0)
      },
      self.mobileMessagesTappedProperty.signal.map {
        (UserAttribute.notification(UserAttribute.Notification.mobileMessages), $0)
      },
      self.mobilePostLikesTappedProperty.signal.map {
        (UserAttribute.notification(UserAttribute.Notification.mobilePostLikes), $0)
      },
      self.mobileUpdatesTappedProperty.signal.map {
        (UserAttribute.notification(UserAttribute.Notification.mobileUpdates), $0)
      },
      self.postLikesTappedProperty.signal.map {
        (UserAttribute.notification(UserAttribute.Notification.postLikes), $0)
      },
      self.privateProfileEnabledProperty.signal.negate().map {
        (UserAttribute.privacy(UserAttribute.Privacy.showPublicProfile), $0)
      },
      self.creatorTipsProperty.signal.map {
        (UserAttribute.notification(UserAttribute.Notification.creatorTips), $0)
      },
      self.updatesTappedProperty.signal.map {
        (UserAttribute.notification(UserAttribute.Notification.updates), $0)
      },
      self.followingSwitchTappedProperty.signal
        .filter { (on, didShowPrompt) in
          didShowPrompt == true || (on == true && didShowPrompt == false)
        }
        .map {
        (UserAttribute.privacy(UserAttribute.Privacy.following), $0.0)
      },
      self.recommendationsTappedProperty.signal.map {
        (UserAttribute.privacy(UserAttribute.Privacy.recommendations), !$0)
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

    self.goToAppStoreRating = self.rateUsTappedProperty.signal
      .map { AppEnvironment.current.config?.iTunesLink ?? "" }

    self.goToDeleteAccountBrowser = self.deleteAccountTappedProperty.signal
      .map {
        AppEnvironment.current.apiService.serverConfig.webBaseUrl.appendingPathComponent("/profile/destroy")
      }

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

    self.logoutWithParams = self.logoutConfirmedProperty.signal
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

    self.privateProfileEnabled = self.updateCurrentUser
      .map { $0.showPublicProfile }.skipNil().negate().skipRepeats()
    self.recommendationsOn = self.updateCurrentUser
      .map { $0.optedOutOfRecommendations }.skipNil().map { $0 ? false : true }.skipRepeats()

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

    let exportEnvelope = initialUser
      .switchMap { _ in
        AppEnvironment.current.apiService.exportDataState()
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .demoteErrors()
    }

    self.exportDataLoadingIndicator = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(false),
      exportEnvelope.map { $0.state == .processing },
      self.exportDataTappedProperty.signal.mapConst(true)
    )

    self.exportDataText = self.exportDataLoadingIndicator.signal
      .map { $0 ? Strings.Preparing_your_personal_data() : Strings.Download_your_personal_data() }

    self.exportDataExpirationDate = exportEnvelope
      .map { dateFormatter(for: $0.expiresAt, state: $0.state) }

    self.exportDataButtonEnabled = self.exportDataLoadingIndicator.signal
      .map { !$0 }

    self.showDataExpirationAndChevron = self.exportDataLoadingIndicator.signal
      .map { $0 }

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
          .mobilePledgeActivity,
          .mobileComments, .mobileFollower, .mobileFriendActivity, .mobilePostLikes, .mobileMessages,
               .mobileUpdates:
            AppEnvironment.current.koala.trackChangePushNotification(type: notification.trackingString,
                                                                     on: on)
          case .pledgeActivity,
               .comments, .follower, .friendActivity, .messages, .postLikes, .creatorTips, .updates:
            AppEnvironment.current.koala.trackChangeEmailNotification(type: notification.trackingString,
                                                                      on: on)
          default: break
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
  public let exportDataLoadingIndicator: Signal<Bool, NoError>
  public let exportDataText: Signal<String, NoError>
  public let exportDataExpirationDate: Signal<String, NoError>
  public let exportDataButtonEnabled: Signal<Bool, NoError>
  public let followingPrivacyOn: Signal<Bool, NoError>
  public let gamesNewsletterOn: Signal<Bool, NoError>
  public let goToAppStoreRating: Signal<String, NoError>
  public let goToDeleteAccountBrowser: Signal<URL, NoError>
  public let happeningNewsletterOn: Signal<Bool, NoError>
  public let inventNewsletterOn: Signal<Bool, NoError>
  public let logoutWithParams: Signal<DiscoveryParams, NoError>
  public let privateProfileEnabled: Signal<Bool, NoError>
  public let promoNewsletterOn: Signal<Bool, NoError>
  public let requestExportData: Signal<(), NoError>
  public let recommendationsOn: Signal<Bool, NoError>
  public let showConfirmLogoutPrompt: Signal<(message: String, cancel: String, confirm: String), NoError>
  public let showDataExpirationAndChevron: Signal<Bool, NoError>
  public let showOptInPrompt: Signal<String, NoError>
  public let showPrivacyFollowingPrompt: Signal<(), NoError>
  public let unableToSaveError: Signal<String, NoError>
  public let updateCurrentUser: Signal<User, NoError>
  public let weeklyNewsletterOn: Signal<Bool, NoError>
  public let versionText: Signal<String, NoError>

  public var inputs: SettingsViewModelInputs { return self }
  public var outputs: SettingsViewModelOutputs { return self }
}

private func dateFormatter(for dateString: String?, state: ExportDataEnvelope.State) -> String {
  guard let isoDate = dateString else { return "" }
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:sZ"
  guard let date = dateFormatter.date(from: isoDate) else { return "" }

  let expirationDate = Format.date(secondsInUTC: date.timeIntervalSince1970, template: "MMM d, yyyy")
  let expirationTime = Format.date(secondsInUTC: date.timeIntervalSince1970, template: "h:mm a")

  if state == .expired {
    return ""
  } else { return Strings.Expires_date_at_time(date: expirationDate, time: expirationTime) }
}
