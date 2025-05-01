@testable import Kickstarter_Framework
@testable import KsApi
import SnapshotTesting
import SwiftUI
import XCTest

final class FilterCategoryViewTest: TestCase {
  private let size = CGSize(width: 375, height: 667)
  private let testCategories = ConcreteFilterCategory.allCases

  @MainActor
  func testFilterCategoryView_LoadingState() async {
    let view =
      VStack {
        FilterCategoryView(categories: [], selectedCategory: .constant(.none))
          .frame(width: self.size.width)
          .frame(maxHeight: .infinity)
          .padding()
      }.frame(height: self.size.height)
    try? await Task.sleep(nanoseconds: 10_000_000)
    assertSnapshot(matching: view, as: .image)
  }

  @MainActor
  func testFilterCategoryView_CategoriesList() async {
    // FIXME: https://kickstarter.atlassian.net/browse/MBL-2384
    // This snapshot test looks wrong, the UI in the app does not have the lines
    // along the left and right sides of the button. This is consistent with
    // other uses of SearchFiltersPillStyle.
    let view =
      VStack {
        FilterCategoryView(categories: [
          .art,
          .filmAndVideo,
          .games
        ], selectedCategory: .constant(.subcategory(.art, .illustration)))
          .frame(width: self.size.width)
          .frame(maxHeight: .infinity)
          .padding()
      }.frame(height: self.size.height)

    try? await Task.sleep(nanoseconds: 10_000_000)
    assertSnapshot(matching: view, as: .image)
  }
}
