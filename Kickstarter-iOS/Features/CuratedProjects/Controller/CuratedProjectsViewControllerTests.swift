@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import SnapshotTesting
import XCTest

internal final class CuratedProjectsViewControllerTests: TestCase {
  func testCuratedProjectsViewController() {
    let categories: [KsApi.Category] = [
      .art,
      .games,
      .filmAndVideo
    ]

    let projects = categories.map { _ -> Project in
      Project.template
    }

    let discoveryEnvelope = DiscoveryEnvelope.template
      |> DiscoveryEnvelope.lens.projects .~ projects

    let mockService = MockService(fetchDiscoveryResponse: discoveryEnvelope)

    orthogonalCombos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(apiService: mockService, language: language) {
        let controller = CuratedProjectsViewController.instantiate()
        controller.configure(with: categories, context: .onboarding)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_000

        self.scheduler.run()

        assertSnapshot(
          matching: parent.view,
          as: .image,
          named: "lang_\(language)_device_\(device)"
        )
      }
    }
  }
}
