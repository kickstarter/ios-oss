import KsApi
import Library
import SwiftUI

public struct LocationView: View {
  private enum ViewState {
    case loading
    case results
    case defaults
  }

  var defaultLocations: [Location]
  var searchLocations: [Location]
  @Binding var selectedLocation: Location?

  @State var searchText = ""
  var onSearchedForLocation: (String) -> Void

  private var viewState: ViewState {
    if !self.searchText.isEmpty && self.searchLocations.count > 0 {
      return .results
    } else if self.defaultLocations.count > 0 {
      return .defaults
    } else {
      return .loading
    }
  }

  var searching: Bool {
    return !self.searchText.isEmpty
  }

  public var body: some View {
    ScrollView {
      switch self.viewState {
      case .loading:
        ProgressView()
      case .results:
        SearchResults(
          items: self.searchLocations,
          selectedItem: self.$selectedLocation
        )
      case .defaults:
        ItemList(
          items: self.defaultLocations,
          selectedItem: self.$selectedLocation
        )
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

  func buttonLabel(title: String, isSelected: Bool) -> some View {
    HStack(spacing: Constants.buttonLabelSpacing) {
      RadioButton(isSelected: isSelected)
      Text(title)
        .font(InterFont.bodyLG.swiftUIFont())
        .foregroundStyle(Colors.Text.primary.swiftUIColor())
    }
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: Constants.spacing) {
      Button {
        self.selectedItem = nil
      } label: {
        self.buttonLabel(
          title: "FPO: Anywhere",
          isSelected: self.selectedItem.isNil
        )
      }
      ForEach(self.items) { item in
        Button {
          self.selectedItem = item
        } label: {
          self.buttonLabel(
            title: item.displayableName,
            isSelected: self.selectedItem?.id == item.id
          )
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
