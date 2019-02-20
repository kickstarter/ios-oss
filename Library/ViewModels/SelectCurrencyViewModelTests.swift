import Foundation
import XCTest
@testable import KsApi
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers
import KsApi
import ReactiveSwift
import Result
@testable import Library
import Prelude

internal final class SelectCurrencyViewModelTests: TestCase {
  private let vm: SelectCurrencyViewModelType = SelectCurrencyViewModel()

  private let activityIndicatorShouldShow = TestObserver<Bool, NoError>()
  private let saveButtonIsEnabled = TestObserver<Bool, NoError>()
  private let updateCurrencyDidFailWithError = TestObserver<String, NoError>()
  private let updateCurrencyDidSucceed = TestObserver<(), NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.activityIndicatorShouldShow.observe(self.activityIndicatorShouldShow.observer)
    self.vm.outputs.saveButtonIsEnabled.observe(self.saveButtonIsEnabled.observer)
    self.vm.outputs.updateCurrencyDidFailWithError.observe(self.updateCurrencyDidFailWithError.observer)
    self.vm.outputs.updateCurrencyDidSucceed.observe(self.updateCurrencyDidSucceed.observer)
  }

  func testUpdateCurrency_Success() {
    self.vm.inputs.configure(with: .USD)
    self.vm.inputs.viewDidLoad()

    self.activityIndicatorShouldShow.assertValues([])
    self.saveButtonIsEnabled.assertValues([false])
    self.updateCurrencyDidFailWithError.assertValues([])
    self.updateCurrencyDidSucceed.assertValueCount(0)

    withEnvironment(apiService: MockService(changeCurrencyResponse: .init())) {
      self.vm.inputs.didSelect(.AUD)
      self.vm.inputs.saveButtonTapped()

      self.activityIndicatorShouldShow.assertValues([true])
      self.saveButtonIsEnabled.assertValues([false, true])
      self.updateCurrencyDidFailWithError.assertValues([])
      self.updateCurrencyDidSucceed.assertValueCount(0)

      self.scheduler.advance()

      self.activityIndicatorShouldShow.assertValues([true, false])
      self.saveButtonIsEnabled.assertValues([false, true, false])
      self.updateCurrencyDidFailWithError.assertValues([])
      self.updateCurrencyDidSucceed.assertValueCount(1)
    }
  }

  func testUpdateCurrency_Failure() {
    self.vm.inputs.configure(with: .USD)
    self.vm.inputs.viewDidLoad()

    self.activityIndicatorShouldShow.assertValues([])
    self.saveButtonIsEnabled.assertValues([false])
    self.updateCurrencyDidFailWithError.assertValues([])
    self.updateCurrencyDidSucceed.assertValueCount(0)

    withEnvironment(apiService: MockService(changeCurrencyError: .invalidInput)) {
      self.vm.inputs.didSelect(.AUD)
      self.vm.inputs.saveButtonTapped()

      self.activityIndicatorShouldShow.assertValues([true])
      self.saveButtonIsEnabled.assertValues([false, true])
      self.updateCurrencyDidFailWithError.assertValues([])
      self.updateCurrencyDidSucceed.assertValueCount(0)

      self.scheduler.advance()

      self.activityIndicatorShouldShow.assertValues([true, false])
      self.saveButtonIsEnabled.assertValues([false, true])
      self.updateCurrencyDidFailWithError.assertValues(["Something went wrong."])
      self.updateCurrencyDidSucceed.assertValueCount(0)
    }
  }

  func testTrackSelectedChosenCurrency() {
    self.vm.inputs.configure(with: .USD)
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual([], self.trackingClient.events)

    withEnvironment(apiService: MockService(changeCurrencyResponse: .init())) {
      self.vm.inputs.didSelect(.CHF)
      self.vm.inputs.saveButtonTapped()

      self.scheduler.advance()

      XCTAssertEqual(["Selected Chosen Currency"], self.trackingClient.events)
      XCTAssertEqual(
        ["Fr Swiss Franc (CHF)"], self.trackingClient.properties(forKey: "currency", as: String.self)
      )
    }
  }

  func testIsSelectedCurrency() {
    self.vm.inputs.configure(with: .USD)
    self.vm.inputs.viewDidLoad()

    self.saveButtonIsEnabled.assertValues([false])
    XCTAssertTrue(self.vm.outputs.isSelectedCurrency(.USD))

    self.vm.inputs.didSelect(.CAD)

    self.saveButtonIsEnabled.assertValues([false, true])
    XCTAssertTrue(self.vm.outputs.isSelectedCurrency(.CAD))

    self.vm.inputs.didSelect(.CHF)

    self.saveButtonIsEnabled.assertValues([false, true, true])
    XCTAssertTrue(self.vm.outputs.isSelectedCurrency(.CHF))

    self.vm.inputs.didSelect(.USD)

    self.saveButtonIsEnabled.assertValues([false, true, true, false])
    XCTAssertTrue(self.vm.outputs.isSelectedCurrency(.USD))
  }
}
