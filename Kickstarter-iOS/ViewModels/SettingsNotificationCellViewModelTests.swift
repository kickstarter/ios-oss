import XCTest
import Result
import Library
import Prelude
@testable import Kickstarter_Framework
@testable import ReactiveExtensions_TestHelpers
@testable import KsApi

final class SettingsNotificationCellViewModelTests: TestCase {
  private let vm = SettingsNotificationCellViewModel()

  private let enableButtonAnimationObserver = TestObserver<Bool, NoError>()
  private let emailNotificationsEnabledObserver = TestObserver<Bool, NoError>()
  private let hideEmailNotificationButtonObserver = TestObserver<Bool, NoError>()
  private let hidePushNotificationButtonObserver = TestObserver<Bool, NoError>()
  private let manageProjectNotificationsHintObserver = TestObserver<String, NoError>()
  private let projectCountTextObserver = TestObserver<String, NoError>()
  private let pushNotificationsEnabledObserver = TestObserver<Bool, NoError>()
  private let unableToSaveErrorObserver = TestObserver<String, NoError>()
  private let updateCurrentUserObserver = TestObserver<User, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.enableButtonAnimation.observe(enableButtonAnimationObserver.observer)
    self.vm.outputs.emailNotificationsEnabled.observe(emailNotificationsEnabledObserver.observer)
    self.vm.outputs.emailNotificationButtonIsHidden.observe(hideEmailNotificationButtonObserver.observer)
    self.vm.outputs.pushNotificationButtonIsHidden.observe(hidePushNotificationButtonObserver.observer)
    self.vm.outputs.manageProjectNotificationsButtonAccessibilityHint
      .observe(manageProjectNotificationsHintObserver.observer)
    self.vm.outputs.projectCountText.observe(projectCountTextObserver.observer)
    self.vm.pushNotificationsEnabled.observe(pushNotificationsEnabledObserver.observer)
    self.vm.unableToSaveError.observe(unableToSaveErrorObserver.observer)
    self.vm.updateCurrentUser.observe(updateCurrentUserObserver.observer)
  }

  func testEnableButtonAnimation_turnedOn() {
    let user = User.template
    let value = SettingsNotificationCellValue(cellType: .projectUpdates, user: user)

    self.vm.inputs.configure(with: value)

    self.enableButtonAnimationObserver.assertValue(true)
  }

  func testEnableButtonAnimation_turnedOff() {
    let user = User.template
    let value = SettingsNotificationCellValue(cellType: .findFacebookFriends, user: user)

    self.vm.inputs.configure(with: value)

    self.enableButtonAnimationObserver.assertValue(false)
  }

  func testEmailNotificationsEnabled() {
    let notificationType = SettingsNotificationCellViewModel.notificationFor(cellType: .projectUpdates,
                                                                         notificationType: .email)

    guard let notification = notificationType else {
      XCTFail("Notification cannot be nil")
      return
    }

    let user = User.template
      |> UserAttribute.notification(notification).lens .~ true

    let value = SettingsNotificationCellValue(cellType: .projectUpdates, user: user)

    self.vm.inputs.configure(with: value)

    self.emailNotificationsEnabledObserver.assertValues([true], "Email notifications are enabled")

    let user1 = user
      |> UserAttribute.notification(notification).lens .~ false
    let value1 = SettingsNotificationCellValue(cellType: .projectUpdates, user: user1)

    self.vm.inputs.configure(with: value1)

    self.emailNotificationsEnabledObserver.assertValues([true, false], "Email notifications are disabled")
  }

  func testEmailNotificationEnabled_NoValue() {
    let user = User.template
    // Should have no Notification value
    let value = SettingsNotificationCellValue(cellType: .findFacebookFriends, user: user)

    self.vm.inputs.configure(with: value)

    self.emailNotificationsEnabledObserver.assertValueCount(0)
  }

  func testPushNotificationsEnabled() {
    let notificationType = SettingsNotificationCellViewModel.notificationFor(cellType: .projectUpdates,
                                                                         notificationType: .push)

    guard let notification = notificationType else {
      XCTFail("Notification cannot be nil")
      return
    }

    let user = User.template
      |> UserAttribute.notification(notification).lens .~ true

    let value = SettingsNotificationCellValue(cellType: .projectUpdates, user: user)

    self.vm.inputs.configure(with: value)

    self.pushNotificationsEnabledObserver.assertValues([true], "Push notifications are enabled")

    let value1 = SettingsNotificationCellValue(cellType: .projectUpdates, user: user
      |> UserAttribute.notification(notification).lens .~ false)

    self.vm.inputs.configure(with: value1)

    self.pushNotificationsEnabledObserver.assertValues([true, false], "Push notifications are disabled")
  }

  func testPushNotificationsEnabled_NoValue() {
    let user = User.template
    // Should have no Notification value
    let value = SettingsNotificationCellValue(cellType: .findFacebookFriends, user: user)

    self.vm.inputs.configure(with: value)

    self.pushNotificationsEnabledObserver.assertValueCount(0, "pushNotificationsEnabled should not fire")

    // Should have no Notification
    let value1 = SettingsNotificationCellValue(cellType: .creatorTips, user: user)

    self.vm.inputs.configure(with: value1)

    self.pushNotificationsEnabledObserver.assertValueCount(0, "pushNotificationsEnabled should not fire")
  }

  func testHideEmailNotificationsButton() {
    let user = User.template

    // Should have no Notification
    let value = SettingsNotificationCellValue(cellType: .findFacebookFriends, user: user)

    self.vm.inputs.configure(with: value)

    self.hideEmailNotificationButtonObserver.assertValues([true], "Should hide email notifications button")

    let value1 = SettingsNotificationCellValue(cellType: .projectUpdates, user: user)

    self.vm.inputs.configure(with: value1)

    self.hideEmailNotificationButtonObserver
      .assertValues([true, false], "Should show email notifications button")
  }

  func testHidePushNotificationButton() {
    let user = User.template

    // Should have no Notification
    let value = SettingsNotificationCellValue(cellType: .findFacebookFriends, user: user)

    self.vm.inputs.configure(with: value)

    self.hidePushNotificationButtonObserver.assertValues([true], "Should hide email notifications button")

    let value1 = SettingsNotificationCellValue(cellType: .projectUpdates, user: user)

    self.vm.inputs.configure(with: value1)

    self.hidePushNotificationButtonObserver
      .assertValues([true, false], "Should show email notifications button")
  }

  func testManageProjectNotificationsButtonAccesibilityHint() {
    let user = User.template |> User.lens.stats.backedProjectsCount .~ 5
    let value = SettingsNotificationCellValue(cellType: .projectNotifications, user: user)

    self.vm.inputs.configure(with: value)

    self.manageProjectNotificationsHintObserver.assertValue("5 projects backed")
  }

  func testProjectTextCount() {
    let user = User.template |> User.lens.stats.backedProjectsCount .~ 5
    let value = SettingsNotificationCellValue(cellType: .projectNotifications, user: user)

    self.vm.inputs.configure(with: value)

    self.projectCountTextObserver.assertValue("5")
  }

  func testUnabletoSaveError() {
    let error = ErrorEnvelope(errorMessages: ["Something bad happened"],
                              ksrCode: nil,
                              httpCode: 500,
                              exception: nil,
                              facebookUser: nil)
    let mockService = MockService(updateUserSelfError: error)

    let user = User.template |> UserAttribute.notification(.updates).lens .~ true
    let value = SettingsNotificationCellValue(cellType: .projectUpdates, user: user)

    withEnvironment(apiService: mockService, currentUser: user) {
      self.vm.configure(with: value)

      self.emailNotificationsEnabledObserver.assertValue(true)

      self.vm.inputs.didTapEmailNotificationsButton(selected: true)

      self.emailNotificationsEnabledObserver
        .assertValues([true, false], "Selected value changes to reflect update")

      scheduler.advance()

      self.unableToSaveErrorObserver.assertValue("Something bad happened")
      self.updateCurrentUserObserver.assertDidNotEmitValue()
      self.emailNotificationsEnabledObserver
        .assertValues([true, false, true], "Selected value is reset to original value")
    }
  }

  func testUpdateCurrentUser_Success() {
    let mockService = MockService()
    let user = User.template
      |> UserAttribute.notification(.updates).lens .~ true
      |> UserAttribute.notification(.mobileUpdates).lens .~ true

    let value = SettingsNotificationCellValue(cellType: .projectUpdates, user: user)

    withEnvironment(apiService: mockService, currentUser: user) {
      self.vm.configure(with: value)
      self.emailNotificationsEnabledObserver.assertValue(true)
      self.pushNotificationsEnabledObserver.assertValue(true)

      self.vm.inputs.didTapEmailNotificationsButton(selected: true)

      scheduler.advance()

      self.updateCurrentUserObserver.assertValueCount(1, "User was updated")

      self.emailNotificationsEnabledObserver
        .assertValues([true, false], "Email notification button was toggled")

      self.vm.inputs.didTapPushNotificationsButton(selected: true)

      scheduler.advance()

      self.updateCurrentUserObserver.assertValueCount(2, "User was updated")

      self.pushNotificationsEnabledObserver
        .assertValues([true, false], "Push notification button was toggled")
    }
  }
}
