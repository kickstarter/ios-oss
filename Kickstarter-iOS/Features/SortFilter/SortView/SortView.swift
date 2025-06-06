import Library
import SwiftUI

struct SortView<T: SortOption>: View {
  @StateObject var viewModel: SortViewModel<T>
  var onSelectedSort: ((T) -> Void)? = nil
  var onClosed: (() -> Void)? = nil

  var body: some View {
    VStack(spacing: 0) {
      self.headerView
      self.sortOptionList
        .frame(height: self.dynamicHeight())
      Spacer()
    }
    .background(Colors.Background.Surface.primary.swiftUIColor())

    // Handle actions
    .onReceive(self.viewModel.selectedSortOption) { sortOption in
      self.onSelectedSort?(sortOption)
    }
    .onReceive(self.viewModel.closeTapped) {
      self.onClosed?()
    }
  }

  @ViewBuilder
  private var headerView: some View {
    HStack {
      Text(Strings.Sort_by())
        .font(Font.ksr_headingXL())
        .foregroundStyle(Colors.Text.primary.swiftUIColor())
      Spacer()
      Button(action: { () in
        self.viewModel.close()
      }) {
        Image(ImageResource.iconCross)
          .foregroundStyle(Colors.Icon.primary.swiftUIColor())
          .accessibilityLabel(Strings.accessibility_discovery_buttons_close())
          .accessibilityAddTraits(.isButton)
      }
    }
    .padding(Constants.headerPadding)
  }

  @ViewBuilder
  private var sortOptionList: some View {
    List(self.viewModel.sortOptions) { sortOption in
      VStack(spacing: 0) {
        HStack {
          Text(sortOption.name)
            .font(Font.ksr_bodyMD())
            .foregroundStyle(Colors.Text.primary.swiftUIColor())
          Spacer()
          RadioButton(isSelected: self.viewModel.isSortOptionSelected(sortOption))
        }
        .padding(.vertical, Constants.rowPaddingVertical)
        .padding(.horizontal, Constants.rowPaddingHorizontal)
      }
      .background(Colors.Background.Surface.primary.swiftUIColor())
      .listRowInsets(EdgeInsets()) // Remove List internal insets
      .listRowSeparator(.hidden) // Hide default separators
      .contentShape(Rectangle())
      .onTapGesture { [weak viewModel] () in
        viewModel?.selectSortOption(sortOption)
      }
    }
    .listStyle(.plain)
  }

  internal func dynamicHeight() -> CGFloat {
    let itemHeight = Constants.rowPaddingVertical * 2 + RadioButton.Constants.radioButtonSize
    let maxHeight = UIScreen.main.bounds.height
    let totalHeight = CGFloat(self.viewModel.sortOptions.count) * itemHeight + Constants.extraDynamicHeight
    return min(totalHeight, maxHeight)
  }
}

private enum Constants {
  static let headerPadding: CGFloat = Styles.grid(4)
  static let rowPaddingHorizontal: CGFloat = Styles.grid(4)
  static let rowPaddingVertical: CGFloat = 9.0
  static let extraDynamicHeight: CGFloat = 30.0
}

#if targetEnvironment(simulator)
  #Preview("Sort Options") {
    let options = ConcreteSortOption.allCases
    SortView(
      viewModel: SortViewModel(
        sortOptions: options,
        selectedSortOption: .sortOne
      ),
      onSelectedSort: { option in
        print("Selected sort option: \(option.name)")
      },
      onClosed: {
        print("Closed")
      }
    )
  }
#endif
