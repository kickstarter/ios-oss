@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

import XCTest

final class PledgeDisclaimerViewModelTests: TestCase {
  private let vm: PledgeDisclaimerViewModelType = PledgeDisclaimerViewModel()

  private let presentTrustAndSafety = TestObserver<Void, Never>()

  override func setUp() {
    self.vm.outputs.presentTrustAndSafety.observe(self.presentTrustAndSafety.observer)
  }

  func testPresentTrustAndSafety() {
    self.vm.inputs.learnMoreTapped()

    self.presentTrustAndSafety.assertDidEmitValue()
  }
}
