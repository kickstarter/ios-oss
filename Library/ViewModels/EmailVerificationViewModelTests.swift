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
  private let footerStackViewIsHidden = TestObserver<Bool, Never>()
  private let notifyDelegateDidComplete = TestObserver<(), Never>()
  private let showErrorBannerWithMessage = TestObserver<String, Never>()
  private let showSuccessBannerWithMessage = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.activityIndicatorIsHidden.observe(self.activityIndicatorIsHidden.observer)
    self.vm.outputs.footerStackViewIsHidden.observe(self.footerStackViewIsHidden.observer)
    self.vm.outputs.notifyDelegateDidComplete.observe(self.notifyDelegateDidComplete.observer)
    self.vm.outputs.showErrorBannerWithMessage.observe(self.showErrorBannerWithMessage.observer)
    self.vm.outputs.showSuccessBannerWithMessage.observe(self.showSuccessBannerWithMessage.observer)
  }

  func testFooterStackViewHidden_FeatureEnabled() {
    let config = .template
      |> Config.lens.features .~ [Feature.emailVerificationSkip.rawValue: true]

    withEnvironment(config: config) {
      self.footerStackViewIsHidden.assertDidNotEmitValue()

      self.vm.inputs.viewDidLoad()

      self.footerStackViewIsHidden.assertValues([false])
    }
  }

  func testFooterStackViewHidden_FeatureDisabled() {
    let config = .template
      |> Config.lens.features .~ [Feature.emailVerificationSkip.rawValue: false]

    withEnvironment(config: config) {
      self.footerStackViewIsHidden.assertDidNotEmitValue()

      self.vm.inputs.viewDidLoad()

      self.footerStackViewIsHidden.assertValues([true])
    }
  }

  func testNotifyDelegateDidComplete() {
    self.notifyDelegateDidComplete.assertDidNotEmitValue()

    self.vm.inputs.skipButtonTapped()

    self.notifyDelegateDidComplete.assertValueCount(1)
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
