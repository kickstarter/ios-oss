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

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.reloadData.observe(self.reloadData.observer)
    self.vm.outputs.unableToSaveError.observe(self.unableToSaveError.observer)
    self.vm.outputs.updateCurrentUser.observe(self.updateCurrentUser.observer)
  }

  func testReloadData() {
    let user = User.template

    self.vm.configureWith(user: user)
    self.vm.inputs.viewDidLoad()

    self.reloadData.assertValues([user])
  }

  // Do We need these outputs?
  func testUnableToSaveError() {

  }

  func testUpdateCurrentUser() {

  }
}
