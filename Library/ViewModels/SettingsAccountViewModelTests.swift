import Foundation
import XCTest
import ReactiveSwift
import Prelude
@testable import KsApi
@testable import Library
@testable import Kickstarter_Framework
import ReactiveExtensions_TestHelpers

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
