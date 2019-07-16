import Foundation
@testable import KsApi
@testable import Library
import ReactiveExtensions
import ReactiveExtensions_TestHelpers

final class PledgePaymentMethodsCellViewModelTests: TestCase {
  private let vm: PledgePaymentMethodsCellViewModelType = PledgePaymentMethodsCellViewModel()

  private let reloadData = TestObserver<[GraphUserCreditCard.CreditCard], Never>()
  private let updateConstraints = TestObserver<CGSize, Never>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.reloadData.observe(self.reloadData.observer)
    self.vm.outputs.updateConstraints.observe(self.updateConstraints.observer)
  }

  func testReloadData() {
    self.reloadData.assertDidNotEmitValue()
    let cards = GraphUserCreditCard.template.storedCards.nodes
    self.vm.inputs.configureWith(cards)
    self.reloadData.assertValue(cards)
  }

  func testUpdateConstraintsEmitsAfter_ChangingContentSize() {
    self.updateConstraints.assertDidNotEmitValue()
    self.vm.inputs.didUpdateContentSize(.zero)
    self.updateConstraints.assertValue(.zero)
  }
}
