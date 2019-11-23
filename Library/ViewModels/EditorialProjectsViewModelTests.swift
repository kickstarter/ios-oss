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
  private let imageName = TestObserver<String, Never>()
  private let titleLabelText = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.configureDiscoveryPageViewControllerWithParams
      .observe(self.configureDiscoveryPageViewControllerWithParams.observer)
    self.vm.outputs.dismiss.observe(self.dismiss.observer)
    self.vm.outputs.imageName.observe(self.imageName.observer)
    self.vm.outputs.titleLabelText.observe(self.titleLabelText.observer)
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

  func testImageName_GoRewardless() {
    self.imageName.assertDidNotEmitValue()

    self.vm.inputs.configure(with: .goRewardless)
    self.vm.inputs.viewDidLoad()

    self.imageName.assertValues(["go-rewardless-home"])
  }

  func testTitleLabel_GoRewardless() {
    self.titleLabelText.assertDidNotEmitValue()

    self.vm.inputs.configure(with: .goRewardless)
    self.vm.inputs.viewDidLoad()

    self.titleLabelText.assertValues([
      "This holiday season, support a project for no reward, just because it speaks to you."
    ])
  }
}
