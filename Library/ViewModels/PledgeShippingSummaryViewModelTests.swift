@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class PledgeShippingSummaryViewModelTests: TestCase {
  private let vm: PledgeShippingSummaryViewModelType = PledgeShippingSummaryViewModel()

  private let amountLabelAttributedText = TestObserver<String, Never>()
  private let locationLabelText = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.amountLabelAttributedText.map(\.string).observe(self.amountLabelAttributedText.observer)
    self.vm.outputs.locationLabelText.observe(self.locationLabelText.observer)
  }

  func testAmountLabelAttributedText_OmitUSCurrencyCode() {
    self.amountLabelAttributedText.assertDidNotEmitValue()

    let data = PledgeShippingSummaryViewData(
      locationName: "Canada",
      omitUSCurrencyCode: true,
      projectCountry: .us,
      total: 100
    )

    self.vm.inputs.configure(with: data)

    self.amountLabelAttributedText.assertValues(["+$100.00"])
  }

  func testAmountLabelAttributedText_DontOmitUSCurrencyCode() {
    self.amountLabelAttributedText.assertDidNotEmitValue()

    let data = PledgeShippingSummaryViewData(
      locationName: "Canada",
      omitUSCurrencyCode: false,
      projectCountry: .us,
      total: 100
    )

    self.vm.inputs.configure(with: data)

    self.amountLabelAttributedText.assertValues(["+ US$ 100.00"])
  }

  func testLocationLabelText() {
    self.locationLabelText.assertDidNotEmitValue()

    let data = PledgeShippingSummaryViewData(
      locationName: "Canada",
      omitUSCurrencyCode: false,
      projectCountry: .us,
      total: 100
    )

    self.vm.inputs.configure(with: data)

    self.locationLabelText.assertValues(["Canada"])
  }
}
