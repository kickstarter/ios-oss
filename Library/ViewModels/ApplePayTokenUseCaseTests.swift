@testable import KsApi
@testable import Library
import PassKit
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class ApplePayTokenUseCaseTests: TestCase {
  let (initialDataSignal, initialDataObserver) = Signal<PaymentAuthorizationData, Never>.pipe()
  let (allRewardsTotalSignal, allRewardsTotalObserver) = Signal<Double, Never>.pipe()
  let (additionalPledgeAmountSignal, additionalPledgeAmountObserver) = Signal<Double, Never>.pipe()
  let (allRewardsShippingTotalSignal, allRewardsShippingTotalObserver) = Signal<Double, Never>.pipe()

  var useCase: ApplePayTokenUseCase!

  let goToApplePayPaymentAuthorization = TestObserver<PKPaymentRequest, Never>()
  let applePayParams = TestObserver<ApplePayParams?, Never>()
  let applePayAuthorizationStatus = TestObserver<PKPaymentAuthorizationStatus, Never>()

  override func setUp() {
    super.setUp()

    self.useCase = ApplePayTokenUseCase(
      initialData: self.initialDataSignal
    )

    self.useCase.outputs.goToApplePayPaymentAuthorization
      .observe(self.goToApplePayPaymentAuthorization.observer)
    self.useCase.outputs.applePayAuthorizationStatus.observe(self.applePayAuthorizationStatus.observer)
    self.useCase.outputs.applePayParams.observe(self.applePayParams.observer)
  }

  func testUseCase_GoesToPaymentAuthorization_WhenApplePayButtonIsTapped() {
    let data = PaymentAuthorizationData(
      project: Project.template,
      reward: Reward.template,
      allRewardsTotal: 92.0,
      additionalPledgeAmount: 15.0,
      allRewardsShippingTotal: 33.0,
      merchantIdentifier: "foo.bar.baz"
    )

    self.initialDataObserver.send(value: data)

    self.goToApplePayPaymentAuthorization.assertDidNotEmitValue()

    self.useCase.inputs.applePayButtonTapped()

    self.goToApplePayPaymentAuthorization.assertDidEmitValue()
  }

  func testUseCase_ApplePayParams_DefaultToNil() {
    let data = PaymentAuthorizationData(
      project: Project.template,
      reward: Reward.template,
      allRewardsTotal: 92.0,
      additionalPledgeAmount: 15.0,
      allRewardsShippingTotal: 33.0,
      merchantIdentifier: "foo.bar.baz"
    )

    self.initialDataObserver.send(value: data)
    self.applePayParams.assertLastValue(nil)
  }

  func testUseCase_CompletingApplePayFlow_SendsApplePayParamsAndStatus() {
    let data = PaymentAuthorizationData(
      project: Project.template,
      reward: Reward.template,
      allRewardsTotal: 92.0,
      additionalPledgeAmount: 15.0,
      allRewardsShippingTotal: 33.0,
      merchantIdentifier: "foo.bar.baz"
    )

    self.initialDataObserver.send(value: data)

    self.useCase.inputs.applePayButtonTapped()
    self.goToApplePayPaymentAuthorization.assertDidEmitValue()

    self.useCase.inputs.paymentAuthorizationDidAuthorizePayment(paymentData: (
      "Display Name",
      "Network",
      "Transaction Identifier"
    ))
    self.applePayParams.assertLastValue(nil, "Params shouldn't emit until transaction is finished")

    let status = self.useCase.inputs.stripeTokenCreated(token: "some_stripe_token", error: nil)
    XCTAssertEqual(status, PKPaymentAuthorizationStatus.success)

    self.applePayParams.assertLastValue(nil, "Params shouldn't emit until transaction is finished")

    self.useCase.inputs.paymentAuthorizationViewControllerDidFinish()

    self.applePayAuthorizationStatus.assertLastValue(PKPaymentAuthorizationStatus.success)
    self.applePayParams.assertDidEmitValue()

    XCTAssertNotNil(self.applePayParams.lastValue as Any)

    let params = self.applePayParams.lastValue!!
    XCTAssertEqual(params.token, "some_stripe_token")
    XCTAssertEqual(params.paymentInstrumentName, "Display Name")
    XCTAssertEqual(params.paymentNetwork, "Network")
    XCTAssertEqual(params.transactionIdentifier, "Transaction Identifier")
  }

  func testUseCase_StripeError_SendsFailedStatus() {
    let data = PaymentAuthorizationData(
      project: Project.template,
      reward: Reward.template,
      allRewardsTotal: 92.0,
      additionalPledgeAmount: 15.0,
      allRewardsShippingTotal: 33.0,
      merchantIdentifier: "foo.bar.baz"
    )

    self.initialDataObserver.send(value: data)

    self.useCase.inputs.applePayButtonTapped()
    self.useCase.inputs.paymentAuthorizationDidAuthorizePayment(paymentData: (
      "Display Name",
      "Network",
      "Transaction Identifier"
    ))

    let status = self.useCase.inputs.stripeTokenCreated(token: nil, error: TestError())
    XCTAssertEqual(status, PKPaymentAuthorizationStatus.failure)

    self.useCase.inputs.paymentAuthorizationViewControllerDidFinish()

    self.applePayAuthorizationStatus.assertLastValue(PKPaymentAuthorizationStatus.failure)
    self.applePayParams.assertLastValue(nil, "Params shouldn't emit when Stripe fails")
  }

  func testUseCase_ApplePayIsCanceled_DoesNotSendParams() {
    let data = PaymentAuthorizationData(
      project: Project.template,
      reward: Reward.template,
      allRewardsTotal: 92.0,
      additionalPledgeAmount: 15.0,
      allRewardsShippingTotal: 33.0,
      merchantIdentifier: "foo.bar.baz"
    )

    self.initialDataObserver.send(value: data)

    self.useCase.inputs.applePayButtonTapped()
    self.useCase.inputs.paymentAuthorizationViewControllerDidFinish()

    self.applePayAuthorizationStatus.assertDidNotEmitValue()
    self.applePayParams.assertLastValue(nil, "Params shouldn't emit when ApplePay is canceled")
  }
}

private class TestError: Error {}
