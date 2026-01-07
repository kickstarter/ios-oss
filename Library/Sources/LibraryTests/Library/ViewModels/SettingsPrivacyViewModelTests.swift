import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class SettingsPrivacyViewModelTests: TestCase {
  let vm = SettingsPrivacyViewModel()
  internal let focusScreenReaderOnFollowingCell = TestObserver<Void, Never>()
  internal let reloadData = TestObserver<User, Never>()
  internal let resetFollowingSection = TestObserver<Void, Never>()
  internal let unableToSaveError = TestObserver<String, Never>()
  internal let updateCurrentUser = TestObserver<User, Never>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.focusScreenReaderOnFollowingCell.observe(self.focusScreenReaderOnFollowingCell.observer)
    self.vm.outputs.reloadData.observe(self.reloadData.observer)
    self.vm.outputs.resetFollowingSection.observe(self.resetFollowingSection.observer)
    self.vm.outputs.unableToSaveError.observe(self.unableToSaveError.observer)
    self.vm.outputs.updateCurrentUser.observe(self.updateCurrentUser.observer)
  }

  func testFocusScreenReaderOnFollowingCel() {
    withEnvironment(isVoiceOverRunning: { true }) {
      self.vm.inputs.didCancelSocialOptOut()

      self.scheduler.advance()

      self.focusScreenReaderOnFollowingCell.assertValueCount(1)

      self.vm.inputs.didConfirmSocialOptOut()

      self.scheduler.advance()

      self.focusScreenReaderOnFollowingCell.assertValueCount(2)
    }
  }

  func testResetFollowingSection_WhenCancelingSocialOptOut() {
    let user = User.template
      |> \.social .~ true

    let mockService = MockService(fetchUserSelfResponse: user)

    withEnvironment(apiService: mockService, currentUser: user) {
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.didCancelSocialOptOut()

      self.scheduler.advance()

      self.resetFollowingSection.assertValueCount(1)
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
    self.vm.viewDidLoad()

    self.vm.didCancelSocialOptOut()
    self.updateCurrentUser.assertValueCount(0)

    self.vm.didConfirmSocialOptOut()

    self.scheduler.advance()

    self.updateCurrentUser.assertValueCount(1)
  }

  func testUpdateCurrentUser() {
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
      |> UserAttribute.privacy(.showPublicProfile).keyPath .~ false
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
