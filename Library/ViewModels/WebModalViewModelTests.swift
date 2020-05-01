@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import WebKit
import XCTest

internal final class WebModalViewModelTests: TestCase {
  fileprivate let vm: WebModalViewModelType = WebModalViewModel()

  fileprivate let dismissViewController = TestObserver<Void, Never>()
  fileprivate let webViewLoadRequest = TestObserver<URLRequest, Never>()
  fileprivate let webViewLoadRequestIsPrepared = TestObserver<Bool, Never>()

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
    self.vm.inputs.configureWith(request: self.request)
    self.vm.inputs.viewDidLoad()

    self.webViewLoadRequest.assertValueCount(1)
    self.webViewLoadRequestIsPrepared.assertValues([true])

    let decision = self.vm.inputs.decidePolicyFor(
      navigationAction: WKNavigationActionData(
        navigationType: .other,
        request: self.request,
        sourceFrame: WKFrameInfoData(mainFrame: true, request: self.request),
        targetFrame: WKFrameInfoData(mainFrame: true, request: self.request)
      )
    )

    XCTAssertEqual(WKNavigationActionPolicy.allow.rawValue, decision.rawValue)
  }

  fileprivate let request = URLRequest(url: URL(string: "https://www.kickstarter.com/projects/tfw/ijc")!)
}
