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
  let vm = SettingsCurrencyPickerCellViewModel()
  let notifyCurrencyPickerCellRemoved = TestObserver<Bool, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.notifyCurrencyPickerCellRemoved.observe(self.notifyCurrencyPickerCellRemoved.observer)
  }

  func testNotifyCurrencyPickerCellRemoveAndUpdateText() {
    self.vm.inputs.didSelectCurrency(currency: Currency.usDollar)
    self.notifyCurrencyPickerCellRemoved.assertValueCount(1)
  }
}
