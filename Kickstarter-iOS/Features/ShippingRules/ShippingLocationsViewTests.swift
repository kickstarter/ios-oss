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

    let vc = ShippingLocationsViewController(
      withLocations: allCountries,
      selectedLocation: Location.australia,
      onSelectedLocation: { _ in },
      onCancelled: {}
    )

    vc.view.frame = CGRectMake(0, 0, 350, 500)

    assertSnapshot(of: vc.view, as: .image, named: "locationView")
  }
}
