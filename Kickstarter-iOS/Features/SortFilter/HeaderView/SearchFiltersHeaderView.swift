import Library
import SwiftUI

struct SelectedSearchFiltersHeaderView: View {
  @ObservedObject var selectedFilters: SearchFilters
  let didTapPill: (SearchFilterPill) -> Void

  var body: some View {
    SearchFiltersHeaderView(
      didTapPill: self.didTapPill,
      pills: self.selectedFilters.pills
    )
  }
}

struct SearchFiltersHeaderView: View {
  let didTapPill: (SearchFilterPill) -> Void
  let pills: [SearchFilterPill]

  @SwiftUICore.Environment(\.horizontalSizeClass) private var horizontalSizeClass

  var body: some View {
    ScrollView(.horizontal) {
      HStack {
        ForEach(self.pills) { pill in
          switch pill.buttonType {
          case let .image(image):
            if let uiImage = Library.image(named: image) {
              ImagePillButton(
                action: {
                  self.didTapPill(pill)
                },
                image: uiImage,
                isHighlighted: pill.isHighlighted,
                count: pill.count
              )
            }
          case let .dropdown(title):
            DropdownPillButton(
              action: {
                self.didTapPill(pill)
              },
              title: title,
              isHighlighted: pill.isHighlighted,
              count: pill.count
            )
          }
        }
      }
      .padding(EdgeInsets(
        top: Styles.grid(1),
        leading: self.horizontalSizeClass == .compact ?
          Constants.pillLeftInsetForIPhone : Constants.pillLeftInsetForIPad,
        bottom: Styles.grid(1),
        trailing: Styles.grid(1)
      ))
    }
    .scrollIndicators(.never)
    .background(Colors.Background.Surface.primary.swiftUIColor())
  }
}

private enum Constants {
  // These match the card insets in BackerDashboardProjectCell
  static let pillLeftInsetForIPad: CGFloat = Styles.grid(20)
  static let pillLeftInsetForIPhone: CGFloat = Styles.grid(2)
}

let previewPills = [
  SearchFilterPill(
    isHighlighted: true,
    filterType: .sort,
    buttonType: .image("icon-sort")
  ),
  SearchFilterPill(
    isHighlighted: false,
    filterType: .category,
    buttonType: .dropdown("Hello world")
  )
]

#Preview {
  SearchFiltersHeaderView(didTapPill: { _ in }, pills: previewPills)
}
