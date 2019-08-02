@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import UIKit

final class ShippingRulesTableViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()

    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)

    super.tearDown()
  }

  func testView() {
    let shippingRules: [ShippingRule] = [
      .template
        |> ShippingRule.lens.cost .~ 25
        |> (ShippingRule.lens.location .. Location.lens.localizedName) .~ "Canada",
      .template
        |> ShippingRule.lens.cost .~ 100
        |> (ShippingRule.lens.location .. Location.lens.localizedName) .~ "Czech Republic",
      .template
        |> ShippingRule.lens.cost .~ 5
        |> (ShippingRule.lens.location .. Location.lens.localizedName) .~ "United States of America"
    ]

    Device.allCases.forEach { device in
      let vc = ShippingRulesTableViewController.instantiate()
      vc.configureWith(.template, shippingRules: shippingRules, selectedShippingRule: .template)
      let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)

      FBSnapshotVerifyView(parent.view, identifier: "device_\(device)")
    }
  }
}
