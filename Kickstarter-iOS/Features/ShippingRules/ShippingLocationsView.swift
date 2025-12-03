import KDS
import KsApi
import Library
import SwiftUI

public func ShippingLocationsViewController(
  withLocations locations: [Location],
  selectedLocation: Location?,
  onSelectedLocation: @escaping (Location) -> Void,
  onCancelled: @escaping () -> Void
) -> UIViewController {
  let viewModel = ShippingLocationsViewModel(
    withLocations: locations,
    selectedLocation: selectedLocation
  )

  var view = ShippingLocationsView(viewModel: viewModel)
  view.onSelectedLocation = onSelectedLocation
  view.onCancelled = onCancelled

  return UIHostingController(rootView: view)
}

private struct ShippingLocationsView<T: ShippingLocationsViewModelType>: View {
  @StateObject var viewModel: T
  var onSelectedLocation: ((Location) -> Void)? = nil
  var onCancelled: (() -> Void)? = nil

  @State private var searchText: String = ""

  @ViewBuilder var locationsList: some View {
    VStack(alignment: .leading, spacing: Spacing.unit_06) {
      ForEach(self.viewModel.outputs.displayedLocations) { location in
        Button {
          self.viewModel.inputs.selectedLocation(location)
        } label: {
          ShippingLocationsRow(
            title: location.localizedName,
            isSelected: self.viewModel.outputs.isLocationSelected(location)
          )
        }
        .id(location.id)
      }
    }
    .padding(Spacing.unit_06)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }

  public var body: some View {
    NavigationStack {
      ScrollViewReader { reader in
        ScrollView {
          self.locationsList
        }
        .onAppear {
          if let selectedLocation = self.viewModel.outputs.selectedLocation {
            reader.scrollTo(selectedLocation.id, anchor: .center)
          }
        }
      }
      .searchable(
        text: self.$searchText,
        placement: .navigationBarDrawer(displayMode: .always)
      )
      .navigationTitle(Strings.Location())
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(Strings.Cancel()) {
            if let onCancelled = self.onCancelled {
              onCancelled()
            }
          }
        }
      }
    }
    .onChange(of: self.searchText) { _, newValue in
      self.viewModel.inputs.filteredLocations(withTerm: newValue)
    }
    .onChange(of: self.viewModel.outputs.selectedLocation) { _, newValue in
      if let newValue, let onSelectedLocation = self.onSelectedLocation {
        onSelectedLocation(newValue)
      }
    }
  }
}

struct ShippingLocationsRow: View {
  let title: String
  let isSelected: Bool

  public var body: some View {
    HStack(spacing: Spacing.unit_02) {
      Text(self.title)
        .font(InterFont.bodyLG.swiftUIFont())
        .multilineTextAlignment(.leading)
        .foregroundStyle(Colors.Text.primary.swiftUIColor())

      if self.isSelected, let checkmark = Library.image(named: "checkmark") {
        Spacer()
        Image(uiImage: checkmark)
      }
    }
  }
}
