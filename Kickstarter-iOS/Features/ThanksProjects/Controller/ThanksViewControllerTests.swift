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

    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
      language, device in
      withEnvironment(apiService: mockService, language: language) {
        let project = Project.cosmicSurgery
          |> Project.lens.id .~ 3

        let controller = ThanksViewController.configured(with: (project, Reward.template, nil, 1))

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_000

        self.scheduler.run()

        assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
      }
    }
  }
}
