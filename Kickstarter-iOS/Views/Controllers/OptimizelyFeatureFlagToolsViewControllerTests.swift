@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude

final class OptimizelyFeatureFlagToolsViewControllerTests: TestCase {
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

  func testOptimizelyFeatureFlagToolsViewController() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [
        OptimizelyFeature.commentFlaggingEnabled.rawValue: false,
        OptimizelyFeature.commentThreading.rawValue: true,
        OptimizelyFeature.commentThreadingRepliesEnabled.rawValue: true
      ]

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, device in
      withEnvironment(language: language, mainBundle: MockBundle(), optimizelyClient: mockOptimizelyClient) {
        let controller = OptimizelyFeatureFlagToolsViewController.instantiate()
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view)
      }
    }
  }
}
