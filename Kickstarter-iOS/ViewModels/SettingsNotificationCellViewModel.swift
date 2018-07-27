import ReactiveSwift
import Result
import Library
import KsApi
import Prelude

protocol SettingsNotificationCellViewModelInputs {
  func didTapPushNotificationsButton(selected: Bool)
  func didTapEmailNotificationsButton(selected: Bool)
  func configure(with cellValue: SettingsNotificationCellValue)
}

protocol SettingsNotificationCellViewModelOutputs {
  var enableButtonAnimation: Signal<Bool, NoError> { get }
  var emailNotificationsEnabled: Signal<Bool, NoError> { get }
  var hideEmailNotificationsButton: Signal<Bool, NoError> { get }
  var hidePushNotificationButton: Signal<Bool, NoError> { get }
  var manageProjectNotificationsButtonAccessibilityHint: Signal<String, NoError> { get }
  var projectCountText: Signal<String, NoError> { get }
  var pushNotificationsEnabled: Signal<Bool, NoError> { get }
  var unableToSaveError: Signal<String, NoError> { get }
  var updateCurrentUser: Signal<User, NoError> { get }
}

protocol SettingsNotificationCellViewModelType {
  var inputs: SettingsNotificationCellViewModelInputs { get }
  var outputs: SettingsNotificationCellViewModelOutputs { get }
}

final class SettingsNotificationCellViewModel: SettingsNotificationCellViewModelInputs,
SettingsNotificationCellViewModelOutputs,
SettingsNotificationCellViewModelType {
  public init() {
    let initialPushNotificationValue = Signal.combineLatest(
      initialUserProperty.signal.skipNil(),
      cellTypeProperty.signal.skipNil().skipRepeats())
      .map { (user, cellType) -> Bool? in
        guard let notification = SettingsNotificationCellViewModel
          .notificationFor(cellType: cellType,
                           notificationType: .push) else {
                            return nil
        }

        return user |> UserAttribute.notification(notification).lens.view
    }.skipNil()

    let pushNotificationValueToggled = pushNotificationValueChangedProperty.signal.negate()

    let initialEmailNotificationsValue = Signal.combineLatest(
      initialUserProperty.signal.skipNil(),
      cellTypeProperty.signal.skipNil().skipRepeats())
      .map { (user, cellType) -> Bool? in
        guard let notification = SettingsNotificationCellViewModel
          .notificationFor(cellType: cellType,
                           notificationType: .email) else {
                            return nil
        }

        return user |> UserAttribute.notification(notification).lens.view
      }.skipNil()

    let emailNotificationValueToggled = emailNotificationValueChangedProperty.signal.negate()

    let updatedNotificationSetting = Signal.merge(
      pushNotificationValueToggled.signal.skipRepeats().map { (NotificationType.push, $0) },
      emailNotificationValueToggled.signal.skipRepeats().map { (NotificationType.email, $0) }
    )

    let userAttributeChanged = cellTypeProperty.signal.skipNil()
    .takePairWhen(updatedNotificationSetting.signal)
    .map(unpack)
    .map { cellType, notificationType, enabled -> (UserAttribute.Notification?, Bool) in
        let notification = SettingsNotificationCellViewModel.notificationFor(cellType: cellType,
                                                                 notificationType: notificationType)

        return (notification, enabled)
    }.logEvents(identifier: "user attribute changed")

    let updatedUser = initialUserProperty.signal
      .skipNil()
      .takePairWhen(userAttributeChanged)
      .map { user, notificationAndOn -> User? in
        let (notification, on) = notificationAndOn

        guard let notificationType = notification else {
          return nil
        }

        return user |> UserAttribute.notification(notificationType).lens .~ on
      }.skipNil()

    let updateEvent = updatedUser
      .switchMap {
        AppEnvironment.current.apiService.updateUserSelf($0)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
      }.logEvents(identifier: "update event")

    self.unableToSaveError = updateEvent.errors()
      .map { env in
        env.errorMessages.first ?? Strings.profile_settings_error()
    }

    self.updateCurrentUser = updateEvent.values().logEvents(identifier: "user was updated")

    let previousPushNotificationValue = initialPushNotificationValue.signal
      .takeWhen(self.unableToSaveError)

    let previousEmailNotificationValue = initialEmailNotificationsValue.signal
      .takeWhen(self.unableToSaveError)

    self.pushNotificationsEnabled = Signal.merge(
      initialPushNotificationValue.signal,
      pushNotificationValueChangedProperty.signal.negate(),
      previousPushNotificationValue
    )

    self.emailNotificationsEnabled = Signal.merge(
      initialEmailNotificationsValue.signal,
      emailNotificationValueToggled.logEvents(identifier: "email toggled"),
      previousEmailNotificationValue.logEvents(identifier: "previous email")
    ).logEvents(identifier: "email notification enabled")

    self.hideEmailNotificationsButton = cellTypeProperty.signal
      .skipNil()
      .map { $0.shouldShowEmailNotificationButton }
      .negate()

    self.hidePushNotificationButton = cellTypeProperty.signal
      .skipNil()
      .map { $0.showShowPushNotificationButton }
      .negate()

    self.enableButtonAnimation = self.hideEmailNotificationsButton
      .negate() // Only add animation if email notification button is shown

    self.manageProjectNotificationsButtonAccessibilityHint = initialUserProperty.signal
      .skipNil()
      .map { Strings.profile_project_count_projects_backed(project_count: $0.stats.backedProjectsCount ?? 0) }

    self.projectCountText = initialUserProperty.signal
      .skipNil()
      .map { Format.wholeNumber($0.stats.backedProjectsCount ?? 0)}

    // Koala tracking
    userAttributeChanged.observeValues { (notification, enabled) in
      SettingsNotificationCellViewModel.trackNotificationStateChanged(notification: notification,
                                                                      enabled: enabled)
    }
  }

  fileprivate let pushNotificationValueChangedProperty = MutableProperty(false)
  func didTapPushNotificationsButton(selected: Bool) {
    self.pushNotificationValueChangedProperty.value = selected
  }

  fileprivate let emailNotificationValueChangedProperty = MutableProperty(false)
  func didTapEmailNotificationsButton(selected: Bool) {
    self.emailNotificationValueChangedProperty.value = selected
  }

  fileprivate let initialUserProperty = MutableProperty<User?>(nil)
  fileprivate let cellTypeProperty = MutableProperty<SettingsNotificationCellType?>(nil)
  func configure(with cellValue: SettingsNotificationCellValue) {
    self.cellTypeProperty.value = cellValue.cellType
    self.initialUserProperty.value = cellValue.user
  }

  public let enableButtonAnimation: Signal<Bool, NoError>
  public let emailNotificationsEnabled: Signal<Bool, NoError>
  public let hideEmailNotificationsButton: Signal<Bool, NoError>
  public let hidePushNotificationButton: Signal<Bool, NoError>
  public let manageProjectNotificationsButtonAccessibilityHint: Signal<String, NoError>
  public let projectCountText: Signal<String, NoError>
  public let pushNotificationsEnabled: Signal<Bool, NoError>
  public let unableToSaveError: Signal<String, NoError>
  public let updateCurrentUser: Signal<User, NoError>

  public var inputs: SettingsNotificationCellViewModelInputs { return self }
  public var outputs: SettingsNotificationCellViewModelOutputs { return self }
}

enum NotificationType {
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
      AppEnvironment.current.koala.trackChangePushNotification(type: notification.trackingString,
                                                               on: enabled)
    case .comments,
         .follower,
         .friendActivity,
         .messages,
         .pledgeActivity,
         .postLikes,
         .creatorTips,
         .updates:
      AppEnvironment.current.koala.trackChangeEmailNotification(type: notification.trackingString,
                                                                on: enabled)
    default: break
    }
  }

  public static func notificationFor(cellType: SettingsNotificationCellType,
                                     notificationType: NotificationType) -> UserAttribute.Notification? {
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
    default:
      return nil
    }
  }
}
