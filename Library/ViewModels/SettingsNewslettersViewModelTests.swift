import Foundation
import XCTest
import ReactiveSwift
import Result
import Prelude
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class SettingsNewslettersViewModelTests: TestCase {
  let vm = SettingsNewslettersViewModel()

  let initialUser = TestObserver<User, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.initialUser.observe(self.initialUser.observer)
  }

  func testInitialUserEmits_OnViewDidLoad() {

    let user = User.template

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))

    self.initialUser.assertValueCount(0)

    self.vm.inputs.viewDidLoad()
    self.initialUser.assertValueCount(1, "initialUser should emit after viewDidLoad.")
  }
}

