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
    let user = User.template
    |> User.lens.social .~ true

    let mockService = MockService(fetchUserSelfResponse: user)

    withEnvironment(apiService: mockService, currentUser: user) {
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.didCancelSocialOptOut()

      self.scheduler.advance()

      self.refreshFollowingSection.assertValueCount(1)
    }
  }

  func testReloadData() {
    let user = User.template
    let mockService = MockService(fetchUserSelfResponse: user)

    withEnvironment(apiService: mockService, currentUser: user) {
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.reloadData.assertValues([user, user])
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

      self.vm.inputs.didConfirmSocialOptOut()

      self.scheduler.advance()

      self.unableToSaveError.assertValueCount(1)
    }
  }

  func testFollowingSwitchTapped_updatesCurrentUser() {

    let mockService = MockService(fetchUserSelfResponse: User.template)
    withEnvironment(apiService: mockService) {
      self.vm.inputs.viewDidLoad()
      self.updateCurrentUser.assertValueCount(0)

      self.vm.inputs.didCancelSocialOptOut()
      self.updateCurrentUser.assertValueCount(0)

      self.vm.inputs.didConfirmSocialOptOut()
      self.scheduler.advance()

      self.updateCurrentUser.assertValueCount(1)
    }
  }

  func testPrivateProfileToggled_updatesCurrentUser() {
    let updatedUser = User.template
      |> UserAttribute.privacy(.showPublicProfile).lens .~ false
    let mockService = MockService(fetchUserSelfResponse: User.template)

    withEnvironment(apiService: mockService) {
      self.vm.inputs.viewDidLoad()
      self.updateCurrentUser.assertValueCount(0)

      self.vm.privateProfileToggled(on: true)

      self.scheduler.advance()

      self.updateCurrentUser.assertValue(updatedUser)
    }
  }
}
