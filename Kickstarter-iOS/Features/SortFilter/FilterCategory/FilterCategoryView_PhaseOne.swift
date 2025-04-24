import Library
import SwiftUI

struct FilterCategoryView_PhaseOne<T: FilterCategory>: View {
  @StateObject var viewModel: FilterCategoryViewModel<T>
  var onSelectedCategory: ((T?) -> Void)? = nil
  var onResults: (() -> Void)? = nil
  var onClose: (() -> Void)? = nil

  var body: some View {
    VStack(spacing: 0) {
      self.headerView

      if self.viewModel.isLoading {
        ProgressView()
          .controlSize(.large)
          .progressViewStyle(CircularProgressViewStyle(tint: Colors.Icon.green.swiftUIColor()))
          .padding(Constants.progressViewPadding)
      } else {
        self.categoryList
      }

      Spacer()

      self.footerView
        .padding()
    }
    .background(Colors.Background.surfacePrimary.swiftUIColor())

    // Handle actions
    .onReceive(self.viewModel.selectedCategory) { category in
      self.onSelectedCategory?(category)
    }
    .onReceive(self.viewModel.seeResultsTapped) {
      self.onResults?()
    }
    .onReceive(self.viewModel.closeTapped) {
      self.onClose?()
    }
  }

  @ViewBuilder
  private var headerView: some View {
    HStack {
      Text(Strings.Category())
        .font(Font.ksr_headingXL())
        .foregroundStyle(Colors.Text.primary.swiftUIColor())
      Spacer()
      Button(action: { [weak viewModel] () in
        viewModel?.close()
      }) {
        Image(ImageResource.iconCross)
          .foregroundStyle(Colors.Icon.primary.swiftUIColor())
          .accessibilityLabel(Strings.accessibility_discovery_buttons_close())
          .accessibilityAddTraits(.isButton)
      }
    }
    .padding(Constants.headerPadding)
    .background(Colors.Background.surfacePrimary.swiftUIColor())
    self.separator
  }

  @ViewBuilder
  private var categoryList: some View {
    List(self.viewModel.categories) { category in
      VStack(spacing: 0) {
        HStack {
          Text(category.name)
            .font(Font.ksr_headingLG())
            .foregroundStyle(Colors.Text.primary.swiftUIColor())
          Spacer()
          self.radioButton(isSelected: self.viewModel.isCategorySelected(category))
        }
        .padding(.vertical, Constants.rowPaddingVertical)
        .padding(.horizontal, Constants.rowPaddingHorizontal)

        self.separator
      }
      .background(Colors.Background.surfacePrimary.swiftUIColor())
      .listRowInsets(EdgeInsets()) // Remove List internal insets
      .listRowSeparator(.hidden) // Hide default separators
      .contentShape(Rectangle())
      .onTapGesture { [weak viewModel] () in
        viewModel?.selectCategory(category)
      }
    }
    .listStyle(.plain)
  }

  @ViewBuilder
  private var separator: some View {
    Rectangle()
      .fill(Colors.Border.subtle.swiftUIColor())
      .frame(height: Constants.separatorHeight)
      .frame(maxWidth: .infinity)
  }

  @ViewBuilder
  private var footerView: some View {
    HStack(spacing: Styles.grid(2)) {
      Button(Strings.Reset_filters()) { [weak viewModel] () in
        viewModel?.resetSelection()
      }
      .buttonStyle(KSRButtonStyleModifier(style: .outlined))
      .frame(maxWidth: Constants.resetButtonMaxWidth)
      .disabled(!self.viewModel.canReset)

      Button(Strings.See_results()) { [weak viewModel] () in
        viewModel?.seeResults()
      }
      .buttonStyle(KSRButtonStyleModifier(style: .filled))
      .frame(maxWidth: .infinity)
      .disabled(self.viewModel.isLoading)
    }
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
}

private enum Constants {
  static let headerPadding: CGFloat = 24.0
  static let progressViewPadding: CGFloat = 24.0
  static let radioButtonSize: CGFloat = 24.0
  static let radioButtonOuterBorder: CGFloat = 1.0
  static let radioButtonInnerBorder: CGFloat = 8.0
  static let resetButtonMaxWidth: CGFloat = 130.0
  static let rowPaddingHorizontal: CGFloat = 24.0
  static let rowPaddingVertical: CGFloat = 20.0
  static let separatorHeight: CGFloat = 1.0
}

#if targetEnvironment(simulator)
  #Preview("Filter Categories") {
    FilterCategoryView_PhaseOne(
      viewModel: FilterCategoryViewModel(with: ConcreteFilterCategory.allCases),
      onSelectedCategory: { category in
        print("Selected Category: \(category?.name ?? "None")")
      },
      onResults: {
        print("Results tapped")
      },
      onClose: {
        print("Closed")
      }
    )
  }
#endif
