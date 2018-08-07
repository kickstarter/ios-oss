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
  internal let reloadData = TestObserver<User, NoError>()
  internal let unableToSaveError = TestObserver<String, NoError>()
  internal let updateCurrentUser = TestObserver<User, NoError>()
  internal let refreshFollowingSection = TestObserver<Void, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.reloadData.observe(self.reloadData.observer)
    self.vm.outputs.unableToSaveError.observe(self.unableToSaveError.observer)
    self.vm.outputs.updateCurrentUser.observe(self.updateCurrentUser.observer)
    self.vm.outputs.refreshFollowingSection.observe(self.refreshFollowingSection.observer)
  }

  func testReloadData() {
    let user = User.template

    self.vm.configureWith(user: user)
    self.vm.inputs.viewDidLoad()

    self.reloadData.assertValues([user])
  }

  func testUnableToSaveError() {
    let error = ErrorEnvelope(
      errorMessages: ["Unable to save."],
      ksrCode: .UnknownCode,
      httpCode: 400,
      exception: nil
    )

    withEnvironment(apiService: MockService(updateUserSelfError: error)) {
      let user = User.template
          |> User.lens.social .~ true

      self.vm.configureWith(user: user)
      self.vm.inputs.viewDidLoad()
      self.vm.followingSwitchTapped(on: true, didShowPrompt: false)

      self.scheduler.advance()

      self.unableToSaveError.assertValueCount(1)
    }
  }

  func testUpdateCurrentUser() {
    let user = User.template
      |> User.lens.social .~ true

    self.vm.configureWith(user: user)
    self.vm.inputs.viewDidLoad()
    self.updateCurrentUser.assertValueCount(1)

    self.vm.followingSwitchTapped(on: true, didShowPrompt: false)
    self.updateCurrentUser.assertValueCount(2)

    self.vm.followingSwitchTapped(on: false, didShowPrompt: true)
    self.updateCurrentUser.assertValueCount(3)
  }
}
