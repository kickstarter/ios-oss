@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class RiskMessagingViewModelTests: TestCase {
  let vm: RiskMessagingViewModelType = RiskMessagingViewModel()

  private let dismissAndNotifyDelegate = TestObserver<Bool, Never>()
  private let presentHelpWebViewController = TestObserver<Void, Never>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.dismissAndNotifyDelegate.observe(self.dismissAndNotifyDelegate.observer)
    self.vm.outputs.presentHelpWebViewController.observe(self.presentHelpWebViewController.observer)
  }

  func testDismissAndNotifiyDelegate() {
    self.vm.inputs.configure(isApplePay: false)

    self.dismissAndNotifyDelegate.assertDidNotEmitValue()

    self.vm.inputs.confirmButtonTapped()

    self.dismissAndNotifyDelegate.assertDidEmitValue()
    self.dismissAndNotifyDelegate.assertValue(false)
  }

  func testPresentHelpWebViewController() {
    self.vm.inputs.configure(isApplePay: false)

    self.presentHelpWebViewController.assertDidNotEmitValue()

    self.vm.inputs.footnoteLabelTapped()

    self.presentHelpWebViewController.assertDidEmitValue()
  }
}
