import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class PledgeScreenCTAContainerViewModelTests: TestCase {
  let vm: PledgeScreenCTAContainerViewModelType = PledgeScreenCTAContainerViewModel()
  private let notifyDelegateApplePayButtonTapped = TestObserver<Void, Never>()
  private let notifyDelegatePledgeButtonTapped = TestObserver<Void, Never>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.notifyDelegateApplePayButtonTapped
      .observe(self.notifyDelegateApplePayButtonTapped.observer)
    self.vm.outputs.notifyDelegatePledgeButtonTapped.observe(self.notifyDelegatePledgeButtonTapped.observer)
  }

  func testApplePayButtonTapped() {
    self.notifyDelegateApplePayButtonTapped.assertDidNotEmitValue()

    self.vm.inputs.applePayButtonTapped()

    self.notifyDelegateApplePayButtonTapped.assertValueCount(1)
  }

  func testPledgeButtonTapped() {
    self.notifyDelegatePledgeButtonTapped.assertDidNotEmitValue()

    self.vm.inputs.pledgeCTAButtonTapped()

    self.notifyDelegatePledgeButtonTapped.assertValueCount(1)
  }
}
