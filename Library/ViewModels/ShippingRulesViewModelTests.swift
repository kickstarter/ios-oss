import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers

final class ShippingRulesViewModelTests: TestCase {
  private let vm: ShippingRulesViewModelType = ShippingRulesViewModel()

  private let values = TestObserver<[String], Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.values.observe(self.values.observer)
  }

  func testValues() {
    let project = Project.template
      |> Project.lens.country .~ Project.Country.ca

    let shippingRule = ShippingRule.template
      |> ShippingRule.lens.cost .~ 25
      |> (ShippingRule.lens.location .. Location.lens.localizedName) .~ "Canada"

    self.vm.inputs.configureWith(project, shippingRules: [shippingRule], selectedShippingRule: .template)
    self.vm.inputs.viewDidLoad()

    self.values.assertValues([["Canada (+CA$ 25)"]])
  }
}
