@testable import ReactiveExtensions_TestHelpers
@testable import KsApi
@testable import Library
@testable import Prelude
import ReactiveCocoa
import Result
import XCTest

internal final class EmptyStatesViewModelTests: TestCase {
  internal let vm: EmptyStatesViewModelType = EmptyStatesViewModel()
  internal let notifyDelegateToGoToDiscovery = TestObserver<DiscoveryParams?, NoError>()
  internal let notifyDelegateToGoToFriends = TestObserver<(), NoError>()

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

  func testTracking() {
    self.vm.inputs.configureWith(emptyState: .activity)
    self.vm.inputs.viewWillAppear()

    XCTAssertEqual(["Viewed Empty State"], self.trackingClient.events)
    XCTAssertEqual(["activity"], self.trackingClient.properties(forKey: "type", as: String.self))

    self.vm.inputs.mainButtonTapped()

    XCTAssertEqual(["Viewed Empty State", "Tapped Empty State Button"], self.trackingClient.events)
    XCTAssertEqual(["activity", "activity"], self.trackingClient.properties(forKey: "type", as: String.self))
  }
}
