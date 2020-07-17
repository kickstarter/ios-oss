import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class RewardAddOnSelectionContinueCTAViewModelTests: TestCase {
  private let vm: RewardAddOnSelectionContinueCTAViewModelType = RewardAddOnSelectionContinueCTAViewModel()

  private let buttonStyle = TestObserver<ButtonStyleType, Never>()
  private let buttonTitle = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.buttonStyle.observe(self.buttonStyle.observer)
    self.vm.outputs.buttonTitle.observe(self.buttonTitle.observer)
  }

  func testButtonStyle_Valid() {
    self.buttonStyle.assertDidNotEmitValue()

    self.vm.inputs.configure(with: (0, true))

    self.buttonStyle.assertValues([.green])
  }

  func testButtonStyle_Invalid() {
    self.buttonStyle.assertDidNotEmitValue()

    self.vm.inputs.configure(with: (0, false))

    self.buttonStyle.assertValues([.black])
  }

  func testButtonTitle() {
    self.buttonTitle.assertDidNotEmitValue()

    self.vm.inputs.configure(with: (0, true))

    self.buttonTitle.assertValues(["Skip add-ons"])

    self.vm.inputs.configure(with: (2, true))

    self.buttonTitle.assertValues(["Skip add-ons", "Continue with 2 add-ons"])

    self.vm.inputs.configure(with: (0, true))

    self.buttonTitle.assertValues(["Skip add-ons", "Continue with 2 add-ons", "Skip add-ons"])

    self.vm.inputs.configure(with: (1, true))

    self.buttonTitle.assertValues([
      "Skip add-ons",
      "Continue with 2 add-ons",
      "Skip add-ons",
      "Continue with 1 add-ons" // FIXME: Once translations are in, this should drop the plural in add-ons
    ])
  }
}
