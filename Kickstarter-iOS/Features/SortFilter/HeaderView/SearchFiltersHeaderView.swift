import Library
import SwiftUI

class SearchFiltersHeaderViewModel: ObservableObject {
  @Published var pills: [SearchFilterPill]

  init(pills: [SearchFilterPill]) {
    self.pills = pills
  }
}

struct SearchFiltersHeaderView: View {
  let didTapPill: (SearchFilterPill) -> Void

  // The pills are passed down from the parent SearchViewController.
  // Using an EnvironmentObject here because that's the cleanest way to represent
  // this relationship to SwiftUI.
  @EnvironmentObject var container: SearchFiltersHeaderViewModel
  @SwiftUICore.Environment(\.horizontalSizeClass) private var horizontalSizeClass

  var body: some View {
    ScrollView(.horizontal) {
      HStack {
        ForEach(self.container.pills) { pill in
          Button {
            self.didTapPill(pill)
          } label: {
            switch pill.buttonType {
            case let .image(image):
              ImagePillLabel(image: Library.image(named: image)!)
            case let .dropdown(title):
              DropdownPillLabel(title: title)
            }
          }
          .buttonStyle(SearchFiltersPillStyle(isHighlighted: pill.isHighlighted))
        }
      }
      .padding(EdgeInsets(
        top: Styles.grid(1),
        leading: self.horizontalSizeClass == .compact ? Constants.pillLeftInsetForIPhone : Constants
          .pillLeftInsetForIPad,
        bottom: Styles.grid(1),
        trailing: Styles.grid(1)
      ))
    }
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

let previewContainer = SearchFiltersHeaderViewModel(pills: previewPills)

#Preview {
  SearchFiltersHeaderView(didTapPill: { _ in })
    .environmentObject(previewContainer)
}
