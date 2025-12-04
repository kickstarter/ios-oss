@testable import Kickstarter_Framework
@testable import KsApi
import SnapshotTesting
import SwiftUI
import XCTest

final class ShippingLocationsViewTests: TestCase {
  func test_screenshot() {
    let allCountries = [
      Location.australia,
      Location.canada,
      Location.usa
    ]

    let vc = shippingLocationsViewController(
      withLocations: allCountries,
      selectedLocation: Location.australia,
      onSelectedLocation: { _ in },
      onCancelled: {}
    )

    vc.view.frame = CGRect(x: 0, y: 0, width: 350, height: 500)

    assertSnapshot(of: vc.view, as: .image, named: "locationView")
  }
}
