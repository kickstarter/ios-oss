import Foundation
import SwiftUI

public struct PagedTabBar<Page: TabBarPage>: View {
  @StateObject var viewModel: PagedContainerViewModel<Page>

  public var body: some View {
    HStack(spacing: Constants.spacing) {
      ForEach(self.viewModel.pages, id: \.page.id) { page, _ in
        self.tab(for: page)
      }
    }
    .frame(height: Constants.height)
  }

  @ViewBuilder
  private func tab(for page: Page) -> some View {
    Button(action: { self.viewModel.didSelect(page: page) }) {
      HStack {
        Text(page.name)
          .lineLimit(Constants.lineLimit)
          .truncationMode(Constants.label.truncation)
          .font(Font(Constants.label.font))
          .foregroundStyle(Color(
            self.isSelected(page: page) ? Constants.label.color.selected : Constants
              .label.color.deselected
          ))
        switch page.badge {
        case .none:
          EmptyView()
        case .dot:
          Circle()
            .fill(Color(Constants.badge.backgroundColor))
            .frame(width: Constants.badge.dotSize, height: Constants.badge.dotSize, alignment: .center)
        case let .count(badgeCount):
          Text("\(badgeCount)")
            .truncationMode(Constants.label.truncation)
            .lineLimit(Constants.badge.lineLimit)
            .font(Font(Constants.badge.font))
            .foregroundStyle(Color(Constants.badge.labelColor))
            .padding(Constants.badge.padding)
            .background(
              Capsule(style: Constants.badge.style)
                .fill(Color(Constants.badge.backgroundColor))
            )
        }
      }
      .padding(Constants.padding)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
      Rectangle()
        .frame(height: Constants.bottomBorder.height)
        .foregroundStyle(Color(
          self.isSelected(page: page) ? Constants.bottomBorder.selected : Constants
            .bottomBorder.deselected
        )),

      alignment: Constants.badge.alignment
    )
    .accessibilityElement(children: .combine)
  }

  private func isSelected(page: Page) -> Bool {
    self.viewModel.displayPage?.page.id == page.id
  }
}

private enum Constants {
  static let height: CGFloat = 46
  static let lineLimit = 2
  static let padding = Edge.Set.horizontal
  static let spacing: CGFloat = 0

  static let label = (
    font: UIFont.ksr_subhead(),
    color: (
      selected: LegacyColors.ksr_black.uiColor(),
      deselected: LegacyColors.ksr_support_500.uiColor()
    ),
    truncation: Text.TruncationMode.tail
  )

  static let bottomBorder = (
    selected: LegacyColors.ksr_black.uiColor(),
    deselected: LegacyColors.ksr_support_300.uiColor(),
    height: CGFloat(1)
  )

  static let badge = (
    font: UIFont.ksr_caption2().bolded,
    labelColor: UIColor.white,
    backgroundColor: UIColor.red,
    padding: EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5),
    style: RoundedCornerStyle.circular,
    alignment: Alignment.bottom,
    dotSize: Styles.grid(1),
    lineLimit: 1
  )
}

#Preview {
  struct FakeTabBarPage: TabBarPage {
    var name: String
    var badge: TabBarBadge

    let id = UUID().uuidString
  }

  let viewModel = PagedContainerViewModel<FakeTabBarPage>()
  viewModel.configure(with: [
    (FakeTabBarPage(name: "Project alerts", badge: .count(5)), UIViewController()),
    (FakeTabBarPage(name: "Activity feed", badge: .none), UIViewController())
  ])
  return PagedTabBar<FakeTabBarPage>(viewModel: viewModel)
    .frame(maxWidth: .infinity)
}
