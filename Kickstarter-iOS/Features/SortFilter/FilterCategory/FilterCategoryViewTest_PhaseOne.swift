@testable import Kickstarter_Framework
import SnapshotTesting
import SwiftUI
import XCTest

final class FilterCategoryViewTest_PhaseOne: TestCase {
  private let size = CGSize(width: 375, height: 667)
  private let testCategories = ConcreteFilterCategory.allCases

  @MainActor
  func testFilterCategoryView_LoadingState() async {
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

  @MainActor
  func testFilterCategoryView_CategoriesList() async {
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
