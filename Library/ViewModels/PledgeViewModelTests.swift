import Foundation
@testable import KsApi
@testable import Library
import PassKit
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

// swiftlint:disable line_length
final class PledgeViewModelTests: TestCase {
  private let vm: PledgeViewModelType = PledgeViewModel()

  private let configurePaymentMethodsViewControllerWithUser = TestObserver<User, Never>()
  private let configurePaymentMethodsViewControllerWithProject = TestObserver<Project, Never>()

  private let configureStripeIntegrationMerchantId = TestObserver<String, Never>()
  private let configureStripeIntegrationPublishableKey = TestObserver<String, Never>()

  private let configureSummaryCellWithDataPledgeTotal = TestObserver<Double, Never>()
  private let configureSummaryCellWithDataProject = TestObserver<Project, Never>()

  private let configureWithPledgeViewDataProject = TestObserver<Project, Never>()
  private let configureWithPledgeViewDataReward = TestObserver<Reward, Never>()

  private let continueViewHidden = TestObserver<Bool, Never>()

  private let createBackingError = TestObserver<String, Never>()

  private let goToApplePayPaymentAuthorizationProject = TestObserver<Project, Never>()
  private let goToApplePayPaymentAuthorizationReward = TestObserver<Reward, Never>()
  private let goToApplePayPaymentAuthorizationPledgeAmount = TestObserver<Double, Never>()
  private let goToApplePayPaymentAuthorizationShippingRule = TestObserver<ShippingRule?, Never>()
  private let goToApplePayPaymentAuthorizationMerchantId = TestObserver<String, Never>()

  private let goToThanks = TestObserver<Project, Never>()

  private let paymentMethodsViewHidden = TestObserver<Bool, Never>()
  private let shippingLocationViewHidden = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.configurePaymentMethodsViewControllerWithValue.map(first)
      .observe(self.configurePaymentMethodsViewControllerWithUser.observer)
    self.vm.outputs.configurePaymentMethodsViewControllerWithValue.map(second)
      .observe(self.configurePaymentMethodsViewControllerWithProject.observer)

    self.vm.outputs.configureSummaryViewControllerWithData.map(second)
      .observe(self.configureSummaryCellWithDataPledgeTotal.observer)
    self.vm.outputs.configureSummaryViewControllerWithData.map(first)
      .observe(self.configureSummaryCellWithDataProject.observer)

    self.vm.outputs.configureWithData.map { $0.project }
      .observe(self.configureWithPledgeViewDataProject.observer)
    self.vm.outputs.configureWithData.map { $0.reward }
      .observe(self.configureWithPledgeViewDataReward.observer)

    self.vm.outputs.configureStripeIntegration.map(first)
      .observe(self.configureStripeIntegrationMerchantId.observer)
    self.vm.outputs.configureStripeIntegration.map(second)
      .observe(self.configureStripeIntegrationPublishableKey.observer)

    self.vm.outputs.continueViewHidden.observe(self.continueViewHidden.observer)

    self.vm.outputs.createBackingError.observe(self.createBackingError.observer)

    self.vm.outputs.goToApplePayPaymentAuthorization.map { $0.project }
      .observe(self.goToApplePayPaymentAuthorizationProject.observer)
    self.vm.outputs.goToApplePayPaymentAuthorization.map { $0.reward }
      .observe(self.goToApplePayPaymentAuthorizationReward.observer)
    self.vm.outputs.goToApplePayPaymentAuthorization.map { $0.pledgeAmount }
      .observe(self.goToApplePayPaymentAuthorizationPledgeAmount.observer)
    self.vm.outputs.goToApplePayPaymentAuthorization.map { $0.selectedShippingRule }
      .observe(self.goToApplePayPaymentAuthorizationShippingRule.observer)
    self.vm.outputs.goToApplePayPaymentAuthorization.map { $0.merchantIdentifier }
      .observe(self.goToApplePayPaymentAuthorizationMerchantId.observer)

    self.vm.outputs.goToThanks.observe(self.goToThanks.observer)

    self.vm.outputs.paymentMethodsViewHidden.observe(self.paymentMethodsViewHidden.observer)
    self.vm.outputs.shippingLocationViewHidden.observe(self.shippingLocationViewHidden.observer)
  }

  func testPledgeView_Logged_Out_Shipping_Disabled() {
    withEnvironment(currentUser: nil) {
      let project = Project.template
      let reward = Reward.template
        |> Reward.lens.shipping.enabled .~ false

      self.vm.inputs.configureWith(project: project, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.configurePaymentMethodsViewControllerWithUser.assertDidNotEmitValue()
      self.configurePaymentMethodsViewControllerWithProject.assertDidNotEmitValue()

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.continueViewHidden.assertValues([false])
      self.paymentMethodsViewHidden.assertValues([true])
      self.shippingLocationViewHidden.assertValues([true])
      self.configureSummaryCellWithDataPledgeTotal.assertValues([reward.minimum])
      self.configureSummaryCellWithDataProject.assertValues([project])
    }
  }

  func testPledgeView_Logged_Out_Shipping_Enabled() {
    withEnvironment(currentUser: nil) {
      let project = Project.template
      let reward = Reward.template
        |> Reward.lens.shipping.enabled .~ true

      self.vm.inputs.configureWith(project: project, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.configurePaymentMethodsViewControllerWithUser.assertDidNotEmitValue()
      self.configurePaymentMethodsViewControllerWithProject.assertDidNotEmitValue()

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.continueViewHidden.assertValues([false])
      self.paymentMethodsViewHidden.assertValues([true])
      self.shippingLocationViewHidden.assertValues([false])

      self.configureSummaryCellWithDataPledgeTotal.assertValues([reward.minimum])
      self.configureSummaryCellWithDataProject.assertValues([project])
    }
  }

  func testPledgeView_Logged_In_Shipping_Disabled() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ false

    withEnvironment(currentUser: .template) {
      self.vm.inputs.configureWith(project: project, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.configurePaymentMethodsViewControllerWithUser.assertValues([User.template])
      self.configurePaymentMethodsViewControllerWithProject.assertValues([project])

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.continueViewHidden.assertValues([true])
      self.paymentMethodsViewHidden.assertValues([false])
      self.shippingLocationViewHidden.assertValues([true])
      self.configureSummaryCellWithDataPledgeTotal.assertValues([reward.minimum])
      self.configureSummaryCellWithDataProject.assertValues([project])
    }
  }

  func testPledgeView_Logged_In_Shipping_Enabled() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true

    withEnvironment(currentUser: .template) {
      self.vm.inputs.configureWith(project: project, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.configurePaymentMethodsViewControllerWithUser.assertValues([User.template])
      self.configurePaymentMethodsViewControllerWithProject.assertValues([project])

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.continueViewHidden.assertValues([true])
      self.paymentMethodsViewHidden.assertValues([false])
      self.shippingLocationViewHidden.assertValues([false])
      self.configureSummaryCellWithDataPledgeTotal.assertValues([reward.minimum])
      self.configureSummaryCellWithDataProject.assertValues([project])
    }
  }

  func testShippingRuleSelectedDefaultShippingRule() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.shipping .~ (.template |> Reward.Shipping.lens.enabled .~ true)

    withEnvironment(currentUser: .template) {
      self.vm.inputs.configureWith(project: project, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.configurePaymentMethodsViewControllerWithUser.assertValues([User.template])
      self.configurePaymentMethodsViewControllerWithProject.assertValues([project])

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.continueViewHidden.assertValues([true])
      self.paymentMethodsViewHidden.assertValues([false])
      self.shippingLocationViewHidden.assertValues([false])
      self.configureSummaryCellWithDataPledgeTotal.assertValues([reward.minimum])
      self.configureSummaryCellWithDataProject.assertValues([project])

      let defaultShippingRule = ShippingRule.template
        |> ShippingRule.lens.cost .~ 5

      self.vm.inputs.shippingRuleSelected(defaultShippingRule)

      self.configureSummaryCellWithDataPledgeTotal
        .assertValues([reward.minimum, reward.minimum + defaultShippingRule.cost])
      self.configureSummaryCellWithDataProject.assertValues([project, project])
    }
  }

  func testShippingRuleSelectedUpdatedShippingRule() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.shipping .~ (.template |> Reward.Shipping.lens.enabled .~ true)

    withEnvironment(currentUser: .template) {
      self.vm.inputs.configureWith(project: project, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.configurePaymentMethodsViewControllerWithUser.assertValues([User.template])
      self.configurePaymentMethodsViewControllerWithProject.assertValues([project])

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.continueViewHidden.assertValues([true])
      self.paymentMethodsViewHidden.assertValues([false])
      self.shippingLocationViewHidden.assertValues([false])
      self.configureSummaryCellWithDataPledgeTotal.assertValues([reward.minimum])
      self.configureSummaryCellWithDataProject.assertValues([project])

      let defaultShippingRule = ShippingRule.template
        |> ShippingRule.lens.cost .~ 5

      self.vm.inputs.shippingRuleSelected(defaultShippingRule)

      self.configureSummaryCellWithDataPledgeTotal
        .assertValues([reward.minimum, reward.minimum + defaultShippingRule.cost])
      self.configureSummaryCellWithDataProject.assertValues([project, project])

      let selectedShippingRule = ShippingRule.template
        |> ShippingRule.lens.cost .~ 5
        |> ShippingRule.lens.location .~ .australia

      self.vm.inputs.shippingRuleSelected(selectedShippingRule)

      self.configureSummaryCellWithDataPledgeTotal.assertValues([
        reward.minimum,
        reward.minimum + defaultShippingRule.cost,
        reward.minimum + selectedShippingRule.cost
      ])
      self.configureSummaryCellWithDataProject.assertValues([project, project, project])
    }
  }

  func testPledgeAmountUpdates() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true

    withEnvironment(currentUser: .template) {
      self.vm.inputs.configureWith(project: project, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.configurePaymentMethodsViewControllerWithUser.assertValues([User.template])
      self.configurePaymentMethodsViewControllerWithProject.assertValues([project])

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.continueViewHidden.assertValues([true])
      self.paymentMethodsViewHidden.assertValues([false])
      self.shippingLocationViewHidden.assertValues([false])

      self.configureSummaryCellWithDataPledgeTotal.assertValues([reward.minimum])
      self.configureSummaryCellWithDataProject.assertValues([project])

      let amount1 = 66.0

      self.vm.inputs.pledgeAmountDidUpdate(to: amount1)

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.configureSummaryCellWithDataPledgeTotal.assertValues([reward.minimum, amount1])
      self.configureSummaryCellWithDataProject.assertValues([project, project])

      let amount2 = 99.0

      self.vm.inputs.pledgeAmountDidUpdate(to: amount2)

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.configureSummaryCellWithDataPledgeTotal.assertValues([reward.minimum, amount1, amount2])
      self.configureSummaryCellWithDataProject.assertValues([project, project, project])
    }
  }

  func testLoginSignup() {
    let project = Project.template
    let reward = Reward.template
    let user = User.template

    withEnvironment(currentUser: nil) {
      self.vm.inputs.configureWith(project: project, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.configurePaymentMethodsViewControllerWithUser.assertDidNotEmitValue()
      self.configurePaymentMethodsViewControllerWithProject.assertDidNotEmitValue()

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.continueViewHidden.assertValues([false])
      self.paymentMethodsViewHidden.assertValues([true])
      self.shippingLocationViewHidden.assertValues([true])

      withEnvironment(currentUser: user) {
        self.vm.inputs.userSessionStarted()

        self.configurePaymentMethodsViewControllerWithUser.assertValues([user])
        self.configurePaymentMethodsViewControllerWithProject.assertValues([project])

        self.configureWithPledgeViewDataProject.assertValues([project])
        self.configureWithPledgeViewDataReward.assertValues([reward])

        self.continueViewHidden.assertValues([false, true])
        self.paymentMethodsViewHidden.assertValues([true, false])
        self.shippingLocationViewHidden.assertValues([true])
      }
    }
  }

  func testSelectedShippingRuleAndPledgeAmountUpdates() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.shipping .~ (.template |> Reward.Shipping.lens.enabled .~ true)

    withEnvironment(currentUser: .template) {
      self.vm.inputs.configureWith(project: project, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.configurePaymentMethodsViewControllerWithUser.assertValues([User.template])
      self.configurePaymentMethodsViewControllerWithProject.assertValues([project])

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.continueViewHidden.assertValues([true])
      self.paymentMethodsViewHidden.assertValues([false])
      self.shippingLocationViewHidden.assertValues([false])

      self.configureSummaryCellWithDataPledgeTotal.assertValues([reward.minimum])
      self.configureSummaryCellWithDataProject.assertValues([project])

      let shippingRule1 = ShippingRule.template
        |> ShippingRule.lens.cost .~ 20.0

      self.vm.inputs.shippingRuleSelected(shippingRule1)

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.configureSummaryCellWithDataPledgeTotal.assertValues([
        reward.minimum,
        reward.minimum + shippingRule1.cost
      ])
      self.configureSummaryCellWithDataProject.assertValues([project, project])

      let amount1 = 200.0

      self.vm.inputs.pledgeAmountDidUpdate(to: amount1)

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.configureSummaryCellWithDataPledgeTotal.assertValues(
        [reward.minimum, reward.minimum + shippingRule1.cost, shippingRule1.cost + amount1]
      )
      self.configureSummaryCellWithDataProject.assertValues([project, project, project])

      let shippingRule2 = ShippingRule.template
        |> ShippingRule.lens.cost .~ 123.0

      self.vm.inputs.shippingRuleSelected(shippingRule2)

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.configureSummaryCellWithDataPledgeTotal.assertValues(
        [
          reward.minimum,
          reward.minimum + shippingRule1.cost,
          shippingRule1.cost + amount1,
          shippingRule2.cost + amount1
        ]
      )
      self.configureSummaryCellWithDataProject.assertValues([project, project, project, project])

      let amount2 = 1_999.0

      self.vm.inputs.pledgeAmountDidUpdate(to: amount2)

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.configureSummaryCellWithDataPledgeTotal.assertValues(
        [
          reward.minimum,
          reward.minimum + shippingRule1.cost,
          shippingRule1.cost + amount1,
          shippingRule2.cost + amount1,
          shippingRule2.cost + amount2
        ]
      )
      self.configureSummaryCellWithDataProject.assertValues([project, project, project, project, project])
    }
  }

  func testStripeConfiguration_StagingEnvironment() {
    let mockService = MockService(serverConfig: ServerConfig.staging)

    withEnvironment(apiService: mockService) {
      self.configureStripeIntegrationMerchantId.assertDidNotEmitValue()
      self.configureStripeIntegrationPublishableKey.assertDidNotEmitValue()

      self.vm.inputs.configureWith(project: .template, reward: .template)
      self.vm.inputs.viewDidLoad()

      self.configureStripeIntegrationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])
      self.configureStripeIntegrationPublishableKey.assertValues([Secrets.StripePublishableKey.staging])
    }
  }

  func testStripeConfiguration_ProductionEnvironment() {
    let mockService = MockService(serverConfig: ServerConfig.production)

    withEnvironment(apiService: mockService) {
      self.configureStripeIntegrationMerchantId.assertDidNotEmitValue()
      self.configureStripeIntegrationPublishableKey.assertDidNotEmitValue()

      self.vm.inputs.configureWith(project: .template, reward: .template)
      self.vm.inputs.viewDidLoad()

      self.configureStripeIntegrationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])
      self.configureStripeIntegrationPublishableKey.assertValues([Secrets.StripePublishableKey.production])
    }
  }

  func testGoToApplePayPaymentAuthorization_WhenApplePayButtonTapped_ShippingDisabled() {
    let project = Project.template
    let reward = Reward.noReward
      |> Reward.lens.minimum .~ 5

    self.vm.inputs.configureWith(project: project, reward: reward)
    self.vm.inputs.viewDidLoad()

    self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationPledgeAmount.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationShippingRule.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

    self.vm.inputs.applePayButtonTapped()

    self.goToApplePayPaymentAuthorizationProject.assertValues([project])
    self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
    self.goToApplePayPaymentAuthorizationShippingRule.assertValues([nil])
    self.goToApplePayPaymentAuthorizationPledgeAmount.assertValues([5])
    self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])
  }

  func testGoToApplePayPaymentAuthorization_WhenApplePayButtonTapped_ShippingEnabled() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.minimum .~ 25
      |> Reward.lens.shipping.enabled .~ true
    let shippingRule = ShippingRule.template

    self.vm.inputs.configureWith(project: project, reward: reward)
    self.vm.inputs.viewDidLoad()

    self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationPledgeAmount.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationShippingRule.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

    self.vm.inputs.shippingRuleSelected(shippingRule)

    self.vm.inputs.applePayButtonTapped()

    self.goToApplePayPaymentAuthorizationProject.assertValues([project])
    self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
    self.goToApplePayPaymentAuthorizationShippingRule.assertValues([shippingRule])
    self.goToApplePayPaymentAuthorizationPledgeAmount.assertValues([25])
    self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])
  }

  func testPaymentAuthorizationViewControllerDidFinish_WithoutCompletingTransaction() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.minimum .~ 25
      |> Reward.lens.shipping.enabled .~ true
    let shippingRule = ShippingRule.template

    self.vm.inputs.configureWith(project: project, reward: reward)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.shippingRuleSelected(shippingRule)

    self.vm.inputs.applePayButtonTapped()

    self.goToApplePayPaymentAuthorizationProject.assertValues([project])
    self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
    self.goToApplePayPaymentAuthorizationShippingRule.assertValues([shippingRule])
    self.goToApplePayPaymentAuthorizationPledgeAmount.assertValues([25])
    self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

    self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

    self.goToThanks.assertDidNotEmitValue()
    self.createBackingError.assertDidNotEmitValue()
  }

  func testStripeTokenCreated_ReturnsStatusFailure_WhenPKPaymentData_IsNil() {
    let project = Project.template
    let reward = Reward.noReward
      |> Reward.lens.minimum .~ 5

    self.vm.inputs.configureWith(project: project, reward: reward)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.applePayButtonTapped()

    self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
      paymentData: (displayName: nil, network: nil, transactionIdentifier: "12345"))

    XCTAssertEqual(PKPaymentAuthorizationStatus.failure,
                   self.vm.inputs.stripeTokenCreated(tokenOrError: .left("stripe_token")))
  }

  func testStripeTokenCreated_ReturnsStatusFailure_WhenStripeReturnsError() {
    let project = Project.template
    let reward = Reward.noReward
      |> Reward.lens.minimum .~ 5

    self.vm.inputs.configureWith(project: project, reward: reward)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.applePayButtonTapped()

    self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
      paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345"))

    let stripeError = GraphError.invalidJson(responseString: nil) // Generic error

    XCTAssertEqual(PKPaymentAuthorizationStatus.failure,
                   self.vm.inputs.stripeTokenCreated(tokenOrError: .right(stripeError)))
  }

  func testStripeTokenCreated_ReturnsStatusFailure_WhenStripeTokenNilErrorNil() {
    let project = Project.template
    let reward = Reward.noReward
      |> Reward.lens.minimum .~ 5

    self.vm.inputs.configureWith(project: project, reward: reward)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.applePayButtonTapped()

    self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
      paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345"))

    XCTAssertEqual(PKPaymentAuthorizationStatus.failure,
                   self.vm.inputs.stripeTokenCreated(tokenOrError: .right(nil)))
  }

  func testStripeTokenCreated_ReturnsStatusSuccess() {
    let project = Project.template
    let reward = Reward.noReward
      |> Reward.lens.minimum .~ 5

    self.vm.inputs.configureWith(project: project, reward: reward)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.applePayButtonTapped()

    self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
      paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345"))

    XCTAssertEqual(PKPaymentAuthorizationStatus.success,
                   self.vm.inputs.stripeTokenCreated(tokenOrError: .left("stripe-token")))
  }

  func testGoToThanks() {
    withEnvironment(apiService: MockService()) {
      let project = Project.template
      let reward = Reward.noReward
        |> Reward.lens.minimum .~ 5

      self.vm.inputs.configureWith(project: project, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.applePayButtonTapped()

      self.goToThanks.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
        paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345"))

      XCTAssertEqual(PKPaymentAuthorizationStatus.success,
                     self.vm.inputs.stripeTokenCreated(tokenOrError: .left("stripe-token")))

      self.goToThanks.assertDidNotEmitValue()

      self.scheduler.run()

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.goToThanks.assertValues([project])
      self.createBackingError.assertDidNotEmitValue()
    }
  }

  func testCreateApplePayBackingError() {
    let mockService = MockService(createApplePayBackingError: GraphError.invalidInput)

    withEnvironment(apiService: mockService) {
      let project = Project.template
      let reward = Reward.noReward
        |> Reward.lens.minimum .~ 5

      self.vm.inputs.configureWith(project: project, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.applePayButtonTapped()

      self.goToThanks.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
        paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345"))

      XCTAssertEqual(PKPaymentAuthorizationStatus.success,
                     self.vm.inputs.stripeTokenCreated(tokenOrError: .left("stripe-token")))

      self.goToThanks.assertDidNotEmitValue()
      self.createBackingError.assertDidNotEmitValue()

      self.scheduler.run()

      self.createBackingError.assertDidNotEmitValue("Signal waits for the Apple Pay sheet to be dismissed")
      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.createBackingError.assertValues([GraphError.invalidInput.localizedDescription])
      self.goToThanks.assertDidNotEmitValue()
    }
  }
}
