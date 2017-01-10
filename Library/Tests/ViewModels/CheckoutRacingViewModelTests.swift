import XCTest
@testable import Library
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers
import Prelude
import Result

final class CheckoutRacingViewModelTests: TestCase {
  fileprivate let vm: CheckoutRacingViewModelType = CheckoutRacingViewModel()

  fileprivate let goToThanks = TestObserver<Void, NoError>()
  fileprivate let showAlert = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.goToThanks.observe(self.goToThanks.observer)
    self.vm.outputs.showAlert.observe(self.showAlert.observer)
  }

  func testApiError() {
    withEnvironment(apiService: MockService(fetchCheckoutError: .couldNotParseJSON)) {
      self.vm.inputs.configureWith(url: racingURL())
      self.goToThanks.assertDidNotEmitValue()
      self.showAlert.assertDidNotEmitValue()

      // Attempts up to 10 times, with one second delay before each attempt
      self.scheduler.advance(by: .seconds(9))
      self.goToThanks.assertDidNotEmitValue()
      self.showAlert.assertDidNotEmitValue()

      self.scheduler.advance(by: .seconds(1))
      self.goToThanks.assertDidNotEmitValue()
      self.showAlert.assertValues([Strings.project_checkout_finalizing_timeout_message()])
    }
  }

  func testAuthorizingThenSuccessful() {
    withEnvironment(apiService: MockService(fetchCheckoutResponse: .authorizing)) {
      self.vm.inputs.configureWith(url: racingURL())
      self.goToThanks.assertDidNotEmitValue()
      self.showAlert.assertDidNotEmitValue()

      self.scheduler.advance(by: .seconds(1))
      self.goToThanks.assertDidNotEmitValue()
      self.showAlert.assertDidNotEmitValue()

      withEnvironment(apiService: MockService(fetchCheckoutResponse: .successful)) {
        self.scheduler.advance(by: .seconds(1))
        self.goToThanks.assertValueCount(1)
        self.showAlert.assertDidNotEmitValue()
      }
    }
  }

  func testFailed() {
    let envelope = CheckoutEnvelope.failed
    withEnvironment(apiService: MockService(fetchCheckoutResponse: envelope)) {
      self.vm.inputs.configureWith(url: racingURL())
      self.goToThanks.assertDidNotEmitValue()
      self.showAlert.assertDidNotEmitValue()

      self.scheduler.advance(by: .seconds(1))
      self.goToThanks.assertDidNotEmitValue()
      self.showAlert.assertValues([envelope.stateReason])
    }
  }

  func testStuckVerifying() {
    withEnvironment(apiService: MockService(fetchCheckoutResponse: .verifying)) {
      self.vm.inputs.configureWith(url: racingURL())

      // Attempts up to 10 times, with one second delay before each attempt
      self.scheduler.advance(by: .seconds(9))
      self.goToThanks.assertDidNotEmitValue()
      self.showAlert.assertDidNotEmitValue()

      self.scheduler.advance(by: .seconds(1))
      self.goToThanks.assertDidNotEmitValue()
      self.showAlert.assertValues([Strings.project_checkout_finalizing_timeout_message()])
    }
  }

  func testVerifyingThenSuccessful() {
    withEnvironment(apiService: MockService(fetchCheckoutResponse: .verifying)) {
      self.vm.inputs.configureWith(url: racingURL())
      self.goToThanks.assertDidNotEmitValue()
      self.showAlert.assertDidNotEmitValue()

      self.scheduler.advance(by: .seconds(1))
      self.goToThanks.assertDidNotEmitValue()
      self.showAlert.assertDidNotEmitValue()

      withEnvironment(apiService: MockService(fetchCheckoutResponse: .successful)) {
        self.scheduler.advance(by: .seconds(1))
        self.goToThanks.assertValueCount(1)
        self.showAlert.assertDidNotEmitValue()
      }
    }
  }

  func testSuccessful() {
    withEnvironment(apiService: MockService(fetchCheckoutResponse: .successful)) {
      self.vm.inputs.configureWith(url: racingURL())
      self.goToThanks.assertDidNotEmitValue()
        self.showAlert.assertDidNotEmitValue()

      self.scheduler.advance(by: .seconds(1))
      self.goToThanks.assertValueCount(1)
      self.showAlert.assertDidNotEmitValue()
    }
  }
}

private func racingURL() -> URL {
  return URL(string: "https://www.kickstarter.com/projects/creator/project/checkouts/1")!
}
