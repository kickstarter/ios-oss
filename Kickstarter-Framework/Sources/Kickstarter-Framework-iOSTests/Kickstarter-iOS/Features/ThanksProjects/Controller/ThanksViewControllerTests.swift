@testable import Kickstarter_Framework
@testable import KsApi
@testable import KsApiTestHelpers
import Library
@testable import LibraryTestHelpers
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

    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
      language, device in
      withEnvironment(apiService: mockService, language: language) {
        let project = Project.cosmicSurgery
          |> Project.lens.id .~ 3

        let controller = ThanksViewController.configured(with: (project, Reward.template, nil, 1))
        // Wrapping this in a nav view so we can see the close button.
        let nav = UINavigationController(rootViewController: controller)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: nav)
        parent.view.frame.size.height = 1_000

        // These are't being correctly passed down to the Thanks controller, now that it's wrapped in a nav view.
        // So calling them manually to force everything to work correctly.
        controller.beginAppearanceTransition(true, animated: false)
        controller.endAppearanceTransition()

        self.scheduler.run()

        assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
      }
    }
  }
}
