import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class PledgeViewCTAContainerViewModelTests: TestCase {
  let vm: PledgeViewCTAContainerViewModelType = PledgeViewCTAContainerViewModel()
  private let applePayButtonIsHidden = TestObserver<Bool, Never>()
  private let continueButtonIsHidden = TestObserver<Bool, Never>()
  private let notifyDelegateApplePayButtonTapped = TestObserver<Void, Never>()
  private let notifyDelegateOpenHelpType = TestObserver<HelpType, Never>()
  private let notifyDelegateSubmitButtonTapped = TestObserver<Void, Never>()
  private let notifyDelegateToGoToLoginSignup = TestObserver<Void, Never>()
  private let submitButtonIsEnabled = TestObserver<Bool, Never>()
  private let submitButtonIsHidden = TestObserver<Bool, Never>()
  private let submitButtonTitle = TestObserver<String, Never>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.applePayButtonIsHidden.observe(self.applePayButtonIsHidden.observer)
    self.vm.outputs.continueButtonIsHidden.observe(self.continueButtonIsHidden.observer)
    self.vm.outputs.notifyDelegateApplePayButtonTapped
      .observe(self.notifyDelegateApplePayButtonTapped.observer)
    self.vm.outputs.notifyDelegateOpenHelpType.observe(self.notifyDelegateOpenHelpType.observer)
    self.vm.outputs.notifyDelegateSubmitButtonTapped.observe(self.notifyDelegateSubmitButtonTapped.observer)
    self.vm.outputs.notifyDelegateToGoToLoginSignup.observe(self.notifyDelegateToGoToLoginSignup.observer)
    self.vm.outputs.submitButtonIsEnabled.observe(self.submitButtonIsEnabled.observer)
    self.vm.outputs.submitButtonIsHidden.observe(self.submitButtonIsHidden.observer)
    self.vm.outputs.submitButtonTitle.observe(self.submitButtonTitle.observer)
  }

  func testPledgeView_UserLoggedOut() {
    let context = PledgeViewContext.pledge

    let pledgeData = PledgeViewCTAContainerViewData(
      isLoggedIn: false,
      isEnabled: true,
      context: context,
      willRetryPaymentMethod: false
    )

    self.submitButtonIsHidden.assertDidNotEmitValue()
    self.applePayButtonIsHidden.assertDidNotEmitValue()
    self.continueButtonIsHidden.assertDidNotEmitValue()
    self.submitButtonIsEnabled.assertDidNotEmitValue()

    self.vm.inputs.configureWith(value: pledgeData)

    self.submitButtonIsHidden.assertValues([true])
    self.applePayButtonIsHidden.assertValues([true])
    self.continueButtonIsHidden.assertValues([false])
    self.submitButtonIsEnabled.assertValues([true])
  }

  func testPledgeView_UserLoggedIn() {
    let context = PledgeViewContext.pledge

    let pledgeData = PledgeViewCTAContainerViewData(
      isLoggedIn: true,
      isEnabled: true,
      context: context,
      willRetryPaymentMethod: false
    )

    self.submitButtonIsHidden.assertDidNotEmitValue()
    self.applePayButtonIsHidden.assertDidNotEmitValue()
    self.continueButtonIsHidden.assertDidNotEmitValue()
    self.submitButtonIsEnabled.assertDidNotEmitValue()

    self.vm.inputs.configureWith(value: pledgeData)

    self.submitButtonIsHidden.assertValues([false])
    self.applePayButtonIsHidden.assertValues([false])
    self.continueButtonIsHidden.assertValues([true])
    self.submitButtonIsEnabled.assertValues([true])
    self.submitButtonTitle.assertValues(["Pledge"])
  }

  func testPledgeView_UpdateContext() {
    let context = PledgeViewContext.update

    let pledgeData = PledgeViewCTAContainerViewData(
      isLoggedIn: true,
      isEnabled: true,
      context: context,
      willRetryPaymentMethod: false
    )

    self.submitButtonIsHidden.assertDidNotEmitValue()
    self.applePayButtonIsHidden.assertDidNotEmitValue()
    self.continueButtonIsHidden.assertDidNotEmitValue()
    self.submitButtonIsEnabled.assertDidNotEmitValue()

    self.vm.inputs.configureWith(value: pledgeData)

    self.submitButtonIsHidden.assertValues([false])
    self.applePayButtonIsHidden.assertValues([true])
    self.continueButtonIsHidden.assertValues([true])
    self.submitButtonIsEnabled.assertValues([true])
    self.submitButtonTitle.assertValues(["Confirm"])
  }

  func testPledgeView_ChangePaymentMethodContext() {
    let context = PledgeViewContext.changePaymentMethod

    let pledgeData = PledgeViewCTAContainerViewData(
      isLoggedIn: true,
      isEnabled: true,
      context: context,
      willRetryPaymentMethod: false
    )

    self.submitButtonIsHidden.assertDidNotEmitValue()
    self.applePayButtonIsHidden.assertDidNotEmitValue()
    self.continueButtonIsHidden.assertDidNotEmitValue()
    self.submitButtonIsEnabled.assertDidNotEmitValue()

    self.vm.inputs.configureWith(value: pledgeData)

    self.submitButtonIsHidden.assertValues([false])
    self.applePayButtonIsHidden.assertValues([false])
    self.continueButtonIsHidden.assertValues([true])
    self.submitButtonIsEnabled.assertValues([true])
    self.submitButtonTitle.assertValues(["Confirm"])
  }

  func testPledgeView_FixPaymentMethodContext_RetryingPaymentMethod() {
    let context = PledgeViewContext.fixPaymentMethod

    let pledgeData = PledgeViewCTAContainerViewData(
      isLoggedIn: true,
      isEnabled: true,
      context: context,
      willRetryPaymentMethod: true
    )

    self.submitButtonIsHidden.assertDidNotEmitValue()
    self.applePayButtonIsHidden.assertDidNotEmitValue()
    self.continueButtonIsHidden.assertDidNotEmitValue()
    self.submitButtonIsEnabled.assertDidNotEmitValue()

    self.vm.inputs.configureWith(value: pledgeData)

    self.submitButtonIsHidden.assertValues([false])
    self.applePayButtonIsHidden.assertValues([false])
    self.continueButtonIsHidden.assertValues([true])
    self.submitButtonIsEnabled.assertValues([true])
    self.submitButtonTitle.assertValues(["Retry"])
  }

  func testContinueButtonTapped() {
    let pledgeData = PledgeViewCTAContainerViewData(
      isLoggedIn: false,
      isEnabled: true,
      context: .pledge,
      willRetryPaymentMethod: false
    )

    self.vm.inputs.configureWith(value: pledgeData)

    self.notifyDelegateToGoToLoginSignup.assertDidNotEmitValue()

    self.vm.inputs.continueButtonTapped()

    self.notifyDelegateToGoToLoginSignup.assertValueCount(1)
  }

  func testApplePayButtonTapped() {
    self.notifyDelegateApplePayButtonTapped.assertDidNotEmitValue()

    self.vm.inputs.applePayButtonTapped()

    self.notifyDelegateApplePayButtonTapped.assertValueCount(1)
  }

  func testNotifyDelegateOpenHelpType() {
    let baseUrl = AppEnvironment.current.apiService.serverConfig.webBaseUrl
    let allCases = HelpType.allCases.filter { $0 != .contact }

    let allHelpTypeUrls = allCases.map { $0.url(withBaseUrl: baseUrl) }.compact()

    allHelpTypeUrls.forEach { self.vm.inputs.tapped($0) }

    self.notifyDelegateOpenHelpType.assertValues(allCases)
  }

  func testSubmitButtonTapped() {
    self.notifyDelegateSubmitButtonTapped.assertDidNotEmitValue()

    self.vm.inputs.submitButtonTapped()

    self.notifyDelegateSubmitButtonTapped.assertValueCount(1)
  }
}
