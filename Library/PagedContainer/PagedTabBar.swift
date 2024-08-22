import Foundation
import SwiftUI

public protocol TabBarPage: Identifiable {
  var name: String { get }
  var badgeCount: Int? { get }
}

public struct PagedTabBar<Page: TabBarPage>: View {
  public init(pages: [Page], selection: Binding<Page?>? = nil) {
    self.pages = pages
    self.selection = selection
  }

  let pages: [Page]
  let selection: Binding<Page?>?

  private func isPageSelected(_ page: Page) -> Bool {
    self.selection?.wrappedValue?.id == page.id
  }

  @ViewBuilder
  private func tab(for page: Page) -> some View {
    Button(action: { self.selection?.wrappedValue = page }) {
      HStack {
        Text(page.name)
          .lineLimit(1)
          .truncationMode(.tail)
          .foregroundStyle(Color(
            self.isPageSelected(page) ? Constants.labelColor.selected : Constants
              .labelColor.deselected
          ))
          .font(Font(Constants.labelFont))
        if let badgeCount = page.badgeCount {
          Text("\(badgeCount)")
            .truncationMode(.tail)
            .lineLimit(1)
            .font(Font(Constants.badge.font))
            .foregroundStyle(Color(Constants.badge.labelColor))
            .padding(EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5))
            .background(
              Capsule(style: .continuous)
                .fill(Color(Constants.badge.backgroundColor))
            )
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .overlay(
      Rectangle()
        .frame(height: 1)
        .foregroundStyle(Color(
          self.isPageSelected(page) ? Constants.bottomBorder.selected : Constants
            .bottomBorder.deselected
        )),
      alignment: .bottom
    )
  }

  public var body: some View {
    HStack(spacing: 0) {
      ForEach(self.pages) { page in
        self.tab(for: page)
      }
    }
    .frame(height: Constants.height)
  }
}

private enum Constants {
  static let height: CGFloat = 46

  static let labelFont = UIFont.ksr_subhead()
  static let labelColor = (
    selected: UIColor.ksr_black,
    deselected: UIColor.ksr_support_500
  )

  static let bottomBorder = (
    selected: UIColor.ksr_black,
    deselected: UIColor.ksr_support_300
  )

  static let badge = (
    font: UIFont.ksr_caption2().bolded,
    labelColor: UIColor.white,
    backgroundColor: UIColor.red
  )
}

#Preview {
  struct FakeTabBarPage: TabBarPage {
    var name: String
    var badgeCount: Int?

    let id = UUID().uuidString
  }

  var pages = [
    FakeTabBarPage(name: "Project alerts", badgeCount: 5),
    FakeTabBarPage(name: "Activity feed", badgeCount: nil)
  ]
  var selection: FakeTabBarPage? = pages.first
  let binding = Binding(get: { selection }, set: { selection = $0 })
  return PagedTabBar(pages: pages, selection: binding)
    .frame(maxWidth: .infinity)
}
