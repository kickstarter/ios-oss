@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class EmptyStatesViewModelTests: TestCase {
  internal let vm: EmptyStatesViewModelType = EmptyStatesViewModel()
  internal let notifyDelegateToGoToDiscovery = TestObserver<DiscoveryParams?, Never>()
  internal let notifyDelegateToGoToFriends = TestObserver<(), Never>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.notifyDelegateToGoToDiscovery.observe(self.notifyDelegateToGoToDiscovery.observer)
    self.vm.outputs.notifyDelegateToGoToFriends.observe(self.notifyDelegateToGoToFriends.observer)
  }

  func testGoToDiscovery_Non_Activity() {
    let params = DiscoveryParams.defaults |> DiscoveryParams.lens.sort .~ .magic
    self.vm.inputs.configureWith(emptyState: .starred)
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.mainButtonTapped()

    self.notifyDelegateToGoToFriends.assertValueCount(0)
    self.notifyDelegateToGoToDiscovery.assertValues([params])
  }

  func testGoToDiscovery_Activity() {
    self.vm.inputs.configureWith(emptyState: .activity)
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.mainButtonTapped()

    self.notifyDelegateToGoToFriends.assertValueCount(0)
    self.notifyDelegateToGoToDiscovery.assertValues([nil])
  }

  func testGoToFriends_SocialNoPledges() {
    self.vm.inputs.configureWith(emptyState: .socialNoPledges)
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.mainButtonTapped()

    self.notifyDelegateToGoToFriends.assertValueCount(1)
    self.notifyDelegateToGoToDiscovery.assertValueCount(0)
  }

  func testGoToFriends_SocialDisabled() {
    self.vm.inputs.configureWith(emptyState: .socialDisabled)
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.mainButtonTapped()

    self.notifyDelegateToGoToFriends.assertValueCount(1)
    self.notifyDelegateToGoToDiscovery.assertValueCount(0)
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
