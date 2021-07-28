import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class SelectCurrencyViewModelTests: TestCase {
  private let vm: SelectCurrencyViewModelType = SelectCurrencyViewModel()

  private let activityIndicatorShouldShow = TestObserver<Bool, Never>()
  private let deselectCellAtIndex = TestObserver<Int, Never>()
  private let didUpdateCurrency = TestObserver<(), Never>()
  private let reloadDataWithCurrenciesData = TestObserver<[SelectedCurrencyData], Never>()
  private let reloadDataWithCurrenciesReload = TestObserver<Bool, Never>()
  private let saveButtonIsEnabled = TestObserver<Bool, Never>()
  private let selectCellAtIndex = TestObserver<Int, Never>()
  private let updateCurrencyDidFailWithError = TestObserver<String, Never>()
  private let updateCurrencyDidSucceed = TestObserver<(), Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.activityIndicatorShouldShow.observe(self.activityIndicatorShouldShow.observer)
    self.vm.outputs.deselectCellAtIndex.observe(self.deselectCellAtIndex.observer)
    self.vm.outputs.didUpdateCurrency.observe(self.didUpdateCurrency.observer)
    self.vm.outputs.reloadDataWithCurrencies.map(first).observe(self.reloadDataWithCurrenciesData.observer)
    self.vm.outputs.reloadDataWithCurrencies.map(second).observe(self.reloadDataWithCurrenciesReload.observer)
    self.vm.outputs.saveButtonIsEnabled.observe(self.saveButtonIsEnabled.observer)
    self.vm.outputs.selectCellAtIndex.observe(self.selectCellAtIndex.observer)
    self.vm.outputs.updateCurrencyDidFailWithError.observe(self.updateCurrencyDidFailWithError.observer)
    self.vm.outputs.updateCurrencyDidSucceed.observe(self.updateCurrencyDidSucceed.observer)
  }

  func testUpdateCurrency_Success() {
    self.activityIndicatorShouldShow.assertValues([])
    self.deselectCellAtIndex.assertValues([])
    self.didUpdateCurrency.assertValueCount(0)
    self.saveButtonIsEnabled.assertValues([])
    self.reloadDataWithCurrenciesReload.assertValues([])
    self.reloadDataWithCurrenciesData.assertValues([])
    self.updateCurrencyDidFailWithError.assertValues([])
    self.updateCurrencyDidSucceed.assertValueCount(0)
    self.selectCellAtIndex.assertValues([])

    self.vm.inputs.configure(with: .USD)
    self.vm.inputs.viewDidLoad()

    let usdSelectedOrdering = currencies(orderedBySelected: .USD)
    let usdSelectededCurrencyData = selectedCurrencyData(with: usdSelectedOrdering, selected: .USD)

    self.activityIndicatorShouldShow.assertValues([])
    self.deselectCellAtIndex.assertValues([])
    self.didUpdateCurrency.assertValueCount(0)
    self.saveButtonIsEnabled.assertValues([false])
    self.reloadDataWithCurrenciesReload.assertValues([true])
    self.reloadDataWithCurrenciesData.assertValues([usdSelectededCurrencyData])
    self.updateCurrencyDidFailWithError.assertValues([])
    self.updateCurrencyDidSucceed.assertValueCount(0)
    self.selectCellAtIndex.assertValues([0])

    withEnvironment(apiService: MockService(changeCurrencyResult: .success(EmptyResponseEnvelope()))) {
      self.vm.inputs.didSelectCurrency(atIndex: usdSelectedOrdering.firstIndex(of: .AUD) ?? -1)
      self.vm.inputs.saveButtonTapped()

      let audSelectededCurrencyData = selectedCurrencyData(with: usdSelectedOrdering, selected: .AUD)

      self.activityIndicatorShouldShow.assertValues([true])
      self.deselectCellAtIndex.assertValues([0])
      self.didUpdateCurrency.assertValueCount(0)
      self.saveButtonIsEnabled.assertValues([false, true])
      self.reloadDataWithCurrenciesReload.assertValues([true, false])
      self.reloadDataWithCurrenciesData.assertValues([
        usdSelectededCurrencyData,
        audSelectededCurrencyData
      ])
      self.updateCurrencyDidFailWithError.assertValues([])
      self.updateCurrencyDidSucceed.assertValueCount(0)
      self.selectCellAtIndex.assertValues([0, 2])

      self.scheduler.advance()

      self.activityIndicatorShouldShow.assertValues([true, false])
      self.deselectCellAtIndex.assertValues([0])
      self.didUpdateCurrency.assertValueCount(1)
      self.saveButtonIsEnabled.assertValues([false, true, false])
      self.reloadDataWithCurrenciesReload.assertValues([true, false])
      self.reloadDataWithCurrenciesData.assertValues([
        usdSelectededCurrencyData,
        audSelectededCurrencyData
      ])
      self.updateCurrencyDidFailWithError.assertValues([])
      self.updateCurrencyDidSucceed.assertValueCount(1)
      self.selectCellAtIndex.assertValues([0, 2])
    }
  }

  func testUpdateCurrency_Failure() {
    self.activityIndicatorShouldShow.assertValues([])
    self.deselectCellAtIndex.assertValues([])
    self.didUpdateCurrency.assertValueCount(0)
    self.saveButtonIsEnabled.assertValues([])
    self.reloadDataWithCurrenciesReload.assertValues([])
    self.reloadDataWithCurrenciesData.assertValues([])
    self.updateCurrencyDidFailWithError.assertValues([])
    self.updateCurrencyDidSucceed.assertValueCount(0)
    self.selectCellAtIndex.assertValues([])

    self.vm.inputs.configure(with: .USD)
    self.vm.inputs.viewDidLoad()

    let usdSelectedOrdering = currencies(orderedBySelected: .USD)
    let usdSelectededCurrencyData = selectedCurrencyData(with: usdSelectedOrdering, selected: .USD)

    self.activityIndicatorShouldShow.assertValues([])
    self.deselectCellAtIndex.assertValues([])
    self.didUpdateCurrency.assertValueCount(0)
    self.saveButtonIsEnabled.assertValues([false])
    self.reloadDataWithCurrenciesReload.assertValues([true])
    self.reloadDataWithCurrenciesData.assertValues([usdSelectededCurrencyData])
    self.updateCurrencyDidFailWithError.assertValues([])
    self.updateCurrencyDidSucceed.assertValueCount(0)
    self.selectCellAtIndex.assertValues([0])

    withEnvironment(apiService: MockService(changeCurrencyResult: .failure(.couldNotParseJSON))) {
      self.vm.inputs.didSelectCurrency(atIndex: usdSelectedOrdering.firstIndex(of: .AUD) ?? -1)
      self.vm.inputs.saveButtonTapped()

      let audSelectededCurrencyData = selectedCurrencyData(with: usdSelectedOrdering, selected: .AUD)

      self.activityIndicatorShouldShow.assertValues([true])
      self.deselectCellAtIndex.assertValues([0])
      self.didUpdateCurrency.assertValueCount(0)
      self.saveButtonIsEnabled.assertValues([false, true])
      self.reloadDataWithCurrenciesReload.assertValues([true, false])
      self.reloadDataWithCurrenciesData.assertValues([
        usdSelectededCurrencyData,
        audSelectededCurrencyData
      ])
      self.updateCurrencyDidFailWithError.assertValues([])
      self.updateCurrencyDidSucceed.assertValueCount(0)
      self.selectCellAtIndex.assertValues([0, 2])

      self.scheduler.advance()

      self.activityIndicatorShouldShow.assertValues([true, false])
      self.deselectCellAtIndex.assertValues([0])
      self.didUpdateCurrency.assertValueCount(0)
      self.saveButtonIsEnabled.assertValues([false, true])
      self.reloadDataWithCurrenciesReload.assertValues([true, false])
      self.reloadDataWithCurrenciesData.assertValues([
        usdSelectededCurrencyData,
        audSelectededCurrencyData
      ])
      self.updateCurrencyDidFailWithError.assertValues(["Something went wrong."])
      self.updateCurrencyDidSucceed.assertValueCount(0)
      self.selectCellAtIndex.assertValues([0, 2])
    }
  }

  func testCurrenciesOrderedBySelected() {
    XCTAssertEqual(
      currencies(orderedBySelected: .USD),
      [.USD, .EUR, .AUD, .CAD, .CHF, .DKK, .GBP, .HKD, .JPY, .MXN, .NOK, .NZD, .PLN, .SEK, .SGD]
    )

    XCTAssertEqual(
      currencies(orderedBySelected: .SEK),
      [.SEK, .EUR, .AUD, .CAD, .CHF, .DKK, .GBP, .HKD, .JPY, .MXN, .NOK, .NZD, .PLN, .SGD, .USD]
    )
  }

  func testSelectedCurrencyDataWithCurrencies() {
    XCTAssertEqual(
      selectedCurrencyData(with: Currency.allCases, selected: .SEK),
      [
        SelectedCurrencyData(currency: .EUR, selected: false),
        SelectedCurrencyData(currency: .AUD, selected: false),
        SelectedCurrencyData(currency: .CAD, selected: false),
        SelectedCurrencyData(currency: .CHF, selected: false),
        SelectedCurrencyData(currency: .DKK, selected: false),
        SelectedCurrencyData(currency: .GBP, selected: false),
        SelectedCurrencyData(currency: .HKD, selected: false),
        SelectedCurrencyData(currency: .JPY, selected: false),
        SelectedCurrencyData(currency: .MXN, selected: false),
        SelectedCurrencyData(currency: .NOK, selected: false),
        SelectedCurrencyData(currency: .NZD, selected: false),
        SelectedCurrencyData(currency: .PLN, selected: false),
        SelectedCurrencyData(currency: .SEK, selected: true),
        SelectedCurrencyData(currency: .SGD, selected: false),
        SelectedCurrencyData(currency: .USD, selected: false)
      ]
    )

    XCTAssertEqual(
      selectedCurrencyData(with: Currency.allCases, selected: .HKD),
      [
        SelectedCurrencyData(currency: .EUR, selected: false),
        SelectedCurrencyData(currency: .AUD, selected: false),
        SelectedCurrencyData(currency: .CAD, selected: false),
        SelectedCurrencyData(currency: .CHF, selected: false),
        SelectedCurrencyData(currency: .DKK, selected: false),
        SelectedCurrencyData(currency: .GBP, selected: false),
        SelectedCurrencyData(currency: .HKD, selected: true),
        SelectedCurrencyData(currency: .JPY, selected: false),
        SelectedCurrencyData(currency: .MXN, selected: false),
        SelectedCurrencyData(currency: .NOK, selected: false),
        SelectedCurrencyData(currency: .NZD, selected: false),
        SelectedCurrencyData(currency: .PLN, selected: false),
        SelectedCurrencyData(currency: .SEK, selected: false),
        SelectedCurrencyData(currency: .SGD, selected: false),
        SelectedCurrencyData(currency: .USD, selected: false)
      ]
    )
  }
}
