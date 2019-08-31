import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers

final class ShippingRulesViewModelTests: TestCase {
  private let vm: ShippingRulesViewModelType = ShippingRulesViewModel()

  private let reloadDataWithShippingRulesData = TestObserver<[ShippingRuleData], Never>()
  private let reloadDataWithShippingRulesReload = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.reloadDataWithShippingRules.map(first).observe(
      self.reloadDataWithShippingRulesData.observer
    )
    self.vm.outputs.reloadDataWithShippingRules.map(second).observe(
      self.reloadDataWithShippingRulesReload.observer
    )
  }

  func testReloadDataWithShippingRules() {
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
    self.reloadDataWithShippingRulesReload.assertValues([true])
  }
}
