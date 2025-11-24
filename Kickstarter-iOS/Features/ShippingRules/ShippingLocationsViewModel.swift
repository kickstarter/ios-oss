import KsApi
import SwiftUICore

public class ShippingLocationsViewModel: ObservableObject {
  @Published var displayedLocations: [Location]
  @Published var selectedLocation: Location?
  let onSelectedLocation: (Location) -> Void
  let onCancelled: () -> Void

  private var allLocations: [Location]

  func isLocationSelected(_ location: Location) -> Bool {
    return location.id == self.selectedLocation?.id
  }

  func selectedLocation(_ location: Location) {
    self.selectedLocation = location

    self.onSelectedLocation(location)
  }

  func tappedCancel() {
    self.onCancelled()
  }

  func filteredLocations(withTerm searchTerm: String) {
    if searchTerm.isEmpty {
      self.displayedLocations = self.allLocations
      return
    }

    self.displayedLocations = self.allLocations.filter { location in
      location.localizedName.lowercased().contains(searchTerm.lowercased())
    }
  }

  init(
    withLocations locations: [Location],
    selectedLocation: Location?,
    onSelectedLocation: @escaping (Location) -> Void,
    onCancelled: @escaping () -> Void
  ) {
    let sortedLocations = locations.sorted { a, b in
      a.localizedName <= b.localizedName
    }

    self.allLocations = sortedLocations
    self.selectedLocation = selectedLocation
    self.displayedLocations = sortedLocations

    self.onSelectedLocation = onSelectedLocation
    self.onCancelled = onCancelled
  }
}
