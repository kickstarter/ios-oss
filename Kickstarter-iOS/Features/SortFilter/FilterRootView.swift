import KsApi
import Library
import SwiftUI

// FIXME: MBL-2220: All of this UI is placeholder UI.
// It's functional, but not up to spec, and includes no translations.
struct FilterRootView: View {
  @State var filterOptions: SearchFilterOptions
  @State var navigationState: [SearchFilterModalType]

  @ObservedObject var selectedFilters: SelectedSearchFilters

  var onSelectedCategory: (((KsApi.Category, KsApi.Category?)?) -> Void)? = nil
  var onSelectedProjectState: ((DiscoveryParams.State) -> Void)? = nil
  var onReset: ((SearchFilterModalType) -> Void)? = nil
  var onResults: (() -> Void)? = nil
  var onClose: (() -> Void)? = nil

  @ViewBuilder
  private var separator: some View {
    Rectangle()
      .fill(Colors.Border.subtle.swiftUIColor())
      .frame(height: 1)
      .frame(maxWidth: .infinity)
  }

  @ViewBuilder
  var categorySection: some View {
    Text(Strings.Category())
      .fontWeight(.bold)
    NavigationLink(value: SearchFilterModalType.category) {
      Text("Pick a category >")
    }
    if let selectedCategory = self.selectedFilters.category?.name {
      Text("Selected category: \(selectedCategory)")
        .font(InterFont.body.swiftUIFont())
        .foregroundStyle(Colors.Text.disabled.swiftUIColor())
    }
  }

  @ViewBuilder
  var projectStateSection: some View {
    Text(Strings.Project_status())
      .fontWeight(.bold)
    VStack {
      ForEach(self.filterOptions.projectState.stateOptions) { state in
        Button(action: {
          if let action = onSelectedProjectState {
            action(state)
          }
        }, label: {
          Text(state.title)
            .lineLimit(1)
        })
        .buttonStyle(BorderedProminentButtonStyle())
        .tint(state == self.selectedFilters.projectState ? .red : .blue)
      }
    }
  }

  @ViewBuilder
  var categoryModal: some View {
    FilterCategoryView(
      viewModel: FilterCategoryViewModel<KsApi.Category>(
        with: self.filterOptions.category.categories,
        selectedCategory: self.selectedFilters.category
      ),
      onSelectedCategory: self.onSelectedCategory,
      onResults: self.onResults,
      onClose: self.onClose
    )
    .navigationTitle(Strings.Category())
  }

  init(
    filterOptions: SearchFilterOptions,
    filterType: SearchFilterModalType,
    selectedFilters: SelectedSearchFilters
  ) {
    self.filterOptions = filterOptions
    if filterType == .allFilters {
      // Show the root view
      self.navigationState = []
    } else {
      self.navigationState = [filterType]
    }

    self.selectedFilters = selectedFilters
  }

  public var body: some View {
    NavigationStack(path: self.$navigationState) {
      VStack(spacing: 20) {
        self.categorySection
        self.separator
        self.projectStateSection
      }
      .navigationDestination(for: SearchFilterModalType.self, destination: { modalType in
        if modalType == .category {
          self.categoryModal
            .modalHeader(withTitle: Strings.Category(), onClose: self.onClose)
        } else {
          EmptyView()
        }
      })
      .modalHeader(withTitle: Strings.Filter(), onClose: self.onClose)
    }
  }
}

extension View {
  func modalHeader(withTitle _: String, onClose: (() -> Void)?) -> some View {
    self
      .navigationTitle(Strings.Filter())
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        Button {
          if let action = onClose {
            action()
          }
        } label: {
          Text("X")
        }
      }
  }
}

extension DiscoveryParams.State: @retroactive Identifiable {
  public var id: Int {
    return self.rawValue.hashValue
  }
}
