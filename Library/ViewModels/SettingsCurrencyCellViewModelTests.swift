import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers
@testable import Kickstarter_Framework

internal final class SettingsCurrencyCellViewModelTests: TestCase {
  internal let vm = SettingsCurrencyCellViewModel()

  internal let chosenCurrencyText = TestObserver<String, NoError>()
  internal let fetchUserError = TestObserver<String, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.chosenCurrencyText.observe(self.chosenCurrencyText.observer)
  }

  internal func testChosenCurrencyText() {
    let currency = Currency.USD
    let value = SettingsCurrencyCellValue(cellType: SettingsAccountCellType.currency, currency: currency)

    withEnvironment(apiService: MockService(fetchGraphCurrencyResponse: .template)) {
      self.vm.inputs.configure(with: value)
      self.scheduler.advance()
      self.chosenCurrencyText.assertValues([Strings.Currency_USD()])
    }
  }
}
