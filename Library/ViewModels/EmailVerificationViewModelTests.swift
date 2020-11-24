import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class EmailVerificationViewModelTests: TestCase {
  private let vm: EmailVerificationViewModelType = EmailVerificationViewModel()

  private let activityIndicatorIsHidden = TestObserver<Bool, Never>()
  private let notifyDelegateDidComplete = TestObserver<(), Never>()
  private let showErrorBannerWithMessage = TestObserver<String, Never>()
  private let showSuccessBannerWithMessage = TestObserver<String, Never>()
  private let skipButtonHidden = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.activityIndicatorIsHidden.observe(self.activityIndicatorIsHidden.observer)
    self.vm.outputs.notifyDelegateDidComplete.observe(self.notifyDelegateDidComplete.observer)
    self.vm.outputs.showErrorBannerWithMessage.observe(self.showErrorBannerWithMessage.observer)
    self.vm.outputs.showSuccessBannerWithMessage.observe(self.showSuccessBannerWithMessage.observer)
    self.vm.outputs.skipButtonHidden.observe(self.skipButtonHidden.observer)
  }

  func testSkipButtonHidden_FeatureEnabled() {
    let config = .template
      |> Config.lens.features .~ [Feature.emailVerificationSkip.rawValue: true]

    withEnvironment(config: config) {
      self.skipButtonHidden.assertDidNotEmitValue()

      self.vm.inputs.viewDidLoad()

      self.skipButtonHidden.assertValues([false])
    }
  }

  func testSkipButtonHidden_FeatureDisabled() {
    let config = .template
      |> Config.lens.features .~ [Feature.emailVerificationSkip.rawValue: false]

    withEnvironment(config: config) {
      self.skipButtonHidden.assertDidNotEmitValue()

      self.vm.inputs.viewDidLoad()

      self.skipButtonHidden.assertValues([true])
    }
  }

  func testNotifyDelegateDidComplete() {
    self.notifyDelegateDidComplete.assertDidNotEmitValue()

    self.vm.inputs.skipButtonTapped()

    self.notifyDelegateDidComplete.assertValueCount(1)
  }

  func testTrackVerificationScreenViewed() {
    XCTAssertEqual(self.trackingClient.events, [])

    self.vm.inputs.viewDidLoad()

    XCTAssertEqual(self.trackingClient.events, ["Verification Screen Viewed"])

    XCTAssertTrue(self.trackingClient.containsKeyPrefix("context_"))
    XCTAssertTrue(self.trackingClient.containsKeyPrefix("session_"))
  }

  func testTrackSkipEmailVerificationButtonClicked() {
    XCTAssertEqual(self.trackingClient.events, [])

    AppEnvironment.login(.init(accessToken: "deadbeef", user: .template))

    self.vm.inputs.skipButtonTapped()

    XCTAssertEqual(self.trackingClient.events, ["Skip Verification Button Clicked"])

    XCTAssertTrue(self.trackingClient.containsKeyPrefix("context_"))
    XCTAssertTrue(self.trackingClient.containsKeyPrefix("session_"))
    XCTAssertTrue(self.trackingClient.containsKeyPrefix("user_"))
  }

  func testResend_Success() {
    let mockService = MockService(sendEmailVerificationResponse: GraphMutationEmptyResponseEnvelope())

    self.showSuccessBannerWithMessage.assertDidNotEmitValue()
    self.showErrorBannerWithMessage.assertDidNotEmitValue()
    self.activityIndicatorIsHidden.assertDidNotEmitValue()

    withEnvironment(apiService: mockService) {
      self.vm.inputs.viewDidLoad()

      self.showSuccessBannerWithMessage.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.activityIndicatorIsHidden.assertValues([true])

      self.vm.inputs.resendButtonTapped()

      self.showSuccessBannerWithMessage.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.activityIndicatorIsHidden.assertValues([true, false])

      self.scheduler.advance()

      self.showSuccessBannerWithMessage.assertValues([
        "We\'ve just sent you a verification email. Click the link in it and your address will be verified."
      ])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.activityIndicatorIsHidden.assertValues([true, false, true])
    }
  }

  func testResend_Error() {
    let error = GraphError.invalidInput

    self.showSuccessBannerWithMessage.assertDidNotEmitValue()
    self.showErrorBannerWithMessage.assertDidNotEmitValue()
    self.activityIndicatorIsHidden.assertDidNotEmitValue()

    withEnvironment(apiService: MockService(sendEmailVerificationError: error)) {
      self.vm.inputs.viewDidLoad()

      self.showSuccessBannerWithMessage.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.activityIndicatorIsHidden.assertValues([true])

      self.vm.inputs.resendButtonTapped()

      self.showSuccessBannerWithMessage.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.activityIndicatorIsHidden.assertValues([true, false])

      self.scheduler.advance()

      self.showSuccessBannerWithMessage.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValue(GraphError.invalidInput.localizedDescription)
      self.activityIndicatorIsHidden.assertValues([true, false, true])
    }
  }
}
