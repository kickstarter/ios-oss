import KsApi
import Library
import SwiftUI

struct FilterCategoryView: View {
  let categories: [KsApi.Category]
  @Binding var selectedCategory: SearchFiltersCategory

  var body: some View {
    VStack(spacing: 0) {
      if self.categories.isEmpty {
        ProgressView()
          .controlSize(.large)
          .progressViewStyle(CircularProgressViewStyle(tint: Colors.Icon.green.swiftUIColor()))
          .padding(Constants.progressViewPadding)
      } else {
        self.categoryList
      }
    }
    .background(Colors.Background.Surface.primary.swiftUIColor())
  }

  @ViewBuilder
  private var categoryList: some View {
    List(self.categories) { category in
      VStack(spacing: 0) {
        HStack {
          Text(category.name)
            .font(Font.ksr_headingLG())
            .foregroundStyle(Colors.Text.primary.swiftUIColor())
          Spacer()
          self.radioButton(isSelected: self.selectedCategory.isRootCategorySelected(category))
            .id("\(category.id)-radio-button")
        }
        .background(Colors.Background.Surface.primary.swiftUIColor())
        .padding(.vertical, Constants.rowPaddingVertical)
        .padding(.horizontal, Constants.rowPaddingHorizontal)

        self.subcategories(
          for: category
        )

        self.separator
          .id("\(category.id)-separator")
      }
      .background(Colors.Background.Surface.primary.swiftUIColor())
      .listRowInsets(EdgeInsets()) // Remove List internal insets
      .listRowSeparator(.hidden) // Hide default separators
      .contentShape(Rectangle())
      .onTapGesture { () in
        self.selectedCategory = .rootCategory(category)
      }
      .id(category.id)
    }
    .listStyle(.plain)
  }

  @ViewBuilder
  private func subcategories(for category: KsApi.Category) -> some View {
    if self.selectedCategory.isRootCategorySelected(category),
       let subcategories = category.subcategories?.nodes {
      FlowLayout(horizontalSpacing: 8, verticalSpacing: 8, alignment: .leading) {
        TitlePillButton(
          title: Strings.Project_status_all(),
          isHighlighted: !self.selectedCategory.hasSubcategory(),
          count: nil
        ) {
          self.selectedCategory = .rootCategory(category)
        }
        ForEach(subcategories) { subcategory in
          TitlePillButton(
            title: subcategory.name,
            isHighlighted: self.selectedCategory.isSubcategorySelected(subcategory),
            count: nil
          ) {
            self.selectedCategory = .subcategory(
              rootCategory: category,
              subcategory: subcategory
            )
          }
          .id(subcategory.id)
        }
      }
      .padding(EdgeInsets(top: 4, leading: 24, bottom: 16, trailing: 24))
    }
  }

  @ViewBuilder
  private var separator: some View {
    Rectangle()
      .fill(Colors.Border.subtle.swiftUIColor())
      .frame(height: Constants.separatorHeight)
      .frame(maxWidth: .infinity)
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

extension KsApi.Category: @retroactive Identifiable {}

#if targetEnvironment(simulator)

  let previewCategories = (1...5).map { i in
    Category(
      analyticsName: nil,
      id: "\(i)",
      name: "Category Number \(i)"
    )
    /* TODO: add subcategories here for a nicer preview */
  }

  #Preview("Filter Categories") {
    FilterCategoryView(
      categories: previewCategories,
      selectedCategory: .constant(.rootCategory(previewCategories[2]))
    )
  }
#endif
