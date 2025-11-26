import KsApi
import SwiftUICore

protocol ShippingLocationsViewModelInputs {
  func tappedCancel()
  func selectedLocation(_ location: Location)
  func filteredLocations(withTerm searchTerm: String)
}

protocol ShippingLocationsViewModelOutputs {
  func isLocationSelected(_ location: Location) -> Bool
  var displayedLocations: [Location] { get }
  var selectedLocation: Location? { get }
}

protocol ShippingLocationsViewModelType: ObservableObject {
  var inputs: ShippingLocationsViewModelInputs { get }
  var outputs: ShippingLocationsViewModelOutputs { get }
}

class ShippingLocationsViewModel: ObservableObject, ShippingLocationsViewModelType,
  ShippingLocationsViewModelInputs, ShippingLocationsViewModelOutputs {
  @Published var displayedLocations: [Location]
  @Published var selectedLocation: Location?
  let onSelectedLocation: (Location) -> Void
  let onCancelled: () -> Void

  // All the possible locations, used for filtering.
  private var allLocations: [Location]

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

  var outputs: any ShippingLocationsViewModelOutputs {
    return self
  }

  var inputs: any ShippingLocationsViewModelInputs {
    return self
  }
}
