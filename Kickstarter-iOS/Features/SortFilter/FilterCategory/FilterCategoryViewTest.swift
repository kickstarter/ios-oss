@testable import Kickstarter_Framework
import SnapshotTesting
import SwiftUI
import XCTest

final class FilterCategoryViewTest: TestCase {
  private let size = CGSize(width: 375, height: 667)
  private let testCategories = ConcreteFilterCategory.allCases

  // TODO: Find a better solution for loading custom fonts and colors in the test bundle.
  // Potential solution: Load assets using `Bundle(for: SomeClass.self)` or set a custom bundle in `withEnvironment`.
  // [MBL-2202](https://kickstarter.atlassian.net/browse/MBL-2202)
  private let mockBundle = MockBundle(bundleIdentifier: "com.Kickstarter-Framework-iOS")

  @MainActor
  func testFilterCategoryView_LoadingState() async {
    await withEnvironment(mainBundle: self.mockBundle) {
      let view =
        VStack {
          FilterCategoryView(viewModel: FilterCategoryViewModel<ConcreteFilterCategory>(with: []))
            .frame(width: self.size.width)
            .frame(maxHeight: .infinity)
            .padding()
        }.frame(height: self.size.height)
      try? await Task.sleep(nanoseconds: 10_000_000)
      assertSnapshot(matching: view, as: .image)
    }
  }

  @MainActor
  func testFilterCategoryView_CategoriesList() async {
    await withEnvironment(mainBundle: self.mockBundle) {
      let viewModel = FilterCategoryViewModel(with: self.testCategories)
      let view =
        VStack {
          FilterCategoryView(viewModel: viewModel)
            .frame(width: self.size.width)
            .frame(maxHeight: .infinity)
            .padding()
        }.frame(height: self.size.height)

      viewModel.selectCategory(.categoryThree)

      try? await Task.sleep(nanoseconds: 10_000_000)
      assertSnapshot(matching: view, as: .image)
    }
  }
}
