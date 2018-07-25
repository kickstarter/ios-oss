import ReactiveSwift
import Result
import Library
import KsApi
import Prelude

protocol SettingsNotificationCellViewModelInputs {
  func didTapPushNotificationsButton()
  func didTapEmailNotificationsButton()
  func configure(with cellValue: SettingsNotificationCellValue)
}

protocol SettingsNotificationCellViewModelOutputs {
  var projectCountText: Signal<String, NoError> { get }
  var pushNotificationsEnabled: Signal<Bool, NoError> { get }
  var emailNotificationsEnabled: Signal<Bool, NoError> { get }
  var hideNotificationButtons: Signal<Bool, NoError> { get }
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
      cellTypeProperty.signal.skipNil())
      .map { (user, cellType) -> Bool? in
        guard let notification = SettingsNotificationCellViewModel.notificationFor(cellType: cellType,
                                                                                   notificationType: .push) else {
                                                                                    return nil
        }

        return user |> UserAttribute.notification(notification).lens.view
    }.skipNil()

    self.pushNotificationsEnabled = Signal.merge(
      initialPushNotificationValue.signal,
      pushNotificationsEnabledProperty.signal
    )

    let initialEmailNotificationsValue = Signal.combineLatest(
      initialUserProperty.signal.skipNil(),
      cellTypeProperty.signal.skipNil())
      .map { (user, cellType) -> Bool? in
        guard let notification = SettingsNotificationCellViewModel.notificationFor(cellType: cellType,
                                                                                   notificationType: .email) else {
                                                                                    return nil
        }

        return user |> UserAttribute.notification(notification).lens.view
      }.skipNil()

    self.emailNotificationsEnabled = Signal.merge(
      initialEmailNotificationsValue.signal,
      emailNotificationsEnabledProperty.signal
    )

    let updatedNotificationSetting = Signal.merge(
      pushNotificationsEnabledProperty.signal.skipRepeats().map { (NotificationType.push, $0) },
      emailNotificationsEnabledProperty.signal.skipRepeats().map { (NotificationType.email, $0) }
    ).logEvents(identifier: "update notification")

    let userAttributeChanged = Signal.combineLatest(
      cellTypeProperty.signal.skipNil(),
      updatedNotificationSetting.signal
    )
    .map(unpack)
    .map { cellType, notificationType, enabled -> (UserAttribute.Notification?, Bool) in
        let notification = SettingsNotificationCellViewModel.notificationFor(cellType: cellType,
                                                                 notificationType: notificationType)

        return (notification, enabled)
    }

    let updatedUser = initialUserProperty.signal
      .skipNil()
      .switchMap { user in
        userAttributeChanged.scan(user) { user, notificationAndOn in
          let (notification, on) = notificationAndOn
          return user |> UserAttribute.notification(notification!).lens .~ on
        }
    }

    self.hideNotificationButtons = cellTypeProperty.signal
      .skipNil()
      .map { $0.shouldShowNotificationButtons }
      .negate()

    self.projectCountText = initialUserProperty.signal
      .skipNil()
      .map { Format.wholeNumber($0.stats.backedProjectsCount ?? 0)}
  }

  fileprivate let pushNotificationsEnabledProperty = MutableProperty(false)
  func didTapPushNotificationsButton() {
    // Toggle value
    self.pushNotificationsEnabledProperty.value = self.pushNotificationsEnabledProperty.negate().value
  }

  fileprivate let emailNotificationsEnabledProperty = MutableProperty(false)
  func didTapEmailNotificationsButton() {
    // Toggle value
    self.emailNotificationsEnabledProperty.value = self.emailNotificationsEnabledProperty.negate().value
  }

  fileprivate let initialUserProperty = MutableProperty<User?>(nil)
  fileprivate let cellTypeProperty = MutableProperty<SettingsNotificationCellType?>(nil)
  func configure(with cellValue: SettingsNotificationCellValue) {
    self.cellTypeProperty.value = cellValue.cellType
    self.initialUserProperty.value = cellValue.user
  }

  public let emailNotificationsEnabled: Signal<Bool, NoError>
  public let hideNotificationButtons: Signal<Bool, NoError>
  public let projectCountText: Signal<String, NoError>
  public let pushNotificationsEnabled: Signal<Bool, NoError>

  public var inputs: SettingsNotificationCellViewModelInputs { return self }
  public var outputs: SettingsNotificationCellViewModelOutputs { return self }
}

enum NotificationType {
  case email
  case push
}

extension SettingsNotificationCellViewModel {
  static func notificationFor(cellType: SettingsNotificationCellType, notificationType: NotificationType) -> UserAttribute.Notification? {
    switch cellType {
    case .projectUpdates:
      return notificationType == .email
        ? UserAttribute.Notification.updates : UserAttribute.Notification.mobileUpdates
    case .pledgeActivity:
      // TODO rename this for clarity
      return notificationType == .email
        ? UserAttribute.Notification.backings : UserAttribute.Notification.mobileBackings
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
