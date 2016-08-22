import XCTest
@testable import Library
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers
import Result
import KsApi
import Prelude

final class CheckoutViewModelTests: TestCase {
  private let vm: CheckoutViewModelType = CheckoutViewModel()

  private let closeLoginTout = TestObserver<Void, NoError>()
  private let openLoginTout = TestObserver<Void, NoError>()
  private let popViewController = TestObserver<Void, NoError>()
  private let webViewLoadRequest = TestObserver<NSURLRequest, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.closeLoginTout.observe(self.closeLoginTout.observer)
    self.vm.outputs.openLoginTout.observe(self.openLoginTout.observer)
    self.vm.outputs.popViewController.observe(self.popViewController.observer)
    self.vm.outputs.webViewLoadRequest.observe(self.webViewLoadRequest.observer)
  }

  func testFlow() {
    self.vm.inputs.configureWith(project: .template, reward: nil, intent: .new)
    self.webViewLoadRequest.assertValueCount(0)

    self.vm.inputs.viewDidLoad()
    self.webViewLoadRequest.assertValueCount(1)
  }

  private func preparedRequest(forRequest request: NSURLRequest) -> NSURLRequest {
    return AppEnvironment.current.apiService.preparedRequest(forRequest: request)
  }
}
