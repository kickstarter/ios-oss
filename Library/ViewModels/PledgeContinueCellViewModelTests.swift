@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class PledgeContinueCellViewModelTests: TestCase {
  private let vm = PledgeContinueCellViewModel()

  private let goToLoginSignup = TestObserver<Void, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.notifyDelegateContinueButtonTapped.observe(self.goToLoginSignup.observer)
  }

  func testGoToLoginSignup() {
    self.goToLoginSignup.assertDidNotEmitValue()

    self.vm.inputs.continueButtonTapped()

    self.goToLoginSignup.assertValueCount(1)

    self.vm.inputs.continueButtonTapped()

    self.goToLoginSignup.assertValueCount(2)
  }
}
