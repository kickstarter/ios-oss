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
  let reloadData = TestObserver<Void, NoError>()
  let presentCurrencyPicker = TestObserver<Bool, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.dismissCurrencyPicker.observe(self.dismissCurrencyPicker.observer)
    self.vm.outputs.reloadData.observe(self.reloadData.observer)
    self.vm.outputs.presentCurrencyPicker.observe(self.presentCurrencyPicker.observer)
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
    self.vm.inputs.tapped()
    self.dismissCurrencyPicker.assertValueCount(1)
  }
}
