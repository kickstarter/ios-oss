import Library
import SwiftUI

struct SortView: View {
  @StateObject var viewModel: SortViewModel
  var onSelectedSort: ((SortOption) -> Void)? = nil
  var onClosed: (() -> Void)? = nil

  var body: some View {
    VStack(spacing: 0) {
      self.headerView
      self.sortOptionList
        .frame(height: self.dynamicHeight())
      Spacer()
    }
    .background(Colors.Background.surfacePrimary.swiftUIColor())

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
          self.radioButton(isSelected: self.viewModel.isSortOptionSelected(sortOption))
        }
        .padding(.vertical, Constants.rowPaddingVertical)
        .padding(.horizontal, Constants.rowPaddingHorizontal)
      }
      .background(Colors.Background.surfacePrimary.swiftUIColor())
      .listRowInsets(EdgeInsets()) // Remove List internal insets
      .listRowSeparator(.hidden) // Hide default separators
      .contentShape(Rectangle())
      .onTapGesture { [weak viewModel] () in
        viewModel?.selectSortOption(sortOption)
      }
    }
    .listStyle(.plain)
  }

  @ViewBuilder
  private func radioButton(isSelected: Bool) -> some View {
    ZStack {
      Circle()
        .strokeBorder(
          isSelected ? Colors.Border.subtle.swiftUIColor() : Colors.Border.bold.swiftUIColor(),
          lineWidth: Constants.radioButtonOuterBorder
        )

      if isSelected {
        Circle()
          .strokeBorder(
            Colors.Background.selected.swiftUIColor(),
            lineWidth: Constants.radioButtonInnerBorder
          )
      }
    }
    .frame(width: Constants.radioButtonSize, height: Constants.radioButtonSize)
  }

  private enum Constants {
    static let headerPadding: CGFloat = Styles.grid(4)
    static let radioButtonSize: CGFloat = Styles.grid(4)
    static let radioButtonOuterBorder: CGFloat = 1.0
    static let radioButtonInnerBorder: CGFloat = 8.0
    static let rowPaddingHorizontal: CGFloat = Styles.grid(4)
    static let rowPaddingVertical: CGFloat = 9.0
    static let extraDynamicHeight: CGFloat = 10.0
  }

  private func dynamicHeight() -> CGFloat {
    let itemHeight = Constants.rowPaddingVertical * 2 + Constants.radioButtonSize
    let maxHeight = UIScreen.main.bounds.height
    let totalHeight = CGFloat(self.viewModel.sortOptions.count) * itemHeight + Constants.extraDynamicHeight
    return min(totalHeight, maxHeight)
  }
}

#if targetEnvironment(simulator)
  #Preview("Sort Options") {
    SortView(
      viewModel: SortViewModel(),
      onSelectedSort: { option in
        print("Selected sort option: \(option.name)")
      },
      onClosed: {
        print("Closed")
      }
    )
  }
#endif
