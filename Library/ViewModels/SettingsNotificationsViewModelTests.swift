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

  let goToManageProjectNotifications = TestObserver<Void, NoError>()
  let pickerViewIsHidden = TestObserver<Bool, NoError>()
  let pickerViewSelectedRow = TestObserver<EmailFrequency, NoError>()
  let unableToSaveError = TestObserver<String, NoError>()
  let updateCurrentUser = TestObserver<User, NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.goToManageProjectNotifications
      .observe(self.goToManageProjectNotifications.observer)
    self.vm.outputs.pickerViewIsHidden.observe(self.pickerViewIsHidden.observer)
    self.vm.outputs.pickerViewSelectedRow.observe(self.pickerViewSelectedRow.observer)
    self.vm.outputs.unableToSaveError.observe(self.unableToSaveError.observer)
    self.vm.outputs.updateCurrentUser.observe(self.updateCurrentUser.observer)
  }

  func testGoToManageProjectNotifications() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.didSelectRow(cellType: .projectNotifications)
    self.goToManageProjectNotifications
      .assertValueCount(1, "Go to manage project notifications screen.")
  }

  func testUpdateError() {
    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.viewDidLoad()
    self.updateCurrentUser.assertValueCount(2, "Begin with environment's current user and refresh.")
    self.vm.inputs.failedToUpdateUser(error: "Unable to save")
    self.unableToSaveError.assertValueCount(1, "Unable to save")
    self.updateCurrentUser.assertValueCount(2, "User is not updated")
  }

  func testUpdateUser() {
    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.viewDidLoad()
    self.updateCurrentUser.assertValueCount(2, "Begin with environment's current user and refresh.")

    self.vm.inputs.updateUser(user: user)

    self.updateCurrentUser.assertValueCount(3, "User should be updated.")
  }

  func testCorrectPickerViewRowSelected() {
    let user = User.template
      |> UserAttribute.notification(.creatorDigest).keyPath .~ true

    let mockService = MockService(fetchUserSelfResponse: user)

    withEnvironment(apiService: mockService, currentUser: user) {
      self.vm.viewDidLoad()

      self.pickerViewSelectedRow.assertLastValue(EmailFrequency.daily)
    }
  }

  func testEmailFrequencySelected_updateSuccess() {
    let user = User.template
      |> UserAttribute.notification(.creatorDigest).keyPath .~ true

    let mockService = MockService(fetchUserSelfResponse: user)

    withEnvironment(apiService: mockService, currentUser: user) {
      self.vm.viewDidLoad()

      self.updateCurrentUser.assertValueCount(2)

      self.pickerViewSelectedRow.assertLastValue(EmailFrequency.daily)

      self.vm.inputs.didSelectEmailFrequency(frequency: EmailFrequency.individualEmails)

      self.scheduler.advance()

      self.updateCurrentUser.assertValueCount(3)
      self.pickerViewIsHidden.assertLastValue(true)
      self.pickerViewSelectedRow.assertLastValue(EmailFrequency.individualEmails)
    }
  }

  func testEmailFrequencySelected_updateError() {
    let user = User.template
      |> UserAttribute.notification(.creatorDigest).keyPath .~ true

    let errorEnvelope = ErrorEnvelope(errorMessages: ["Something went wrong"],
                              ksrCode: nil,
                              httpCode: 500,
                              exception: nil)

    let mockService = MockService(fetchUserSelfResponse: user,
                                  updateUserSelfError: errorEnvelope)

    withEnvironment(apiService: mockService, currentUser: user) {
      self.vm.viewDidLoad()

      self.updateCurrentUser.assertValueCount(2)

      self.pickerViewSelectedRow.assertLastValue(EmailFrequency.daily)

      self.vm.inputs.didSelectEmailFrequency(frequency: EmailFrequency.individualEmails)

      self.scheduler.advance()

      self.updateCurrentUser.assertValueCount(2)
      self.pickerViewIsHidden.assertLastValue(true)
      self.pickerViewSelectedRow.assertLastValue(EmailFrequency.daily)
      self.unableToSaveError.assertValueCount(1)
    }
  }

  func testShowHidePickerView() {
    self.vm.inputs.viewDidLoad()

    self.pickerViewIsHidden.assertDidNotEmitValue()

    self.vm.inputs.didSelectRow(cellType: .emailFrequency)

    self.pickerViewIsHidden.assertValues([false], "Picker view should not be hidden")
  }
}
