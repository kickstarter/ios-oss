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

    let vc = ShippingLocations.viewController(
      withLocations: allCountries,
      selectedLocation: Location.australia,
      onSelectedLocation: { _ in },
      onCancelled: {}
    )

    let size = CGSize(width: 350, height: 500)
    vc.view.frame = CGRect(origin: .zero, size: size)

    forEachScreenshotType { type in
      assertSnapshot(
        forView: vc.view,
        withType: type,
        size: size,
        testName: "locationView"
      )
    }
  }
}
