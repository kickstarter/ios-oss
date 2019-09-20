@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class PledgeAddNewCardViewModelTests: TestCase {
  private let vm = PledgeAddNewCardViewModel()

  private let notifyDelegateAddNewCardTappedWithIntent = TestObserver<AddNewCardIntent, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.notifyDelegateAddNewCardTappedWithIntent
      .observe(self.notifyDelegateAddNewCardTappedWithIntent.observer)
  }

  func testAddNewCard() {
    self.notifyDelegateAddNewCardTappedWithIntent.assertDidNotEmitValue()

    self.vm.inputs.addNewCardButtonTapped()

    self.notifyDelegateAddNewCardTappedWithIntent.assertValues([.pledgeView])

    self.vm.inputs.addNewCardButtonTapped()

    self.notifyDelegateAddNewCardTappedWithIntent.assertValues([.pledgeView, .pledgeView])
  }
}
