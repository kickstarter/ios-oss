import KsApi
import Library
import SwiftUI

public struct LocationView: View {
  let defaultLocations: [Location]
  let suggestedLocations: [Location]
  @Binding var selectedLocation: Location?
  let onSearchedForLocations: (String) -> Void

  @State var searchText: String = ""

  func buttonLabel(title: String, isSelected: Bool) -> some View {
    HStack(spacing: Constants.buttonLabelSpacing) {
      RadioButton(isSelected: isSelected)
      Text(title)
        .font(InterFont.bodyLG.swiftUIFont())
        .foregroundStyle(Colors.Text.primary.swiftUIColor())
    }
  }

  @ViewBuilder var defaultLocationsList: some View {
    VStack(alignment: .leading, spacing: Constants.spacing) {
      Button {
        self.selectedDefaultLocation(nil)
      } label: {
        self.buttonLabel(
          title: Strings.Location_anywhere(),
          isSelected: self.selectedLocation.isNil
        )
      }
      ForEach(self.defaultLocations) { item in
        Button {
          self.selectedDefaultLocation(item)
        } label: {
          self.buttonLabel(
            title: item.displayableName,
            isSelected: self.selectedLocation?.id == item.id
          )
        }
      }
    }
    .padding(Constants.padding)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }

  public var body: some View {
    ScrollView {
      self.defaultLocationsList
    }
    .searchable(
      text: self.$searchText,
      placement: .navigationBarDrawer(displayMode: .always),
      prompt: Strings.Location_searchbox_placeholder()
    )
    .searchSuggestions {
      ForEach(self.suggestedLocations) { location in
        Text(location.displayableName)
          .font(InterFont.bodyLG.swiftUIFont())
          .foregroundStyle(Colors.Text.primary.swiftUIColor())
          .searchCompletion(location.displayableName)
      }
    }
    .onAppear {
      self.searchText = self.selectedLocation?.displayableName ?? ""
    }
    .onChange(of: self.searchText) { newValue in
      self.didChangeSearchText(newValue)
    }
    .onChange(of: self.selectedLocation) { newValue in
      if newValue.isNil {
        self.didResetLocation()
      }
    }
  }

  func didChangeSearchText(_ newValue: String) {
    // If the search bar is already showing the displayableName
    // of the selected location, no action is needed.
    if let location = self.selectedLocation {
      if location.displayableName == newValue {
        return
      }
    }

    // If the new search text is the displayableName of a suggested location,
    // then they selected an option from auto-complete.
    // Set the selected location.
    if let location = self.suggestedLocations.first(where: { $0.displayableName == newValue }) {
      self.selectedLocation = location
      return
    }

    // Otherwise, they have some partial location text entered
    // in the search bar.
    // Update the suggested locations.
    self.selectedLocation = nil
    self.onSearchedForLocations(newValue)
  }

  func selectedDefaultLocation(_ location: Location?) {
    self.selectedLocation = location

    // If a location is selected from the default location list,
    // update the search bar.
    // This will also trigger `didChangeSearchText`.
    self.searchText = self.selectedLocation?.displayableName ?? ""

    // Clear the autosuggest results, too.
    self.onSearchedForLocations("")
  }

  func didResetLocation() {
    if !self.searchText.isEmpty {
      self.searchText = ""
    }
  }

  internal enum Constants {
    static let padding: CGFloat = 24.0
    static let spacing: CGFloat = 24.0
    static let buttonLabelSpacing: CGFloat = 8.0
  }
}

extension KsApi.Location: @retroactive Identifiable {}
