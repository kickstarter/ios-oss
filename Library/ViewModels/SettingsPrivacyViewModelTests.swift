import Foundation
import XCTest
import ReactiveSwift
import Result
import Prelude
@testable import KsApi
@testable import Library
import ReactiveExtensions_TestHelpers

internal final class SettingsPrivacyViewModelTests: TestCase {
  let vm = SettingsPrivacyViewModel()
  internal let focusScreenReaderOnFollowingCell = TestObserver<Void, NoError>()
  internal let reloadData = TestObserver<User, NoError>()
  internal let resetFollowingSection = TestObserver<Void, NoError>()
  internal let unableToSaveError = TestObserver<String, NoError>()
  internal let updateCurrentUser = TestObserver<User, NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.focusScreenReaderOnFollowingCell.observe(self.focusScreenReaderOnFollowingCell.observer)
    self.vm.outputs.reloadData.observe(self.reloadData.observer)
    self.vm.outputs.resetFollowingSection.observe(self.resetFollowingSection.observer)
    self.vm.outputs.unableToSaveError.observe(self.unableToSaveError.observer)
    self.vm.outputs.updateCurrentUser.observe(self.updateCurrentUser.observer)
  }

  func testFocusScreenReaderOnFollowingCel() {
    let isVoiceOverRunning = { true }
    withEnvironment(isVoiceOverRunning: isVoiceOverRunning) {
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
