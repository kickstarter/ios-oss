@testable import Kickstarter_Framework
@testable import KsApi
import Library
import Prelude
import SnapshotTesting
import UIKit

class ThanksViewControllerTests: TestCase {
  private let categoryEnvelope = CategoryEnvelope(node: .template)

  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testThanksViewController() {
    let discoveryEnvelope = DiscoveryEnvelope.template
    let rootCategories = RootCategoriesEnvelope(rootCategories: [Category.tabletopGames])
    let mockService = MockService(
      fetchGraphCategoryResult: .success(categoryEnvelope),
      fetchGraphCategoriesResult: .success(rootCategories),
      fetchDiscoveryResponse: discoveryEnvelope
    )

    forEachScreenshotType { type in
      withEnvironment(apiService: mockService, language: type.language) {
        let project = Project.cosmicSurgery
          |> Project.lens.id .~ 3

        let controller = ThanksViewController.configured(with: (project, Reward.template, nil, 1))
        controller.view.frame.size.height = 1_000

        self.scheduler.run()

        assertSnapshot(
          forController: controller,
          withType: type,
          testName: "testThanksViewController"
        )
      }
    }
  }
}
