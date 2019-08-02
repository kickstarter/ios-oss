@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class PledgeAddNewCardViewModelTests: TestCase {
  private let vm = PledgeAddNewCardViewModel()

  private let notifyDelegateAddNewCardTapped = TestObserver<Void, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.notifyDelegateAddNewCardTapped.observe(self.notifyDelegateAddNewCardTapped.observer)
  }

  func testAddNewCard() {
    self.notifyDelegateAddNewCardTapped.assertDidNotEmitValue()

    self.vm.inputs.addNewCardButtonTapped()

    self.notifyDelegateAddNewCardTapped.assertValueCount(1)

    self.vm.inputs.addNewCardButtonTapped()

    self.notifyDelegateAddNewCardTapped.assertValueCount(2)
  }
}
