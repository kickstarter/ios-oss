import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class PledgeViewCTAContainerViewModelTests: TestCase {
  let vm: PledgeViewCTAContainerViewModelType = PledgeViewCTAContainerViewModel()
  private let notifyDelegateApplePayButtonTapped = TestObserver<Void, Never>()
  private let notifyDelegateSubmitButtonTapped = TestObserver<Void, Never>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.notifyDelegateApplePayButtonTapped
      .observe(self.notifyDelegateApplePayButtonTapped.observer)
    self.vm.outputs.notifyDelegateSubmitButtonTapped.observe(self.notifyDelegateSubmitButtonTapped.observer)
  }

  func testApplePayButtonTapped() {
    self.notifyDelegateApplePayButtonTapped.assertDidNotEmitValue()

    self.vm.inputs.applePayButtonTapped()

    self.notifyDelegateApplePayButtonTapped.assertValueCount(1)
  }

  func testPledgeButtonTapped() {
    self.notifyDelegateSubmitButtonTapped.assertDidNotEmitValue()

    self.vm.inputs.submitButtonTapped()

    self.notifyDelegateSubmitButtonTapped.assertValueCount(1)
  }
}
