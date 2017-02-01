import Prelude
import ReactiveSwift
import Result
import WebKit
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class WebModalViewModelTests: TestCase {
  fileprivate let vm: WebModalViewModelType = WebModalViewModel()

  fileprivate let dismissViewController = TestObserver<Void, NoError>()
  fileprivate let webViewLoadRequest = TestObserver<URLRequest, NoError>()
  fileprivate let webViewLoadRequestIsPrepared = TestObserver<Bool, NoError>()

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
      navigationAction: WKNavigationActionData(
        navigationType: .other,
        request: request,
        sourceFrame: WKFrameInfoData(mainFrame: true, request: request),
        targetFrame: WKFrameInfoData(mainFrame: true, request: request)
      )
    )

    XCTAssertEqual(WKNavigationActionPolicy.allow.rawValue, decision.rawValue)
  }

  fileprivate let request = URLRequest(url: URL(string: "https://www.kickstarter.com/projects/tfw/ijc")!)
}
