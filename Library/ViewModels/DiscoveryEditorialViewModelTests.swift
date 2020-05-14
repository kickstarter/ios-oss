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
  private let notifyDelegateViewTapped = TestObserver<DiscoveryParams.TagID, Never>()
  private let subtitleText = TestObserver<String, Never>()
  private let titleText = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.imageName.observe(self.imageName.observer)
    self.vm.outputs.subtitleText.observe(self.subtitleText.observer)
    self.vm.outputs.notifyDelegateViewTapped.observe(self.notifyDelegateViewTapped.observer)
    self.vm.outputs.titleText.observe(self.titleText.observer)
  }

  override func tearDown() {
    super.tearDown()
  }

  func testConfigureView() {
    self.imageName.assertDidNotEmitValue()
    self.titleText.assertDidNotEmitValue()
    self.subtitleText.assertDidNotEmitValue()
    self.notifyDelegateViewTapped.assertDidNotEmitValue()

    self.vm.inputs.configureWith(
      .init(
        title: "hello",
        subtitle: "boop",
        imageName: "image",
        tagId: .lightsOn
      )
    )

    self.imageName.assertValues(["image"])
    self.titleText.assertValues(["hello"])
    self.subtitleText.assertValues(["boop"])
    self.notifyDelegateViewTapped.assertDidNotEmitValue()
  }

  func testEditorialCellTapped() {
    self.vm.inputs.configureWith(
      .init(
        title: "hello",
        subtitle: "boop",
        imageName: "image",
        tagId: .lightsOn
      )
    )

    self.vm.inputs.editorialCellTapped()
    self.notifyDelegateViewTapped.assertValues([.lightsOn])
  }
}
