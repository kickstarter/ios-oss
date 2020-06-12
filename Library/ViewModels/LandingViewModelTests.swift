@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class LandingViewModelTests: TestCase {
  private let goToCategorySelection = TestObserver<Void, Never>()

  private let vm: LandingViewModelType = LandingViewModel()

  override func setUp() {
    super.setUp()

    self.vm.outputs.goToCategorySelection.observe(self.goToCategorySelection.observer)
  }

  func testGoToCategorySelection() {
    self.goToCategorySelection.assertDidNotEmitValue()

    XCTAssertNil(self.optimizelyClient.trackedEventKey)
    XCTAssertNil(self.optimizelyClient.trackedAttributes)
    XCTAssertEqual(self.trackingClient.events, [])

    self.vm.inputs.getStartedButtonTapped()

    self.goToCategorySelection.assertValueCount(1)

    XCTAssertEqual(self.optimizelyClient.trackedEventKey, "Get Started Button Clicked")
    XCTAssertEqual(self.trackingClient.events, ["Onboarding Get Started Button Clicked"])
    XCTAssertEqual(self.trackingClient.properties(forKey: "context_location"), ["landing_page"])
    assertBaseUserAttributesLoggedOut()
  }

  func testHasSeenCategoryPersonalizationFlowPropertyIsSet() {
    let mockKVStore = MockKeyValueStore()

    withEnvironment(userDefaults: mockKVStore) {
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      XCTAssertTrue(mockKVStore.hasSeenCategoryPersonalizationFlow)
    }
  }
}
