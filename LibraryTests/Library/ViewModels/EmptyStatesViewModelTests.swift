@testable import KsApi
@testable import KsApiTestHelpers
@testable import Library
@testable import LibraryTestHelpers
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class EmptyStatesViewModelTests: TestCase {
  internal let vm: EmptyStatesViewModelType = EmptyStatesViewModel()
  internal let notifyDelegateToGoToDiscovery = TestObserver<DiscoveryParams?, Never>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.notifyDelegateToGoToDiscovery.observe(self.notifyDelegateToGoToDiscovery.observer)
  }

  func testGoToDiscovery_Non_Activity() {
    let params = DiscoveryParams.defaults |> DiscoveryParams.lens.sort .~ .magic
    self.vm.inputs.configureWith(emptyState: .starred)
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.mainButtonTapped()

    self.notifyDelegateToGoToDiscovery.assertValues([params])
  }

  func testGoToDiscovery_Activity() {
    self.vm.inputs.configureWith(emptyState: .activity)
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.mainButtonTapped()

    self.notifyDelegateToGoToDiscovery.assertValues([nil])
  }

  func testMainButtonTapped_TrackingEvents() {
    self.vm.inputs.configureWith(emptyState: .activity)
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.mainButtonTapped()

    XCTAssertEqual(["CTA Clicked"], self.segmentTrackingClient.events)

    XCTAssertEqual(self.segmentTrackingClient.properties(forKey: "context_page"), ["activity_feed"])

    XCTAssertEqual(self.segmentTrackingClient.properties(forKey: "context_cta"), ["discover"])
  }
}
