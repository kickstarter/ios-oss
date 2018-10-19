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
  let reloadData = TestObserver<User, NoError>()
  let presentCurrencyPicker = TestObserver<Bool, NoError>()
  let updateCurrency = TestObserver<String, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.dismissCurrencyPicker.observe(self.dismissCurrencyPicker.observer)
    self.vm.outputs.reloadData.observe(self.reloadData.observer)
    self.vm.outputs.presentCurrencyPicker.observe(self.presentCurrencyPicker.observer)
    self.vm.outputs.updateCurrency.observe(self.updateCurrency.observer)
  }

  func testReloadData() {
    self.vm.inputs.viewDidLoad()
    self.reloadData.assertValueCount(1)
  }

  func testPresentCurrencyPicker() {
    self.vm.inputs.viewDidLoad()
    self.reloadData.assertValueCount(1)
    self.vm.inputs.didSelectRow(cellType: .currency)
    self.presentCurrencyPicker.assertValues([true])
  }

  func testDismissCurrencyPicker() {
    self.vm.inputs.viewDidLoad()
    self.reloadData.assertValueCount(1)
    self.vm.inputs.didSelectRow(cellType: .currency)
    self.presentCurrencyPicker.assertValues([true])
    self.vm.inputs.dismissPickerTap()
    self.dismissCurrencyPicker.assertValueCount(1)
  }

  func testUpdateCurrency() {
    let currency = UserCurrency
      .template |> UserCurrency.lens.chosenCurrency .~ "CHF"

    self.vm.inputs.viewDidLoad()
    self.reloadData.assertValueCount(1)
    self.vm.inputs.didConfirmChangeCurrency(currency: .CHF)
    scheduler.advance()
    self.updateCurrency.assertValues([""])
  }
}
