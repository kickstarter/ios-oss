import Prelude
import ReactiveCocoa
import Result
import WebKit
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class WebModalViewModelTests: TestCase {
  private let vm: WebModalViewModelType = WebModalViewModel()

  private let dismissViewController = TestObserver<Void, NoError>()
  private let webViewLoadRequest = TestObserver<NSURLRequest, NoError>()
  private let webViewLoadRequestIsPrepared = TestObserver<Bool, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.dismissViewController.observe(self.dismissViewController.observer)
    self.vm.outputs.webViewLoadRequest.observe(self.webViewLoadRequest.observer)
    self.vm.outputs.webViewLoadRequest.map { AppEnvironment.current.apiService.isPrepared(request: $0) }
      .observe(self.webViewLoadRequestIsPrepared.observer)
  }

  func testDismissViewControllerOnCloseButtonTapped() {

    self.vm.inputs.configureWith(request: self.request)
    self.vm.inputs.viewDidLoad()
    self.dismissViewController.assertDidNotEmitValue()

    self.vm.inputs.closeButtonTapped()
    self.dismissViewController.assertValueCount(1)
  }

  func testWebViewLoadRequest() {

    self.vm.inputs.configureWith(request: request)
    self.vm.inputs.viewDidLoad()

    self.webViewLoadRequest.assertValueCount(1)
    self.webViewLoadRequestIsPrepared.assertValues([true])

    let decision = self.vm.inputs.decidePolicyFor(
      navigationAction: MockNavigationAction(
        navigationType: .Other,
        request: request
      )
    )

    XCTAssertEqual(WKNavigationActionPolicy.Allow.rawValue, decision.rawValue)
  }

  private let request = NSURLRequest(URL: NSURL(string: "https://www.kickstarter.com/projects/tfw/ijc")!)
}
