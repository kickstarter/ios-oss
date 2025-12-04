@testable import Kickstarter_Framework
@testable import KsApi
import SwiftUI
import XCTest

final class ShippingLocationsViewModelTests: TestCase {
  func test_filteredLocationsWithTerm_displaysFilteredLocations() {
    let allCountries = [
      Location.australia,
      Location.canada,
      Location.usa
    ]

    let vm = ShippingLocationsViewModel(
      withLocations: allCountries,
      selectedLocation: nil
    )

    vm.filteredLocations(withTerm: "u")
    XCTAssertEqual(vm.displayedLocations, [Location.australia, Location.usa])

    vm.filteredLocations(withTerm: "uni")
    XCTAssertEqual(vm.displayedLocations, [Location.usa])

    vm.filteredLocations(withTerm: "unitarian")
    XCTAssertEqual(vm.displayedLocations, [])

    vm.filteredLocations(withTerm: "")
    XCTAssertEqual(
      vm.displayedLocations,
      allCountries,
      "Clearing the search term should show all countries again"
    )
  }

  func test_selectingLocation_changesSelectedLocation() {
    let allCountries = [
      Location.australia,
      Location.canada,
      Location.usa
    ]

    let vm = ShippingLocationsViewModel(
      withLocations: allCountries,
      selectedLocation: nil
    )

    XCTAssertNil(vm.selectedLocation)

    vm.selectedLocation(Location.canada)

    XCTAssertEqual(vm.selectedLocation, Location.canada)
    XCTAssertTrue(vm.isLocationSelected(Location.canada))
    XCTAssertFalse(vm.isLocationSelected(Location.usa))
  }

  func test_initialSelectedLocation_isSelected() {
    let allCountries = [
      Location.australia,
      Location.canada,
      Location.usa
    ]

    let vm = ShippingLocationsViewModel(
      withLocations: allCountries,
      selectedLocation: Location.australia
    )

    XCTAssertEqual(vm.selectedLocation, Location.australia)
  }
}
