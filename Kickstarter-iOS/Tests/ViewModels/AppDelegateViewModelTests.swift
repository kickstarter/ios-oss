import XCTest
@testable import Kickstarter_iOS
@testable import Library

final class AppDelegateViewModelTests: XCTestCase {


  func testHockeyManagerStartsWhenAppLaunches() {
    let hockeyManager = MockHockeyManager()

    withEnvironment(hockeyManager: hockeyManager) {
      let viewModel = AppDelegateViewModel()

      XCTAssertFalse(hockeyManager.managerStarted, "Manager should not start right away.")

      viewModel.inputs.applicationDidFinishLaunching(launchOptions: [:])
      XCTAssertTrue(hockeyManager.managerStarted, "Manager should start when the app launches.")
    }
  }

  func testKoala_AppLifecycle() {
    let hockeyManager = MockHockeyManager()
    let trackingClient = MockTrackingClient()
    let koala = Koala(client: trackingClient)

    withEnvironment(hockeyManager: hockeyManager, koala: koala) {
      let viewModel = AppDelegateViewModel()

      XCTAssertEqual([], trackingClient.events)

      viewModel.inputs.applicationDidFinishLaunching(launchOptions: [:])
      XCTAssertEqual(["App Open"], trackingClient.events)

      viewModel.inputs.applicationDidEnterBackground()
      XCTAssertEqual(["App Open", "App Close"], trackingClient.events)

      viewModel.inputs.applicationWillEnterForeground()
      XCTAssertEqual(["App Open", "App Close", "App Open"], trackingClient.events)
    }
  }
}
