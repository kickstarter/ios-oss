import Foundation
@testable import Kickstarter_Framework
@testable import KsApi
@testable import KsApiTestHelpers
@testable import Library
@testable import LibraryTestHelpers
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class SettingsAccountViewModelTests: TestCase {
  private let vm: SettingsAccountViewModelType
    = SettingsAccountViewModel(SettingsAccountViewController.viewController(for:currency:))

  private let fetchAccountFieldsError = TestObserver<Void, Never>()
  private let reloadDataCurrency = TestObserver<Currency, Never>()
  private let reloadDataEmail = TestObserver<String?, Never>()
  private let reloadDataIsAppleConnectedAccount = TestObserver<Bool, Never>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.fetchAccountFieldsError.observe(self.fetchAccountFieldsError.observer)
    self.vm.outputs.reloadData.map { $0.currency }.observe(self.reloadDataCurrency.observer)
    self.vm.outputs.reloadData.map { $0.email }.observe(self.reloadDataEmail.observer)
    self.vm.outputs.reloadData.map { $0.isAppleConnectedAccount }
      .observe(self.reloadDataIsAppleConnectedAccount.observer)
  }

  func testReloadData() {
    let userEnvelope = UserEnvelope(me: GraphUser.template)
    let mockService = MockService(fetchGraphUserResult: .success(userEnvelope))

    withEnvironment(apiService: mockService) {
      self.reloadDataCurrency.assertValueCount(0)
      self.reloadDataEmail.assertValueCount(0)
      self.reloadDataIsAppleConnectedAccount.assertValueCount(0)

      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear()

      self.scheduler.advance()

      self.reloadDataCurrency.assertValues([.USD])
      self.reloadDataEmail.assertValues(["user@example.com"])
      self.reloadDataIsAppleConnectedAccount.assertValues([false])

      self.fetchAccountFieldsError.assertDidNotEmitValue()

      self.vm.inputs.viewWillAppear()

      self.scheduler.advance()

      self.reloadDataCurrency.assertValueCount(2)
      self.reloadDataEmail.assertValueCount(2)
      self.reloadDataIsAppleConnectedAccount.assertValueCount(2)

      self.fetchAccountFieldsError.assertDidNotEmitValue()
    }
  }

  func testFetchUserAccountFields_Failure() {
    let mockService = MockService(fetchGraphUserResult: .failure(.couldNotParseJSON))

    withEnvironment(apiService: mockService) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear()

      self.scheduler.advance()

      self.reloadDataCurrency.assertValueCount(0)
      self.reloadDataEmail.assertValueCount(0)
      self.reloadDataIsAppleConnectedAccount.assertValueCount(0)

      self.fetchAccountFieldsError.assertValueCount(1)
    }
  }

  func testIsAppleConnectedAccount() {
    let user = GraphUser.template
      |> \.isAppleConnected .~ true

    let mockService = MockService(fetchGraphUserResult: .success(UserEnvelope(me: user)))

    withEnvironment(apiService: mockService) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear()

      self.scheduler.advance()

      self.reloadDataCurrency.assertValues([.USD])
      self.reloadDataEmail.assertValues(["user@example.com"])
      self.reloadDataIsAppleConnectedAccount.assertValues([true])

      self.fetchAccountFieldsError.assertDidNotEmitValue()
    }
  }
}
