import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers

final class ShippingRulesViewModelTests: TestCase {
  private let vm: ShippingRulesViewModelType = ShippingRulesViewModel()

  private let deselectCellAtIndex = TestObserver<Int, Never>()
  private let selectCellAtIndex = TestObserver<Int, Never>()
  private let reloadDataWithShippingRulesData = TestObserver<[ShippingRuleData], Never>()
  private let reloadDataWithShippingRulesReload = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.deselectCellAtIndex.observe(self.deselectCellAtIndex.observer)
    self.vm.outputs.selectCellAtIndex.observe(self.selectCellAtIndex.observer)

    self.vm.outputs.reloadDataWithShippingRules.map(first).observe(
      self.reloadDataWithShippingRulesData.observer
    )
    self.vm.outputs.reloadDataWithShippingRules.map(second).observe(
      self.reloadDataWithShippingRulesReload.observer
    )
  }

  func testShippingRuleSelection() {
    let project = Project.template
      |> Project.lens.country .~ Project.Country.ca

    let shippingRule1 = ShippingRule.template
      |> ShippingRule.lens.cost .~ 50
      |> (ShippingRule.lens.location .. Location.lens.localizedName) .~ "Canada"

    let shippingRule2 = ShippingRule.template
      |> ShippingRule.lens.cost .~ 99
      |> (ShippingRule.lens.location .. Location.lens.localizedName) .~ "Czechoslovakia"

    let shippingRule3 = ShippingRule.template
      |> ShippingRule.lens.cost .~ 1_337
      |> (ShippingRule.lens.location .. Location.lens.localizedName) .~ "Kazakhstan"

    let shippingRules = [shippingRule1, shippingRule2, shippingRule3]
    let selectedShippingRule = shippingRule2

    self.vm.inputs.configureWith(
      project, shippingRules: shippingRules, selectedShippingRule: selectedShippingRule
    )
    self.vm.inputs.viewDidLoad()

    self.reloadDataWithShippingRulesData.assertValues([
      [
        ShippingRuleData(
          project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRule1
        ),
        ShippingRuleData(
          project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRule2
        ),
        ShippingRuleData(
          project: project, selectedShippingRule: selectedShippingRule, shippingRule: shippingRule3
        )
      ]
    ])
    self.reloadDataWithShippingRulesData.assertValueCount(1)
    self.reloadDataWithShippingRulesReload.assertValues([true])

    self.vm.inputs.didSelectShippingRule(at: 0)
    self.reloadDataWithShippingRulesData.assertValueCount(2)
    self.reloadDataWithShippingRulesReload.assertValues([true, false])

    // Selecting out of bounds index does nothing Jon Snow
    self.vm.inputs.didSelectShippingRule(at: Int.min)
    self.reloadDataWithShippingRulesData.assertValueCount(2)
    self.reloadDataWithShippingRulesReload.assertValues([true, false])

    self.vm.inputs.didSelectShippingRule(at: Int.max)
    self.reloadDataWithShippingRulesData.assertValueCount(2)
    self.reloadDataWithShippingRulesReload.assertValues([true, false])

    // Selecting index within bounds does work
    self.vm.inputs.didSelectShippingRule(at: 2)
    self.reloadDataWithShippingRulesData.assertValueCount(3)
    self.reloadDataWithShippingRulesReload.assertValues([true, false, false])
  }

  func testCellSelectionDeselection() {
    let selectedShippingRule = ShippingRule.template
      |> ShippingRule.lens.location .~ Location.australia

    self.vm.inputs.configureWith(
      .template,
      shippingRules: [.template, .template, selectedShippingRule, .template],
      selectedShippingRule: selectedShippingRule
    )
    self.vm.inputs.viewDidLoad()

    self.deselectCellAtIndex.assertDidNotEmitValue()
    self.selectCellAtIndex.assertValues([2])

    self.vm.inputs.didSelectShippingRule(at: 0)

    self.deselectCellAtIndex.assertValues([2])
    self.selectCellAtIndex.assertValues([2, 0])

    // Selecting the same index as is currently selected does nothing Jon Snow
    self.vm.inputs.didSelectShippingRule(at: 0)

    self.deselectCellAtIndex.assertValues([2])
    self.selectCellAtIndex.assertValues([2, 0])

    self.vm.inputs.didSelectShippingRule(at: 1)

    self.deselectCellAtIndex.assertValues([2, 0])
    self.selectCellAtIndex.assertValues([2, 0, 1])
  }
}
