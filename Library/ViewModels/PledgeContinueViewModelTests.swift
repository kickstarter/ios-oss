@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class PledgeContinueViewModelTests: TestCase {
  private let vm = PledgeContinueViewModel()

  private let goToLoginSignup = TestObserver<LoginIntent, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.goToLoginSignup.observe(self.goToLoginSignup.observer)
  }

  func testGoToLoginSignup() {
    self.goToLoginSignup.assertDidNotEmitValue()

    self.vm.inputs.continueButtonTapped()

    self.goToLoginSignup.assertValues([LoginIntent.backProject])

    self.vm.inputs.continueButtonTapped()

    self.goToLoginSignup.assertValues([LoginIntent.backProject, LoginIntent.backProject])
  }
}
