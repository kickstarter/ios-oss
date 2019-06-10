@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class SettingsFollowCellViewModelTests: TestCase {
  internal let vm = SettingsFollowCellViewModel()

  internal let followingPrivacyOn = TestObserver<Bool, Never>()
  internal let showPrivacyFollowingPrompt = TestObserver<(), Never>()
  internal let updateCurrentUser = TestObserver<User, Never>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.followingPrivacyOn.observe(self.followingPrivacyOn.observer)
    self.vm.outputs.showPrivacyFollowingPrompt.observe(self.showPrivacyFollowingPrompt.observer)
    self.vm.outputs.updateCurrentUser.observe(self.updateCurrentUser.observer)
  }

  func testPresentPrivacyFollowingPrompt() {
    let user = User.template
      |> \.social .~ true

    self.vm.inputs.configureWith(user: user)
    self.followingPrivacyOn.assertValues([true])
    self.vm.inputs.followTapped(on: true)
    self.showPrivacyFollowingPrompt.assertValueCount(0)
  }

  func testFollowPrivacyToggleOn() {
    let user = User.template
      |> \.social .~ false

    self.vm.inputs.configureWith(user: user)
    self.followingPrivacyOn.assertValues([false])
  }

  func testFollowPrivacyToggleOff() {
    let user = User.template
      |> \.social .~ true

    self.vm.inputs.configureWith(user: user)
    self.followingPrivacyOn.assertValues([true])
  }

  func testFollowOptingOut() {
    let user = User.template
      |> \.social .~ true

    self.vm.inputs.configureWith(user: user)
    self.followingPrivacyOn.assertValues([true])

    self.vm.inputs.followTapped(on: false)
    self.showPrivacyFollowingPrompt.assertValueCount(1)

    let userOptedOut = User.template
      |> \.social .~ false

    self.vm.inputs.configureWith(user: userOptedOut)
    self.followingPrivacyOn.assertValues([true, false])
  }

  func testUpdateCurrentUser() {
    let user = User.template
    self.vm.inputs.configureWith(user: user)
    self.updateCurrentUser.assertValueCount(0)
    self.vm.inputs.followTapped(on: true)
    self.updateCurrentUser.assertValueCount(1)
    self.vm.inputs.followTapped(on: true)
    self.updateCurrentUser.assertValueCount(2)
  }
}
