@testable import Kickstarter_Framework
@testable import KsApi
import Library
import Prelude

class ThanksViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()

    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)

    super.tearDown()
  }

  func testThanksViewController() {
    let discoveryEnvelope = DiscoveryEnvelope.template
    let rootCategories = RootCategoriesEnvelope(rootCategories: [Category.tabletopGames])
    let mockService = MockService(
      fetchGraphCategoriesResponse: rootCategories,
      fetchDiscoveryResponse: discoveryEnvelope
    )

    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
      language, device in
      withEnvironment(apiService: mockService, language: language) {
        let project = Project.cosmicSurgery
          |> Project.lens.id .~ 3

        let controller = ThanksViewController.configured(with: (project, Reward.template, nil))

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_000

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testThanksViewController_ExperimentalCards() {
    let discoveryEnvelope = DiscoveryEnvelope.template
    let rootCategories = RootCategoriesEnvelope(rootCategories: [Category.tabletopGames])
    let mockService = MockService(
      fetchGraphCategoriesResponse: rootCategories,
      fetchDiscoveryResponse: discoveryEnvelope
    )

    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.nativeProjectCards.rawValue: OptimizelyExperiment.Variant.variant1.rawValue
      ]

    combos(Language.allLanguages, Device.allCases).forEach {
      language, device in
      withEnvironment(apiService: mockService, language: language, optimizelyClient: mockOptimizelyClient) {
        let project = Project.cosmicSurgery
          |> Project.lens.id .~ 3

        let controller = ThanksViewController.configured(with: (project, Reward.template, nil))

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_000

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }
}
