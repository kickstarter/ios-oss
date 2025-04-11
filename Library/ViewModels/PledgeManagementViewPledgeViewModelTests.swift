@testable import KsApi
@testable import Library
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class PledgeManagementViewPledgeViewModelTests: TestCase {
  private let vm: PledgeManagementViewPledgeViewModelType = PledgeManagementViewPledgeViewModel()
  private let webViewLoadRequest = TestObserver<URLRequest, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.webViewLoadRequest.observe(self.webViewLoadRequest.observer)
  }

  func testLoadWebViewRequest() {
    let project = Project.template
    let urlString =
      "\(AppEnvironment.current.apiService.serverConfig.webBaseUrl)/projects/\(project.creator.id)/\(project.slug)/backing/details"
    let request = AppEnvironment.current.apiService.preparedRequest(
      forURL: URL(string: urlString)!
    )

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.webViewLoadRequest.assertValues([request])
  }
}
