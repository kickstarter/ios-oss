import KsApi
import Library
import SwiftUI

public struct LocationView: View {
  var defaultLocations: [Location]
  var searchLocations: [Location]
  @Binding var selectedLocation: Location?

  @State var searchText = ""
  var onSearchedForLocation: (String) -> Void

  public var body: some View {
    ScrollView {
      if self.searchLocations.count > 0 {
        SearchResults(
          items: self.searchLocations,
          selectedItem: self.$selectedLocation
        )
      } else if self.defaultLocations.count > 0 {
        ItemList(
          items: self.defaultLocations,
          selectedItem: self.$selectedLocation
        )
      } else {
        ProgressView()
      }
    }
    .searchable(
      text: self.$searchText,
      placement: .navigationBarDrawer(displayMode: .always)
    )
    .onChange(of: self.searchText) { newValue in
      self.onSearchedForLocation(newValue)
    }
  }
}

private struct Item: Identifiable {
  var id: String
  var title: String
}

private struct SearchResults: View {
  var items: [Location]
  @Binding var selectedItem: Location?

  var body: some View {
    VStack(alignment: .leading, spacing: Constants.spacing) {
      ForEach(self.items) { item in
        Button {
          self.selectedItem = item
        } label: {
          Text(item.displayableName)
            .font(InterFont.bodyLG.swiftUIFont())
            .foregroundStyle(Colors.Text.primary.swiftUIColor())
        }
      }
    }
    .padding(Constants.padding)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }
}

private struct ItemList: View {
  let items: [Location]
  @Binding var selectedItem: Location?

  public var body: some View {
    VStack(alignment: .leading, spacing: Constants.spacing) {
      ForEach(self.items) { item in
        Button {
          self.selectedItem = item
        } label: {
          HStack(spacing: Constants.buttonLabelSpacing) {
            RadioButton(isSelected: self.selectedItem?.id == item.id)
            Text(item.displayableName)
              .font(InterFont.bodyLG.swiftUIFont())
              .foregroundStyle(Colors.Text.primary.swiftUIColor())
          }
        }
      }
    }
    .padding(Constants.padding)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }
}

extension Location: @retroactive Identifiable {}

private enum Constants {
  static let padding: CGFloat = 24.0
  static let spacing: CGFloat = 24.0
  static let buttonLabelSpacing: CGFloat = 8.0
}

/*
 private let previewItems = [
   Item(id: "1", title: "Item One"),
   Item(id: "2", title: "Item Two"),
   Item(id: "3", title: "Item Three")
 ]

 #Preview("Location") {
   NavigationStack {
     ItemList(
       items: previewItems,
       selectedItem: .constant(previewItems[2])
     )
   }
 }
 */
