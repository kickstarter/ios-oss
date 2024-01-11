@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class SettingsDeleteOrRequestCellViewModelTests: TestCase {
  internal let vm = SettingsDeleteOrRequestCellViewModel()
  internal let notifyDeleteAccountTapped = TestObserver<URL, Never>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.notifyDeleteAccountTapped.observe(self.notifyDeleteAccountTapped.observer)
  }

  func testNotifyDeleteAccountTapped() {
    let user = User.template
    let url = URL(string: "https://legal.kickstarter.com/policies/en/?modal=take-control")!
    self.vm.inputs.configureWith(user: user)
    self.vm.inputs.deleteAccountTapped()
    self.notifyDeleteAccountTapped.assertValues([url])
  }
}
