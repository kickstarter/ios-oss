@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class PledgeDisclaimerViewModelTests: TestCase {
  private let vm: PledgeDisclaimerViewModelType = PledgeDisclaimerViewModel()

  private let notifyDelegatePresentTrustAndSafety = TestObserver<Void, Never>()

  override func setUp() {
    self.vm.outputs.notifyDelegatePresentTrustAndSafety
      .observe(self.notifyDelegatePresentTrustAndSafety.observer)
  }

  func testPresentTrustAndSafety() {
    self.vm.inputs.learnMoreTapped()

    self.notifyDelegatePresentTrustAndSafety.assertDidEmitValue()
  }
}
