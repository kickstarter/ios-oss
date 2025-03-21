@testable import Kickstarter_Framework
import SnapshotTesting
import SwiftUI
import XCTest

final class SortViewTest: TestCase {
  private let size = CGSize(width: 375, height: 667)

  // TODO: Find a better solution for loading custom fonts and colors in the test bundle.
  // Potential solution: Load assets using `Bundle(for: SomeClass.self)` or set a custom bundle in `withEnvironment`.
  // [MBL-2202](https://kickstarter.atlassian.net/browse/MBL-2202)
  private let mockBundle = MockBundle(bundleIdentifier: "com.Kickstarter-Framework-iOS")

  @MainActor
  func testSortView_DefaultOption() async {
    await withEnvironment(mainBundle: self.mockBundle) {
      let view =
        VStack {
          SortView(viewModel: SortViewModel())
            .frame(width: self.size.width)
            .frame(maxHeight: .infinity)
            .padding()
        }.frame(height: self.size.height)
      try? await Task.sleep(nanoseconds: 10_000_000)
      assertSnapshot(matching: view, as: .image)
    }
  }

  @MainActor
  func testSortView_SelectedOption() async {
    await withEnvironment(mainBundle: self.mockBundle) {
      let viewModel = SortViewModel()
      let view =
        VStack {
          SortView(viewModel: viewModel)
            .frame(width: self.size.width)
            .frame(maxHeight: .infinity)
            .padding()
        }.frame(height: self.size.height)
      viewModel.selectSortOption(.popularity)
      try? await Task.sleep(nanoseconds: 10_000_000)
      assertSnapshot(matching: view, as: .image)
    }
  }
}
