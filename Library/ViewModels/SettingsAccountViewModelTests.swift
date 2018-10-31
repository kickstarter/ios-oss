import Foundation
import XCTest
import ReactiveSwift
import Result
import Prelude
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers
@testable import Kickstarter_Framework

internal final class SettingsAccountViewModelTests: TestCase {
  let vm = SettingsAccountViewModel()
  let dismissCurrencyPicker = TestObserver<Void, NoError>()
  let presentCurrencyPicker = TestObserver<Void, NoError>()
  let reloadDataUser = TestObserver<User, NoError>()
  let reloadDataCurrency = TestObserver<Currency, NoError>()
  let showAlert = TestObserver<(), NoError>()
  let updateCurrencyFailure = TestObserver<String, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.dismissCurrencyPicker.observe(self.dismissCurrencyPicker.observer)
    self.vm.outputs.presentCurrencyPicker.observe(self.presentCurrencyPicker.observer)
    self.vm.outputs.reloadData.map(first).observe(self.reloadDataUser.observer)
    self.vm.outputs.reloadData.map(second).observe(self.reloadDataCurrency.observer)
    self.vm.outputs.showAlert.observe(self.showAlert.observer)
    self.vm.outputs.updateCurrencyFailure.observe(self.updateCurrencyFailure.observer)
  }

  func testReloadData() {
    self.vm.inputs.viewDidLoad()
    self.reloadDataUser.assertValueCount(1)
    self.reloadDataCurrency.assertValueCount(1)
    self.vm.inputs.showChangeCurrencyAlert(for: Currency.CHF)
    self.vm.inputs.didConfirmChangeCurrency()
    self.scheduler.advance()
    self.reloadDataUser.assertValueCount(2)
    self.reloadDataCurrency.assertValueCount(2)
  }

  func testPresentCurrencyPicker() {
    self.vm.inputs.viewDidLoad()
    self.reloadDataUser.assertValueCount(1)
    self.reloadDataCurrency.assertValueCount(1)
    self.vm.inputs.didSelectRow(cellType: .currency)
    self.presentCurrencyPicker.assertValueCount(1)
  }

  func testDismissCurrencyPicker() {
    self.vm.inputs.viewDidLoad()
    self.reloadDataUser.assertValueCount(1)
    self.reloadDataCurrency.assertValueCount(1)
    self.vm.inputs.didSelectRow(cellType: .currency)
    self.presentCurrencyPicker.assertValueCount(1)
    self.vm.inputs.dismissPickerTap()
    self.dismissCurrencyPicker.assertValueCount(1)
  }

  func testShowAlert() {
    self.vm.inputs.viewDidLoad()
    self.reloadDataUser.assertValueCount(1)
    self.reloadDataCurrency.assertValueCount(1)
    self.vm.inputs.showChangeCurrencyAlert(for: Currency.EUR)
    self.showAlert.assertDidEmitValue()
  }

  func testUpdateCurrencyFailure() {
    let graphError = GraphError.emptyResponse(nil)

    withEnvironment(apiService: MockService(changeCurrencyError: graphError)) {
      self.vm.inputs.viewDidLoad()
      self.reloadDataUser.assertValueCount(1)
      self.reloadDataCurrency.assertValueCount(1)
      self.vm.inputs.showChangeCurrencyAlert(for: Currency.CHF)
      self.vm.inputs.didConfirmChangeCurrency()
      self.scheduler.advance()
      self.updateCurrencyFailure.assertDidEmitValue()
    }
  }
}
