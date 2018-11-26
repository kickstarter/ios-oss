import Foundation
import XCTest
import ReactiveSwift
import Result
import Prelude
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers
@testable import Kickstarter_Framework

internal final class SettingsCurrencyPickerCellViewModelTests: TestCase {
  let vm = SettingsCurrencyPickerCellViewModel()
  let showCurrencyChangeAlert = TestObserver<Currency, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.showCurrencyChangeAlert.observe(self.showCurrencyChangeAlert.observer)
  }

  func testShowCurrencyChangeAlert() {
    self.vm.inputs.didSelectCurrency(currency: Currency.SGD)
    self.showCurrencyChangeAlert.assertValue(Currency.SGD)
  }

  func testTrackSelectedChosenCurrency() {
    self.vm.inputs.didSelectCurrency(currency: Currency.SGD)

    XCTAssertEqual(["Selected Chosen Currency"], self.trackingClient.events)
    XCTAssertEqual(["$ Singapore Dollar (SGD)"], self.trackingClient.properties(forKey: "currency",
                                                                                as: String.self))
  }
}
