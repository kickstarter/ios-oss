@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class DiscoveryProjectTagPillViewModelTests: TestCase {
  private let backgroundColor = TestObserver<UIColor, Never>()
  private let tagIconImageName = TestObserver<String, Never>()
  private let tagIconImageTintColor = TestObserver<UIColor, Never>()
  private let tagLabelText = TestObserver<String, Never>()
  private let tagLabelTextColor = TestObserver<UIColor, Never>()

  private let vm: DiscoveryProjectTagPillViewModelType = DiscoveryProjectTagPillViewModel()

  override func setUp() {
    super.setUp()

    self.vm.outputs.backgroundColor.observe(self.backgroundColor.observer)
    self.vm.outputs.tagIconImageName.observe(self.tagIconImageName.observer)
    self.vm.outputs.tagIconImageTintColor.observe(self.tagIconImageTintColor.observer)
    self.vm.outputs.tagLabelText.observe(self.tagLabelText.observer)
    self.vm.outputs.tagLabelTextColor.observe(self.tagLabelTextColor.observer)
  }

  func testPillCell_GreyStyle() {
    self.backgroundColor.assertDidNotEmitValue()
    self.tagIconImageTintColor.assertDidNotEmitValue()
    self.tagLabelTextColor.assertDidNotEmitValue()

    self.vm.inputs.configure(with: .init(type: .grey, tagIconImageName: "icon-name", tagLabelText: "PWL"))

    self.backgroundColor.assertValues([.ksr_grey_300])
    self.tagIconImageTintColor.assertValues([.ksr_dark_grey_500])
    self.tagLabelTextColor.assertValues([.ksr_dark_grey_500])
  }

  func testPillCell_GreenStyle() {
    self.backgroundColor.assertDidNotEmitValue()
    self.tagIconImageTintColor.assertDidNotEmitValue()
    self.tagLabelTextColor.assertDidNotEmitValue()

    self.vm.inputs.configure(with: .init(type: .green, tagIconImageName: "icon-name", tagLabelText: "PWL"))

    self.backgroundColor.assertValues([UIColor.ksr_green_500.withAlphaComponent(0.07)])
    self.tagIconImageTintColor.assertValues([.ksr_green_500])
    self.tagLabelTextColor.assertValues([.ksr_green_500])
  }

  func testTagIconImageName() {
    self.tagIconImageName.assertDidNotEmitValue()

    self.vm.inputs.configure(with: .init(type: .green, tagIconImageName: "icon-name", tagLabelText: "PWL"))

    self.tagIconImageName.assertValues(["icon-name"])
  }

  func testLabelText() {
    self.tagLabelText.assertDidNotEmitValue()

    self.vm.inputs
      .configure(with: .init(type: .green, tagIconImageName: "icon-name", tagLabelText: "Projects We Love"))

    self.tagLabelText.assertValues(["Projects We Love"])
  }
}
