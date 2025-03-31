@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import SnapshotTesting
import XCTest

internal final class CategorySelectionViewControllerTests: TestCase {
  func testCategorySelectionViewController() {
    let categoriesResponse = RootCategoriesEnvelope.init(rootCategories: [
      .art,
      .games,
      .filmAndVideo
    ])

    let mockService = MockService(fetchGraphCategoriesResult: .success(categoriesResponse))

    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(apiService: mockService, language: language) {
        let controller = CategorySelectionViewController.instantiate()
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.run()

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
      }
    }
  }
}
