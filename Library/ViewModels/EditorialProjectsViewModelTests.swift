import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import XCTest

final class EditorialProjectsViewModelTests: TestCase {
  private let vm: EditorialProjectsViewModelType = EditorialProjectsViewModel()

  private let applyViewTransformsWithY = TestObserver<CGFloat, Never>()
  private let configureDiscoveryPageViewControllerWithParams = TestObserver<DiscoveryParams, Never>()
  private let closeButtonImageTintColor = TestObserver<UIColor, Never>()
  private let dismiss = TestObserver<(), Never>()
  private let imageName = TestObserver<String, Never>()
  private let titleLabelText = TestObserver<String, Never>()
  private let setNeedsStatusBarAppearanceUpdate = TestObserver<(), Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.applyViewTransformsWithY.observe(self.applyViewTransformsWithY.observer)
    self.vm.outputs.configureDiscoveryPageViewControllerWithParams
      .observe(self.configureDiscoveryPageViewControllerWithParams.observer)
    self.vm.outputs.closeButtonImageTintColor.observe(self.closeButtonImageTintColor.observer)
    self.vm.outputs.dismiss.observe(self.dismiss.observer)
    self.vm.outputs.imageName.observe(self.imageName.observer)
    self.vm.outputs.titleLabelText.observe(self.titleLabelText.observer)
    self.vm.outputs.setNeedsStatusBarAppearanceUpdate.observe(self.setNeedsStatusBarAppearanceUpdate.observer)
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

  func testCloseButtonImageTintColor() {
    self.closeButtonImageTintColor.assertDidNotEmitValue()

    self.vm.inputs.configure(with: .goRewardless)
    self.vm.inputs.viewDidLoad()

    self.closeButtonImageTintColor.assertDidNotEmitValue()

    self.vm.inputs.contentOffsetChanged(to: .init(x: 0, y: -1))

    self.closeButtonImageTintColor.assertValues([.white])

    self.vm.inputs.contentOffsetChanged(to: .init(x: 0, y: 0))

    self.closeButtonImageTintColor.assertValues([.white, .ksr_soft_black])

    self.vm.inputs.contentOffsetChanged(to: .init(x: 0, y: 1))

    self.closeButtonImageTintColor.assertValues([.white, .ksr_soft_black])

    self.vm.inputs.contentOffsetChanged(to: .init(x: 0, y: 100))

    self.closeButtonImageTintColor.assertValues([.white, .ksr_soft_black])

    self.vm.inputs.contentOffsetChanged(to: .init(x: 0, y: -5))

    self.closeButtonImageTintColor.assertValues([.white, .ksr_soft_black, .white])

    self.vm.inputs.contentOffsetChanged(to: .init(x: 0, y: -100))

    self.closeButtonImageTintColor.assertValues([.white, .ksr_soft_black, .white])
  }

  func testPreferredStatusBarStyle() {
    self.setNeedsStatusBarAppearanceUpdate.assertDidNotEmitValue()
    XCTAssertEqual(.lightContent, self.vm.outputs.preferredStatusBarStyle())

    self.vm.inputs.configure(with: .goRewardless)
    self.vm.inputs.viewDidLoad()

    self.setNeedsStatusBarAppearanceUpdate.assertDidNotEmitValue()
    XCTAssertEqual(.lightContent, self.vm.outputs.preferredStatusBarStyle())

    self.vm.inputs.contentOffsetChanged(to: .init(x: 0, y: -1))

    self.setNeedsStatusBarAppearanceUpdate.assertValueCount(1)
    XCTAssertEqual(.lightContent, self.vm.outputs.preferredStatusBarStyle())

    self.vm.inputs.contentOffsetChanged(to: .init(x: 0, y: 0))

    self.setNeedsStatusBarAppearanceUpdate.assertValueCount(2)
    XCTAssertEqual(.default, self.vm.outputs.preferredStatusBarStyle())

    self.vm.inputs.contentOffsetChanged(to: .init(x: 0, y: 1))

    self.setNeedsStatusBarAppearanceUpdate.assertValueCount(2)
    XCTAssertEqual(.default, self.vm.outputs.preferredStatusBarStyle())

    self.vm.inputs.contentOffsetChanged(to: .init(x: 0, y: 100))

    self.setNeedsStatusBarAppearanceUpdate.assertValueCount(2)
    XCTAssertEqual(.default, self.vm.outputs.preferredStatusBarStyle())

    self.vm.inputs.contentOffsetChanged(to: .init(x: 0, y: -5))

    self.setNeedsStatusBarAppearanceUpdate.assertValueCount(3)
    XCTAssertEqual(.lightContent, self.vm.outputs.preferredStatusBarStyle())

    self.vm.inputs.contentOffsetChanged(to: .init(x: 0, y: -100))

    self.setNeedsStatusBarAppearanceUpdate.assertValueCount(3)
    XCTAssertEqual(.lightContent, self.vm.outputs.preferredStatusBarStyle())
  }

  func testApplyViewTransformsWithY() {
    self.applyViewTransformsWithY.assertDidNotEmitValue()

    self.vm.inputs.configure(with: .goRewardless)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.contentOffsetChanged(to: .init(x: 0, y: 100))

    self.applyViewTransformsWithY.assertValues([100])

    self.vm.inputs.contentOffsetChanged(to: .init(x: 0, y: 250))

    self.applyViewTransformsWithY.assertValues([100, 250])

    self.vm.inputs.contentOffsetChanged(to: .init(x: 0, y: 350))

    self.applyViewTransformsWithY.assertValues([100, 250, 350])

    self.vm.inputs.contentOffsetChanged(to: .zero)

    self.applyViewTransformsWithY.assertValues([100, 250, 350, 0])
  }
}
