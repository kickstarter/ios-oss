import Foundation
import XCTest
import ReactiveSwift
import Result
import Prelude
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers
@testable import Kickstarter_Framework

internal final class SettingsNotificationsViewModelTests: TestCase {
  let vm = SettingsNotificationsViewModel()

  let goToFindFriendsObserver = TestObserver<Void, NoError>()
  let goToManageProjectNotificationsObserver = TestObserver<Void, NoError>()
  let pickerViewIsHiddenObserver = TestObserver<Bool, NoError>()
  let pickerViewSelectedRowObserver = TestObserver<EmailFrequency, NoError>()
  let unableToSaveErrorObserver = TestObserver<String, NoError>()
  let updateCurrentUserObserver = TestObserver<User, NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.goToFindFriends.observe(self.goToFindFriendsObserver.observer)
    self.vm.outputs.goToManageProjectNotifications
      .observe(self.goToManageProjectNotificationsObserver.observer)
    self.vm.outputs.pickerViewIsHidden.observe(self.pickerViewIsHiddenObserver.observer)
    self.vm.outputs.pickerViewSelectedRow.observe(self.pickerViewSelectedRowObserver.observer)
    self.vm.outputs.unableToSaveError.observe(self.unableToSaveErrorObserver.observer)
    self.vm.outputs.updateCurrentUser.observe(self.updateCurrentUserObserver.observer)
  }

  func testGoToFindFriends() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.didSelectRow(cellType: .findFacebookFriends)
    self.goToFindFriendsObserver.assertValueCount(1, "Go to Find Friends screen.")
  }

  func testGoToManageProjectNotifications() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.didSelectRow(cellType: .projectNotifications)
    self.goToManageProjectNotificationsObserver
      .assertValueCount(1, "Go to manage project notifications screen.")
  }

  func testUpdateError() {
    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.viewDidLoad()
    self.updateCurrentUserObserver.assertValueCount(2, "Begin with environment's current user and refresh.")
    self.vm.inputs.failedToUpdateUser(error: "Unable to save")
    self.unableToSaveErrorObserver.assertValueCount(1, "Unable to save")
    self.updateCurrentUserObserver.assertValueCount(2, "User is not updated")
  }

  func testUpdateUser() {
    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.viewDidLoad()
    self.updateCurrentUserObserver.assertValueCount(2, "Begin with environment's current user and refresh.")

    self.vm.inputs.updateUser(user: user)

    self.updateCurrentUserObserver.assertValueCount(3, "User should be updated.")
  }

  func testCorrectPickerViewRowSelected() {
    let user = User.template
      |> UserAttribute.notification(.creatorDigest).lens .~ true

    let mockService = MockService(fetchUserSelfResponse: user)

    withEnvironment(apiService: mockService, currentUser: user) {
      self.vm.viewDidLoad()

      self.pickerViewSelectedRowObserver.assertLastValue(EmailFrequency.daily)
    }
  }

  func testEmailFrequencySelected_updateSuccess() {
    let user = User.template
      |> UserAttribute.notification(.creatorDigest).lens .~ true

    let mockService = MockService(fetchUserSelfResponse: user)

    withEnvironment(apiService: mockService, currentUser: user) {
      self.vm.viewDidLoad()

      self.updateCurrentUserObserver.assertValueCount(2)

      self.pickerViewSelectedRowObserver.assertLastValue(EmailFrequency.daily)

      self.vm.inputs.didSelectEmailFrequency(frequency: EmailFrequency.individualEmails)

      self.scheduler.advance()

      self.updateCurrentUserObserver.assertValueCount(3)
      self.pickerViewIsHiddenObserver.assertLastValue(true)
      self.pickerViewSelectedRowObserver.assertLastValue(EmailFrequency.individualEmails)
    }
  }

  func testEmailFrequencySelected_updateError() {
    let user = User.template
      |> UserAttribute.notification(.creatorDigest).lens .~ true

    let errorEnvelope = ErrorEnvelope(errorMessages: ["Something went wrong"],
                              ksrCode: nil,
                              httpCode: 500,
                              exception: nil)

    let mockService = MockService(fetchUserSelfResponse: user,
                                  updateUserSelfError: errorEnvelope)

    withEnvironment(apiService: mockService, currentUser: user) {
      self.vm.viewDidLoad()

      self.updateCurrentUserObserver.assertValueCount(2)

      self.pickerViewSelectedRowObserver.assertLastValue(EmailFrequency.daily)

      self.vm.inputs.didSelectEmailFrequency(frequency: EmailFrequency.individualEmails)

      self.scheduler.advance()

      self.updateCurrentUserObserver.assertValueCount(2)
      self.pickerViewIsHiddenObserver.assertLastValue(true)
      self.pickerViewSelectedRowObserver.assertLastValue(EmailFrequency.daily)
      self.unableToSaveErrorObserver.assertValueCount(1)
    }
  }

  func testShowPickerView() {
    self.vm.inputs.viewDidLoad()

    self.pickerViewIsHiddenObserver.assertDidNotEmitValue()

    self.vm.inputs.didTapFrequencyPickerButton()

    self.pickerViewIsHiddenObserver.assertValues([false], "Picker view should not be hidden")

    self.vm.inputs.didTapFrequencyPickerButton()

    self.pickerViewIsHiddenObserver.assertValues([false, true], "Picker view should be hidden")
  }
}
