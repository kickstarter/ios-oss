@testable import KsApi
@testable import Library
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class PledgeManagementViewPledgeViewModelTests: TestCase {
  private let vm: PledgeManagementDetailsViewModelType = PledgeManagementDetailsViewModel()
  private let webViewLoadRequest = TestObserver<URLRequest, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.webViewLoadRequest.observe(self.webViewLoadRequest.observer)
  }

  func testLoadWebViewRequest() {
    let url =
      URL(string: "\(AppEnvironment.current.apiService.serverConfig.webBaseUrl)/projects/backing/details")!
    let request = AppEnvironment.current.apiService.preparedRequest(
      forURL: url
    )

    self.vm.inputs.configure(with: url)
    self.vm.inputs.viewDidLoad()

    self.webViewLoadRequest.assertValues([request])
  }
}
