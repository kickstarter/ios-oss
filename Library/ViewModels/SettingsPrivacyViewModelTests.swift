import Foundation
import XCTest
import ReactiveSwift
import Result
import Prelude
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class SettingsPrivacyViewModelTests: TestCase {
  let vm = SettingsPrivacyViewModel()
  internal let refreshFollowingSection = TestObserver<Void, NoError>()
  internal let reloadData = TestObserver<User, NoError>()
  internal let unableToSaveError = TestObserver<String, NoError>()
  internal let updateCurrentUser = TestObserver<User, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.refreshFollowingSection.observe(self.refreshFollowingSection.observer)
    self.vm.outputs.reloadData.observe(self.reloadData.observer)
    self.vm.outputs.unableToSaveError.observe(self.unableToSaveError.observer)
    self.vm.outputs.updateCurrentUser.observe(self.updateCurrentUser.observer)
  }

  func testRefreshFollowingSection() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.followingSwitchTapped(on: false, didShowPrompt: false)

    self.updateCurrentUser.assertValueCount(1)
    self.refreshFollowingSection.assertValueCount(1)
  }

  func testReloadData() {
    let user = User.template
    let mockService = MockService(fetchUserSelfResponse: user)

    withEnvironment(apiService: mockService, currentUser: user) {
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.reloadData.assertValues([user, user], "Reload data event fires twice: once for the prefixed currentUser, and once with the updated response from the server")
    }
  }

  func testUnableToSaveError() {
    let error = ErrorEnvelope(
      errorMessages: ["Unable to save."],
      ksrCode: .UnknownCode,
      httpCode: 400,
      exception: nil
    )

    withEnvironment(apiService: MockService(updateUserSelfError: error)) {
      self.vm.inputs.viewDidLoad()
      self.vm.followingSwitchTapped(on: true, didShowPrompt: false)

      self.scheduler.advance()

      self.unableToSaveError.assertValueCount(1)
    }
  }

  func testUpdateCurrentUser() {
    let mockService = MockService(fetchUserSelfResponse: User.template)
    withEnvironment(apiService: mockService) {
      self.vm.inputs.viewDidLoad()
      self.updateCurrentUser.assertValueCount(0)

      self.vm.followingSwitchTapped(on: true, didShowPrompt: false)
      self.updateCurrentUser.assertValueCount(0)

      self.vm.followingSwitchTapped(on: false, didShowPrompt: true)

      self.scheduler.advance()

      self.updateCurrentUser.assertValueCount(1)
    }
  }
}
