@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import XCTest
import Prelude

internal final class CuratedProjectsViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()

    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()

    super.tearDown()
  }

  func testCategorySelectionViewController() {
    let categories: [KsApi.Category] = [
      .art,
      .games,
      .filmAndVideo
    ]

    let projects = categories.map { category -> Project in
      return Project.template
    }

    let discoveryEnvelope = DiscoveryEnvelope.template
      |> DiscoveryEnvelope.lens.projects .~ projects

    let mockService = MockService(fetchDiscoveryResponse: discoveryEnvelope)

    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(apiService: mockService, language: language) {
        let controller = CuratedProjectsViewController.instantiate()
        controller.configure(with: categories)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }
}

