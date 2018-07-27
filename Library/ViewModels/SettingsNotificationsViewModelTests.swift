import Foundation
import XCTest
import ReactiveSwift
import Result
import Prelude
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class SettingsNotificationsViewModelTests: TestCase {
  let vm = SettingsNotificationsViewModel()

  let goToEmailFrequency = TestObserver<User, NoError>()
  let goToFindFriends = TestObserver<Void, NoError>()
  let goToManageProjectNotifications = TestObserver<Void, NoError>()
  let unableToSaveError = TestObserver<String, NoError>()
  let updateCurrentUser = TestObserver<User, NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.goToEmailFrequency.observe(self.goToEmailFrequency.observer)
    self.vm.outputs.goToFindFriends.observe(self.goToFindFriends.observer)
    self.vm.outputs.goToManageProjectNotifications.observe(self.goToManageProjectNotifications.observer)
    self.vm.outputs.unableToSaveError.observe(self.unableToSaveError.observer)
    self.vm.outputs.updateCurrentUser.observe(self.updateCurrentUser.observer)
  }

  func testGoToFindFriends() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.didSelectRow(cellType: .findFacebookFriends)
    self.goToFindFriends.assertValueCount(1, "Go to Find Friends screen.")
  }

  func testGoToManageProjectNotifications() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.didSelectRow(cellType: .projectNotifications)
    self.goToManageProjectNotifications.assertValueCount(1, "Go to manage project notifications screen.")
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
}
