@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class DiscoveryEditorialViewModelTests: TestCase {
  private let vm: DiscoveryEditorialViewModelType = DiscoveryEditorialViewModel()

  private let imageName = TestObserver<String, Never>()
  private let notifyDelegateViewTappedRefTag = TestObserver<RefTag, Never>()
  private let notifyDelegateViewTappedTag = TestObserver<String, Never>()
  private let subtitleText = TestObserver<String, Never>()
  private let titleText = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.imageName.observe(self.imageName.observer)
    self.vm.outputs.subtitleText.observe(self.subtitleText.observer)
    self.vm.outputs.notifyDelegateViewTapped.map(first).observe(self.notifyDelegateViewTappedTag.observer)
    self.vm.outputs.notifyDelegateViewTapped.map(second)
      .observe(self.notifyDelegateViewTappedRefTag.observer)
    self.vm.outputs.titleText.observe(self.titleText.observer)
  }

  override func tearDown() {
    super.tearDown()
  }

  func testConfigureView() {
    self.imageName.assertDidNotEmitValue()
    self.titleText.assertDidNotEmitValue()
    self.subtitleText.assertDidNotEmitValue()
    self.notifyDelegateViewTappedTag.assertDidNotEmitValue()
    self.notifyDelegateViewTappedRefTag.assertDidNotEmitValue()

    self.vm.inputs.configureWith((title: "hello",
                                  subtitle: "boop",
                                  imageName: "image",
                                  tag: "123", refTag:
      RefTag.editorial(.goRewardless)))

    self.imageName.assertValues(["image"])
    self.titleText.assertValues(["hello"])
    self.subtitleText.assertValues(["boop"])
    self.notifyDelegateViewTappedTag.assertDidNotEmitValue()
    self.notifyDelegateViewTappedRefTag.assertDidNotEmitValue()
  }

  func testEditorialCellTapped() {
    self.vm.inputs.configureWith((title: "hello",
                                  subtitle: "boop",
                                  imageName: "image",
                                  tag: "123", refTag:
      RefTag.editorial(.goRewardless)))

    self.notifyDelegateViewTappedRefTag.assertDidNotEmitValue()
    self.notifyDelegateViewTappedTag.assertDidNotEmitValue()

    self.vm.inputs.editorialCellTapped()

    self.notifyDelegateViewTappedRefTag.assertValues([RefTag.editorial(.goRewardless)])
    self.notifyDelegateViewTappedTag.assertValues(["123"])
  }
}
