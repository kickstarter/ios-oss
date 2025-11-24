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
    selectedLocation: selectedLocation,
    onSelectedLocation: onSelectedLocation,
    onCancelled: onCancelled
  )

  let view = ShippingLocationsView(viewModel: viewModel)

  return UIHostingController(rootView: view)
}

private struct ShippingLocationsView: View {
  @StateObject var viewModel: ShippingLocationsViewModel
  @State private var searchText: String = ""

  @ViewBuilder var locationsList: some View {
    VStack(alignment: .leading, spacing: Constants.spacing) {
      ForEach(self.viewModel.displayedLocations) { location in
        Button {
          self.viewModel.selectedLocation(location)
        } label: {
          ShippingLocationsRow(
            title: location.localizedName,
            isSelected: self.viewModel.isLocationSelected(location)
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
          if let selectedLocation = self.viewModel.selectedLocation {
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
            self.viewModel.tappedCancel()
          }
        }
      }
    }
    .onChange(of: self.searchText) { newValue in
      self.viewModel.filteredLocations(withTerm: newValue)
    }
  }

  internal enum Constants {
    static let padding = Spacing.unit_06
    static let spacing = Spacing.unit_06
    static let buttonLabelSpacing = Spacing.unit_02
  }
}

private struct ShippingLocationsRow: View {
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
