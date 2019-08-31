import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import UIKit.UITableViewCell

final class ShippingRuleCellViewModelTests: TestCase {
  private let vm: ShippingRuleCellViewModelType = ShippingRuleCellViewModel()

  private let accessoryType = TestObserver<UITableViewCell.AccessoryType, Never>()
  private let textLabelText = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.accessoryType.observe(self.accessoryType.observer)
    self.vm.outputs.textLabelText.observe(self.textLabelText.observer)
  }

  func testAccessoryType_None() {
    let selectedShippingRule: ShippingRule = .template
      |> ShippingRule.lens.location .~ Location.canada
    let data = ShippingRuleData(
      project: .template,
      selectedShippingRule: selectedShippingRule,
      shippingRule: .template
    )

    self.vm.inputs.configureWith(data)

    self.accessoryType.assertValues([.none])
  }

  func testAccessoryType_Checkmark() {
    let data = ShippingRuleData(
      project: .template,
      selectedShippingRule: .template,
      shippingRule: .template
    )

    self.vm.inputs.configureWith(data)

    self.accessoryType.assertValues([.checkmark])
  }

  func testTextLabelText() {
    let data = ShippingRuleData(
      project: .template,
      selectedShippingRule: .template,
      shippingRule: .template
    )

    self.vm.inputs.configureWith(data)

    self.textLabelText.assertValues(["Brooklyn, NY (+$5)"])
  }
}
