import Foundation
@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class SettingsAccountViewModelTests: TestCase {
  let vm = SettingsAccountViewModel(SettingsAccountViewController.viewController(for:currency:))

  private let fetchAccountFieldsError = TestObserver<Void, Never>()
  private let reloadDataShouldHideWarningIcon = TestObserver<Bool, Never>()
  private let reloadDataCurrency = TestObserver<Currency, Never>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.fetchAccountFieldsError.observe(self.fetchAccountFieldsError.observer)
    self.vm.outputs.reloadData.map(first).observe(self.reloadDataCurrency.observer)
    self.vm.outputs.reloadData.map(second).observe(self.reloadDataShouldHideWarningIcon.observer)
  }

  func testReloadData() {
    self.vm.inputs.viewWillAppear()
    self.reloadDataShouldHideWarningIcon.assertValueCount(1)
    self.reloadDataCurrency.assertValueCount(1)
    self.scheduler.advance()
    self.reloadDataShouldHideWarningIcon.assertValueCount(1)
    self.reloadDataCurrency.assertValueCount(1)
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

  func testHideEmailPasswordHeaderView_HasNoPassword() {
    let user = UserAccountFields.template
      |> \.hasPassword .~ false

    let mockService = MockService(fetchGraphUserAccountFieldsResponse: UserEnvelope(me: user))

    withEnvironment(apiService: mockService) {
      self.vm.inputs.viewWillAppear()
      self.reloadDataShouldHideWarningIcon.assertValueCount(1)
      self.reloadDataCurrency.assertValueCount(1)
      self.fetchAccountFieldsError.assertValueCount(0)
    }
  }

  func testHideEmailPasswordHeaderView_HasPassword() {
    let user = UserAccountFields.template
      |> \.hasPassword .~ true

    let mockService = MockService(fetchGraphUserAccountFieldsResponse: UserEnvelope(me: user))

    withEnvironment(apiService: mockService) {
      self.vm.inputs.viewWillAppear()
      self.reloadDataShouldHideWarningIcon.assertValueCount(1)
      self.reloadDataCurrency.assertValueCount(1)
      self.fetchAccountFieldsError.assertValueCount(0)
    }
  }

  func testTrackViewedAccount() {
    let koalaClient = MockTrackingClient()

    withEnvironment(koala: Koala(client: koalaClient)) {
      XCTAssertEqual([], koalaClient.events)

      self.vm.inputs.viewDidAppear()

      XCTAssertEqual(["Viewed Account"], koalaClient.events)

      self.vm.inputs.viewDidAppear()

      XCTAssertEqual(["Viewed Account", "Viewed Account"], koalaClient.events)
    }
  }
}
