import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class PledgeAmountSummaryViewModelTests: TestCase {
  private let vm: PledgeAmountSummaryViewModelType = PledgeAmountSummaryViewModel()

  private let pledgeAmountText = TestObserver<String, Never>()
  private let shippingAmountText = TestObserver<String, Never>()
  private let shippingLocationStackViewIsHidden = TestObserver<Bool, Never>()
  private let shippingLocationText = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.pledgeAmountText.map { $0.string }
      .observe(self.pledgeAmountText.observer)
    self.vm.outputs.shippingAmountText.map { $0.string }
      .observe(self.shippingAmountText.observer)
    self.vm.outputs.shippingLocationStackViewIsHidden
      .observe(self.shippingLocationStackViewIsHidden.observer)
    self.vm.outputs.shippingLocationText.observe(self.shippingLocationText.observer)
  }

  func testTextOutputsEmitTheCorrectValue() {
    let data = PledgeAmountSummaryViewData(
      projectCountry: Project.Country.us,
      pledgeAmount: 30.0,
      pledgedOn: 1_568_666_243.0,
      shippingAmount: 7.0,
      locationName: "United States",
      omitUSCurrencyCode: true
    )

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.pledgeAmountText.assertValue("$23.00")
    self.shippingAmountText.assertValue("+$7.00")
    self.shippingLocationText.assertValue("Shipping: United States")
  }

  func testTextOutputsEmitTheCorrectValue_ZeroShippingAmount() {
    let data = PledgeAmountSummaryViewData(
      projectCountry: Project.Country.us,
      pledgeAmount: 30.0,
      pledgedOn: 1_568_666_243.0,
      shippingAmount: 0,
      locationName: "United States",
      omitUSCurrencyCode: true
    )

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.pledgeAmountText.assertValue("$30.00")
    self.shippingAmountText.assertValue("+$0.00")
    self.shippingLocationText.assertValue("Shipping: United States")
  }

  func testShippingLocationStackViewIsHidden_isTrue_WhenLocationNameIsNil() {
    let data = PledgeAmountSummaryViewData(
      projectCountry: Project.Country.us,
      pledgeAmount: 30.0,
      pledgedOn: 1_568_666_243.0,
      shippingAmount: 7.0,
      locationName: nil,
      omitUSCurrencyCode: true
    )

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.shippingLocationStackViewIsHidden.assertValue(true)
  }

  func testShippingLocationStackViewIsHidden_isFalse_WhenLocationNameIsNotNil() {
    let data = PledgeAmountSummaryViewData(
      projectCountry: Project.Country.us,
      pledgeAmount: 30.0,
      pledgedOn: 1_568_666_243.0,
      shippingAmount: 7.0,
      locationName: "United States",
      omitUSCurrencyCode: true
    )

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.shippingLocationStackViewIsHidden.assertValue(false)
  }
}
