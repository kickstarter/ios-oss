import KsApi
import Library
import SwiftUI

public struct LocationView: View {
  let defaultLocations: [Location]
  let suggestedLocations: [Location]
  @Binding var selectedLocation: Location?
  let onSearchedForLocations: (String) -> Void
  @Binding var searchText: String

  public var body: some View {
    ScrollView {
      DefaultLocationsList(
        defaultLocations: self.defaultLocations,
        selectedLocation: self.$selectedLocation
      )
    }
    .searchable(
      text: self.$searchText,
      placement: .navigationBarDrawer(displayMode: .always),
      // FIXME: MBL-2343 Add translations
      prompt: "FPO: Search by city, state, country..."
    )
    .searchSuggestions {
      ForEach(self.suggestedLocations) { location in
        Text(location.displayableName)
          .font(InterFont.bodyLG.swiftUIFont())
          .foregroundStyle(Colors.Text.primary.swiftUIColor())
          .searchCompletion(location.displayableName)
      }
    }
    .onChange(of: self.searchText) { newValue in
      // If the new search text is the displayableName of a suggested location,
      // then they selected an option from auto-complete.
      if let location = self.suggestedLocations.first(where: { $0.displayableName == newValue }) {
        self.selectedLocation = location
        return
      }

      // Otherwise, they have some partial search results.
      // Update the suggested locations.
      self.selectedLocation = nil
      self.onSearchedForLocations(newValue)
    }
    .onChange(of: self.selectedLocation) { _ in
      // If a location is selected in the UI, update the search bar.
      self.searchText = self.selectedLocation?.displayableName ?? ""
    }
  }

  internal enum Constants {
    static let padding: CGFloat = 24.0
    static let spacing: CGFloat = 24.0
    static let buttonLabelSpacing: CGFloat = 8.0
  }
}
