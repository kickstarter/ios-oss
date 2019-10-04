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

  private let confirmButtonEnabled = TestObserver<Bool, Never>()
  private let confirmButtonHidden = TestObserver<Bool, Never>()
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

  private let notifyDelegateUpdatePledgeDidSucceed = TestObserver<(), Never>()

  private let paymentMethodsViewHidden = TestObserver<Bool, Never>()
  private let sectionSeparatorsHidden = TestObserver<Bool, Never>()
  private let shippingLocationViewHidden = TestObserver<Bool, Never>()
  private let showApplePayAlertMessage = TestObserver<String, Never>()
  private let showApplePayAlertTitle = TestObserver<String, Never>()
  private let title = TestObserver<String, Never>()
  private let updatePledgeButtonEnabled = TestObserver<Bool, Never>()
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

    self.vm.outputs.confirmButtonEnabled.observe(self.confirmButtonEnabled.observer)
    self.vm.outputs.confirmButtonHidden.observe(self.confirmButtonHidden.observer)
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

    self.vm.outputs.notifyDelegateUpdatePledgeDidSucceed
      .observe(self.notifyDelegateUpdatePledgeDidSucceed.observer)

    self.vm.outputs.paymentMethodsViewHidden.observe(self.paymentMethodsViewHidden.observer)

    self.vm.outputs.updatePledgeButtonEnabled.observe(self.updatePledgeButtonEnabled.observer)
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

      self.confirmButtonHidden.assertValues([true])
      self.confirmationLabelHidden.assertValues([true])

      self.descriptionViewHidden.assertValues([false])

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.continueViewHidden.assertValues([true])
      self.paymentMethodsViewHidden.assertValues([false])
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

      self.confirmButtonHidden.assertValues([true])
      self.confirmationLabelHidden.assertValues([true])

      self.descriptionViewHidden.assertValues([false])

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.continueViewHidden.assertValues([false])
      self.paymentMethodsViewHidden.assertValues([true])
      self.sectionSeparatorsHidden.assertValues([false])
      self.shippingLocationViewHidden.assertValues([false])
      self.configureSummaryCellWithDataPledgeTotal.assertValues([reward.minimum])
      self.configureSummaryCellWithDataProject.assertValues([project])
    }
  }

  func testUpdateContext_LoggedIn() {
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

      self.confirmButtonHidden.assertValues([false])
      self.confirmationLabelHidden.assertValues([false])

      self.descriptionViewHidden.assertValues([true])

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.continueViewHidden.assertValues([true])
      self.paymentMethodsViewHidden.assertValues([true])
      self.sectionSeparatorsHidden.assertValues([true])
      self.shippingLocationViewHidden.assertValues([false])
      self.configureSummaryCellWithDataPledgeTotal.assertValues([reward.minimum])
      self.configureSummaryCellWithDataProject.assertValues([project])
    }
  }

  func testUpdateContext_LoggedOut() {
    let mockService = MockService(serverConfig: ServerConfig.staging)

    withEnvironment(apiService: mockService, currentUser: nil) {
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

      self.confirmButtonHidden.assertValues([false])
      self.confirmationLabelHidden.assertValues([false])

      self.descriptionViewHidden.assertValues([true])

      self.configureWithPledgeViewDataProject.assertValues([project])
      self.configureWithPledgeViewDataReward.assertValues([reward])

      self.continueViewHidden.assertValues([true])
      self.paymentMethodsViewHidden.assertValues([true])
      self.sectionSeparatorsHidden.assertValues([true])
      self.shippingLocationViewHidden.assertValues([false])
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

      self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage, context: .pledge)
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
      self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage, context: .pledge)
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
      self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage, context: .pledge)
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
      self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage, context: .pledge)
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
      self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage, context: .pledge)
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
      self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage, context: .pledge)
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
      self.vm.inputs.configureWith(project: project, reward: reward, refTag: .projectPage, context: .pledge)
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

      self.scheduler.run()

      self.goToThanks.assertDidNotEmitValue("Signal waits for Apple Pay sheet to dismiss")
      self.createBackingError.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

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

      self.scheduler.run()

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

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

  func testPledgeButtonEnabled() {
    withEnvironment(currentUser: .template) {
      self.vm.inputs.configureWith(project: .template, reward: .template, refTag: nil, context: .pledge)
      self.vm.inputs.viewDidLoad()
      self.updatePledgeButtonEnabled.assertDidNotEmitValue()

      let data1 = (amount: 25.0, min: 10.0, max: 10_000.0, isValid: true)

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: data1)
      self.updatePledgeButtonEnabled.assertDidNotEmitValue()

      self.vm.inputs.creditCardSelected(with: "123")
      self.updatePledgeButtonEnabled.assertValues([true])

      let data2 = (amount: 5.0, min: 10.0, max: 10_000.0, isValid: false)

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: data2)
      self.updatePledgeButtonEnabled.assertValues([true, false])
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

      self.updatePledgeButtonEnabled.assertDidNotEmitValue()
      self.goToThanks.assertDidNotEmitValue()
      self.createBackingError.assertDidNotEmitValue()

      self.vm.inputs.creditCardSelected(with: "123")
      self.vm.inputs.pledgeAmountViewControllerDidUpdate(
        with: (amount: 25.0, min: 10.0, max: 10_000.0, isValid: true)
      )

      self.updatePledgeButtonEnabled.assertValues([true])

      self.vm.inputs.pledgeButtonTapped()

      self.goToThanks.assertDidNotEmitValue()
      self.createBackingError.assertDidNotEmitValue()

      self.scheduler.run()

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

      self.updatePledgeButtonEnabled.assertDidNotEmitValue()
      self.goToThanks.assertDidNotEmitValue()
      self.createBackingError.assertDidNotEmitValue()

      self.vm.inputs.creditCardSelected(with: "123")
      self.vm.inputs.pledgeAmountViewControllerDidUpdate(
        with: (amount: 25.0, min: 10.0, max: 10_000.0, isValid: true)
      )

      self.updatePledgeButtonEnabled.assertValues([true])

      self.vm.inputs.pledgeButtonTapped()

      self.goToThanks.assertDidNotEmitValue()
      self.createBackingError.assertDidNotEmitValue()

      self.scheduler.run()

      self.goToThanks.assertDidNotEmitValue()
      self.createBackingError.assertValues(["Something went wrong."])
    }
  }

  func testUpdateBacking_Success() {
    let reward = Reward.postcards

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ GraphUserCreditCard.amex
          |> Backing.lens.status .~ .errored
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

      self.notifyDelegateUpdatePledgeDidSucceed.assertDidNotEmitValue()
      self.updatePledgeFailedWithError.assertDidNotEmitValue()
      self.confirmButtonEnabled.assertDidNotEmitValue()

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(
        with: (amount: 10.0, min: 25.0, max: 10_000.0, isValid: true)
      )

      self.notifyDelegateUpdatePledgeDidSucceed.assertDidNotEmitValue()
      self.updatePledgeFailedWithError.assertDidNotEmitValue()
      self.confirmButtonEnabled.assertValues([true])

      self.vm.inputs.confirmButtonTapped()

      self.notifyDelegateUpdatePledgeDidSucceed.assertDidNotEmitValue()
      self.updatePledgeFailedWithError.assertDidNotEmitValue()
      self.confirmButtonEnabled.assertValues([true, false])

      self.scheduler.run()

      self.notifyDelegateUpdatePledgeDidSucceed.assertValueCount(1)
      self.updatePledgeFailedWithError.assertDidNotEmitValue()
      self.confirmButtonEnabled.assertValues([true, false, true])
    }
  }

  func testUpdateBacking_Failure() {
    let reward = Reward.postcards

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ GraphUserCreditCard.amex
          |> Backing.lens.status .~ .errored
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

      self.notifyDelegateUpdatePledgeDidSucceed.assertDidNotEmitValue()
      self.updatePledgeFailedWithError.assertDidNotEmitValue()
      self.confirmButtonEnabled.assertDidNotEmitValue()

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(
        with: (amount: 10.0, min: 25.0, max: 10_000.0, isValid: true)
      )

      self.notifyDelegateUpdatePledgeDidSucceed.assertDidNotEmitValue()
      self.updatePledgeFailedWithError.assertDidNotEmitValue()
      self.confirmButtonEnabled.assertValues([true])

      self.vm.inputs.confirmButtonTapped()

      self.notifyDelegateUpdatePledgeDidSucceed.assertDidNotEmitValue()
      self.updatePledgeFailedWithError.assertDidNotEmitValue()
      self.confirmButtonEnabled.assertValues([true, false])

      self.scheduler.run()

      self.notifyDelegateUpdatePledgeDidSucceed.assertDidNotEmitValue()
      self.updatePledgeFailedWithError.assertValueCount(1)
      self.confirmButtonEnabled.assertValues([true, false, true])
    }
  }

  func testConfirmButtonEnabled() {
    let reward = Reward.postcards

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ GraphUserCreditCard.amex
          |> Backing.lens.status .~ .errored
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.amount .~ 700
      )

    self.confirmButtonHidden.assertDidNotEmitValue()
    self.confirmButtonEnabled.assertDidNotEmitValue()

    self.vm.inputs.configureWith(project: project, reward: reward, refTag: nil, context: .update)
    self.vm.inputs.viewDidLoad()

    self.confirmButtonHidden.assertValues([false])
    self.confirmButtonEnabled.assertDidNotEmitValue()

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(
      with: (amount: 690, min: 25.0, max: 10_000.0, isValid: true)
    )

    self.confirmButtonHidden.assertValues([false])
    self.confirmButtonEnabled.assertValues([false])

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(
      with: (amount: 550, min: 25.0, max: 10_000.0, isValid: true)
    )

    self.confirmButtonHidden.assertValues([false])
    self.confirmButtonEnabled.assertValues([false, true])

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(
      with: (amount: 690, min: 25.0, max: 10_000.0, isValid: true)
    )

    self.confirmButtonHidden.assertValues([false])
    self.confirmButtonEnabled.assertValues([false, true, false])

    self.vm.inputs.shippingRuleSelected(.template)

    self.confirmButtonHidden.assertValues([false])
    self.confirmButtonEnabled.assertValues([false, true, false, true])

    self.vm.inputs.shippingRuleSelected(.init(cost: 1, id: 1, location: .brooklyn))

    self.confirmButtonHidden.assertValues([false])
    self.confirmButtonEnabled.assertValues([false, true, false, true, false])
  }
}
