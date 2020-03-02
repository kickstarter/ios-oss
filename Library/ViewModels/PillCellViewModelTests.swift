@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class PillCellViewModelTests: TestCase {
  private let backgroundColor = TestObserver<UIColor, Never>()
  private let text = TestObserver<String, Never>()
  private let textColor = TestObserver<UIColor, Never>()

  private let vm: PillCellViewModelType = PillCellViewModel()

  override func setUp() {
    super.setUp()

    self.vm.outputs.backgroundColor.observe(self.backgroundColor.observer)
    self.vm.outputs.text.observe(self.text.observer)
    self.vm.outputs.textColor.observe(self.textColor.observer)
  }

  func testBackgroundColor_GreyCase() {
    self.backgroundColor.assertDidNotEmitValue()
    self.vm.inputs.configure(with: ("hi", .grey))

    self.backgroundColor.assertValues([UIColor.ksr_grey_400.withAlphaComponent(0.8)])
  }

  func testBackgroundColor_GreenCase() {
    self.backgroundColor.assertDidNotEmitValue()
    self.vm.inputs.configure(with: ("hi", .green))

    self.backgroundColor.assertValues([UIColor.ksr_green_500.withAlphaComponent(0.06)])
  }

  func testText() {
    self.text.assertDidNotEmitValue()
    self.vm.inputs.configure(with: ("hi", .grey))

    self.text.assertValues(["hi"])
  }

  func testTextColor_GreyCase() {
    self.textColor.assertDidNotEmitValue()
    self.vm.inputs.configure(with: ("hi", .grey))

    self.textColor.assertValues([UIColor.ksr_soft_black])
  }

  func testTextColor_GreenCase() {
    self.textColor.assertDidNotEmitValue()
    self.vm.inputs.configure(with: ("hi", .green))

    self.textColor.assertValues([UIColor.ksr_green_500])
  }
}
