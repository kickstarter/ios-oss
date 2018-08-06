import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers

internal final class SettingsDeleteAccountCellViewModelTests: TestCase {
  internal let vm = SettingsDeleteAccountCellViewModel()
  internal let notifyDeleteAccountTapped = TestObserver<URL, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.notifyDeleteAccountTapped.observe(self.notifyDeleteAccountTapped.observer)
  }

  func testNotifyDeleteAccountTapped() {
    let user = User.template
    let url =
      AppEnvironment.current.apiService.serverConfig.webBaseUrl.appendingPathComponent("/profile/destroy")
    self.vm.inputs.configureWith(user: user)
    self.vm.inputs.deleteAccountTapped()
    self.notifyDeleteAccountTapped.assertValues([url])
  }
}
