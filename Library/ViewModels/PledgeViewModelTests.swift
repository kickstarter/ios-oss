import Foundation
@testable import KsApi
@testable import Library
import PassKit
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

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

  private let confirmationLabelAttributedText = TestObserver<NSAttributedString, Never>()
  private let confirmationLabelHidden = TestObserver<Bool, Never>()

  private let continueViewHidden = TestObserver<Bool, Never>()

  private let descriptionViewHidden = TestObserver<Bool, Never>()

  private let createBackingError = TestObserver<String, Never>()

  private let goToApplePayPaymentAuthorizationProject = TestObserver<Project, Never>()
  private let goToApplePayPaymentAuthorizationReward = TestObserver<Reward, Never>()
  private let goToApplePayPaymentAuthorizationPledgeAmount = TestObserver<Double, Never>()
  private let goToApplePayPaymentAuthorizationShippingRule = TestObserver<ShippingRule?, Never>()
  private let goToApplePayPaymentAuthorizationMerchantId = TestObserver<String, Never>()

  private let goToThanks = TestObserver<Project, Never>()

  private let notifyDelegateUpdatePledgeDidSucceedWithMessage = TestObserver<String, Never>()

  private let paymentMethodsViewHidden = TestObserver<Bool, Never>()
  private let pledgeAmountViewHidden = TestObserver<Bool, Never>()
  private let pledgeAmountSummaryViewHidden = TestObserver<Bool, Never>()
  private let sectionSeparatorsHidden = TestObserver<Bool, Never>()
  private let shippingLocationViewHidden = TestObserver<Bool, Never>()
  private let showApplePayAlertMessage = TestObserver<String, Never>()
  private let showApplePayAlertTitle = TestObserver<String, Never>()
  private let submitButtonEnabled = TestObserver<Bool, Never>()
  private let submitButtonHidden = TestObserver<Bool, Never>()
  private let submitButtonTitle = TestObserver<String, Never>()
  private let title = TestObserver<String, Never>()
  private let updatePledgeFailedWithError = TestObserver<String, Never>()

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

    self.vm.outputs.submitButtonEnabled.observe(self.submitButtonEnabled.observer)
    self.vm.outputs.submitButtonHidden.observe(self.submitButtonHidden.observer)
    self.vm.outputs.submitButtonTitle.observe(self.submitButtonTitle.observer)
    self.vm.outputs.confirmationLabelAttributedText.observe(self.confirmationLabelAttributedText.observer)
    self.vm.outputs.confirmationLabelHidden.observe(self.confirmationLabelHidden.observer)

    self.vm.outputs.continueViewHidden.observe(self.continueViewHidden.observer)

    self.vm.outputs.createBackingError.observe(self.createBackingError.observer)

    self.vm.outputs.descriptionViewHidden.observe(self.descriptionViewHidden.observer)

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

    self.vm.outputs.notifyDelegateUpdatePledgeDidSucceedWithMessage
      .observe(self.notifyDelegateUpdatePledgeDidSucceedWithMessage.observer)

    self.vm.outputs.paymentMethodsViewHidden.observe(self.paymentMethodsViewHidden.observer)
    self.vm.outputs.pledgeAmountViewHidden.observe(self.pledgeAmountViewHidden.observer)
    self.vm.outputs.pledgeAmountSummaryViewHidden.observe(self.pledgeAmountSummaryViewHidden.observer)

    self.vm.outputs.sectionSeparatorsHidden.observe(self.sectionSeparatorsHidden.observer)
    self.vm.outputs.shippingLocationViewHidden.observe(self.shippingLocationViewHidden.observer)
    self.vm.outputs.showApplePayAlert.map(second).observe(self.showApplePayAlertMessage.observer)
    self.vm.outputs.showApplePayAlert.map(first).observe(self.showApplePayAlertTitle.observer)

    self.vm.outputs.title.observe(self.title.observer)

    self.vm.outputs.updatePledgeFailedWithError.observe(self.updatePledgeFailedWithError.observer)
  }

  func testPledgeContext_LoggedIn() {
    let mockService = MockService(serverConfig: ServerConfig.staging)

    withEnvironment(apiService: mockService, currentUser: .template) {
      let project = Project.template
      let reward = Reward.template
        |> Reward.lens.shipping.enabled .~ true

      self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage, context: .pledge)
      self.vm.inputs.viewDidLoad()

      self.title.assertValues(["Back this project"])

      self.configurePaymentMethodsViewControllerWithUser.assertValues([User.template])
      self.configurePaymentMethodsViewControllerWithProject.assertValues([project])

      self.configureStripeIntegrationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])
      self.configureStripeIntegrationPublishableKey.assertValues([Secrets.StripePublishableKey.staging])

      self.submitButtonTitle.assertValues(["Pledge"])
      self.confirmationLabelHidden.assertValues([true])

      self.descriptionViewHidden.assertValues([false])

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.continueViewHidden.assertValues([true])
      self.submitButtonHidden.assertValues([false])
      self.paymentMethodsViewHidden.assertValues([false])
      self.pledgeAmountViewHidden.assertValues([false])
      self.pledgeAmountSummaryViewHidden.assertValues([true])
      self.sectionSeparatorsHidden.assertValues([false])
      self.shippingLocationViewHidden.assertValues([false])
      self.configureSummaryCellWithDataPledgeTotal.assertValues([reward.minimum])
      self.configureSummaryCellWithDataProject.assertValues([project])
    }
  }

  func testPledgeContext_LoggedOut() {
    let mockService = MockService(serverConfig: ServerConfig.staging)

    withEnvironment(apiService: mockService, currentUser: nil) {
      let project = Project.template
      let reward = Reward.template
        |> Reward.lens.shipping.enabled .~ true

      self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage, context: .pledge)
      self.vm.inputs.viewDidLoad()

      self.title.assertValues(["Back this project"])

      self.configurePaymentMethodsViewControllerWithUser.assertDidNotEmitValue()
      self.configurePaymentMethodsViewControllerWithProject.assertDidNotEmitValue()

      self.configureStripeIntegrationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])
      self.configureStripeIntegrationPublishableKey.assertValues([Secrets.StripePublishableKey.staging])

      self.submitButtonTitle.assertValues(["Pledge"])
      self.confirmationLabelHidden.assertValues([true])

      self.descriptionViewHidden.assertValues([false])

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.continueViewHidden.assertValues([false])
      self.submitButtonHidden.assertValues([true])
      self.paymentMethodsViewHidden.assertValues([true])
      self.pledgeAmountViewHidden.assertValues([false])
      self.pledgeAmountSummaryViewHidden.assertValues([true])
      self.sectionSeparatorsHidden.assertValues([false])
      self.shippingLocationViewHidden.assertValues([false])
      self.configureSummaryCellWithDataPledgeTotal.assertValues([reward.minimum])
      self.configureSummaryCellWithDataProject.assertValues([project])
    }
  }

  func testUpdateContext() {
    let mockService = MockService(serverConfig: ServerConfig.staging)

    withEnvironment(apiService: mockService, currentUser: .template) {
      let project = Project.template
      let reward = Reward.template
        |> Reward.lens.shipping.enabled .~ true

      self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage, context: .update)
      self.vm.inputs.viewDidLoad()

      self.title.assertValues(["Update pledge"])

      self.configurePaymentMethodsViewControllerWithUser.assertDidNotEmitValue()
      self.configurePaymentMethodsViewControllerWithProject.assertDidNotEmitValue()

      self.configureStripeIntegrationMerchantId.assertDidNotEmitValue()
      self.configureStripeIntegrationPublishableKey.assertDidNotEmitValue()

      self.submitButtonTitle.assertValues(["Confirm"])
      self.confirmationLabelHidden.assertValues([false])

      self.descriptionViewHidden.assertValues([true])

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.continueViewHidden.assertValues([true])
      self.submitButtonHidden.assertValues([false])
      self.paymentMethodsViewHidden.assertValues([true])
      self.pledgeAmountViewHidden.assertValues([false])
      self.pledgeAmountSummaryViewHidden.assertValues([true])
      self.sectionSeparatorsHidden.assertValues([true])
      self.shippingLocationViewHidden.assertValues([false])
      self.configureSummaryCellWithDataPledgeTotal.assertValues([reward.minimum])
      self.configureSummaryCellWithDataProject.assertValues([project])
    }
  }

  func testUpdateRewardContext() {
    let mockService = MockService(serverConfig: ServerConfig.staging)

    withEnvironment(apiService: mockService, currentUser: .template) {
      let project = Project.template
      let reward = Reward.template
        |> Reward.lens.shipping.enabled .~ true

      self.vm.inputs.configureWith(
        project: project, reward: reward, refTag: .projectPage, context: .updateReward
      )
      self.vm.inputs.viewDidLoad()

      self.title.assertValues(["Update pledge"])

      self.configurePaymentMethodsViewControllerWithUser.assertValues([User.template])
      self.configurePaymentMethodsViewControllerWithProject.assertValues([project])

      self.configureStripeIntegrationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])
      self.configureStripeIntegrationPublishableKey.assertValues([Secrets.StripePublishableKey.staging])

      self.submitButtonTitle.assertValues(["Confirm"])
      self.confirmationLabelHidden.assertValues([true])

      self.descriptionViewHidden.assertValues([false])

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.continueViewHidden.assertValues([true])
      self.submitButtonHidden.assertValues([false])
      self.paymentMethodsViewHidden.assertValues([false])
      self.pledgeAmountViewHidden.assertValues([false])
      self.pledgeAmountSummaryViewHidden.assertValues([true])
      self.sectionSeparatorsHidden.assertValues([false])
      self.shippingLocationViewHidden.assertValues([false])
      self.configureSummaryCellWithDataPledgeTotal.assertValues([reward.minimum])
      self.configureSummaryCellWithDataProject.assertValues([project])
    }
  }

  func testChangePaymentMethodContext() {
    let mockService = MockService(serverConfig: ServerConfig.staging)

    withEnvironment(apiService: mockService, currentUser: .template) {
      let project = Project.template
      let reward = Reward.template
        |> Reward.lens.shipping.enabled .~ true

      self.vm.inputs.configureWith(
        project: project, reward: reward, refTag: .projectPage, context: .changePaymentMethod
      )
      self.vm.inputs.viewDidLoad()

      self.title.assertValues(["Change payment method"])

      self.configurePaymentMethodsViewControllerWithUser.assertValues([User.template])
      self.configurePaymentMethodsViewControllerWithProject.assertValues([project])

      self.configureStripeIntegrationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])
      self.configureStripeIntegrationPublishableKey.assertValues([Secrets.StripePublishableKey.staging])

      self.submitButtonTitle.assertValues(["Confirm"])
      self.confirmationLabelHidden.assertValues([true])

      self.descriptionViewHidden.assertValues([true])

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.continueViewHidden.assertValues([true])
      self.submitButtonHidden.assertValues([false])
      self.paymentMethodsViewHidden.assertValues([false])
      self.pledgeAmountViewHidden.assertValues([true])
      self.pledgeAmountSummaryViewHidden.assertValues([false])
      self.sectionSeparatorsHidden.assertValues([true])
      self.shippingLocationViewHidden.assertValues([true])
      self.configureSummaryCellWithDataPledgeTotal.assertValues([reward.minimum])
      self.configureSummaryCellWithDataProject.assertValues([project])
    }
  }

  func testPledgeView_Logged_Out_Shipping_Disabled() {
    withEnvironment(currentUser: nil) {
      let project = Project.template
      let reward = Reward.template
        |> Reward.lens.shipping.enabled .~ false

      self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage, context: .pledge)
      self.vm.inputs.viewDidLoad()

      self.configurePaymentMethodsViewControllerWithUser.assertDidNotEmitValue()
      self.configurePaymentMethodsViewControllerWithProject.assertDidNotEmitValue()

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.continueViewHidden.assertValues([false])
      self.submitButtonHidden.assertValues([true])
      self.paymentMethodsViewHidden.assertValues([true])
      self.pledgeAmountViewHidden.assertValues([false])
      self.pledgeAmountSummaryViewHidden.assertValues([true])
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

      self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage, context: .pledge)
      self.vm.inputs.viewDidLoad()

      self.configurePaymentMethodsViewControllerWithUser.assertDidNotEmitValue()
      self.configurePaymentMethodsViewControllerWithProject.assertDidNotEmitValue()

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.continueViewHidden.assertValues([false])
      self.submitButtonHidden.assertValues([true])
      self.paymentMethodsViewHidden.assertValues([true])
      self.pledgeAmountViewHidden.assertValues([false])
      self.pledgeAmountSummaryViewHidden.assertValues([true])
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
      self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage, context: .pledge)
      self.vm.inputs.viewDidLoad()

      self.configurePaymentMethodsViewControllerWithUser.assertValues([User.template])
      self.configurePaymentMethodsViewControllerWithProject.assertValues([project])

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.continueViewHidden.assertValues([true])
      self.submitButtonHidden.assertValues([false])
      self.paymentMethodsViewHidden.assertValues([false])
      self.pledgeAmountViewHidden.assertValues([false])
      self.pledgeAmountSummaryViewHidden.assertValues([true])
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
      self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage, context: .pledge)
      self.vm.inputs.viewDidLoad()

      self.configurePaymentMethodsViewControllerWithUser.assertValues([User.template])
      self.configurePaymentMethodsViewControllerWithProject.assertValues([project])

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.continueViewHidden.assertValues([true])
      self.submitButtonHidden.assertValues([false])
      self.paymentMethodsViewHidden.assertValues([false])
      self.pledgeAmountViewHidden.assertValues([false])
      self.pledgeAmountSummaryViewHidden.assertValues([true])
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
      self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage, context: .pledge)
      self.vm.inputs.viewDidLoad()

      self.configurePaymentMethodsViewControllerWithUser.assertValues([User.template])
      self.configurePaymentMethodsViewControllerWithProject.assertValues([project])

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.continueViewHidden.assertValues([true])
      self.submitButtonHidden.assertValues([false])
      self.paymentMethodsViewHidden.assertValues([false])
      self.pledgeAmountViewHidden.assertValues([false])
      self.pledgeAmountSummaryViewHidden.assertValues([true])
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
      self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage, context: .pledge)
      self.vm.inputs.viewDidLoad()

      self.configurePaymentMethodsViewControllerWithUser.assertValues([User.template])
      self.configurePaymentMethodsViewControllerWithProject.assertValues([project])

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.continueViewHidden.assertValues([true])
      self.submitButtonHidden.assertValues([false])
      self.paymentMethodsViewHidden.assertValues([false])
      self.pledgeAmountViewHidden.assertValues([false])
      self.pledgeAmountSummaryViewHidden.assertValues([true])
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
      self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage, context: .pledge)
      self.vm.inputs.viewDidLoad()

      self.configurePaymentMethodsViewControllerWithUser.assertValues([User.template])
      self.configurePaymentMethodsViewControllerWithProject.assertValues([project])

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.continueViewHidden.assertValues([true])
      self.submitButtonHidden.assertValues([false])
      self.paymentMethodsViewHidden.assertValues([false])
      self.pledgeAmountViewHidden.assertValues([false])
      self.pledgeAmountSummaryViewHidden.assertValues([true])
      self.shippingLocationViewHidden.assertValues([false])

      self.configureSummaryCellWithDataPledgeTotal.assertValues([reward.minimum])
      self.configureSummaryCellWithDataProject.assertValues([project])

      let data1 = (amount: 66.0, min: 10.0, max: 10_000.0, isValid: true)

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: data1)

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.configureSummaryCellWithDataPledgeTotal.assertValues([reward.minimum, data1.amount])
      self.configureSummaryCellWithDataProject.assertValues([project, project])

      let data2 = (amount: 99.0, min: 10.0, max: 10_000.0, isValid: true)

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: data2)

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.configureSummaryCellWithDataPledgeTotal.assertValues([reward.minimum, data1.amount, data2.amount])
      self.configureSummaryCellWithDataProject.assertValues([project, project, project])
    }
  }

  func testLoginSignup() {
    let project = Project.template
    let reward = Reward.template
    let user = User.template

    withEnvironment(currentUser: nil) {
      self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage, context: .pledge)
      self.vm.inputs.viewDidLoad()

      self.configurePaymentMethodsViewControllerWithUser.assertDidNotEmitValue()
      self.configurePaymentMethodsViewControllerWithProject.assertDidNotEmitValue()

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.continueViewHidden.assertValues([false])
      self.submitButtonHidden.assertValues([true])
      self.paymentMethodsViewHidden.assertValues([true])
      self.pledgeAmountViewHidden.assertValues([false])
      self.pledgeAmountSummaryViewHidden.assertValues([true])
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
      self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage, context: .pledge)
      self.vm.inputs.viewDidLoad()

      self.configurePaymentMethodsViewControllerWithUser.assertValues([User.template])
      self.configurePaymentMethodsViewControllerWithProject.assertValues([project])

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.continueViewHidden.assertValues([true])
      self.submitButtonHidden.assertValues([false])
      self.paymentMethodsViewHidden.assertValues([false])
      self.pledgeAmountViewHidden.assertValues([false])
      self.pledgeAmountSummaryViewHidden.assertValues([true])
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

      let data1 = (amount: 200.0, min: 10.0, max: 10_000.0, isValid: true)

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: data1)

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.configureSummaryCellWithDataPledgeTotal.assertValues(
        [reward.minimum, reward.minimum + shippingRule1.cost, shippingRule1.cost + data1.amount]
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
          shippingRule1.cost + data1.amount,
          shippingRule2.cost + data1.amount
        ]
      )
      self.configureSummaryCellWithDataProject.assertValues([project, project, project, project])

      let data2 = (amount: 1_999.0, min: 10.0, max: 10_000.0, isValid: true)

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: data2)

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.configureSummaryCellWithDataPledgeTotal.assertValues(
        [
          reward.minimum,
          reward.minimum + shippingRule1.cost,
          shippingRule1.cost + data1.amount,
          shippingRule2.cost + data1.amount,
          shippingRule2.cost + data2.amount
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

      self.vm.inputs.configureWith(
        project: .template, reward: .template, refTag: .projectPage, context: .pledge
      )
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

      self.vm.inputs.configureWith(project: .template, reward: .template, refTag: .activity, context: .pledge)
      self.vm.inputs.viewDidLoad()

      self.configureStripeIntegrationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])
      self.configureStripeIntegrationPublishableKey.assertValues([Secrets.StripePublishableKey.production])
    }
  }

  func testGoToApplePayPaymentAuthorization_WhenApplePayButtonTapped_ShippingDisabled() {
    let project = Project.template
    let reward = Reward.noReward
      |> Reward.lens.minimum .~ 5
    let pledgeAmountData = (amount: 99.0, min: 5.0, max: 10_000.0, isValid: true)

    self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage, context: .pledge)
    self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: pledgeAmountData)
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
    let pledgeAmountData = (amount: 99.0, min: 25.0, max: 10_000.0, isValid: true)

    self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage, context: .pledge)
    self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: pledgeAmountData)
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

  func testShowApplePayAlert_WhenApplePayButtonTapped_PledgeInputAmount_AboveMax() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.minimum .~ 25
    let pledgeAmountData = (amount: 20_000.0, min: 25.0, max: 10_000.0, isValid: false)

    self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage, context: .pledge)
    self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: pledgeAmountData)
    self.vm.inputs.viewDidLoad()

    self.showApplePayAlertMessage.assertDidNotEmitValue()
    self.showApplePayAlertTitle.assertDidNotEmitValue()

    self.vm.inputs.applePayButtonTapped()

    self.showApplePayAlertMessage.assertValues(
      ["Please enter a pledge amount between US$ 25 and US$ 10,000."]
    )
    self.showApplePayAlertTitle.assertValues(["Almost there!"])
  }

  func testShowApplePayAlert_WhenApplePayButtonTapped_PledgeInputAmount_BellowMin() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.minimum .~ 25
    let pledgeAmountData = (amount: 10.0, min: 25.0, max: 10_000.0, isValid: false)

    self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage, context: .pledge)
    self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: pledgeAmountData)
    self.vm.inputs.viewDidLoad()

    self.showApplePayAlertMessage.assertDidNotEmitValue()
    self.showApplePayAlertTitle.assertDidNotEmitValue()

    self.vm.inputs.applePayButtonTapped()

    self.showApplePayAlertMessage.assertValues(
      ["Please enter a pledge amount between US$ 25 and US$ 10,000."]
    )
    self.showApplePayAlertTitle.assertValues(["Almost there!"])
  }

  func testPaymentAuthorizationViewControllerDidFinish_WithoutCompletingTransaction() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.minimum .~ 25
      |> Reward.lens.shipping.enabled .~ true
    let shippingRule = ShippingRule.template
    let pledgeAmountData = (amount: 99.0, min: 25.0, max: 10_000.0, isValid: true)

    self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage, context: .pledge)
    self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: pledgeAmountData)
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

    self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage, context: .pledge)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.applePayButtonTapped()

    self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
      paymentData: (displayName: nil, network: nil, transactionIdentifier: "12345")
    )

    XCTAssertEqual(
      PKPaymentAuthorizationStatus.failure,
      self.vm.inputs.stripeTokenCreated(token: "stripe_token", error: nil)
    )
  }

  func testStripeTokenCreated_ReturnsStatusFailure_WhenStripeTokenNil_ErrorNotNil() {
    let project = Project.template
    let reward = Reward.noReward
      |> Reward.lens.minimum .~ 5

    self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage, context: .pledge)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.applePayButtonTapped()

    self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
      paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345")
    )

    let stripeError = GraphError.invalidJson(responseString: nil) // Generic error

    XCTAssertEqual(
      PKPaymentAuthorizationStatus.failure,
      self.vm.inputs.stripeTokenCreated(token: nil, error: stripeError)
    )
  }

  func testStripeTokenCreated_ReturnsStatusFailure_WhenStripeTokenNil_ErrorNil() {
    let project = Project.template
    let reward = Reward.noReward
      |> Reward.lens.minimum .~ 5

    self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage, context: .pledge)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.applePayButtonTapped()

    self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
      paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345")
    )

    XCTAssertEqual(
      PKPaymentAuthorizationStatus.failure,
      self.vm.inputs.stripeTokenCreated(token: nil, error: nil)
    )
  }

  func testStripeTokenCreated_ReturnsStatusFailure_WhenStripeTokenNotNil_ErrorNotNil() {
    let project = Project.template
    let reward = Reward.noReward

    self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage, context: .pledge)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.applePayButtonTapped()

    self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
      paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345")
    )

    let stripeError = GraphError.invalidJson(responseString: nil)

    XCTAssertEqual(
      PKPaymentAuthorizationStatus.failure,
      self.vm.inputs.stripeTokenCreated(token: "stripe-token", error: stripeError)
    )
  }

  func testStripeTokenCreated_ReturnsStatusSuccess() {
    let project = Project.template
    let reward = Reward.noReward
      |> Reward.lens.minimum .~ 5

    self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage, context: .pledge)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.applePayButtonTapped()

    self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
      paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345")
    )

    XCTAssertEqual(
      PKPaymentAuthorizationStatus.success,
      self.vm.inputs.stripeTokenCreated(token: "stripe_token", error: nil)
    )
  }

  func testGoToThanks() {
    withEnvironment(apiService: MockService()) {
      let project = Project.template
      let reward = Reward.noReward
        |> Reward.lens.minimum .~ 5

      self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage, context: .pledge)
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.applePayButtonTapped()

      self.goToThanks.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
        paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345")
      )

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.success,
        self.vm.inputs.stripeTokenCreated(token: "stripe_token", error: nil)
      )

      self.goToThanks.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.goToThanks.assertDidNotEmitValue("Signal waits for Create Backing to complete")
      self.createBackingError.assertDidNotEmitValue()

      self.scheduler.run()

      self.goToThanks.assertValues([project])
      self.createBackingError.assertDidNotEmitValue()
    }
  }

  func testApplePay_GoToThanks_WhenRefTag_IsNil() {
    withEnvironment(apiService: MockService(), currentUser: .template) {
      let project = Project.template
      let reward = Reward.noReward
        |> Reward.lens.minimum .~ 5

      self.vm.inputs.configureWith(project: project, reward: reward, refTag: nil, context: .pledge)
      self.vm.inputs.viewDidLoad()

      self.configurePaymentMethodsViewControllerWithUser.assertValues([User.template])
      self.configurePaymentMethodsViewControllerWithProject.assertValues([project])

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.configureSummaryCellWithDataPledgeTotal.assertValues([reward.minimum])
      self.configureSummaryCellWithDataProject.assertValues([project])

      self.continueViewHidden.assertValues([true])
      self.submitButtonHidden.assertValues([false])
      self.paymentMethodsViewHidden.assertValues([false])
      self.shippingLocationViewHidden.assertValues([true])

      self.vm.inputs.applePayButtonTapped()

      self.goToThanks.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
        paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345")
      )

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.success,
        self.vm.inputs.stripeTokenCreated(token: "stripe_token", error: nil)
      )

      self.goToThanks.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.goToThanks.assertDidNotEmitValue()

      self.scheduler.run()

      self.goToThanks.assertValues([project])
      self.createBackingError.assertDidNotEmitValue()
    }
  }

  func testGoToThanks_WhenStripeTokenCreated_ReturnsFailure() {
    withEnvironment(apiService: MockService()) {
      let project = Project.template
      let reward = Reward.noReward

      self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage, context: .pledge)
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.applePayButtonTapped()

      self.goToThanks.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
        paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345")
      )

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.failure,
        self.vm.inputs.stripeTokenCreated(token: nil, error: GraphError.invalidInput)
      )

      self.scheduler.run()

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.goToThanks.assertDidNotEmitValue()
      self.createBackingError.assertDidNotEmitValue()
    }
  }

  func testCreateApplePayBackingError() {
    let mockService = MockService(createApplePayBackingError: GraphError.invalidInput)

    withEnvironment(apiService: mockService) {
      let project = Project.template
      let reward = Reward.noReward
        |> Reward.lens.minimum .~ 5

      self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage, context: .pledge)
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.applePayButtonTapped()

      self.goToThanks.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
        paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345")
      )

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.success,
        self.vm.inputs.stripeTokenCreated(token: "stripe_token", error: nil)
      )

      self.goToThanks.assertDidNotEmitValue()
      self.createBackingError.assertDidNotEmitValue()

      self.scheduler.run()

      self.createBackingError.assertDidNotEmitValue("Signal waits for the Apple Pay sheet to be dismissed")
      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.createBackingError.assertValues(["Something went wrong."])
      self.goToThanks.assertDidNotEmitValue()
    }
  }

  func testCreateBacking() {
    let createBacking = CreateBackingEnvelope.CreateBacking(
      checkout: Checkout(state: .verifying, backing: .init(requiresAction: false, clientSecret: nil))
    )
    let mockService = MockService(
      createBackingResult:
      Result.success(CreateBackingEnvelope(createBacking: createBacking))
    )

    withEnvironment(apiService: mockService, currentUser: .template) {
      self.vm.inputs.configureWith(project: .template, reward: .template, refTag: .activity, context: .pledge)
      self.vm.inputs.viewDidLoad()

      self.submitButtonEnabled.assertValues([false])
      self.goToThanks.assertDidNotEmitValue()
      self.createBackingError.assertDidNotEmitValue()

      self.vm.inputs.creditCardSelected(with: "123")

      self.submitButtonEnabled.assertValues([false])

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(
        with: (amount: 25.0, min: 10.0, max: 10_000.0, isValid: true)
      )

      self.submitButtonEnabled.assertValues([false, true])

      self.vm.inputs.submitButtonTapped()

      self.submitButtonEnabled.assertValues([false, true, false])
      self.goToThanks.assertDidNotEmitValue()
      self.createBackingError.assertDidNotEmitValue()

      self.scheduler.run()

      self.submitButtonEnabled.assertValues([false, true, false, true])
      self.goToThanks.assertValues([.template])
      self.createBackingError.assertDidNotEmitValue()
    }
  }

  func testCreateBacking_Failure() {
    let mockService = MockService(
      createBackingResult:
      Result.failure(GraphError.invalidInput)
    )

    withEnvironment(apiService: mockService, currentUser: .template) {
      self.vm.inputs.configureWith(project: .template, reward: .template, refTag: .activity, context: .pledge)
      self.vm.inputs.viewDidLoad()

      self.submitButtonEnabled.assertValues([false])
      self.goToThanks.assertDidNotEmitValue()
      self.createBackingError.assertDidNotEmitValue()

      self.vm.inputs.creditCardSelected(with: "123")

      self.submitButtonEnabled.assertValues([false])

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(
        with: (amount: 25.0, min: 10.0, max: 10_000.0, isValid: true)
      )

      self.submitButtonEnabled.assertValues([false, true])

      self.vm.inputs.submitButtonTapped()

      self.submitButtonEnabled.assertValues([false, true, false])
      self.goToThanks.assertDidNotEmitValue()
      self.createBackingError.assertDidNotEmitValue()

      self.scheduler.run()

      self.submitButtonEnabled.assertValues([false, true, false, true])
      self.goToThanks.assertDidNotEmitValue()
      self.createBackingError.assertValues(["Something went wrong."])
    }
  }

  func testUpdateBacking_Success() {
    let reward = Reward.postcards
      |> Reward.lens.shipping.enabled .~ true

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ GraphUserCreditCard.amex
          |> Backing.lens.status .~ .pledged
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.amount .~ 700
      )

    let updateBackingEnvelope = UpdateBackingEnvelope(
      updateBacking: .init(
        checkout: .init(
          state: .successful,
          backing: .init(
            requiresAction: false,
            clientSecret: "client-secret"
          )
        )
      )
    )

    let mockService = MockService(
      updateBackingResult: .success(updateBackingEnvelope)
    )

    withEnvironment(apiService: mockService, currentUser: .template) {
      self.vm.inputs.configureWith(project: project, reward: reward, refTag: nil, context: .update)
      self.vm.inputs.viewDidLoad()

      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.updatePledgeFailedWithError.assertDidNotEmitValue()
      self.submitButtonEnabled.assertValues([false])

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(
        with: (amount: 25.0, min: 25.0, max: 10_000.0, isValid: true)
      )

      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.updatePledgeFailedWithError.assertDidNotEmitValue()
      self.submitButtonEnabled.assertValues([false, true])

      self.vm.inputs.shippingRuleSelected(.template)

      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.updatePledgeFailedWithError.assertDidNotEmitValue()
      self.submitButtonEnabled.assertValues([false, true, true])

      self.vm.inputs.submitButtonTapped()

      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.updatePledgeFailedWithError.assertDidNotEmitValue()
      self.submitButtonEnabled.assertValues([false, true, true, false])

      self.scheduler.run()

      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertValues([
        "Got it! Your changes have been saved."
      ])
      self.updatePledgeFailedWithError.assertDidNotEmitValue()
      self.submitButtonEnabled.assertValues([false, true, true, false, true])
    }
  }

  func testUpdateBacking_Failure() {
    let reward = Reward.postcards
      |> Reward.lens.shipping.enabled .~ true

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ GraphUserCreditCard.amex
          |> Backing.lens.status .~ .pledged
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.amount .~ 700
      )

    let mockService = MockService(
      updateBackingResult: .failure(.invalidInput)
    )

    withEnvironment(apiService: mockService, currentUser: .template) {
      self.vm.inputs.configureWith(project: project, reward: reward, refTag: nil, context: .update)
      self.vm.inputs.viewDidLoad()

      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.updatePledgeFailedWithError.assertDidNotEmitValue()
      self.submitButtonEnabled.assertValues([false])

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(
        with: (amount: 25.0, min: 25.0, max: 10_000.0, isValid: true)
      )

      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.updatePledgeFailedWithError.assertDidNotEmitValue()
      self.submitButtonEnabled.assertValues([false, true])

      self.vm.inputs.shippingRuleSelected(.template)

      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.updatePledgeFailedWithError.assertDidNotEmitValue()
      self.submitButtonEnabled.assertValues([false, true, true])

      self.vm.inputs.submitButtonTapped()

      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.updatePledgeFailedWithError.assertDidNotEmitValue()
      self.submitButtonEnabled.assertValues([false, true, true, false])

      self.scheduler.run()

      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.updatePledgeFailedWithError.assertValueCount(1)
      self.submitButtonEnabled.assertValues([false, true, true, false, true])
    }
  }

  func testUpdatingSubmitButtonEnabled_ShippingEnabled() {
    let reward = Reward.postcards
      |> Reward.lens.shipping.enabled .~ true

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ GraphUserCreditCard.amex
          |> Backing.lens.status .~ .pledged
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.amount .~ 700
      )

    self.submitButtonTitle.assertDidNotEmitValue()
    self.submitButtonEnabled.assertDidNotEmitValue()

    self.vm.inputs.configureWith(project: project, reward: reward, refTag: nil, context: .update)
    self.vm.inputs.viewDidLoad()

    self.submitButtonTitle.assertValues(["Confirm"])
    self.submitButtonEnabled.assertValues([false])

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(
      with: (amount: 690, min: 25.0, max: 10_000.0, isValid: true)
    )

    self.submitButtonEnabled.assertValues([false, false], "Amount unchanged")

    self.vm.inputs.shippingRuleSelected(.init(cost: 1, id: 1, location: .brooklyn))

    self.submitButtonEnabled.assertValues([false, false, false], "Shipping rule and amount unchanged")

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(
      with: (amount: 690, min: 25.0, max: 10_000.0, isValid: true)
    )

    self.submitButtonEnabled.assertValues([false, false, false, false], "Amount unchanged")

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(
      with: (amount: 550, min: 25.0, max: 10_000.0, isValid: true)
    )

    self.submitButtonEnabled.assertValues([false, false, false, false, true], "Amount changed")

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(
      with: (amount: 690, min: 25.0, max: 10_000.0, isValid: true)
    )

    self.submitButtonEnabled.assertValues([false, false, false, false, true, false], "Amount unchanged")

    self.vm.inputs.shippingRuleSelected(.template)

    self.submitButtonEnabled.assertValues(
      [false, false, false, false, true, false, true], "Shipping rule changed"
    )

    self.vm.inputs.shippingRuleSelected(.init(cost: 1, id: 1, location: .brooklyn))

    self.submitButtonEnabled.assertValues(
      [false, false, false, false, true, false, true, false], "Amount and shipping rule unchanged"
    )
  }

  func testUpdatingSubmitButtonEnabled_NoShipping() {
    let reward = Reward.postcards
      |> Reward.lens.shipping.enabled .~ false

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ GraphUserCreditCard.amex
          |> Backing.lens.status .~ .pledged
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.shippingAmount .~ nil
          |> Backing.lens.amount .~ 700
      )

    self.submitButtonTitle.assertDidNotEmitValue()
    self.submitButtonEnabled.assertDidNotEmitValue()

    self.vm.inputs.configureWith(project: project, reward: reward, refTag: nil, context: .update)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(
      with: (amount: 700, min: 25.0, max: 10_000.0, isValid: true)
    )

    self.submitButtonTitle.assertValues(["Confirm"])
    self.submitButtonEnabled.assertValues([false, false], "Amount unchanged")

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(
      with: (amount: 550, min: 25.0, max: 10_000.0, isValid: true)
    )

    self.submitButtonEnabled.assertValues([false, false, true], "Amount changed")

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(
      with: (amount: 700, min: 25.0, max: 10_000.0, isValid: true)
    )

    self.submitButtonEnabled.assertValues([false, false, true, false], "Amount unchanged")
  }

  func testUpdatingRewardSubmitButtonEnabled_ShippingEnabled() {
    let reward = Reward.postcards
      |> Reward.lens.shipping.enabled .~ true

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ GraphUserCreditCard.amex
          |> Backing.lens.status .~ .pledged
          |> Backing.lens.reward .~ Reward.otherReward
          |> Backing.lens.rewardId .~ Reward.otherReward.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.amount .~ 700
      )

    self.submitButtonTitle.assertDidNotEmitValue()
    self.submitButtonEnabled.assertDidNotEmitValue()

    self.vm.inputs.configureWith(project: project, reward: reward, refTag: nil, context: .updateReward)
    self.vm.inputs.viewDidLoad()

    self.submitButtonTitle.assertValues(["Confirm"])
    self.submitButtonEnabled.assertValues([false])

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(
      with: (amount: 690, min: 25.0, max: 10_000.0, isValid: true)
    )

    self.submitButtonEnabled.assertValues([false, false], "Amount unchanged")

    self.vm.inputs.shippingRuleSelected(.init(cost: 1, id: 1, location: .brooklyn))

    self.submitButtonEnabled.assertValues(
      [false, false, true], "Shipping rule and amount unchanged, button enabled due to different reward"
    )
  }

  func testChangingPaymentMethodSubmitButtonEnabled_ShippingEnabled() {
    let reward = Reward.postcards
      |> Reward.lens.shipping.enabled .~ true

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ GraphUserCreditCard.amex
          |> Backing.lens.status .~ .pledged
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.amount .~ 700
      )

    self.submitButtonTitle.assertDidNotEmitValue()
    self.submitButtonEnabled.assertDidNotEmitValue()

    self.vm.inputs.configureWith(project: project, reward: reward, refTag: nil, context: .update)
    self.vm.inputs.viewDidLoad()

    self.submitButtonTitle.assertValues(["Confirm"])
    self.submitButtonEnabled.assertValues([false])

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(
      with: (amount: 690, min: 25.0, max: 10_000.0, isValid: true)
    )

    self.submitButtonEnabled.assertValues([false, false], "Amount unchanged")

    self.vm.inputs.shippingRuleSelected(.init(cost: 1, id: 1, location: .brooklyn))

    self.submitButtonEnabled.assertValues([false, false, false], "Shipping rule and amount unchanged")

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(
      with: (amount: 690, min: 25.0, max: 10_000.0, isValid: true)
    )

    self.submitButtonEnabled.assertValues([false, false, false, false], "Amount unchanged")

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(
      with: (amount: 550, min: 25.0, max: 10_000.0, isValid: true)
    )

    self.submitButtonEnabled.assertValues([false, false, false, false, true], "Amount changed")

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(
      with: (amount: 690, min: 25.0, max: 10_000.0, isValid: true)
    )

    self.submitButtonEnabled.assertValues([false, false, false, false, true, false], "Amount unchanged")

    self.vm.inputs.shippingRuleSelected(.template)

    self.submitButtonEnabled.assertValues(
      [false, false, false, false, true, false, true], "Shipping rule changed"
    )

    self.vm.inputs.shippingRuleSelected(.init(cost: 1, id: 1, location: .brooklyn))

    self.submitButtonEnabled.assertValues(
      [false, false, false, false, true, false, true, false], "Amount and shipping rule unchanged"
    )

    self.vm.inputs.creditCardSelected(with: "12345")

    self.submitButtonEnabled.assertValues(
      [false, false, false, false, true, false, true, false, true],
      "Payment method changed"
    )

    #warning("This fixes tests for now, remove once we've fixed the issue with GraphUserCreditCard ID")
    self.vm.inputs.creditCardSelected(
      with: Data("Card-\(GraphUserCreditCard.amex.id)".utf8).base64EncodedString()
    )

    self.submitButtonEnabled.assertValues(
      [false, false, false, false, true, false, true, false, true, false],
      "Payment method unchanged"
    )
  }

  func testUpdateApplePayBacking_Success() {
    let updateBackingEnvelope = UpdateBackingEnvelope(
      updateBacking: .init(
        checkout: .init(
          state: .successful,
          backing: .init(
            requiresAction: false,
            clientSecret: "client-secret"
          )
        )
      )
    )

    let mockService = MockService(
      updateBackingResult: .success(updateBackingEnvelope)
    )

    self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationPledgeAmount.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationShippingRule.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

    self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
    self.updatePledgeFailedWithError.assertDidNotEmitValue()
    self.submitButtonEnabled.assertDidNotEmitValue()
    self.createBackingError.assertDidNotEmitValue()
    self.goToThanks.assertDidNotEmitValue()

    withEnvironment(apiService: mockService) {
      let reward = Reward.postcards
        |> Reward.lens.shipping.enabled .~ true

      let project = Project.cosmicSurgery
        |> Project.lens.state .~ .live
        |> Project.lens.personalization.isBacking .~ true
        |> Project.lens.personalization.backing .~ (
          .template
            |> Backing.lens.paymentSource .~ GraphUserCreditCard.amex
            |> Backing.lens.status .~ .pledged
            |> Backing.lens.reward .~ reward
            |> Backing.lens.rewardId .~ reward.id
            |> Backing.lens.shippingAmount .~ 10
            |> Backing.lens.amount .~ 700
        )

      self.vm.inputs.configureWith(
        project: project, reward: reward, refTag: .projectPage, context: .changePaymentMethod
      )
      self.vm.inputs.viewDidLoad()

      let pledgeAmountData = (amount: 99.0, min: 5.0, max: 10_000.0, isValid: true)
      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: pledgeAmountData)

      self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationPledgeAmount.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationShippingRule.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.updatePledgeFailedWithError.assertDidNotEmitValue()
      self.submitButtonEnabled.assertValues([false])
      self.createBackingError.assertDidNotEmitValue()
      self.goToThanks.assertDidNotEmitValue()

      self.vm.inputs.applePayButtonTapped()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingRule.assertValues([nil])
      self.goToApplePayPaymentAuthorizationPledgeAmount.assertValues([99])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.updatePledgeFailedWithError.assertDidNotEmitValue()
      self.submitButtonEnabled.assertValues([false])
      self.createBackingError.assertDidNotEmitValue()
      self.goToThanks.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
        paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345")
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingRule.assertValues([nil])
      self.goToApplePayPaymentAuthorizationPledgeAmount.assertValues([99])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.updatePledgeFailedWithError.assertDidNotEmitValue()
      self.submitButtonEnabled.assertValues([false])
      self.createBackingError.assertDidNotEmitValue()
      self.goToThanks.assertDidNotEmitValue()

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.success,
        self.vm.inputs.stripeTokenCreated(token: "stripe_token", error: nil)
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingRule.assertValues([nil])
      self.goToApplePayPaymentAuthorizationPledgeAmount.assertValues([99])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.updatePledgeFailedWithError.assertDidNotEmitValue()
      self.submitButtonEnabled.assertValues([false])
      self.createBackingError.assertDidNotEmitValue()
      self.goToThanks.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingRule.assertValues([nil])
      self.goToApplePayPaymentAuthorizationPledgeAmount.assertValues([99])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.updatePledgeFailedWithError.assertDidNotEmitValue()
      self.submitButtonEnabled.assertValues([false])
      self.createBackingError.assertDidNotEmitValue()
      self.goToThanks.assertDidNotEmitValue()

      self.scheduler.run()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingRule.assertValues([nil])
      self.goToApplePayPaymentAuthorizationPledgeAmount.assertValues([99])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertValues([
        "Got it! Your changes have been saved."
      ])
      self.updatePledgeFailedWithError.assertDidNotEmitValue()
      self.submitButtonEnabled.assertValues([false, true])
      self.createBackingError.assertDidNotEmitValue()
      self.goToThanks.assertDidNotEmitValue()
    }
  }

  func testUpdateApplePayBacking_StripeTokenFailure() {
    let updateBackingEnvelope = UpdateBackingEnvelope(
      updateBacking: .init(
        checkout: .init(
          state: .successful,
          backing: .init(
            requiresAction: false,
            clientSecret: "client-secret"
          )
        )
      )
    )

    let mockService = MockService(
      updateBackingResult: .success(updateBackingEnvelope)
    )

    self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationPledgeAmount.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationShippingRule.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

    self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
    self.updatePledgeFailedWithError.assertDidNotEmitValue()
    self.submitButtonEnabled.assertDidNotEmitValue()
    self.createBackingError.assertDidNotEmitValue()
    self.goToThanks.assertDidNotEmitValue()

    withEnvironment(apiService: mockService) {
      let reward = Reward.postcards
        |> Reward.lens.shipping.enabled .~ true

      let project = Project.cosmicSurgery
        |> Project.lens.state .~ .live
        |> Project.lens.personalization.isBacking .~ true
        |> Project.lens.personalization.backing .~ (
          .template
            |> Backing.lens.paymentSource .~ GraphUserCreditCard.amex
            |> Backing.lens.status .~ .pledged
            |> Backing.lens.reward .~ reward
            |> Backing.lens.rewardId .~ reward.id
            |> Backing.lens.shippingAmount .~ 10
            |> Backing.lens.amount .~ 700
        )

      self.vm.inputs.configureWith(
        project: project, reward: reward, refTag: .projectPage, context: .changePaymentMethod
      )
      self.vm.inputs.viewDidLoad()

      let pledgeAmountData = (amount: 99.0, min: 5.0, max: 10_000.0, isValid: true)
      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: pledgeAmountData)

      self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationPledgeAmount.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationShippingRule.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.updatePledgeFailedWithError.assertDidNotEmitValue()
      self.submitButtonEnabled.assertValues([false])
      self.createBackingError.assertDidNotEmitValue()
      self.goToThanks.assertDidNotEmitValue()

      self.vm.inputs.applePayButtonTapped()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingRule.assertValues([nil])
      self.goToApplePayPaymentAuthorizationPledgeAmount.assertValues([99])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.updatePledgeFailedWithError.assertDidNotEmitValue()
      self.submitButtonEnabled.assertValues([false])
      self.createBackingError.assertDidNotEmitValue()
      self.goToThanks.assertDidNotEmitValue()

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.failure,
        self.vm.inputs.stripeTokenCreated(token: nil, error: GraphError.invalidInput)
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingRule.assertValues([nil])
      self.goToApplePayPaymentAuthorizationPledgeAmount.assertValues([99])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.updatePledgeFailedWithError.assertDidNotEmitValue()
      self.submitButtonEnabled.assertValues([false])
      self.createBackingError.assertDidNotEmitValue()
      self.goToThanks.assertDidNotEmitValue()

      self.scheduler.run()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingRule.assertValues([nil])
      self.goToApplePayPaymentAuthorizationPledgeAmount.assertValues([99])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.updatePledgeFailedWithError.assertDidNotEmitValue()
      self.submitButtonEnabled.assertValues([false])
      self.createBackingError.assertDidNotEmitValue()
      self.goToThanks.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingRule.assertValues([nil])
      self.goToApplePayPaymentAuthorizationPledgeAmount.assertValues([99])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.updatePledgeFailedWithError.assertDidNotEmitValue()
      self.submitButtonEnabled.assertValues([false])
      self.createBackingError.assertDidNotEmitValue()
      self.goToThanks.assertDidNotEmitValue()
    }
  }

  func testUpdateApplePayBacking_Failure() {
    let mockService = MockService(
      updateBackingResult: .failure(.invalidInput)
    )

    self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
    self.updatePledgeFailedWithError.assertDidNotEmitValue()
    self.submitButtonEnabled.assertDidNotEmitValue()
    self.createBackingError.assertDidNotEmitValue()
    self.goToThanks.assertDidNotEmitValue()

    withEnvironment(apiService: mockService) {
      let reward = Reward.postcards
        |> Reward.lens.shipping.enabled .~ true

      let project = Project.cosmicSurgery
        |> Project.lens.state .~ .live
        |> Project.lens.personalization.isBacking .~ true
        |> Project.lens.personalization.backing .~ (
          .template
            |> Backing.lens.paymentSource .~ GraphUserCreditCard.amex
            |> Backing.lens.status .~ .pledged
            |> Backing.lens.reward .~ reward
            |> Backing.lens.rewardId .~ reward.id
            |> Backing.lens.shippingAmount .~ 10
            |> Backing.lens.amount .~ 700
        )

      self.vm.inputs.configureWith(
        project: project, reward: reward, refTag: .projectPage, context: .changePaymentMethod
      )
      self.vm.inputs.viewDidLoad()

      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.updatePledgeFailedWithError.assertDidNotEmitValue()
      self.submitButtonEnabled.assertValues([false])
      self.createBackingError.assertDidNotEmitValue()
      self.goToThanks.assertDidNotEmitValue()

      self.vm.inputs.applePayButtonTapped()

      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.updatePledgeFailedWithError.assertDidNotEmitValue()
      self.submitButtonEnabled.assertValues([false])
      self.createBackingError.assertDidNotEmitValue()
      self.goToThanks.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
        paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345")
      )

      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.updatePledgeFailedWithError.assertDidNotEmitValue()
      self.submitButtonEnabled.assertValues([false])
      self.createBackingError.assertDidNotEmitValue()
      self.goToThanks.assertDidNotEmitValue()

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.success,
        self.vm.inputs.stripeTokenCreated(token: "stripe_token", error: nil)
      )

      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.updatePledgeFailedWithError.assertDidNotEmitValue()
      self.submitButtonEnabled.assertValues([false])
      self.createBackingError.assertDidNotEmitValue()
      self.goToThanks.assertDidNotEmitValue()

      self.scheduler.run()

      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.updatePledgeFailedWithError.assertDidNotEmitValue()
      self.submitButtonEnabled.assertValues([false, true])
      self.createBackingError.assertDidNotEmitValue()
      self.goToThanks.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.updatePledgeFailedWithError.assertValues([
        "Something went wrong."
      ])
      self.submitButtonEnabled.assertValues([false, true])
      self.createBackingError.assertDidNotEmitValue()
      self.goToThanks.assertDidNotEmitValue()
    }
  }
}
