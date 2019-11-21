import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import XCTest

final class EditorialProjectsViewModelTests: TestCase {
  private let vm: EditorialProjectsViewModelType = EditorialProjectsViewModel()

  private let configureDiscoveryPageViewControllerWithParams = TestObserver<DiscoveryParams, Never>()
  private let dismiss = TestObserver<(), Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.configureDiscoveryPageViewControllerWithParams
      .observe(self.configureDiscoveryPageViewControllerWithParams.observer)
    self.vm.outputs.dismiss.observe(self.dismiss.observer)
  }

  func testConfigureDiscoveryPageViewControllerWithParams() {
    self.configureDiscoveryPageViewControllerWithParams.assertDidNotEmitValue()

    self.vm.inputs.configure(with: .goRewardless)
    self.vm.inputs.viewDidLoad()

    let expectedParams = DiscoveryParams.defaults
      |> \.tagId .~ .goRewardless

    self.configureDiscoveryPageViewControllerWithParams.assertValues([expectedParams])
  }

  func testDismiss() {
    self.dismiss.assertDidNotEmitValue()

    self.vm.inputs.closeButtonTapped()

    self.dismiss.assertValueCount(1)
  }
}
