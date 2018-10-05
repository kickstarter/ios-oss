import Foundation
import XCTest
import ReactiveSwift
import Result
import Prelude
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers
@testable import Kickstarter_Framework

internal final class SettingsAccountPickerCellViewModelTests: TestCase {
  let vm = SettingsAccountPickerCellViewModel()
  let notifyCurrencyPickerCellRemoved = TestObserver<Bool, NoError>()
  let updateCurrencyDetailText = TestObserver<String, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.notifyCurrencyPickerCellRemoved.observe(self.notifyCurrencyPickerCellRemoved.observer)
    self.vm.outputs.updateCurrencyDetailText.observe(self.updateCurrencyDetailText.observer)
  }

  func testNotifyCurrencyPickerCellRemoveAndUpdateText() {
    self.vm.inputs.didSelectCurrency(currency: Currency.usDollar)
    self.notifyCurrencyPickerCellRemoved.assertValueCount(1)
    self.updateCurrencyDetailText.assertValues([Strings.Currency_USD()])
  }
}
