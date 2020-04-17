import KsApi
import Prelude
import ReactiveSwift

public protocol SettingsNotificationCellViewModelInputs {
  func didTapPushNotificationsButton(selected: Bool)
  func didTapEmailNotificationsButton(selected: Bool)
  func configure(with cellValue: SettingsNotificationCellValue)
}

public protocol SettingsNotificationCellViewModelOutputs {
  var enableButtonAnimation: Signal<Bool, Never> { get }
  var emailNotificationsButtonAccessibilityLabel: Signal<String, Never> { get }
  var emailNotificationsEnabled: Signal<Bool, Never> { get }
  var emailNotificationButtonIsHidden: Signal<Bool, Never> { get }
  var projectCountText: Signal<String, Never> { get }
  var pushNotificationsButtonAccessibilityLabel: Signal<String, Never> { get }
  var pushNotificationButtonIsHidden: Signal<Bool, Never> { get }
  var pushNotificationsEnabled: Signal<Bool, Never> { get }
  var unableToSaveError: Signal<String, Never> { get }
  var updateCurrentUser: Signal<User, Never> { get }
}

public protocol SettingsNotificationCellViewModelType {
  var inputs: SettingsNotificationCellViewModelInputs { get }
  var outputs: SettingsNotificationCellViewModelOutputs { get }
}

public final class SettingsNotificationCellViewModel: SettingsNotificationCellViewModelInputs,
  SettingsNotificationCellViewModelOutputs,
  SettingsNotificationCellViewModelType {
  public init() {
    let initialUser = self.initialUserProperty.signal.skipNil()

    let cellType = self.cellTypeProperty.signal.skipNil().skipRepeats()

    let initialPushNotificationValue = Signal.zip(initialUser, cellType)
      .map { (user, cellType) -> Bool? in
        guard let notification = SettingsNotificationCellViewModel
          .notificationFor(
            cellType: cellType,
            notificationType: .push
          ) else {
          return nil
        }

        return user |> UserAttribute.notification(notification).keyPath.view
      }.skipNil()

    let pushNotificationValueToggled = self.pushNotificationValueChangedProperty.signal.negate()

    let initialEmailNotificationsValue = Signal.zip(initialUser, cellType)
      .map { (user, cellType) -> Bool? in
        guard let notification = SettingsNotificationCellViewModel
          .notificationFor(
            cellType: cellType,
            notificationType: .email
          ) else {
          return nil
        }

        return user |> UserAttribute.notification(notification).keyPath.view
      }.skipNil()

    let emailNotificationValueToggled = self.emailNotificationValueChangedProperty.signal.negate()

    let updatedNotificationSetting = Signal.merge(
      pushNotificationValueToggled.signal.skipRepeats().map { (NotificationType.push, $0) },
      emailNotificationValueToggled.signal.skipRepeats().map { (NotificationType.email, $0) }
    )

    let userAttributeChanged = cellType
      .takePairWhen(updatedNotificationSetting)
      .map(unpack)
      .map { cellType, notificationType, enabled -> (UserAttribute.Notification?, Bool) in
        let notification = SettingsNotificationCellViewModel.notificationFor(
          cellType: cellType,
          notificationType: notificationType
        )
        return (notification, enabled)
      }

    let updatedUser = initialUser
      .takePairWhen(userAttributeChanged)
      .map { user, notificationAndOn -> User? in
        let (notification, on) = notificationAndOn

        guard let notificationType = notification else {
          return nil
        }

        return user |> UserAttribute.notification(notificationType).keyPath .~ on
      }.skipNil()

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

    self.updateCurrentUser = updateEvent.values()

    let previousPushNotificationValue = initialPushNotificationValue.signal
      .takeWhen(self.unableToSaveError)

    let previousEmailNotificationValue = initialEmailNotificationsValue.signal
      .takeWhen(self.unableToSaveError)

    self.pushNotificationsEnabled = Signal.merge(
      initialPushNotificationValue.signal,
      pushNotificationValueToggled,
      previousPushNotificationValue
    )

    self.emailNotificationsEnabled = Signal.merge(
      initialEmailNotificationsValue,
      emailNotificationValueToggled,
      previousEmailNotificationValue
    )

    self.pushNotificationsButtonAccessibilityLabel =
      Signal.combineLatest(self.pushNotificationsEnabled, cellType)
        .map { pushNotificationEnabled, cellType in
          pushNotificationEnabled ? Strings.Notification_push_notification_on(notification: cellType.title)
            : Strings.Notification_push_notification_off(notification: cellType.title)
        }

    self.emailNotificationsButtonAccessibilityLabel =
      Signal.combineLatest(self.emailNotificationsEnabled, cellType)
        .map { emailNotificationEnabled, cellType in
          emailNotificationEnabled ? Strings.Notification_email_notification_on(notification: cellType.title)
            : Strings.Notification_email_notification_off(notification: cellType.title)
        }

    self.emailNotificationButtonIsHidden = cellType
      .map { $0.shouldShowEmailNotificationButton }
      .negate()

    self.pushNotificationButtonIsHidden = cellType
      .map { $0.shouldShowPushNotificationButton }
      .negate()

    self.enableButtonAnimation = Signal.combineLatest(
      self.emailNotificationButtonIsHidden,
      self.pushNotificationButtonIsHidden
    ).map { !$0.0 || !$0.1 }

    self.projectCountText = initialUser
      .map { Format.wholeNumber($0.stats.backedProjectsCount ?? 0) }

    // Koala tracking
    userAttributeChanged.observeValues { notification, enabled in
      SettingsNotificationCellViewModel.trackNotificationStateChanged(
        notification: notification,
        enabled: enabled
      )
    }
  }

  fileprivate let pushNotificationValueChangedProperty = MutableProperty(false)
  public func didTapPushNotificationsButton(selected: Bool) {
    self.pushNotificationValueChangedProperty.value = selected
  }

  fileprivate let emailNotificationValueChangedProperty = MutableProperty(false)
  public func didTapEmailNotificationsButton(selected: Bool) {
    self.emailNotificationValueChangedProperty.value = selected
  }

  fileprivate let initialUserProperty = MutableProperty<User?>(nil)
  fileprivate let cellTypeProperty = MutableProperty<SettingsNotificationCellType?>(nil)
  public func configure(with cellValue: SettingsNotificationCellValue) {
    self.cellTypeProperty.value = cellValue.cellType
    self.initialUserProperty.value = cellValue.user
  }

  public let enableButtonAnimation: Signal<Bool, Never>
  public let emailNotificationsButtonAccessibilityLabel: Signal<String, Never>
  public let emailNotificationsEnabled: Signal<Bool, Never>
  public let emailNotificationButtonIsHidden: Signal<Bool, Never>
  public var pushNotificationsButtonAccessibilityLabel: Signal<String, Never>
  public let pushNotificationButtonIsHidden: Signal<Bool, Never>
  public let pushNotificationsEnabled: Signal<Bool, Never>
  public let projectCountText: Signal<String, Never>
  public let unableToSaveError: Signal<String, Never>
  public let updateCurrentUser: Signal<User, Never>

  public var inputs: SettingsNotificationCellViewModelInputs { return self }
  public var outputs: SettingsNotificationCellViewModelOutputs { return self }
}

public enum NotificationType {
  case email
  case push
}

extension SettingsNotificationCellViewModel {
  static func trackNotificationStateChanged(notification: UserAttribute.Notification?, enabled: Bool) {
    guard let notification = notification else {
      return
    }

    switch notification {
    case .mobileComments,
         .mobileFollower,
         .mobileFriendActivity,
         .mobilePledgeActivity,
         .mobilePostLikes,
         .mobileMessages,
         .mobileUpdates:
      AppEnvironment.current.koala.trackChangePushNotification(
        type: notification.trackingString,
        on: enabled
      )
    case .commentReplies,
         .comments,
         .follower,
         .friendActivity,
         .messages,
         .pledgeActivity,
         .postLikes,
         .creatorTips,
         .updates:
      AppEnvironment.current.koala.trackChangeEmailNotification(
        type: notification.trackingString,
        on: enabled
      )
    default: break
    }
  }

  public static func notificationFor(
    cellType: SettingsNotificationCellType,
    notificationType: NotificationType
  ) -> UserAttribute.Notification? {
    switch cellType {
    case .projectUpdates:
      return notificationType == .email
        ? UserAttribute.Notification.updates : UserAttribute.Notification.mobileUpdates
    case .pledgeActivity:
      return notificationType == .email
        ? UserAttribute.Notification.pledgeActivity : UserAttribute.Notification.mobilePledgeActivity
    case .newComments:
      return notificationType == .email
        ? UserAttribute.Notification.comments : UserAttribute.Notification.mobileComments
    case .newLikes:
      return notificationType == .email
        ? UserAttribute.Notification.postLikes : UserAttribute.Notification.mobilePostLikes
    case .creatorTips:
      return notificationType == .email
        ? UserAttribute.Notification.creatorTips : nil
    case .messages:
      return notificationType == .email
        ? UserAttribute.Notification.messages : UserAttribute.Notification.mobileMessages
    case .newFollowers:
      return notificationType == .email
        ? UserAttribute.Notification.follower : UserAttribute.Notification.mobileFollower
    case .friendBacksProject:
      return notificationType == .email
        ? UserAttribute.Notification.friendActivity : UserAttribute.Notification.mobileFriendActivity
    case .commentReplyDigest:
      return notificationType == .email
        ? UserAttribute.Notification.commentReplies : nil
    default:
      return nil
    }
  }
}
