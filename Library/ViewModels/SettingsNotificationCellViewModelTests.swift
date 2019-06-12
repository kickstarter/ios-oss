@testable import KsApi
import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class SettingsNotificationCellViewModelTests: TestCase {
  private let vm = SettingsNotificationCellViewModel()

  private let enableButtonAnimation = TestObserver<Bool, Never>()
  private let emailNotificationsButtonAccessibilityLabel = TestObserver<String, Never>()
  private let emailNotificationsEnabled = TestObserver<Bool, Never>()
  private let emailNotificationButtonIsHidden = TestObserver<Bool, Never>()
  private let pushNotificationButtonIsHidden = TestObserver<Bool, Never>()
  private let manageProjectNotificationsButtonAccessibilityHint = TestObserver<String, Never>()
  private let projectCountText = TestObserver<String, Never>()
  private let pushNotificationsButtonAccessibilityLabel = TestObserver<String, Never>()
  private let pushNotificationsEnabled = TestObserver<Bool, Never>()
  private let unableToSaveError = TestObserver<String, Never>()
  private let updateCurrentUser = TestObserver<User, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.enableButtonAnimation.observe(self.enableButtonAnimation.observer)
    self.vm.outputs.emailNotificationsButtonAccessibilityLabel
      .observe(self.emailNotificationsButtonAccessibilityLabel.observer)
    self.vm.outputs.emailNotificationsEnabled.observe(self.emailNotificationsEnabled.observer)
    self.vm.outputs.emailNotificationButtonIsHidden.observe(self.emailNotificationButtonIsHidden.observer)
    self.vm.outputs.pushNotificationsButtonAccessibilityLabel
      .observe(self.pushNotificationsButtonAccessibilityLabel.observer)
    self.vm.outputs.pushNotificationButtonIsHidden.observe(self.pushNotificationButtonIsHidden.observer)
    self.vm.outputs.projectCountText.observe(self.projectCountText.observer)
    self.vm.pushNotificationsEnabled.observe(self.pushNotificationsEnabled.observer)
    self.vm.unableToSaveError.observe(self.unableToSaveError.observer)
    self.vm.updateCurrentUser.observe(self.updateCurrentUser.observer)
  }

  func testEnableButtonAnimation_turnedOn() {
    let user = User.template
    let value = SettingsNotificationCellValue(cellType: .projectUpdates, user: user)

    self.vm.inputs.configure(with: value)

    self.enableButtonAnimation.assertValue(true)
  }

  func testEnableButtonAnimation_turnedOff() {
    let user = User.template
    let value = SettingsNotificationCellValue(cellType: .emailFrequency, user: user)

    self.vm.inputs.configure(with: value)

    self.enableButtonAnimation.assertValue(false)
  }

  func testEmailNotificationButtonAccessibilityLabel_disabled() {
    let notificationType = SettingsNotificationCellViewModel.notificationFor(
      cellType: .projectUpdates,
      notificationType: .email
    )

    guard let notification = notificationType else {
      XCTFail("Notification cannot be nil")
      return
    }

    let user = User.template
      |> UserAttribute.notification(notification).keyPath .~ false

    let value = SettingsNotificationCellValue(cellType: .projectUpdates, user: user)

    self.vm.inputs.configure(with: value)

    self.emailNotificationsEnabled.assertValues([false], "Email notifications are disabled")
    self.emailNotificationsButtonAccessibilityLabel.assertValues(
      [Strings.Notification_email_notification_off(notification: value.cellType.title)])
  }

  func testEmailNotificationButtonAccessibilityLabel_enabled() {
    let notificationType = SettingsNotificationCellViewModel.notificationFor(
      cellType: .projectUpdates,
      notificationType: .email
    )

    guard let notification = notificationType else {
      XCTFail("Notification cannot be nil")
      return
    }

    let user = User.template
      |> UserAttribute.notification(notification).keyPath .~ true

    let value = SettingsNotificationCellValue(cellType: .projectUpdates, user: user)

    self.vm.inputs.configure(with: value)

    self.emailNotificationsEnabled.assertValues([true], "Email notifications are enabled")
    self.emailNotificationsButtonAccessibilityLabel.assertValues(
      [Strings.Notification_email_notification_on(notification: value.cellType.title)])
  }

  func testPushNotificationButtonAccessibilityLabel_disabled() {
    let notificationType = SettingsNotificationCellViewModel.notificationFor(
      cellType: .projectUpdates,
      notificationType: .push
    )

    guard let notification = notificationType else {
      XCTFail("Notification cannot be nil")
      return
    }

    let user = User.template
      |> UserAttribute.notification(notification).keyPath .~ false

    let value = SettingsNotificationCellValue(cellType: .projectUpdates, user: user)

    self.vm.inputs.configure(with: value)

    self.pushNotificationsEnabled.assertValues([false], "Push notifications are disabled")
    self.pushNotificationsButtonAccessibilityLabel.assertValues(
      [Strings.Notification_push_notification_off(notification: value.cellType.title)])
  }

  func testPushNotificationButtonAccessibilityLabel_enabled() {
    let notificationType = SettingsNotificationCellViewModel.notificationFor(
      cellType: .projectUpdates,
      notificationType: .push
    )

    guard let notification = notificationType else {
      XCTFail("Notification cannot be nil")
      return
    }

    let user = User.template
      |> UserAttribute.notification(notification).keyPath .~ true

    let value = SettingsNotificationCellValue(cellType: .projectUpdates, user: user)

    self.vm.inputs.configure(with: value)

    self.pushNotificationsEnabled.assertValues([true], "Push notifications are enabled")
    self.pushNotificationsButtonAccessibilityLabel.assertValues(
      [Strings.Notification_push_notification_on(notification: value.cellType.title)])
  }

  func testEmailNotificationsEnabled() {
    let notificationType = SettingsNotificationCellViewModel.notificationFor(
      cellType: .projectUpdates,
      notificationType: .email
    )

    guard let notification = notificationType else {
      XCTFail("Notification cannot be nil")
      return
    }

    let user = User.template
      |> UserAttribute.notification(notification).keyPath .~ true

    let value = SettingsNotificationCellValue(cellType: .projectUpdates, user: user)

    self.vm.inputs.configure(with: value)

    self.emailNotificationsEnabled.assertValues([true], "Email notifications are enabled")
  }

  func testEmailNotificationsDisabled() {
    let notificationType = SettingsNotificationCellViewModel.notificationFor(
      cellType: .projectUpdates,
      notificationType: .email
    )

    guard let notification = notificationType else {
      XCTFail("Notification cannot be nil")
      return
    }

    let user = User.template
      |> UserAttribute.notification(notification).keyPath .~ false

    let value = SettingsNotificationCellValue(cellType: .projectUpdates, user: user)

    self.vm.inputs.configure(with: value)

    self.emailNotificationsEnabled.assertValues([false], "Email notifications are disabled")
  }

  func testPushNotificationsEnabled() {
    let notificationType = SettingsNotificationCellViewModel.notificationFor(
      cellType: .projectUpdates,
      notificationType: .push
    )

    guard let notification = notificationType else {
      XCTFail("Notification cannot be nil")
      return
    }

    let user = User.template
      |> UserAttribute.notification(notification).keyPath .~ true

    let value = SettingsNotificationCellValue(cellType: .projectUpdates, user: user)

    self.vm.inputs.configure(with: value)

    self.pushNotificationsEnabled.assertValues([true], "Push notifications are enabled")
  }

  func testPushNotificationsDisabled() {
    let notificationType = SettingsNotificationCellViewModel.notificationFor(
      cellType: .projectUpdates,
      notificationType: .push
    )

    guard let notification = notificationType else {
      XCTFail("Notification cannot be nil")
      return
    }

    let user = User.template
      |> UserAttribute.notification(notification).keyPath .~ false

    let value = SettingsNotificationCellValue(cellType: .projectUpdates, user: user)

    self.vm.inputs.configure(with: value)

    self.pushNotificationsEnabled.assertValues([false], "Push notifications are disabled")
  }

  func testEmailNotificationEnabled_NoValue() {
    let user = User.template
    // Should have no Notification value
    let value = SettingsNotificationCellValue(cellType: .emailFrequency, user: user)

    self.vm.inputs.configure(with: value)

    self.emailNotificationsEnabled.assertValueCount(0)
  }

  func testPushNotificationsEnabled_NoValue() {
    let user = User.template
    // Should have no Notification value
    let value = SettingsNotificationCellValue(cellType: .emailFrequency, user: user)

    self.vm.inputs.configure(with: value)

    self.pushNotificationsEnabled.assertValueCount(0, "pushNotificationsEnabled should not fire")

    // Should have no Notification
    let value1 = SettingsNotificationCellValue(cellType: .creatorTips, user: user)

    self.vm.inputs.configure(with: value1)

    self.pushNotificationsEnabled.assertValueCount(0, "pushNotificationsEnabled should not fire")
  }

  func testHideEmailNotificationsButton() {
    let user = User.template

    // Should have no Notification
    let value = SettingsNotificationCellValue(cellType: .projectNotifications, user: user)

    self.vm.inputs.configure(with: value)

    self.emailNotificationButtonIsHidden.assertValues([true], "Should hide email notifications button")

    let value1 = SettingsNotificationCellValue(cellType: .projectUpdates, user: user)

    self.vm.inputs.configure(with: value1)

    self.emailNotificationButtonIsHidden
      .assertValues([true, false], "Should show email notifications button")
  }

  func testHidePushNotificationButton() {
    let user = User.template

    // Should have no Notification
    let value = SettingsNotificationCellValue(cellType: .projectNotifications, user: user)

    self.vm.inputs.configure(with: value)

    self.pushNotificationButtonIsHidden.assertValues([true], "Should hide email notifications button")

    let value1 = SettingsNotificationCellValue(cellType: .projectUpdates, user: user)

    self.vm.inputs.configure(with: value1)

    self.pushNotificationButtonIsHidden
      .assertValues([true, false], "Should show email notifications button")
  }

  func testManageProjectNotificationsButtonAccesibilityHint() {
    let user = User.template |> \.stats.backedProjectsCount .~ 5
    let value = SettingsNotificationCellValue(cellType: .projectNotifications, user: user)

    self.vm.inputs.configure(with: value)
  }

  func testProjectTextCount() {
    let user = User.template |> \.stats.backedProjectsCount .~ 5
    let value = SettingsNotificationCellValue(cellType: .projectNotifications, user: user)

    self.vm.inputs.configure(with: value)

    self.projectCountText.assertValue("5")
  }

  func testUnabletoSaveError() {
    let error = ErrorEnvelope(
      errorMessages: ["Something bad happened"],
      ksrCode: nil,
      httpCode: 500,
      exception: nil,
      facebookUser: nil
    )
    let mockService = MockService(updateUserSelfError: error)

    let user = User.template |> UserAttribute.notification(.updates).keyPath .~ true
    let value = SettingsNotificationCellValue(cellType: .projectUpdates, user: user)

    withEnvironment(apiService: mockService, currentUser: user) {
      self.vm.configure(with: value)

      self.emailNotificationsEnabled.assertValue(true)

      self.vm.inputs.didTapEmailNotificationsButton(selected: true)

      self.emailNotificationsEnabled
        .assertValues([true, false], "Selected value changes to reflect update")

      scheduler.advance()

      self.unableToSaveError.assertValue("Something bad happened")
      self.updateCurrentUser.assertDidNotEmitValue()
      self.emailNotificationsEnabled
        .assertValues([true, false, true], "Selected value is reset to original value")
    }
  }

  func testUpdateCurrentUser_Success() {
    let mockService = MockService()
    let user = User.template
      |> UserAttribute.notification(.updates).keyPath .~ true
      |> UserAttribute.notification(.mobileUpdates).keyPath .~ true

    let value = SettingsNotificationCellValue(cellType: .projectUpdates, user: user)

    withEnvironment(apiService: mockService, currentUser: user) {
      self.vm.configure(with: value)
      self.emailNotificationsEnabled.assertValue(true)
      self.pushNotificationsEnabled.assertValue(true)

      self.vm.inputs.didTapEmailNotificationsButton(selected: true)

      scheduler.advance()

      self.updateCurrentUser.assertValueCount(1, "User was updated")

      self.emailNotificationsEnabled
        .assertValues([true, false], "Email notification button was toggled")

      self.vm.inputs.didTapPushNotificationsButton(selected: true)

      scheduler.advance()

      self.updateCurrentUser.assertValueCount(2, "User was updated")

      self.pushNotificationsEnabled
        .assertValues([true, false], "Push notification button was toggled")
    }
  }
}
