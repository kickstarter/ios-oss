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
    let size = CGSize(width: 350, height: 500)
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "GMT")!

    forEachScreenshotType { type in
      withEnvironment(
        calendar: calendar,
        language: type.language,
        locale: Locale(identifier: type.language.rawValue),
        mainBundle: self.mainBundle
      ) {
        let vc = ShippingLocations.viewController(
          withLocations: allCountries,
          selectedLocation: Location.australia,
          onSelectedLocation: { _ in },
          onCancelled: {}
        )
        _ = vc.view
        vc.view.frame = CGRect(origin: .zero, size: size)

        assertSnapshot(
          forView: vc.view,
          withType: type,
          size: size,
          testName: "locationView"
        )
      }
    }
  }
}
