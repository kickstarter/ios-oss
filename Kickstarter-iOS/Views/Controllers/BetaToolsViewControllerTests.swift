import Library
import Prelude
import Result
@testable import Kickstarter_Framework
@testable import KsApi

final class BetaToolsViewControllerTests: TestCase {

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

  func testBetaToolsViewController() {
    let service = MockService(serverConfig: ServerConfig.staging)

    withEnvironment(apiService: service, language: .en) {
        let controller = BetaToolsViewController.instantiate()
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view)
    }
  }
}
