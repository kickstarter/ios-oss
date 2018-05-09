@testable import Library
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

    self.webViewLoadRequest.assertValues(["/cookies", "https://help.kickstarter.com/hc"])

    self.vm.inputs.configureWith(helpType: .howItWorks)
    self.vm.inputs.viewDidLoad()

    self.webViewLoadRequest.assertValues(["/cookies", "https://help.kickstarter.com/hc", "/about"])

    self.vm.inputs.configureWith(helpType: .privacy)
    self.vm.inputs.viewDidLoad()

    self.webViewLoadRequest.assertValues(
      ["/cookies", "https://help.kickstarter.com/hc", "/about", "/privacy"]
    )

    self.vm.inputs.configureWith(helpType: .terms)
    self.vm.inputs.viewDidLoad()

    self.webViewLoadRequest.assertValues(["/cookies", "https://help.kickstarter.com/hc", "/about", "/privacy",
      "/terms-of-use"])
  }

  private func urlFrom(request: URLRequest) -> String {
    guard let relativePath = request.url?.relativePath else { return "" }

    let helpCenterUrl = request.url?.absoluteString.components(separatedBy: "?").first ?? ""
    return relativePath == "/hc" ? helpCenterUrl : relativePath
  }
}
