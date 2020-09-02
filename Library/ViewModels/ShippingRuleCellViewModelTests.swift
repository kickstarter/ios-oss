import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers

final class ShippingRuleCellViewModelTests: TestCase {
  private let vm: ShippingRuleCellViewModelType = ShippingRuleCellViewModel()

  private let isSelected = TestObserver<Bool, Never>()
  private let textLabelText = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.isSelected.observe(self.isSelected.observer)
    self.vm.outputs.textLabelText.observe(self.textLabelText.observer)
  }

  func testIsSelected_False() {
    let selectedShippingRule: ShippingRule = .template
      |> ShippingRule.lens.location .~ Location.canada
    let data = ShippingRuleData(
      selectedShippingRule: selectedShippingRule,
      shippingRule: .template
    )

    self.vm.inputs.configureWith(data)

    self.isSelected.assertValues([false])
  }

  func testIsSelected_True() {
    let data = ShippingRuleData(
      selectedShippingRule: .template,
      shippingRule: .template
    )

    self.vm.inputs.configureWith(data)

    self.isSelected.assertValues([true])
  }

  func testTextLabelText() {
    let data = ShippingRuleData(
      selectedShippingRule: .template,
      shippingRule: .template
    )

    self.vm.inputs.configureWith(data)

    self.textLabelText.assertValues(["Brooklyn, NY"])
  }
}
