import Foundation
import SwiftUI

public struct PagedTabBar<Page: TabBarPage>: View {
  @ObservedObject var viewModel: PagedContainerViewModel<Page>

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
        if let badgeCount = page.badgeCount {
          Text("\(badgeCount)")
            .truncationMode(Constants.label.truncation)
            .lineLimit(Constants.lineLimit)
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
  }

  private func isSelected(page: Page) -> Bool {
    self.viewModel.displayPage?.page.id == page.id
  }
}

private enum Constants {
  static let height: CGFloat = 46
  static let lineLimit = 1
  static let padding = Edge.Set.horizontal
  static let spacing: CGFloat = 0

  static let label = (
    font: UIFont.ksr_subhead(),
    color: (
      selected: UIColor.ksr_black,
      deselected: UIColor.ksr_support_500
    ),
    truncation: Text.TruncationMode.tail
  )

  static let bottomBorder = (
    selected: UIColor.ksr_black,
    deselected: UIColor.ksr_support_300,
    height: CGFloat(1)
  )

  static let badge = (
    font: UIFont.ksr_caption2().bolded,
    labelColor: UIColor.white,
    backgroundColor: UIColor.red,
    padding: EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5),
    style: RoundedCornerStyle.circular,
    alignment: Alignment.bottom
  )
}

#Preview {
  struct FakeTabBarPage: TabBarPage {
    var name: String
    var badgeCount: Int?

    let id = UUID().uuidString
  }

  let viewModel = PagedContainerViewModel<FakeTabBarPage>()
  viewModel.configure(with: [
    (FakeTabBarPage(name: "Project alerts", badgeCount: 5), UIViewController()),
    (FakeTabBarPage(name: "Activity feed", badgeCount: nil), UIViewController())
  ])
  return PagedTabBar<FakeTabBarPage>(viewModel: viewModel)
    .frame(maxWidth: .infinity)
}
