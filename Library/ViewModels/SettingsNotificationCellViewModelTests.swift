import XCTest
import Result
import Library
import Prelude
@testable import Kickstarter_Framework
@testable import ReactiveExtensions_TestHelpers
@testable import KsApi

final class SettingsNotificationCellViewModelTests: TestCase {
  private let vm = SettingsNotificationCellViewModel()

  private let enableButtonAnimation = TestObserver<Bool, NoError>()
  private let emailNotificationsEnabled = TestObserver<Bool, NoError>()
  private let emailNotificationButtonIsHidden = TestObserver<Bool, NoError>()
  private let pushNotificationButtonIsHidden = TestObserver<Bool, NoError>()
  private let manageProjectNotificationsButtonAccessibilityHint = TestObserver<String, NoError>()
  private let projectCountText = TestObserver<String, NoError>()
  private let pushNotificationsEnabled = TestObserver<Bool, NoError>()
  private let unableToSaveError = TestObserver<String, NoError>()
  private let updateCurrentUser = TestObserver<User, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.enableButtonAnimation.observe(enableButtonAnimation.observer)
    self.vm.outputs.emailNotificationsEnabled.observe(emailNotificationsEnabled.observer)
    self.vm.outputs.emailNotificationButtonIsHidden.observe(emailNotificationButtonIsHidden.observer)
    self.vm.outputs.pushNotificationButtonIsHidden.observe(pushNotificationButtonIsHidden.observer)
    self.vm.outputs.manageProjectNotificationsButtonAccessibilityHint
      .observe(manageProjectNotificationsButtonAccessibilityHint.observer)
    self.vm.outputs.projectCountText.observe(projectCountText.observer)
    self.vm.pushNotificationsEnabled.observe(pushNotificationsEnabled.observer)
    self.vm.unableToSaveError.observe(unableToSaveError.observer)
    self.vm.updateCurrentUser.observe(updateCurrentUser.observer)
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

  func testEmailNotificationsEnabled() {
    let notificationType = SettingsNotificationCellViewModel.notificationFor(cellType: .projectUpdates,
                                                                         notificationType: .email)

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
    let notificationType = SettingsNotificationCellViewModel.notificationFor(cellType: .projectUpdates,
                                                                             notificationType: .email)

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
    let notificationType = SettingsNotificationCellViewModel.notificationFor(cellType: .projectUpdates,
                                                                             notificationType: .push)

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
    let notificationType = SettingsNotificationCellViewModel.notificationFor(cellType: .projectUpdates,
                                                                             notificationType: .push)

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

    self.manageProjectNotificationsButtonAccessibilityHint.assertValue("5 projects backed")
  }

  func testProjectTextCount() {
    let user = User.template |> \.stats.backedProjectsCount .~ 5
    let value = SettingsNotificationCellValue(cellType: .projectNotifications, user: user)

    self.vm.inputs.configure(with: value)

    self.projectCountText.assertValue("5")
  }

  func testUnabletoSaveError() {
    let error = ErrorEnvelope(errorMessages: ["Something bad happened"],
                              ksrCode: nil,
                              httpCode: 500,
                              exception: nil,
                              facebookUser: nil)
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
