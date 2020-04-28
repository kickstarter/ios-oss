@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class FindFriendsHeaderCellViewModelTests: TestCase {
  let vm: FindFriendsHeaderCellViewModelType = FindFriendsHeaderCellViewModel()

  let notifyPresenterGoToFriends = TestObserver<(), Never>()
  let notifyPresenterToDismissHeader = TestObserver<(), Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.notifyDelegateGoToFriends.observe(self.notifyPresenterGoToFriends.observer)
    self.vm.outputs.notifyDelegateToDismissHeader.observe(self.notifyPresenterToDismissHeader.observer)
  }

  func testGoToFriends() {
    self.vm.inputs.configureWith(source: FriendsSource.activity)

    self.notifyPresenterGoToFriends.assertValueCount(0)

    self.vm.inputs.findFriendsButtonTapped()

    self.notifyPresenterGoToFriends.assertValueCount(1)
  }

  func testDismissal() {
    self.vm.inputs.configureWith(source: FriendsSource.activity)

    self.notifyPresenterToDismissHeader.assertValueCount(0)

    self.vm.inputs.closeButtonTapped()

    self.notifyPresenterToDismissHeader.assertValueCount(1)
    XCTAssertEqual(["Close Find Friends"], self.trackingClient.events)
    XCTAssertEqual(["activity"], self.trackingClient.properties.map { $0["source"] as! String? })
  }
}
