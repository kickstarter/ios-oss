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
  let notifyCurrencyPickerCellRemoved = TestObserver<Void, NoError>()
  let showCurrencyChangeAlert = TestObserver<Currency, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.notifyCurrencyPickerCellRemoved.observe(self.notifyCurrencyPickerCellRemoved.observer)
    self.vm.outputs.showCurrencyChangeAlert.observe(self.showCurrencyChangeAlert.observer)
  }

  func testNotifyCurrencyPickerCellRemoveAndUpdateText() {
    self.vm.inputs.didSelectCurrency(currency: Currency.USD)
    self.notifyCurrencyPickerCellRemoved.assertValueCount(1)
  }

  func testShowCurrencyChangeAlert() {
    self.vm.inputs.didSelectCurrency(currency: Currency.SGD)
    self.showCurrencyChangeAlert.assertValue(Currency.SGD)
  }
}
