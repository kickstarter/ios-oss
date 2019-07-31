import Foundation
@testable import KsApi
@testable import Library
import ReactiveExtensions
import ReactiveExtensions_TestHelpers

final class PledgePaymentMethodsViewModelTests: TestCase {
  private let vm: PledgePaymentMethodsViewModelType = PledgePaymentMethodsViewModel()

  private let reloadPaymentMethods = TestObserver<[GraphUserCreditCard.CreditCard], Never>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.reloadPaymentMethods.observe(self.reloadPaymentMethods.observer)
  }

  func testReloadPaymentMethods() {
    self.reloadPaymentMethods.assertDidNotEmitValue()
    let cards = GraphUserCreditCard.template.storedCards.nodes
    self.vm.inputs.configureWith(cards)
    self.reloadPaymentMethods.assertValue(cards)
  }
}
