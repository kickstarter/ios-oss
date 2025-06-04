import KsApi
import Library
import SwiftUI

public struct LocationView: View {
  var defaultLocations: [Location]
  var searchLocations: [Location]
  @Binding var selectedLocationId: String?
  @State var searchText = ""

  public var body: some View {
    ItemList(
      items: self.defaultLocations.map { location in
        Item(id: location.graphID, title: location.displayableName)
      },
      selectedItemId: self.$selectedLocationId,
      searchText: self.$searchText
    )
  }
}

private struct Item: Identifiable {
  var id: String
  var title: String
}

private struct ItemList: View {
  var items: [Item]
  @Binding var selectedItemId: String?
  @Binding var searchText: String

  public var body: some View {
    VStack(alignment: .leading, spacing: Constants.spacing) {
      Text("Searching locations for \"\(self.searchText)\"")
      ForEach(self.items) { item in
        Button {
          self.selectedItemId = item.id
        } label: {
          HStack(spacing: Constants.buttonLabelSpacing) {
            RadioButton(isSelected: item.id == self.selectedItemId)
            Text(item.title)
              .font(InterFont.bodyLG.swiftUIFont())
              .foregroundStyle(Colors.Text.primary.swiftUIColor())
          }
        }
      }
    }
    .padding(Constants.padding)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .searchable(text: self.$searchText)
  }

  internal enum Constants {
    static let padding: CGFloat = 24.0
    static let spacing: CGFloat = 24.0
    static let buttonLabelSpacing: CGFloat = 8.0
  }
}

#Preview("Location") {
  NavigationStack {
    ItemList(
      items: [
        Item(id: "1", title: "Item One"),
        Item(id: "2", title: "Item Two"),
        Item(id: "3", title: "Item Three")

      ],
      selectedItemId: Binding.constant("2"),
      searchText: Binding.constant("Hello world")
    )
  }
}
