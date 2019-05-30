import XCTest
@testable import Library
@testable import KsApi
import ReactiveExtensions_TestHelpers
import KsApi
import Prelude

final class FindFriendsHeaderCellViewModelTests: TestCase {
  let vm: FindFriendsHeaderCellViewModelType = FindFriendsHeaderCellViewModel()

  let notifyPresenterGoToFriends = TestObserver<(), Never>()
  let notifyPresenterToDismissHeader = TestObserver<(), Never>()

  override func setUp() {
    super.setUp()

    vm.outputs.notifyDelegateGoToFriends.observe(notifyPresenterGoToFriends.observer)
    vm.outputs.notifyDelegateToDismissHeader.observe(notifyPresenterToDismissHeader.observer)
  }

  func testGoToFriends() {
    vm.inputs.configureWith(source: FriendsSource.activity)

    notifyPresenterGoToFriends.assertValueCount(0)

    vm.inputs.findFriendsButtonTapped()

    notifyPresenterGoToFriends.assertValueCount(1)
  }

  func testDismissal() {
    vm.inputs.configureWith(source: FriendsSource.activity)

    notifyPresenterToDismissHeader.assertValueCount(0)

    vm.inputs.closeButtonTapped()

    notifyPresenterToDismissHeader.assertValueCount(1)
    XCTAssertEqual(["Close Find Friends"], self.trackingClient.events)
    // swiftlint:disable:next force_cast
    XCTAssertEqual(["activity"], self.trackingClient.properties.map { $0["source"] as! String? })
  }
}
