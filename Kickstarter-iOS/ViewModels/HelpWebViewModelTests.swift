@testable import Library
@testable import KsApi
@testable import Kickstarter_Framework
@testable import ReactiveExtensions_TestHelpers
import Prelude
import ReactiveSwift
import Result
import XCTest

internal final class HelpWebViewModelTests: TestCase {
  fileprivate let vm: HelpWebViewModelType = HelpWebViewModel()

  fileprivate let webViewLoadRequest = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.webViewLoadRequest.map(urlFrom(request:))
      .observe(self.webViewLoadRequest.observer)
  }

  func testWebRequestURLString() {

    self.vm.inputs.configureWith(helpType: .cookie)

    self.webViewLoadRequest.assertValueCount(0)

    self.vm.inputs.viewDidLoad()

    self.webViewLoadRequest.assertValues(["/cookies"])

    self.vm.inputs.configureWith(helpType: .helpCenter)
    self.vm.inputs.viewDidLoad()

    self.webViewLoadRequest.assertValues(["/cookies", helpCenterUrl.absoluteString])

    self.vm.inputs.configureWith(helpType: .howItWorks)
    self.vm.inputs.viewDidLoad()

    self.webViewLoadRequest.assertValues(["/cookies", helpCenterUrl.absoluteString, "/about"])

    self.vm.inputs.configureWith(helpType: .privacy)
    self.vm.inputs.viewDidLoad()

    self.webViewLoadRequest.assertValues(
      ["/cookies", helpCenterUrl.absoluteString, "/about", "/privacy"]
    )

    self.vm.inputs.configureWith(helpType: .terms)
    self.vm.inputs.viewDidLoad()

    self.webViewLoadRequest.assertValues(["/cookies", helpCenterUrl.absoluteString, "/about", "/privacy",
      "/terms-of-use"])
  }

  private func urlFrom(request: URLRequest) -> String {

    guard let url = request.url else { return "" }

    let relativePath = request.url?.relativePath ?? ""
    return url.absoluteString.contains("help") ? helpCenterUrl.absoluteString : relativePath
  }
}
