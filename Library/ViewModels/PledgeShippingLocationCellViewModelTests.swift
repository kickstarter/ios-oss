import Foundation
@testable import KsApi
@testable import Library
import ReactiveExtensions
import ReactiveExtensions_TestHelpers

final class PledgeShippingLocationCellViewModelTests: TestCase {
  private let vm: PledgeShippingLocationCellViewModelType = PledgeShippingLocationCellViewModel()

  private let amountAttributedText = TestObserver<NSAttributedString, Never>()
  private let shippingLocation = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.amountAttributedText.observe(self.amountAttributedText.observer)
    self.vm.outputs.shippingLocationButtonTitle.observe(self.shippingLocation.observer)
  }

  func testAmountAttributedText() {
    let expectedAttributedString = NSMutableAttributedString(
      string: "+$5.00", attributes: checkoutCurrencyDefaultAttributes()
    )
    expectedAttributedString.addAttributes(
      checkoutCurrencySuperscriptAttributes(), range: NSRange(location: 0, length: 2)
    )
    expectedAttributedString.addAttributes(
      checkoutCurrencySuperscriptAttributes(), range: NSRange(location: 3, length: 3)
    )

    self.vm.inputs.configureWith(isLoading: false, project: .template, selectedShippingRule: nil)
    self.amountAttributedText.assertDidNotEmitValue()

    self.vm.inputs.configureWith(isLoading: false, project: .template, selectedShippingRule: .template)
    self.amountAttributedText.assertValues([expectedAttributedString])
  }

  func testShippingLocation() {
    self.vm.inputs.configureWith(isLoading: false, project: .template, selectedShippingRule: nil)
    self.shippingLocation.assertDidNotEmitValue()

    self.vm.inputs.configureWith(isLoading: false, project: .template, selectedShippingRule: .template)
    self.shippingLocation.assertValues(["Brooklyn, NY"])
  }
}
