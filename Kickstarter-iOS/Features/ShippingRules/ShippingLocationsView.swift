import KDS
import KsApi
import Library
import SwiftUI

public func ShippingLocationsViewController(
  withLocations locations: [Location],
  selectedLocation: Location?,
  onSelectedLocation: @escaping (Location) -> Void
) -> UIViewController {
  let sortedLocations = locations.sorted { a, b in
    a.localizedName <= b.localizedName
  }

  let view = ShippingLocationsView(
    locations: sortedLocations,
    selectedLocation: selectedLocation,
    onSelectedLocation: onSelectedLocation
  )

  return UIHostingController(rootView: view)
}

public struct ShippingLocationsView: View {
  let locations: [Location]
  @State var selectedLocation: Location?
  let onSelectedLocation: (Location) -> Void

  @State private var filteredLocations: [Location]? = nil
  @State private var searchText: String = ""

  func buttonLabel(title: String, isSelected: Bool) -> some View {
    HStack(spacing: Constants.buttonLabelSpacing) {
      RadioButton(isSelected: isSelected)
      Text(title)
        .font(InterFont.bodyLG.swiftUIFont())
        .foregroundStyle(Colors.Text.primary.swiftUIColor())
    }
  }

  @ViewBuilder var locationsList: some View {
    VStack(alignment: .leading, spacing: Constants.spacing) {
      ForEach(self.filteredLocations ?? self.locations) { location in
        Button {
          self.selectedLocation = location
        } label: {
          self.buttonLabel(
            title: location.localizedName,
            isSelected: self.selectedLocation?.id == location.id
          )
        }
        .id(location.id)
      }
    }
    .padding(Constants.padding)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }

  public var body: some View {
    NavigationStack {
      ScrollViewReader { reader in
        ScrollView {
          self.locationsList
        }
        .onAppear {
          if let selectedLocation {
            reader.scrollTo(selectedLocation.id, anchor: .center)
          }
        }
      }
      .searchable(
        text: self.$searchText,
        placement: .navigationBarDrawer(displayMode: .always),
        prompt: Strings.Location_searchbox_placeholder() // TODO: what string
      )
      .navigationTitle(Strings.Location()) // TODO: what title
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(Strings.Cancel()) {
            // TODO: do something
          }
        }
      }
    }
    .onChange(of: self.selectedLocation) { newValue in
      if let location = newValue {
        self.onSelectedLocation(location)
      }
    }
    .onChange(of: self.searchText) { newValue in
      if newValue.isEmpty {
        self.filteredLocations = nil
        return
      }

      self.filteredLocations = self.locations.filter { location in
        location.localizedName.lowercased().contains(self.searchText.lowercased())
      }
    }
  }

  internal enum Constants {
    static let padding = Spacing.unit_06
    static let spacing = Spacing.unit_06
    static let buttonLabelSpacing = Spacing.unit_02
  }
}

// TODO: preview
