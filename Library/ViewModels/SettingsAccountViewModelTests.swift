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
  let vm = SettingsAccountViewModel(SettingsAccountViewController.viewController(for:))

  let dismissCurrencyPicker = TestObserver<Void, NoError>()
  let fetchAccountFieldsError = TestObserver<Void, NoError>()
  let presentCurrencyPicker = TestObserver<Void, NoError>()
  let reloadDataShouldHideWarningIcon = TestObserver<Bool, NoError>()
  let reloadDataCurrency = TestObserver<Currency, NoError>()
  let showAlert = TestObserver<(), NoError>()
  let updateCurrencyFailure = TestObserver<String, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.dismissCurrencyPicker.observe(self.dismissCurrencyPicker.observer)
    self.vm.outputs.fetchAccountFieldsError.observe(self.fetchAccountFieldsError.observer)
    self.vm.outputs.presentCurrencyPicker.observe(self.presentCurrencyPicker.observer)
    self.vm.outputs.reloadData.map(first).observe(self.reloadDataCurrency.observer)
    self.vm.outputs.reloadData.map(second).observe(self.reloadDataShouldHideWarningIcon.observer)
    self.vm.outputs.showAlert.observe(self.showAlert.observer)
    self.vm.outputs.updateCurrencyFailure.observe(self.updateCurrencyFailure.observer)
  }

  func testReloadData() {
    self.vm.inputs.viewWillAppear()
    self.reloadDataShouldHideWarningIcon.assertValueCount(1)
    self.reloadDataCurrency.assertValueCount(1)
    self.vm.inputs.showChangeCurrencyAlert(for: Currency.CHF)
    self.vm.inputs.didConfirmChangeCurrency()
    self.scheduler.advance()
    self.reloadDataShouldHideWarningIcon.assertValueCount(2)
    self.reloadDataCurrency.assertValueCount(2)
  }

  func testPresentCurrencyPicker() {
    self.vm.inputs.viewWillAppear()
    self.reloadDataShouldHideWarningIcon.assertValueCount(1)
    self.reloadDataCurrency.assertValueCount(1)
    self.vm.inputs.didSelectRow(cellType: .currency)
    self.presentCurrencyPicker.assertValueCount(1)
  }

  func testDismissCurrencyPicker() {
    self.vm.inputs.viewWillAppear()
    self.reloadDataShouldHideWarningIcon.assertValueCount(1)
    self.reloadDataCurrency.assertValueCount(1)
    self.vm.inputs.didSelectRow(cellType: .currency)
    self.presentCurrencyPicker.assertValueCount(1)
    self.vm.inputs.dismissPickerTap()
    self.dismissCurrencyPicker.assertValueCount(1)
  }

  func testShowAlert() {
    self.vm.inputs.viewWillAppear()
    self.reloadDataShouldHideWarningIcon.assertValueCount(1)
    self.reloadDataCurrency.assertValueCount(1)
    self.vm.inputs.showChangeCurrencyAlert(for: Currency.EUR)
    self.showAlert.assertDidEmitValue()
  }

  func testFetchUserAccountFields_Failure() {
    let graphError = GraphError.emptyResponse(nil)
    let mockService = MockService(fetchGraphUserAccountFieldsError: graphError)

    withEnvironment(apiService: mockService) {
      self.vm.inputs.viewWillAppear()
      self.reloadDataShouldHideWarningIcon.assertValueCount(0)
      self.reloadDataCurrency.assertValueCount(0)
      self.fetchAccountFieldsError.assertValueCount(1)
    }
  }

  func testUpdateCurrencyFailure() {
    let graphError = GraphError.emptyResponse(nil)

    withEnvironment(apiService: MockService(changeCurrencyError: graphError)) {
      self.vm.inputs.viewWillAppear()
      self.reloadDataShouldHideWarningIcon.assertValueCount(1)
      self.reloadDataCurrency.assertValueCount(1)
      self.vm.inputs.showChangeCurrencyAlert(for: Currency.CHF)
      self.vm.inputs.didConfirmChangeCurrency()
      self.scheduler.advance()
      self.updateCurrencyFailure.assertDidEmitValue()
    }
  }

  func testTrackViewedAccount() {
    let client = MockTrackingClient()

    withEnvironment(koala: Koala(client: client)) {
      XCTAssertEqual([], client.events)

      self.vm.inputs.viewDidAppear()

      XCTAssertEqual(["Viewed Account"], client.events)

      self.vm.inputs.viewDidAppear()

      XCTAssertEqual(["Viewed Account", "Viewed Account"], client.events)
    }
  }
}
