import Foundation
@testable import KsApi
@testable import Library
import PassKit
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

private struct MockStripePaymentHandlerActionStatus: StripePaymentHandlerActionStatusType {
  let status: StripePaymentHandlerActionStatus
}

final class NoShippingPledgeViewModelTests: TestCase {
  private let vm: NoShippingPledgeViewModelType = NoShippingPledgeViewModel()

  private let beginSCAFlowWithClientSecret = TestObserver<String, Never>()

  private let configureLocalPickupViewWithData = TestObserver<PledgeLocalPickupViewData, Never>()
  private let configurePaymentMethodsViewControllerWithUser = TestObserver<User, Never>()
  private let configurePaymentMethodsViewControllerWithProject = TestObserver<Project, Never>()
  private let configurePaymentMethodsViewControllerWithCheckoutId = TestObserver<String, Never>()
  private let configurePaymentMethodsViewControllerWithReward = TestObserver<Reward, Never>()
  private let configurePaymentMethodsViewControllerWithContext = TestObserver<PledgeViewContext, Never>()

  private let configurePledgeRewardsSummaryViewRewards = TestObserver<[Reward], Never>()
  private let configurePledgeRewardsSummaryViewSelectedQuantities
    = TestObserver<SelectedRewardQuantities, Never>()
  private let configurePledgeRewardsSummaryViewProjectCurrencyCountry = TestObserver<
    Project.Country,
    Never
  >()
  private let configurePledgeRewardsSummaryViewOmitCurrencyCode = TestObserver<Bool, Never>()
  private let configurePledgeRewardsSummaryViewShipping = TestObserver<
    PledgeShippingSummaryViewData?,
    Never
  >()

  private let configurePledgeViewCTAContainerViewIsLoggedIn = TestObserver<Bool, Never>()
  private let configurePledgeViewCTAContainerViewIsEnabled = TestObserver<Bool, Never>()
  private let configurePledgeViewCTAContainerViewContext = TestObserver<PledgeViewContext, Never>()
  private let configurePledgeViewCTAContainerViewWillRetryPaymentMethod = TestObserver<Bool, Never>()

  private let configureStripeIntegrationMerchantId = TestObserver<String, Never>()
  private let configureStripeIntegrationPublishableKey = TestObserver<String, Never>()

  private let goToApplePayPaymentAuthorizationProject = TestObserver<Project, Never>()
  private let goToApplePayPaymentAuthorizationReward = TestObserver<Reward, Never>()
  private let goToApplePayPaymentAuthorizationAllRewardsTotal = TestObserver<Double, Never>()
  private let goToApplePayPaymentAuthorizationAdditionalPledgeAmount = TestObserver<Double, Never>()
  private let goToApplePayPaymentAuthorizationAllRewardsShippingTotal = TestObserver<Double, Never>()
  private let goToApplePayPaymentAuthorizationMerchantId = TestObserver<String, Never>()
  private let goToThanksCheckoutData = TestObserver<KSRAnalytics.CheckoutPropertiesData?, Never>()
  private let goToThanksProject = TestObserver<Project, Never>()
  private let goToThanksReward = TestObserver<Reward, Never>()
  private let localPickupViewHidden = TestObserver<Bool, Never>()
  private let notifyDelegateUpdatePledgeDidSucceedWithMessage = TestObserver<String, Never>()

  private let paymentMethodsViewHidden = TestObserver<Bool, Never>()
  private let pledgeAmountSummaryViewHidden = TestObserver<Bool, Never>()
  private let popToRootViewController = TestObserver<(), Never>()
  private let processingViewIsHidden = TestObserver<Bool, Never>()
  private let showErrorBannerWithMessage = TestObserver<String, Never>()
  private let showWebHelp = TestObserver<HelpType, Never>()
  private let title = TestObserver<String, Never>()
  private let showPledgeOverTimeUI = TestObserver<Bool, Never>()
  private let plotSelectedPlan = TestObserver<PledgePaymentPlansType, Never>()
  private let pledgeOverTimeConfigData = TestObserver<PledgePaymentPlansAndSelectionData, Never>()

  let shippingRule = ShippingRule.template
    |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 55)

  override func setUp() {
    super.setUp()

    self.vm.outputs.beginSCAFlowWithClientSecret.observe(self.beginSCAFlowWithClientSecret.observer)

    self.vm.outputs.configureLocalPickupViewWithData.observe(self.configureLocalPickupViewWithData.observer)
    self.vm.outputs.configurePaymentMethodsViewControllerWithValue.map { $0.0 }
      .observe(self.configurePaymentMethodsViewControllerWithUser.observer)
    self.vm.outputs.configurePaymentMethodsViewControllerWithValue.map { $0.1 }
      .observe(self.configurePaymentMethodsViewControllerWithProject.observer)
    self.vm.outputs.configurePaymentMethodsViewControllerWithValue.map { $0.2 }
      .observe(self.configurePaymentMethodsViewControllerWithCheckoutId.observer)
    self.vm.outputs.configurePaymentMethodsViewControllerWithValue.map { $0.3 }
      .observe(self.configurePaymentMethodsViewControllerWithReward.observer)
    self.vm.outputs.configurePaymentMethodsViewControllerWithValue.map { $0.4 }
      .observe(self.configurePaymentMethodsViewControllerWithContext.observer)

    self.vm.outputs.configurePledgeRewardsSummaryViewWithData.map(\.0.rewards)
      .observe(self.configurePledgeRewardsSummaryViewRewards.observer)
    self.vm.outputs.configurePledgeRewardsSummaryViewWithData.map(\.0.selectedQuantities)
      .observe(self.configurePledgeRewardsSummaryViewSelectedQuantities.observer)
    self.vm.outputs.configurePledgeRewardsSummaryViewWithData.map(\.0.projectCountry)
      .observe(self.configurePledgeRewardsSummaryViewProjectCurrencyCountry.observer)
    self.vm.outputs.configurePledgeRewardsSummaryViewWithData.map(\.0.omitCurrencyCode)
      .observe(self.configurePledgeRewardsSummaryViewOmitCurrencyCode.observer)
    self.vm.outputs.configurePledgeRewardsSummaryViewWithData.map(\.0.shipping)
      .observe(self.configurePledgeRewardsSummaryViewShipping.observer)

    self.vm.outputs.configurePledgeViewCTAContainerView.map { $0.2 }
      .observe(self.configurePledgeViewCTAContainerViewIsLoggedIn.observer)
    self.vm.outputs.configurePledgeViewCTAContainerView.map { $0.3 }
      .observe(self.configurePledgeViewCTAContainerViewIsEnabled.observer)
    self.vm.outputs.configurePledgeViewCTAContainerView.map { $0.4 }
      .observe(self.configurePledgeViewCTAContainerViewContext.observer)
    self.vm.outputs.configurePledgeViewCTAContainerView.map { $0.5 }
      .observe(self.configurePledgeViewCTAContainerViewWillRetryPaymentMethod.observer)

    self.vm.outputs.configureStripeIntegration.map(first)
      .observe(self.configureStripeIntegrationMerchantId.observer)
    self.vm.outputs.configureStripeIntegration.map(second)
      .observe(self.configureStripeIntegrationPublishableKey.observer)

    self.vm.outputs.goToApplePayPaymentAuthorization.map { $0.project }
      .observe(self.goToApplePayPaymentAuthorizationProject.observer)
    self.vm.outputs.goToApplePayPaymentAuthorization.map { $0.reward }
      .observe(self.goToApplePayPaymentAuthorizationReward.observer)
    self.vm.outputs.goToApplePayPaymentAuthorization.map { $0.allRewardsTotal }
      .observe(self.goToApplePayPaymentAuthorizationAllRewardsTotal.observer)
    self.vm.outputs.goToApplePayPaymentAuthorization.map { $0.additionalPledgeAmount }
      .observe(self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.observer)
    self.vm.outputs.goToApplePayPaymentAuthorization.map { $0.allRewardsShippingTotal }
      .observe(self.goToApplePayPaymentAuthorizationAllRewardsShippingTotal.observer)
    self.vm.outputs.goToApplePayPaymentAuthorization.map { $0.merchantIdentifier }
      .observe(self.goToApplePayPaymentAuthorizationMerchantId.observer)

    self.vm.outputs.goToThanks.map { $0.project }.observe(self.goToThanksProject.observer)
    self.vm.outputs.goToThanks.map { $0.reward }.observe(self.goToThanksReward.observer)
    self.vm.outputs.goToThanks.map { $0.checkoutData }.observe(self.goToThanksCheckoutData.observer)
    self.vm.outputs.localPickupViewHidden.observe(self.localPickupViewHidden.observer)

    self.vm.outputs.notifyDelegateUpdatePledgeDidSucceedWithMessage
      .observe(self.notifyDelegateUpdatePledgeDidSucceedWithMessage.observer)

    self.vm.outputs.paymentMethodsViewHidden.observe(self.paymentMethodsViewHidden.observer)
    self.vm.outputs.pledgeAmountSummaryViewHidden.observe(self.pledgeAmountSummaryViewHidden.observer)
    self.vm.outputs.popToRootViewController.observe(self.popToRootViewController.observer)
    self.vm.outputs.processingViewIsHidden.observe(self.processingViewIsHidden.observer)

    self.vm.outputs.showWebHelp.observe(self.showWebHelp.observer)
    self.vm.outputs.showErrorBannerWithMessage.observe(self.showErrorBannerWithMessage.observer)

    self.vm.outputs.title.observe(self.title.observer)

    self.vm.outputs.showPledgeOverTimeUI.observe(self.showPledgeOverTimeUI.observer)

    self.vm.outputs.pledgeOverTimeConfigData
      .skipNil()
      .map { $0.selectedPlan }
      .observe(self.plotSelectedPlan.observer)

    self.vm.outputs.pledgeOverTimeConfigData
      .skipNil()
      .observe(self.pledgeOverTimeConfigData.observer)
  }

  func testShowWebHelp() {
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.termsOfUseTapped(with: .terms)

    self.showWebHelp.assertValues([HelpType.terms])
  }

  func testShowWebHelpLearnMore() {
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.pledgeDisclaimerViewDidTapLearnMore()

    self.showWebHelp.assertValues([HelpType.trust])
  }

  func testPledgeContext_LoggedIn() {
    let mockService = MockService(serverConfig: ServerConfig.staging)

    withEnvironment(apiService: mockService, currentUser: .template) {
      let project = Project.template
      let reward = Reward.template
        |> Reward.lens.shipping.enabled .~ true

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.title.assertValues(["Back this project"])

      self.configurePledgeRewardsSummaryViewRewards.assertValues([[reward]])
      self.configurePledgeRewardsSummaryViewProjectCurrencyCountry.assertValues([.us])
      self.configurePledgeRewardsSummaryViewOmitCurrencyCode.assertLastValue(true)

      self.configurePaymentMethodsViewControllerWithUser.assertValues([User.template])
      self.configurePaymentMethodsViewControllerWithProject.assertValues([project])
      self.configurePaymentMethodsViewControllerWithReward.assertValues([reward])
      self.configurePaymentMethodsViewControllerWithContext.assertValues([.pledge])

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertLastValue(true)
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.configurePledgeViewCTAContainerViewContext.assertValues([.pledge])

      self.configureStripeIntegrationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])
      self.configureStripeIntegrationPublishableKey.assertValues([Secrets.StripePublishableKey.staging])

      self.paymentMethodsViewHidden.assertLastValue(false)
      self.pledgeAmountSummaryViewHidden.assertLastValue(true)
    }
  }

  func testPledgeContext_LoggedOut() {
    let mockService = MockService(serverConfig: ServerConfig.staging)

    withEnvironment(apiService: mockService, currentUser: nil) {
      let project = Project.template
      let reward = Reward.template
        |> Reward.lens.shipping.enabled .~ true

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.title.assertValues(["Back this project"])

      self.configurePledgeRewardsSummaryViewRewards.assertValues([[reward]])
      self.configurePledgeRewardsSummaryViewProjectCurrencyCountry.assertValues([.us])
      self.configurePledgeRewardsSummaryViewOmitCurrencyCode.assertLastValue(true)

      self.configurePaymentMethodsViewControllerWithUser.assertDidNotEmitValue()
      self.configurePaymentMethodsViewControllerWithProject.assertDidNotEmitValue()
      self.configurePaymentMethodsViewControllerWithReward.assertDidNotEmitValue()
      self.configurePaymentMethodsViewControllerWithContext.assertDidNotEmitValue()

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertLastValue(false)
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.configurePledgeViewCTAContainerViewContext.assertValues([.pledge])

      self.configureStripeIntegrationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])
      self.configureStripeIntegrationPublishableKey.assertValues([Secrets.StripePublishableKey.staging])

      self.paymentMethodsViewHidden.assertLastValue(true)
      self.pledgeAmountSummaryViewHidden.assertLastValue(true)
    }
  }

  func testUpdateRewardContext() {
    let mockService = MockService(serverConfig: ServerConfig.staging)

    withEnvironment(apiService: mockService, currentUser: .template) {
      let project = Project.template
      let reward = Reward.template
        |> Reward.lens.shipping.enabled .~ true

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .updateReward
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.title.assertValues(["Update pledge"])

      self.configurePledgeRewardsSummaryViewRewards.assertValues([[reward]])
      self.configurePledgeRewardsSummaryViewProjectCurrencyCountry.assertValues([.us])
      self.configurePledgeRewardsSummaryViewOmitCurrencyCode.assertLastValue(true)

      self.configurePaymentMethodsViewControllerWithUser.assertDidNotEmitValue()
      self.configurePaymentMethodsViewControllerWithProject.assertDidNotEmitValue()
      self.configurePaymentMethodsViewControllerWithReward.assertDidNotEmitValue()
      self.configurePaymentMethodsViewControllerWithContext.assertDidNotEmitValue()

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertLastValue(true)
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues(
        [true],
        "CTA is automatically enabled when you are updating the pledge."
      )
      XCTAssertTrue(
        self.configurePledgeViewCTAContainerViewContext.lastValue!.applePayButtonHidden,
        "ApplePay button is hidden when you are updating the pledge."
      )
      self.configurePledgeViewCTAContainerViewContext.assertValues([.updateReward])

      self.configureStripeIntegrationMerchantId.assertDidNotEmitValue()
      self.configureStripeIntegrationPublishableKey.assertDidNotEmitValue()

      self.paymentMethodsViewHidden.assertLastValue(true)
      self.pledgeAmountSummaryViewHidden.assertLastValue(true)
    }
  }

  func testChangePaymentMethodContext() {
    let mockService = MockService(serverConfig: ServerConfig.staging)

    withEnvironment(apiService: mockService, currentUser: .template) {
      let shippingRule = ShippingRule.template
        |> ShippingRule.lens.id .~ 123
        |> ShippingRule.lens.cost .~ 10.0
      let backing = Backing.template
        |> Backing.lens.amount .~ 100
        |> Backing.lens.bonusAmount .~ 80
        |> Backing.lens.shippingAmount .~ .some(10)
        |> Backing.lens.locationId .~ .some(123)
      let project = Project.template
        |> Project.lens.personalization.backing .~ backing
      let reward = Reward.template
        |> Reward.lens.shipping.enabled .~ true
        |> Reward.lens.minimum .~ 10.00

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: shippingRule.location.id,
        refTag: .projectPage,
        context: .changePaymentMethod
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.title.assertValues(["Change payment method"])

      self.configurePledgeRewardsSummaryViewRewards.assertValues([[reward]])
      self.configurePledgeRewardsSummaryViewProjectCurrencyCountry.assertValues([.us])
      self.configurePledgeRewardsSummaryViewOmitCurrencyCode.assertLastValue(true)

      self.configurePaymentMethodsViewControllerWithUser.assertValues([User.template])
      self.configurePaymentMethodsViewControllerWithProject.assertValues([project])
      self.configurePaymentMethodsViewControllerWithReward.assertValues([reward])
      self.configurePaymentMethodsViewControllerWithContext.assertValues([.changePaymentMethod])

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertLastValue(true)
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        false,
        "CTA is disabled until new payment method is selected"
      )
      self.configurePledgeViewCTAContainerViewContext.assertValues([.changePaymentMethod])

      self.configureStripeIntegrationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])
      self.configureStripeIntegrationPublishableKey.assertValues([Secrets.StripePublishableKey.staging])

      self.paymentMethodsViewHidden.assertLastValue(false)
      self.pledgeAmountSummaryViewHidden.assertLastValue(false)

      self.vm.inputs.creditCardSelected(with: .savedCreditCard("12345", "pm_fake"))
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        true,
        "Selecting new payment method enables CTA"
      )
    }
  }

  func testFixPaymentMethodContext() {
    let mockService = MockService(serverConfig: ServerConfig.staging)

    withEnvironment(apiService: mockService, currentUser: .template) {
      let shippingRule = ShippingRule.template
        |> ShippingRule.lens.id .~ 123
        |> ShippingRule.lens.cost .~ 10.0
      let backing = Backing.template
        |> Backing.lens.amount .~ 100
        |> Backing.lens.bonusAmount .~ 80
        |> Backing.lens.shippingAmount .~ .some(10)
        |> Backing.lens.locationId .~ .some(123)
        |> Backing.lens.status .~ .errored
      let project = Project.template
        |> Project.lens.personalization.backing .~ backing
      let reward = Reward.template
        |> Reward.lens.shipping.enabled .~ true
        |> Reward.lens.minimum .~ 10.00

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: shippingRule.location.id,
        refTag: .projectPage,
        context: .fixPaymentMethod
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.title.assertValues(["Fix payment method"])

      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        false,
        "CTA is disabled until new payment method is selected"
      )

      self.configurePledgeRewardsSummaryViewRewards.assertValues([[reward]])
      self.configurePledgeRewardsSummaryViewProjectCurrencyCountry.assertValues([.us])
      self.configurePledgeRewardsSummaryViewOmitCurrencyCode.assertLastValue(true)

      self.configurePaymentMethodsViewControllerWithUser.assertValues([User.template])
      self.configurePaymentMethodsViewControllerWithProject.assertValues([project])
      self.configurePaymentMethodsViewControllerWithReward.assertValues([reward])
      self.configurePaymentMethodsViewControllerWithContext.assertValues([.fixPaymentMethod])

      self.configureStripeIntegrationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])
      self.configureStripeIntegrationPublishableKey.assertValues([Secrets.StripePublishableKey.staging])

      self.configurePledgeViewCTAContainerViewWillRetryPaymentMethod.assertLastValue(false)

      self.configurePledgeViewCTAContainerViewWillRetryPaymentMethod.assertLastValue(false)
      self.paymentMethodsViewHidden.assertLastValue(false)
      self.pledgeAmountSummaryViewHidden.assertLastValue(false)

      let paymentSourceSelected = PaymentSourceSelected.savedCreditCard(backing.paymentSource!.id!, "pm_fake")

      self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

      self.configurePledgeViewCTAContainerViewWillRetryPaymentMethod.assertLastValue(true)
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        true,
        "CTA is disabled until new payment method is selected"
      )
    }
  }

  func testChangePaymentMethodContext_NoReward() {
    let backing = Backing.template
      |> Backing.lens.amount .~ 10
      |> Backing.lens.bonusAmount .~ 10
      |> Backing.lens.shippingAmount .~ .some(0)
    let reward = Reward.noReward
      |> Reward.lens.minimum .~ 1.0
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ backing
      |> Project.lens.rewardData.rewards .~ [reward]

    let mockService = MockService(serverConfig: ServerConfig.staging)

    withEnvironment(apiService: mockService, currentUser: .template) {
      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .changePaymentMethod
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.title.assertValues(["Change payment method"])

      self.configurePledgeRewardsSummaryViewRewards.assertValues([[reward]])
      self.configurePledgeRewardsSummaryViewProjectCurrencyCountry.assertValues([.us])
      self.configurePledgeRewardsSummaryViewOmitCurrencyCode.assertLastValue(true)

      self.configurePaymentMethodsViewControllerWithUser.assertValues([User.template])
      self.configurePaymentMethodsViewControllerWithProject.assertValues([project])
      self.configurePaymentMethodsViewControllerWithReward.assertValues([reward])
      self.configurePaymentMethodsViewControllerWithContext.assertValues([.changePaymentMethod])

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertLastValue(true)
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.configurePledgeViewCTAContainerViewContext.assertValues([.changePaymentMethod])

      self.configureStripeIntegrationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])
      self.configureStripeIntegrationPublishableKey.assertValues([Secrets.StripePublishableKey.staging])

      self.paymentMethodsViewHidden.assertLastValue(false)
      self.pledgeAmountSummaryViewHidden.assertLastValue(false)
    }
  }

  func testChangePaymentMethodContext_RewardWithShipping() {
    let backing = Backing.template
    let reward = Reward.template
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ backing
      |> Project.lens.rewardData.rewards .~ [reward]

    let mockService = MockService(serverConfig: ServerConfig.staging)

    withEnvironment(apiService: mockService, currentUser: .template) {
      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: nil,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .changePaymentMethod
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.title.assertValues(["Change payment method"])

      self.configurePledgeRewardsSummaryViewRewards.assertValues([[reward]])
      self.configurePledgeRewardsSummaryViewProjectCurrencyCountry.assertValues([.us])
      self.configurePledgeRewardsSummaryViewOmitCurrencyCode.assertLastValue(true)

      self.configurePaymentMethodsViewControllerWithUser.assertValues([User.template])
      self.configurePaymentMethodsViewControllerWithProject.assertValues([project])
      self.configurePaymentMethodsViewControllerWithReward.assertValues([reward])
      self.configurePaymentMethodsViewControllerWithContext.assertValues([.changePaymentMethod])

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertLastValue(true)
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.configurePledgeViewCTAContainerViewContext.assertValues([.changePaymentMethod])

      self.configureStripeIntegrationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])
      self.configureStripeIntegrationPublishableKey.assertValues([Secrets.StripePublishableKey.staging])

      self.paymentMethodsViewHidden.assertLastValue(false)
      self.pledgeAmountSummaryViewHidden.assertLastValue(false)

      self.configurePledgeRewardsSummaryViewRewards.assertLastValue([reward])

      let expectedShipping = PledgeShippingSummaryViewData(
        locationName: backing.locationName!,
        omitUSCurrencyCode: project.stats.omitUSCurrencyCode,
        projectCountry: project.country,
        total: backing.shippingAmount!
      )
      self.configurePledgeRewardsSummaryViewShipping.assertLastValue(expectedShipping)
    }
  }

  func testPledgeView_Logged_Out_Shipping_Disabled() {
    withEnvironment(currentUser: nil) {
      let project = Project.template
      let reward = Reward.template
        |> Reward.lens.shipping.enabled .~ false

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.configurePaymentMethodsViewControllerWithUser.assertDidNotEmitValue()
      self.configurePaymentMethodsViewControllerWithProject.assertDidNotEmitValue()
      self.configurePaymentMethodsViewControllerWithReward.assertDidNotEmitValue()
      self.configurePaymentMethodsViewControllerWithContext.assertDidNotEmitValue()

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertLastValue(false)
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.configurePledgeViewCTAContainerViewContext.assertValues([.pledge])

      self.paymentMethodsViewHidden.assertLastValue(true)
      self.pledgeAmountSummaryViewHidden.assertLastValue(true)
    }
  }

  func testPledgeView_Logged_Out_Shipping_Enabled() {
    withEnvironment(currentUser: nil) {
      let project = Project.template
      let reward = Reward.template
        |> Reward.lens.shipping.enabled .~ true

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.configurePaymentMethodsViewControllerWithUser.assertDidNotEmitValue()
      self.configurePaymentMethodsViewControllerWithProject.assertDidNotEmitValue()
      self.configurePaymentMethodsViewControllerWithReward.assertDidNotEmitValue()
      self.configurePaymentMethodsViewControllerWithContext.assertDidNotEmitValue()

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertLastValue(false)
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.configurePledgeViewCTAContainerViewContext.assertValues([.pledge])

      self.paymentMethodsViewHidden.assertLastValue(true)
      self.pledgeAmountSummaryViewHidden.assertLastValue(true)
    }
  }

  func testPledgeView_Logged_In_Shipping_Disabled() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ false

    withEnvironment(currentUser: .template) {
      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.configurePaymentMethodsViewControllerWithUser.assertValues([User.template])
      self.configurePaymentMethodsViewControllerWithProject.assertValues([project])
      self.configurePaymentMethodsViewControllerWithReward.assertValues([reward])
      self.configurePaymentMethodsViewControllerWithContext.assertValues([.pledge])

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertLastValue(true)
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.configurePledgeViewCTAContainerViewContext.assertValues([.pledge])

      self.paymentMethodsViewHidden.assertLastValue(false)
      self.pledgeAmountSummaryViewHidden.assertLastValue(true)
    }
  }

  func testPledgeView_Logged_In_Shipping_Enabled() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true

    withEnvironment(currentUser: .template) {
      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.configurePaymentMethodsViewControllerWithUser.assertValues([User.template])
      self.configurePaymentMethodsViewControllerWithProject.assertValues([project])
      self.configurePaymentMethodsViewControllerWithReward.assertValues([reward])
      self.configurePaymentMethodsViewControllerWithContext.assertValues([.pledge])

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertLastValue(true)
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.configurePledgeViewCTAContainerViewContext.assertValues([.pledge])

      self.paymentMethodsViewHidden.assertLastValue(false)
      self.pledgeAmountSummaryViewHidden.assertLastValue(true)
    }
  }

  func testShippingRuleSelectedUpdatedShippingRule() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.shipping .~ (.template |> Reward.Shipping.lens.enabled .~ true)

    withEnvironment(currentUser: .template) {
      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.configurePaymentMethodsViewControllerWithUser.assertValues([User.template])
      self.configurePaymentMethodsViewControllerWithProject.assertValues([project])
      self.configurePaymentMethodsViewControllerWithReward.assertValues([reward])
      self.configurePaymentMethodsViewControllerWithContext.assertValues([.pledge])

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertLastValue(true)
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.configurePledgeViewCTAContainerViewContext.assertValues([.pledge])

      self.paymentMethodsViewHidden.assertLastValue(false)
      self.pledgeAmountSummaryViewHidden.assertLastValue(true)
    }
  }

  func testLoginSignup() {
    let project = Project.template
    let reward = Reward.template
    let user = User.template

    withEnvironment(currentUser: nil) {
      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.configurePaymentMethodsViewControllerWithUser.assertDidNotEmitValue()
      self.configurePaymentMethodsViewControllerWithProject.assertDidNotEmitValue()
      self.configurePaymentMethodsViewControllerWithReward.assertDidNotEmitValue()
      self.configurePaymentMethodsViewControllerWithContext.assertDidNotEmitValue()

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertLastValue(false)
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.configurePledgeViewCTAContainerViewContext.assertValues([.pledge])

      self.paymentMethodsViewHidden.assertLastValue(true)
      self.pledgeAmountSummaryViewHidden.assertLastValue(true)

      withEnvironment(currentUser: user) {
        self.vm.inputs.userSessionDidChange()

        self.configurePaymentMethodsViewControllerWithUser.assertValues([user])
        self.configurePaymentMethodsViewControllerWithProject.assertValues([project])
        self.configurePaymentMethodsViewControllerWithReward.assertValues([reward])
        self.configurePaymentMethodsViewControllerWithContext.assertValues([.pledge])

        self.configurePledgeViewCTAContainerViewIsLoggedIn.assertValues([false, true])
        self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, false])
        self.configurePledgeViewCTAContainerViewContext.assertValues([.pledge, .pledge])

        self.paymentMethodsViewHidden.assertValues([true, false])
      }
    }
  }

  func testStripeConfiguration_StagingEnvironment() {
    let mockService = MockService(serverConfig: ServerConfig.staging)

    withEnvironment(apiService: mockService) {
      self.configureStripeIntegrationMerchantId.assertDidNotEmitValue()
      self.configureStripeIntegrationPublishableKey.assertDidNotEmitValue()

      let project = Project.template
      let reward = Reward.template

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
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

      let project = Project.template
      let reward = Reward.template

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .activity,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.configureStripeIntegrationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])
      self.configureStripeIntegrationPublishableKey.assertValues([Secrets.StripePublishableKey.production])
    }
  }

  func testGoToApplePayPaymentAuthorization_WhenApplePayButtonTapped_ShippingDisabled() {
    let project = Project.template
    let reward = Reward.noReward
      |> Reward.lens.minimum .~ 1

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      bonusSupport: 5.0,
      selectedShippingRule: shippingRule,
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: .projectPage,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAllRewardsShippingTotal.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

    self.vm.inputs.applePayButtonTapped()

    self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationProject.assertValues([project])
    self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
    self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([0])
    self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([5])
    self.goToApplePayPaymentAuthorizationAllRewardsShippingTotal.assertValues([0])
    self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])
  }

  func testGoToApplePayPaymentAuthorization_WhenApplePayButtonTapped_ShippingEnabled() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.minimum .~ 20
      |> Reward.lens.shipping.enabled .~ true
    let shippingRule = ShippingRule.template

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      bonusSupport: 25,
      selectedShippingRule: shippingRule,
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: .projectPage,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAllRewardsShippingTotal.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

    self.vm.inputs.applePayButtonTapped()

    self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationProject.assertValues([project])
    self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
    self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([20])
    self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([25])
    self.goToApplePayPaymentAuthorizationAllRewardsShippingTotal.assertValues([5])
    self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])
  }

  func testPaymentAuthorizationViewControllerDidFinish_WithoutCompletingTransaction() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.minimum .~ 20
      |> Reward.lens.shipping.enabled .~ true
    let shippingRule = ShippingRule.template

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      bonusSupport: 25.0,
      selectedShippingRule: shippingRule,
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: .projectPage,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.applePayButtonTapped()

    self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationProject.assertValues([project])
    self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
    self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([20])
    self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([25])
    self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

    self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

    self.goToThanksProject.assertDidNotEmitValue()
    self.showErrorBannerWithMessage.assertDidNotEmitValue()
  }

  func testStripeTokenCreated_ReturnsStatusFailure_WhenPKPaymentData_IsNil() {
    let project = Project.template
    let reward = Reward.noReward
      |> Reward.lens.minimum .~ 5

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedShippingRule: shippingRule,
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: .projectPage,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
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

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedShippingRule: shippingRule,
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: .projectPage,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
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

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedShippingRule: shippingRule,
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: .projectPage,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
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

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedShippingRule: shippingRule,
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: .projectPage,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
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

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedShippingRule: shippingRule,
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: .projectPage,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
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

  func testApplePay_GoToThanks() {
    let createBacking = CreateBackingEnvelope.CreateBacking(
      checkout: Checkout(
        id: "Q2hlY2tvdXQtMQ==",
        state: .successful,
        backing: .init(clientSecret: nil, requiresAction: false)
      )
    )
    let mockService = MockService(
      createBackingResult:
      Result.success(CreateBackingEnvelope(createBacking: createBacking))
    )

    withEnvironment(apiService: mockService, currentUser: .template) {
      let project = Project.template
      let reward = Reward.template
        |> Reward.lens.minimum .~ 5

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        bonusSupport: 10.0,
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.applePayButtonTapped()

      self.goToThanksProject.assertDidNotEmitValue()
      self.processingViewIsHidden.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
        paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345")
      )

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.success,
        self.vm.inputs.stripeTokenCreated(token: "stripe_token", error: nil)
      )

      self.goToThanksProject.assertDidNotEmitValue()

      self.processingViewIsHidden.assertLastValue(false)

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.processingViewIsHidden.assertLastValue(false)
      self.goToThanksProject.assertDidNotEmitValue("Signal waits for Create Backing to complete")
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      self.scheduler.run()

      let checkoutData = KSRAnalytics.CheckoutPropertiesData(
        addOnsCountTotal: 0,
        addOnsCountUnique: 0,
        addOnsMinimumUsd: 0.00,
        bonusAmountInUsd: 10.00,
        checkoutId: "1",
        estimatedDelivery: 1_506_897_315.0,
        paymentType: "apple_pay",
        revenueInUsd: 15.00,
        rewardId: "1",
        rewardMinimumUsd: 5.00,
        rewardTitle: "My Reward",
        shippingEnabled: false,
        shippingAmountUsd: nil,
        userHasStoredApplePayCard: true
      )

      self.processingViewIsHidden.assertValues([false, true])
      self.goToThanksProject.assertValues([project])
      self.goToThanksReward.assertValues([reward])
      self.goToThanksCheckoutData.assertValues([checkoutData])

      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      XCTAssertEqual(
        ["Page Viewed", "CTA Clicked"],
        self.segmentTrackingClient.events
      )
    }
  }

  func testApplePay_GoToThanks_NonUSDProject() {
    let createBacking = CreateBackingEnvelope.CreateBacking(
      checkout: Checkout(
        id: "Q2hlY2tvdXQtMQ==",
        state: .successful,
        backing: .init(clientSecret: nil, requiresAction: false)
      )
    )
    let mockService = MockService(
      createBackingResult:
      Result.success(CreateBackingEnvelope(createBacking: createBacking))
    )

    withEnvironment(apiService: mockService, currentUser: .template) {
      let project = Project.cosmicSurgery
      let reward = Reward.template
        |> Reward.lens.minimum .~ 5

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        bonusSupport: 10.0,
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.applePayButtonTapped()

      self.goToThanksProject.assertDidNotEmitValue()
      self.processingViewIsHidden.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
        paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345")
      )

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.success,
        self.vm.inputs.stripeTokenCreated(token: "stripe_token", error: nil)
      )

      self.goToThanksProject.assertDidNotEmitValue()

      self.processingViewIsHidden.assertLastValue(false)

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.processingViewIsHidden.assertLastValue(false)
      self.goToThanksProject.assertDidNotEmitValue("Signal waits for Create Backing to complete")
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      self.scheduler.run()

      let checkoutData = KSRAnalytics.CheckoutPropertiesData(
        addOnsCountTotal: 0,
        addOnsCountUnique: 0,
        addOnsMinimumUsd: 0.00,
        bonusAmountInUsd: 13.10,
        checkoutId: "1",
        estimatedDelivery: 1_506_897_315.0,
        paymentType: "apple_pay",
        revenueInUsd: 19.65,
        rewardId: "1",
        rewardMinimumUsd: 6.55,
        rewardTitle: "My Reward",
        shippingEnabled: false,
        shippingAmountUsd: nil,
        userHasStoredApplePayCard: true
      )

      self.processingViewIsHidden.assertValues([false, true])
      self.goToThanksProject.assertValues([project])
      self.goToThanksReward.assertValues([reward])
      self.goToThanksCheckoutData.assertValues([checkoutData])

      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      XCTAssertEqual(
        ["Page Viewed", "CTA Clicked"],
        self.segmentTrackingClient.events
      )
    }
  }

  func testApplePay_GoToThanks_WhenRefTag_IsNil() {
    let createBacking = CreateBackingEnvelope.CreateBacking(
      checkout: Checkout(
        id: "Q2hlY2tvdXQtMQ==",
        state: .successful,
        backing: .init(clientSecret: nil, requiresAction: false)
      )
    )
    let mockService = MockService(
      createBackingResult:
      Result.success(CreateBackingEnvelope(createBacking: createBacking))
    )

    withEnvironment(apiService: mockService, currentUser: .template) {
      let project = Project.template

      let shippingRule = ShippingRule.template

      let reward = Reward.template
        |> Reward.lens.minimum .~ 5
        |> Reward.lens.shipping.enabled .~ true
        |> Reward.lens.shippingRules .~ [shippingRule]

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: nil,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.configurePaymentMethodsViewControllerWithUser.assertValues([User.template])
      self.configurePaymentMethodsViewControllerWithProject.assertValues([project])
      self.configurePaymentMethodsViewControllerWithReward.assertValues([reward])
      self.configurePaymentMethodsViewControllerWithContext.assertValues([.pledge])

      self.paymentMethodsViewHidden.assertLastValue(false)

      self.vm.inputs.applePayButtonTapped()

      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
        paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345")
      )

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.success,
        self.vm.inputs.stripeTokenCreated(token: "stripe_token", error: nil)
      )

      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.goToThanksProject.assertDidNotEmitValue()

      self.scheduler.run()

      let checkoutData = KSRAnalytics.CheckoutPropertiesData(
        addOnsCountTotal: 0,
        addOnsCountUnique: 0,
        addOnsMinimumUsd: 0.00,
        bonusAmountInUsd: 0.00,
        checkoutId: "1",
        estimatedDelivery: 1_506_897_315.0,
        paymentType: "apple_pay",
        revenueInUsd: 10,
        rewardId: "1",
        rewardMinimumUsd: 5.00,
        rewardTitle: "My Reward",
        shippingEnabled: true,
        shippingAmountUsd: 5.0,
        userHasStoredApplePayCard: true
      )

      self.goToThanksProject.assertValues([project])
      self.goToThanksReward.assertValues([reward])
      self.goToThanksCheckoutData.assertValues([checkoutData])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      XCTAssertEqual(
        ["Page Viewed", "CTA Clicked"],
        self.segmentTrackingClient.events
      )
    }
  }

  func testApplePay_WhenStripeTokenCreated_IsNil_ReturnsFailure() {
    withEnvironment(apiService: MockService()) {
      let project = Project.template
      let reward = Reward.noReward

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.applePayButtonTapped()

      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
        paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345")
      )

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.failure,
        self.vm.inputs.stripeTokenCreated(token: nil, error: GraphError.invalidInput)
      )

      self.scheduler.run()

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      XCTAssertEqual(
        ["Page Viewed", "CTA Clicked"],
        self.segmentTrackingClient.events
      )
    }
  }

  func testCreateApplePayBackingError() {
    let mockService = MockService(createBackingResult: .failure(.couldNotParseJSON))

    withEnvironment(apiService: mockService) {
      let project = Project.template
      let reward = Reward.noReward
        |> Reward.lens.minimum .~ 5

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.applePayButtonTapped()

      self.processingViewIsHidden.assertDidNotEmitValue()
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
        paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345")
      )

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.success,
        self.vm.inputs.stripeTokenCreated(token: "stripe_token", error: nil)
      )

      self.processingViewIsHidden.assertLastValue(false)
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      self.scheduler.run()

      self.processingViewIsHidden.assertValues([false, true])
      self.showErrorBannerWithMessage.assertDidNotEmitValue(
        "Signal waits for the Apple Pay sheet to be dismissed"
      )
      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.goToThanksProject.assertDidNotEmitValue()

      XCTAssertEqual(
        ["Page Viewed", "CTA Clicked"],
        self.segmentTrackingClient.events
      )
    }
  }

  func testCreateBacking_Success() {
    let createBacking = CreateBackingEnvelope.CreateBacking(
      checkout: Checkout(
        id: "Q2hlY2tvdXQtMQ==",
        state: .verifying,
        backing: .init(clientSecret: nil, requiresAction: false)
      )
    )
    let mockService = MockService(
      createBackingResult:
      Result.success(CreateBackingEnvelope(createBacking: createBacking))
    )

    withEnvironment(apiService: mockService, currentUser: .template) {
      let shippingRule = ShippingRule.template

      let reward = Reward.template
        |> Reward.lens.id .~ 1
        |> Reward.lens.hasAddOns .~ true
        |> Reward.lens.minimum .~ 10.0
        |> Reward.lens.shipping.enabled .~ true
        |> Reward.lens.shipping.preference .~ Reward.Shipping.Preference.unrestricted
        |> Reward.lens.shippingRules .~ [shippingRule]

      let addOn1 = Reward.template
        |> Reward.lens.id .~ 2
        |> Reward.lens.minimum .~ 5.0
        |> Reward.lens.shipping.enabled .~ true
        |> Reward.lens.shipping.preference .~ Reward.Shipping.Preference.restricted
        |> Reward.lens.shippingRules .~ [shippingRule]

      let addOn2 = Reward.template
        |> Reward.lens.id .~ 3
        |> Reward.lens.minimum .~ 8.0
        |> Reward.lens.shipping.enabled .~ false

      let project = Project.template
        |> Project.lens.rewardData.rewards .~ [reward]
        |> Project.lens.rewardData.addOns .~ [addOn1, addOn2]

      let data = PledgeViewData(
        project: project,
        rewards: [reward, addOn1, addOn2],
        bonusSupport: 15.0,
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1, addOn1.id: 2, addOn2.id: 1],
        selectedLocationId: shippingRule.location.id,
        refTag: .activity,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      let paymentSourceSelected = PaymentSourceSelected.savedCreditCard("123", "pm_fake")

      self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

      self.processingViewIsHidden.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])

      self.vm.inputs.submitButtonTapped()

      self.processingViewIsHidden.assertLastValue(false)
      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      self.scheduler.run()

      self.processingViewIsHidden.assertValues([false, true])
      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false, true])

      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      let checkoutData = KSRAnalytics.CheckoutPropertiesData(
        addOnsCountTotal: 3,
        addOnsCountUnique: 2,
        addOnsMinimumUsd: 18.00,
        bonusAmountInUsd: 15.00,
        checkoutId: "1",
        estimatedDelivery: reward.estimatedDeliveryOn,
        paymentType: "credit_card",
        revenueInUsd: 58.00,
        rewardId: String(reward.id),
        rewardMinimumUsd: 10.00,
        rewardTitle: reward.title,
        shippingEnabled: true,
        shippingAmountUsd: 15.0,
        userHasStoredApplePayCard: true
      )

      self.goToThanksProject.assertValues([.template])
      self.goToThanksReward.assertValues([.template])
      self.goToThanksCheckoutData.assertValues([checkoutData])

      XCTAssertEqual(
        ["Page Viewed", "CTA Clicked"],
        self.segmentTrackingClient.events
      )
    }
  }

  func testCreateBacking_Success_AddOns() {
    let createBacking = CreateBackingEnvelope.CreateBacking(
      checkout: Checkout(
        id: "Q2hlY2tvdXQtMQ==",
        state: .verifying,
        backing: .init(clientSecret: nil, requiresAction: false)
      )
    )
    let mockService = MockService(
      createBackingResult:
      Result.success(CreateBackingEnvelope(createBacking: createBacking))
    )

    withEnvironment(apiService: mockService, currentUser: .template) {
      let project = Project.template
      let reward = Reward.template
        |> Reward.lens.hasAddOns .~ true
        |> Reward.lens.id .~ 99
      let addOnReward1 = Reward.template
        |> Reward.lens.id .~ 1
      let addOnReward2 = Reward.template
        |> Reward.lens.id .~ 2

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        bonusSupport: 25.00,
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1, addOnReward1.id: 2, addOnReward2.id: 1],
        selectedLocationId: nil,
        refTag: .activity,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      let paymentSourceSelected = PaymentSourceSelected.savedCreditCard("123", "pm_fake")

      self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

      self.processingViewIsHidden.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])

      self.vm.inputs.submitButtonTapped()

      self.processingViewIsHidden.assertLastValue(false)
      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      self.scheduler.run()

      self.processingViewIsHidden.assertValues([false, true])
      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false, true])

      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      let checkoutData = KSRAnalytics.CheckoutPropertiesData(
        addOnsCountTotal: 0,
        addOnsCountUnique: 0,
        addOnsMinimumUsd: 0.00,
        bonusAmountInUsd: 25.00,
        checkoutId: "1",
        estimatedDelivery: reward.estimatedDeliveryOn,
        paymentType: "credit_card",
        revenueInUsd: 35.00,
        rewardId: String(reward.id),
        rewardMinimumUsd: 10.00,
        rewardTitle: reward.title,
        shippingEnabled: reward.shipping.enabled,
        shippingAmountUsd: nil,
        userHasStoredApplePayCard: true
      )

      self.goToThanksProject.assertValues([.template])
      self.goToThanksReward.assertValues([reward])
      self.goToThanksCheckoutData.assertValues([checkoutData])

      XCTAssertEqual(
        ["Page Viewed", "CTA Clicked"],
        self.segmentTrackingClient.events
      )
    }
  }

  func testCreateBacking_Failure() {
    let mockService = MockService(createBackingResult: .failure(.couldNotParseJSON))

    withEnvironment(apiService: mockService, currentUser: .template) {
      let project = Project.template
      let reward = Reward.template

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .activity,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.processingViewIsHidden.assertDidNotEmitValue()

      let paymentSourceSelected = PaymentSourceSelected.savedCreditCard("123", "pm_fake")

      self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])

      self.vm.inputs.submitButtonTapped()

      self.processingViewIsHidden.assertLastValue(false)
      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      self.scheduler.run()

      self.processingViewIsHidden.assertValues([false, true])
      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false, true])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])

      XCTAssertEqual(
        ["Page Viewed", "CTA Clicked"],
        self.segmentTrackingClient.events
      )
    }
  }

  func testUpdateReward_Success() {
    let reward = Reward.postcards
      |> Reward.lens.shipping.enabled .~ true

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ Backing.PaymentSource.template
          |> Backing.lens.status .~ .pledged
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.amount .~ 700.0
      )

    let updateBackingEnvelope = UpdateBackingEnvelope(
      updateBacking: .init(
        checkout: .init(
          id: "Q2hlY2tvdXQtMQ==",
          state: .successful,
          backing: .init(
            clientSecret: "client-secret",
            requiresAction: false
          )
        )
      )
    )

    let mockService = MockService(
      updateBackingResult: .success(updateBackingEnvelope)
    )

    withEnvironment(apiService: mockService, currentUser: .template) {
      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .discovery,
        context: .updateReward
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(true)
      self.processingViewIsHidden.assertDidNotEmitValue()

      self.vm.inputs.submitButtonTapped()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([true, false])
      self.processingViewIsHidden.assertLastValue(false)

      self.scheduler.run()

      self.processingViewIsHidden.assertValues([false, true])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([true, false, true])
      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertValues([
        "Got it! Your changes have been saved."
      ])
      self.popToRootViewController.assertValueCount(1)
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
    }
  }

  func testUpdateReward_Failure() {
    let reward = Reward.postcards
      |> Reward.lens.shipping.enabled .~ true

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ Backing.PaymentSource.template
          |> Backing.lens.status .~ .pledged
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.amount .~ 700.0
      )

    let mockService = MockService(
      updateBackingResult: .failure(.couldNotParseJSON)
    )

    withEnvironment(apiService: mockService, currentUser: .template) {
      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .discovery,
        context: .updateReward
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(true)
      self.processingViewIsHidden.assertDidNotEmitValue()

      self.vm.inputs.submitButtonTapped()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([true, false])
      self.processingViewIsHidden.assertLastValue(false)

      self.scheduler.run()

      self.processingViewIsHidden.assertValues([false, true])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([true, false, true])
      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValueCount(1)
    }
  }

  func testChangingPaymentMethod_SubmitButtonEnabled_OnlyWhenNewMethodIsSelected() {
    let reward = Reward.postcards
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.minimum .~ 10

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ Backing.PaymentSource.template
          |> Backing.lens.status .~ .pledged
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.bonusAmount .~ 680.0
          |> Backing.lens.amount .~ 700.0
      )

    self.configurePledgeViewCTAContainerViewIsEnabled.assertDidNotEmitValue()

    let defaultShippingRule = ShippingRule(
      cost: 10,
      id: 1,
      location: .brooklyn,
      estimatedMin: Money(amount: 1.0),
      estimatedMax: Money(amount: 10.0)
    )

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedShippingRule: shippingRule,
      selectedQuantities: [reward.id: 1],
      selectedLocationId: defaultShippingRule.location.id,
      refTag: .discovery,
      context: .changePaymentMethod
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()
    self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false, "No payment method selected")

    var paymentSourceSelected = PaymentSourceSelected.savedCreditCard("12345", "pm_fake")

    self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

    self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(true)

    paymentSourceSelected = PaymentSourceSelected.savedCreditCard(
      Backing.PaymentSource.template.id ?? "",
      "pm_fake"
    )

    self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

    self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
      false,
      "Selected original payment method again"
    )
  }

  func testGoToApplePayPaymentAuthorization_HasAddOns() {
    self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.id .~ 99
    let addOnReward1 = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ Reward.Shipping.Preference.unrestricted
      |> Reward.lens.id .~ 1
    let addOnReward2 = Reward.template
      |> Reward.lens.id .~ 2

    let shippingRule = ShippingRule.template

    let data = PledgeViewData(
      project: project,
      rewards: [reward, addOnReward1, addOnReward2],
      bonusSupport: 15.0,
      selectedShippingRule: shippingRule,
      selectedQuantities: [reward.id: 1, addOnReward1.id: 2, addOnReward2.id: 1],
      selectedLocationId: shippingRule.location.id,
      refTag: .projectPage,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.applePayButtonTapped()

    self.goToApplePayPaymentAuthorizationProject.assertValues([project])
    self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
    self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([40])
    self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
    self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])
  }

  func testChangePaymentMethod_ApplePay_Success() {
    let updateBackingEnvelope = UpdateBackingEnvelope(
      updateBacking: .init(
        checkout: .init(
          id: "Q2hlY2tvdXQtMQ==",
          state: .successful,
          backing: .init(
            clientSecret: "client-secret",
            requiresAction: false
          )
        )
      )
    )

    let mockService = MockService(
      updateBackingResult: .success(updateBackingEnvelope)
    )

    self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

    self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
    self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
    self.popToRootViewController.assertDidNotEmitValue()
    self.showErrorBannerWithMessage.assertDidNotEmitValue()
    self.configurePledgeViewCTAContainerViewIsEnabled.assertDidNotEmitValue()
    self.goToThanksProject.assertDidNotEmitValue()

    withEnvironment(apiService: mockService) {
      let reward = Reward.postcards
        |> Reward.lens.shipping.enabled .~ true
        |> Reward.lens.minimum .~ 10

      let project = Project.cosmicSurgery
        |> Project.lens.state .~ .live
        |> Project.lens.personalization.isBacking .~ true
        |> Project.lens.personalization.backing .~ (
          .template
            |> Backing.lens.paymentSource .~ Backing.PaymentSource.template
            |> Backing.lens.status .~ .pledged
            |> Backing.lens.reward .~ reward
            |> Backing.lens.rewardId .~ reward.id
            |> Backing.lens.shippingAmount .~ 10
            |> Backing.lens.amount .~ 700.0
        )

      let defaultShippingRule = ShippingRule(
        cost: 10,
        id: 1,
        location: .brooklyn,
        estimatedMin: Money(amount: 1.0),
        estimatedMax: Money(amount: 10.0)
      )

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        bonusSupport: 15.0,
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: defaultShippingRule.location.id,
        refTag: .projectPage,
        context: .changePaymentMethod
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.applePayButtonTapped()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
        paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345")
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.goToThanksProject.assertDidNotEmitValue()

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.success,
        self.vm.inputs.stripeTokenCreated(token: "stripe_token", error: nil)
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.goToThanksProject.assertDidNotEmitValue()

      self.scheduler.run()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertValues([
        "Got it! Your changes have been saved."
      ])
      self.popToRootViewController.assertValueCount(1)
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.goToThanksProject.assertDidNotEmitValue()
    }
  }

  func testChangePaymentMethod_ApplePay_StripeTokenFailure() {
    let updateBackingEnvelope = UpdateBackingEnvelope(
      updateBacking: .init(
        checkout: .init(
          id: "Q2hlY2tvdXQtMQ==",
          state: .successful,
          backing: .init(
            clientSecret: "client-secret",
            requiresAction: false
          )
        )
      )
    )

    let mockService = MockService(
      updateBackingResult: .success(updateBackingEnvelope)
    )

    self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

    self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
    self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
    self.popToRootViewController.assertDidNotEmitValue()
    self.showErrorBannerWithMessage.assertDidNotEmitValue()
    self.configurePledgeViewCTAContainerViewIsEnabled.assertDidNotEmitValue()
    self.goToThanksProject.assertDidNotEmitValue()

    withEnvironment(apiService: mockService) {
      let reward = Reward.postcards
        |> Reward.lens.shipping.enabled .~ true

      let project = Project.cosmicSurgery
        |> Project.lens.state .~ .live
        |> Project.lens.personalization.isBacking .~ true
        |> Project.lens.personalization.backing .~ (
          .template
            |> Backing.lens.paymentSource .~ Backing.PaymentSource.template
            |> Backing.lens.status .~ .pledged
            |> Backing.lens.reward .~ reward
            |> Backing.lens.rewardId .~ reward.id
            |> Backing.lens.shippingAmount .~ 10
            |> Backing.lens.amount .~ 700.0
            |> Backing.lens.bonusAmount .~ 15.0
        )

      let defaultShippingRule = ShippingRule(
        cost: 10,
        id: 1,
        location: .brooklyn,
        estimatedMin: Money(amount: 1.0),
        estimatedMax: Money(amount: 10.0)
      )

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        bonusSupport: 15.0,
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: defaultShippingRule.location.id,
        refTag: .projectPage,
        context: .changePaymentMethod
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.applePayButtonTapped()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.goToThanksProject.assertDidNotEmitValue()

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.failure,
        self.vm.inputs.stripeTokenCreated(token: nil, error: GraphError.invalidInput)
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.goToThanksProject.assertDidNotEmitValue()

      self.scheduler.run()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.goToThanksProject.assertDidNotEmitValue()
    }
  }

  func testChangePaymentMethod_ApplePay_Failure() {
    let mockService = MockService(
      updateBackingResult: .failure(.couldNotParseJSON)
    )

    self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

    self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
    self.popToRootViewController.assertDidNotEmitValue()
    self.showErrorBannerWithMessage.assertDidNotEmitValue()
    self.configurePledgeViewCTAContainerViewIsEnabled.assertDidNotEmitValue()
    self.goToThanksProject.assertDidNotEmitValue()

    withEnvironment(apiService: mockService) {
      let reward = Reward.postcards
        |> Reward.lens.shipping.enabled .~ true

      let project = Project.cosmicSurgery
        |> Project.lens.state .~ .live
        |> Project.lens.personalization.isBacking .~ true
        |> Project.lens.personalization.backing .~ (
          .template
            |> Backing.lens.paymentSource .~ Backing.PaymentSource.template
            |> Backing.lens.status .~ .pledged
            |> Backing.lens.reward .~ reward
            |> Backing.lens.rewardId .~ reward.id
            |> Backing.lens.shippingAmount .~ 10
            |> Backing.lens.amount .~ 700.0
            |> Backing.lens.bonusAmount .~ 15.0
        )

      let defaultShippingRule = ShippingRule(
        cost: 10,
        id: 1,
        location: .brooklyn,
        estimatedMin: Money(amount: 1.0),
        estimatedMax: Money(amount: 10.0)
      )

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        bonusSupport: 15.0,
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: defaultShippingRule.location.id,
        refTag: .projectPage,
        context: .changePaymentMethod
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.applePayButtonTapped()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
        paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345")
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.goToThanksProject.assertDidNotEmitValue()

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.success,
        self.vm.inputs.stripeTokenCreated(token: "stripe_token", error: nil)
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.goToThanksProject.assertDidNotEmitValue()

      self.scheduler.run()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.goToThanksProject.assertDidNotEmitValue()
    }
  }

  func testApplePayBackingFails_ThenSucceeds_SignalsDoNotOverlap_ChangePaymentMethodContext() {
    let mockService1 = MockService(
      updateBackingResult: .failure(.couldNotParseJSON)
    )

    let reward = Reward.postcards
      |> Reward.lens.shipping.enabled .~ true

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ Backing.PaymentSource.template
          |> Backing.lens.status .~ .pledged
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.amount .~ 700.0
      )

    self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

    self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
    self.popToRootViewController.assertDidNotEmitValue()
    self.showErrorBannerWithMessage.assertDidNotEmitValue()
    self.configurePledgeViewCTAContainerViewIsEnabled.assertDidNotEmitValue()
    self.goToThanksProject.assertDidNotEmitValue()

    withEnvironment(apiService: mockService1) {
      let defaultShippingRule = ShippingRule(
        cost: 10,
        id: 1,
        location: .brooklyn,
        estimatedMin: Money(amount: 1.0),
        estimatedMax: Money(amount: 10.0)
      )

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        bonusSupport: 15.0,
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: defaultShippingRule.location.id,
        refTag: .projectPage,
        context: .changePaymentMethod
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        false,
        "CTA is disabled until payment method is selected"
      )
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.applePayButtonTapped()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        false,
        "CTA is disabled until payment method is selected"
      )
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
        paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345")
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        false,
        "CTA is disabled until payment method is selected"
      )
      self.goToThanksProject.assertDidNotEmitValue()

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.success,
        self.vm.inputs.stripeTokenCreated(token: "stripe_token", error: nil)
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        false,
        "CTA is disabled until payment method is selected"
      )
      self.goToThanksProject.assertDidNotEmitValue()

      self.scheduler.run()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        false,
        "CTA is disabled until payment method is selected"
      )
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        false,
        "CTA is disabled until payment method is selected"
      )
      self.goToThanksProject.assertDidNotEmitValue()
    }

    let updateBackingEnvelope = UpdateBackingEnvelope(
      updateBacking: .init(
        checkout: .init(
          id: "Q2hlY2tvdXQtMQ==",
          state: .successful,
          backing: .init(
            clientSecret: "client-secret",
            requiresAction: false
          )
        )
      )
    )

    let mockService2 = MockService(
      updateBackingResult: .success(updateBackingEnvelope)
    )

    withEnvironment(apiService: mockService2) {
      self.vm.inputs.applePayButtonTapped()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project, project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward, reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6, 6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15, 15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([
        Secrets.ApplePay.merchantIdentifier,
        Secrets.ApplePay.merchantIdentifier
      ])

      self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
        paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345")
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project, project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward, reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6, 6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15, 15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([
        Secrets.ApplePay.merchantIdentifier,
        Secrets.ApplePay.merchantIdentifier
      ])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        false,
        "CTA is disabled until payment method is selected"
      )
      self.goToThanksProject.assertDidNotEmitValue()

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.success,
        self.vm.inputs.stripeTokenCreated(token: "stripe_token", error: nil)
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project, project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward, reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6, 6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15, 15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([
        Secrets.ApplePay.merchantIdentifier,
        Secrets.ApplePay.merchantIdentifier
      ])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        false,
        "CTA is disabled until payment method is selected"
      )
      self.goToThanksProject.assertDidNotEmitValue()

      self.scheduler.run()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project, project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward, reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6, 6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15, 15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([
        Secrets.ApplePay.merchantIdentifier,
        Secrets.ApplePay.merchantIdentifier
      ])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        false,
        "CTA is disabled until payment method is selected"
      )
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project, project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward, reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6, 6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15, 15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([
        Secrets.ApplePay.merchantIdentifier,
        Secrets.ApplePay.merchantIdentifier
      ])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertValues([
        "Got it! Your changes have been saved."
      ])
      self.popToRootViewController.assertValueCount(1)
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        false,
        "CTA is disabled until payment method is selected"
      )
      self.goToThanksProject.assertDidNotEmitValue()
    }
  }

  func testApplePayBackingFails_ThenStoredCardSucceeds_SignalsDoNotOverlap_ChangePaymentMethodContext() {
    let mockService1 = MockService(
      updateBackingResult: .failure(.couldNotParseJSON)
    )

    let reward = Reward.postcards
      |> Reward.lens.shipping.enabled .~ true

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ Backing.PaymentSource.template
          |> Backing.lens.status .~ .pledged
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.amount .~ 700.0
          |> Backing.lens.bonusAmount .~ 15.0
      )

    self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

    self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
    self.popToRootViewController.assertDidNotEmitValue()
    self.showErrorBannerWithMessage.assertDidNotEmitValue()
    self.configurePledgeViewCTAContainerViewIsEnabled.assertDidNotEmitValue()
    self.goToThanksProject.assertDidNotEmitValue()

    withEnvironment(apiService: mockService1) {
      let defaultShippingRule = ShippingRule(
        cost: 10,
        id: 1,
        location: .brooklyn,
        estimatedMin: Money(amount: 1.0),
        estimatedMax: Money(amount: 10.0)
      )

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        bonusSupport: 15.0,
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: defaultShippingRule.location.id,
        refTag: .projectPage,
        context: .changePaymentMethod
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        false,
        "CTA is disabled until payment method is selected"
      )
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.applePayButtonTapped()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        false,
        "CTA is disabled until payment method is selected"
      )
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
        paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345")
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        false,
        "CTA is disabled until payment method is selected"
      )
      self.goToThanksProject.assertDidNotEmitValue()

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.success,
        self.vm.inputs.stripeTokenCreated(token: "stripe_token", error: nil)
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        false,
        "CTA is disabled until payment method is selected"
      )
      self.goToThanksProject.assertDidNotEmitValue()

      self.scheduler.run()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        false,
        "CTA is disabled until payment method is selected"
      )
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        false,
        "CTA is disabled until payment method is selected"
      )
      self.goToThanksProject.assertDidNotEmitValue()
    }

    let updateBackingEnvelope = UpdateBackingEnvelope(
      updateBacking: .init(
        checkout: .init(
          id: "Q2hlY2tvdXQtMQ==",
          state: .successful,
          backing: .init(
            clientSecret: "client-secret",
            requiresAction: false
          )
        )
      )
    )

    let mockService2 = MockService(
      updateBackingResult: .success(updateBackingEnvelope)
    )

    withEnvironment(apiService: mockService2) {
      let paymentSourceSelected = PaymentSourceSelected.savedCreditCard("123", "pm_fake")

      self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        true,
        "CTA enabled because payment method was selected"
      )
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.submitButtonTapped()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        false,
        "CTA disabled because submit button was tapped"
      )
      self.goToThanksProject.assertDidNotEmitValue()

      self.scheduler.run()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertValues([
        "Got it! Your changes have been saved."
      ])
      self.popToRootViewController.assertValueCount(1)
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        true,
        "CTA enabled because update backing completed"
      )
      self.goToThanksProject.assertDidNotEmitValue()
    }
  }

  func testStoredCardFails_ThenApplePaySucceeds_SignalsDoNotOverlap_ChangePaymentMethodContext() {
    let mockService1 = MockService(
      updateBackingResult: .failure(.couldNotParseJSON)
    )

    let reward = Reward.postcards
      |> Reward.lens.shipping.enabled .~ true

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ Backing.PaymentSource.template
          |> Backing.lens.status .~ .pledged
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.amount .~ 700.0
          |> Backing.lens.bonusAmount .~ 15.0
      )

    self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

    self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
    self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
    self.popToRootViewController.assertDidNotEmitValue()
    self.showErrorBannerWithMessage.assertDidNotEmitValue()
    self.configurePledgeViewCTAContainerViewIsEnabled.assertDidNotEmitValue()
    self.goToThanksProject.assertDidNotEmitValue()

    withEnvironment(apiService: mockService1) {
      let defaultShippingRule = ShippingRule(
        cost: 10,
        id: 1,
        location: .brooklyn,
        estimatedMin: Money(amount: 1.0),
        estimatedMax: Money(amount: 10.0)
      )

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        bonusSupport: 15.0,
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: defaultShippingRule.location.id,
        refTag: .projectPage,
        context: .changePaymentMethod
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      let paymentSourceSelected = PaymentSourceSelected.savedCreditCard("123", "pm_fake")

      self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

      self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(true)
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.submitButtonTapped()

      self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.goToThanksProject.assertDidNotEmitValue()

      self.scheduler.run()

      self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(true)
      self.goToThanksProject.assertDidNotEmitValue()
    }

    let updateBackingEnvelope = UpdateBackingEnvelope(
      updateBacking: .init(
        checkout: .init(
          id: "Q2hlY2tvdXQtMQ==",
          state: .successful,
          backing: .init(
            clientSecret: "client-secret",
            requiresAction: false
          )
        )
      )
    )

    let mockService2 = MockService(
      updateBackingResult: .success(updateBackingEnvelope)
    )

    withEnvironment(apiService: mockService2) {
      self.vm.inputs.applePayButtonTapped()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(true)
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
        paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345")
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(true)
      self.goToThanksProject.assertDidNotEmitValue()

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.success,
        self.vm.inputs.stripeTokenCreated(token: "stripe_token", error: nil)
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(true)
      self.goToThanksProject.assertDidNotEmitValue()

      self.scheduler.run()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(true)
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertValues([
        "Got it! Your changes have been saved."
      ])
      self.popToRootViewController.assertValueCount(1)
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(true)
      self.goToThanksProject.assertDidNotEmitValue()
    }
  }

  func testStoredCardFails_ThenApplePayFails_SignalsDoNotOverlap_ChangePaymentMethodContext() {
    let mockService = MockService(
      updateBackingResult: .failure(.couldNotParseJSON)
    )

    let reward = Reward.postcards
      |> Reward.lens.shipping.enabled .~ true

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ Backing.PaymentSource.template
          |> Backing.lens.status .~ .pledged
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.amount .~ 700.0
          |> Backing.lens.bonusAmount .~ 15.0
      )

    self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

    self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
    self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
    self.popToRootViewController.assertDidNotEmitValue()
    self.showErrorBannerWithMessage.assertDidNotEmitValue()
    self.configurePledgeViewCTAContainerViewIsEnabled.assertDidNotEmitValue()
    self.goToThanksProject.assertDidNotEmitValue()

    withEnvironment(apiService: mockService) {
      let defaultShippingRule = ShippingRule(
        cost: 10,
        id: 1,
        location: .brooklyn,
        estimatedMin: Money(amount: 1.0),
        estimatedMax: Money(amount: 10.0)
      )

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        bonusSupport: 15.0,
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: defaultShippingRule.location.id,
        refTag: .projectPage,
        context: .changePaymentMethod
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        false,
        "CTA is disabled until payment method is selected"
      )

      let paymentSourceSelected = PaymentSourceSelected.savedCreditCard("123", "pm_fake")
      self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

      self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        true,
        "CTA is enabled once payment method is selected"
      )
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.submitButtonTapped()

      self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        false,
        "CTA is disabled after submit button tapped"
      )
      self.goToThanksProject.assertDidNotEmitValue()

      self.scheduler.run()

      self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        true,
        "CTA is enabled again after update backing completes"
      )
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.applePayButtonTapped()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        true,
        "CTA stays enabled because a payment method has been selected"
      )
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
        paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345")
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        true,
        "CTA stays enabled because a payment method has been selected"
      )
      self.goToThanksProject.assertDidNotEmitValue()

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.success,
        self.vm.inputs.stripeTokenCreated(token: "stripe_token", error: nil)
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        true,
        "CTA stays enabled because a payment method has been selected"
      )
      self.goToThanksProject.assertDidNotEmitValue()

      self.scheduler.run()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        true,
        "CTA stays enabled because a payment method has been selected"
      )
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues([
        "Something went wrong.",
        "Something went wrong."
      ])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        true,
        "CTA stays enabled because a payment method has been selected"
      )
      self.goToThanksProject.assertDidNotEmitValue()
    }
  }

  func testCreateBacking_RequiresSCA_Success() {
    let createBacking = CreateBackingEnvelope.CreateBacking(
      checkout: Checkout(
        id: "Q2hlY2tvdXQtMQ==",
        state: .verifying,
        backing: .init(clientSecret: "client-secret", requiresAction: true)
      )
    )
    let mockService = MockService(
      createBackingResult:
      Result.success(CreateBackingEnvelope(createBacking: createBacking))
    )

    self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
    self.configurePledgeViewCTAContainerViewIsEnabled.assertDidNotEmitValue()
    self.goToThanksProject.assertDidNotEmitValue()
    self.showErrorBannerWithMessage.assertDidNotEmitValue()

    withEnvironment(apiService: mockService, currentUser: .template) {
      let reward = Reward.template
        |> Reward.lens.shipping.enabled .~ true
      let project = Project.template
        |> Project.lens.rewardData.rewards .~ [reward]

      let defaultShippingRule = ShippingRule(
        cost: 0,
        id: 1,
        location: .brooklyn,
        estimatedMin: Money(amount: 1.0),
        estimatedMax: Money(amount: 10.0)
      )

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        bonusSupport: 15.00,
        selectedShippingRule: defaultShippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: defaultShippingRule.location.id,
        refTag: .activity,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      let paymentSourceSelected = PaymentSourceSelected.savedCreditCard("123", "pm_fake")

      self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      self.vm.inputs.submitButtonTapped()

      self.processingViewIsHidden.assertLastValue(false)
      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      self.scheduler.run()

      self.processingViewIsHidden.assertValues([false, true])
      self.beginSCAFlowWithClientSecret.assertValues(["client-secret"])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false, true])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      self.vm.inputs.scaFlowCompleted(
        with: MockStripePaymentHandlerActionStatus(status: .succeeded), error: nil
      )

      self.processingViewIsHidden.assertValues([false, true])
      self.beginSCAFlowWithClientSecret.assertValues(["client-secret"])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false, true])

      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      let checkoutData = KSRAnalytics.CheckoutPropertiesData(
        addOnsCountTotal: 0,
        addOnsCountUnique: 0,
        addOnsMinimumUsd: 0.00,
        bonusAmountInUsd: 15.00,
        checkoutId: "1",
        estimatedDelivery: Reward.template.estimatedDeliveryOn,
        paymentType: "credit_card",
        revenueInUsd: 25.00,
        rewardId: String(reward.id),
        rewardMinimumUsd: 10.00,
        rewardTitle: reward.title,
        shippingEnabled: reward.shipping.enabled,
        shippingAmountUsd: 0,
        userHasStoredApplePayCard: true
      )

      self.goToThanksProject.assertValues([.template])
      self.goToThanksReward.assertValues([.template])
      self.goToThanksCheckoutData.assertValues([checkoutData])

      XCTAssertEqual(
        ["Page Viewed", "CTA Clicked"],
        self.segmentTrackingClient.events
      )
      XCTAssertEqual(
        KSRAnalytics.CTAContext.pledgeSubmit.trackingString,
        self.segmentTrackingClient.properties.last?["context_cta"] as? String
      )
      XCTAssertEqual(
        KSRAnalytics.TypeContext.creditCard.trackingString,
        self.segmentTrackingClient.properties.last?["context_type"] as? String
      )
    }
  }

  func testCreateBacking_RequiresSCA_Failed() {
    let createBacking = CreateBackingEnvelope.CreateBacking(
      checkout: Checkout(
        id: "Q2hlY2tvdXQtMQ==",
        state: .verifying,
        backing: .init(clientSecret: "client-secret", requiresAction: true)
      )
    )
    let mockService = MockService(
      createBackingResult:
      Result.success(CreateBackingEnvelope(createBacking: createBacking))
    )

    self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
    self.configurePledgeViewCTAContainerViewIsEnabled.assertDidNotEmitValue()
    self.goToThanksProject.assertDidNotEmitValue()
    self.showErrorBannerWithMessage.assertDidNotEmitValue()

    withEnvironment(apiService: mockService, currentUser: .template) {
      let project = Project.template
      let reward = Reward.template

      let defaultShippingRule = ShippingRule(
        cost: 10,
        id: 1,
        location: .brooklyn,
        estimatedMin: Money(amount: 1.0),
        estimatedMax: Money(amount: 10.0)
      )

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: defaultShippingRule.location.id,
        refTag: .activity,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      let paymentSourceSelected = PaymentSourceSelected.savedCreditCard("123", "pm_fake")

      self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.processingViewIsHidden.assertDidNotEmitValue()

      self.vm.inputs.submitButtonTapped()

      self.processingViewIsHidden.assertLastValue(false)
      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      self.scheduler.run()

      self.processingViewIsHidden.assertValues([false, true])
      self.beginSCAFlowWithClientSecret.assertValues(["client-secret"])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false, true])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      self.vm.inputs.scaFlowCompleted(
        with: MockStripePaymentHandlerActionStatus(status: .failed), error: GraphError.invalidInput
      )

      self.processingViewIsHidden.assertValues([false, true])
      self.beginSCAFlowWithClientSecret.assertValues(["client-secret"])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false, true])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(
        ["The operation couldn’t be completed. (KsApi.GraphError error 5.)"]
      )

      XCTAssertEqual(
        ["Page Viewed", "CTA Clicked"],
        self.segmentTrackingClient.events
      )
      XCTAssertEqual(
        KSRAnalytics.CTAContext.pledgeSubmit.trackingString,
        self.segmentTrackingClient.properties.last?["context_cta"] as? String
      )
      XCTAssertEqual(
        KSRAnalytics.TypeContext.creditCard.trackingString,
        self.segmentTrackingClient.properties.last?["context_type"] as? String
      )
    }
  }

  func testCreateBacking_RequiresSCA_Canceled() {
    let createBacking = CreateBackingEnvelope.CreateBacking(
      checkout: Checkout(
        id: "Q2hlY2tvdXQtMQ==",
        state: .verifying,
        backing: .init(clientSecret: "client-secret", requiresAction: true)
      )
    )
    let mockService = MockService(
      createBackingResult:
      Result.success(CreateBackingEnvelope(createBacking: createBacking))
    )

    self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
    self.configurePledgeViewCTAContainerViewIsEnabled.assertDidNotEmitValue()
    self.goToThanksProject.assertDidNotEmitValue()
    self.showErrorBannerWithMessage.assertDidNotEmitValue()

    withEnvironment(apiService: mockService, currentUser: .template) {
      let project = Project.template
      let reward = Reward.template

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .activity,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      let paymentSourceSelected = PaymentSourceSelected.savedCreditCard("123", "pm_fake")

      self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      self.vm.inputs.submitButtonTapped()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      self.scheduler.run()

      self.beginSCAFlowWithClientSecret.assertValues(["client-secret"])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false, true])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      self.vm.inputs.scaFlowCompleted(
        with: MockStripePaymentHandlerActionStatus(status: .canceled), error: nil
      )

      self.beginSCAFlowWithClientSecret.assertValues(["client-secret"])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false, true])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      XCTAssertEqual(
        ["Page Viewed", "CTA Clicked"],
        self.segmentTrackingClient.events
      )
      XCTAssertEqual(
        KSRAnalytics.CTAContext.pledgeSubmit.trackingString,
        self.segmentTrackingClient.properties.last?["context_cta"] as? String
      )
      XCTAssertEqual(
        KSRAnalytics.TypeContext.creditCard.trackingString,
        self.segmentTrackingClient.properties.last?["context_type"] as? String
      )
    }
  }

  func testChangePaymentMethod_RequiresSCA_Success() {
    let reward = Reward.postcards
      |> Reward.lens.shipping.enabled .~ true

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ Backing.PaymentSource.template
          |> Backing.lens.status .~ .pledged
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.amount .~ 700.0
      )

    let updateBackingEnvelope = UpdateBackingEnvelope(
      updateBacking: .init(
        checkout: .init(
          id: "Q2hlY2tvdXQtMQ==",
          state: .successful,
          backing: .init(
            clientSecret: "client-secret",
            requiresAction: true
          )
        )
      )
    )

    let mockService = MockService(
      updateBackingResult: .success(updateBackingEnvelope)
    )

    withEnvironment(apiService: mockService, currentUser: .template) {
      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .discovery,
        context: .changePaymentMethod
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.creditCardSelected(with: .savedCreditCard(
        "12345",
        "pm_fake"
      ))

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        true,
        "CTA is enabled because payment method is selected"
      )
      self.processingViewIsHidden.assertDidNotEmitValue()

      self.vm.inputs.submitButtonTapped()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        false,
        "CTA is disabled because submit button was tapped"
      )
      self.processingViewIsHidden.assertLastValue(false)

      self.scheduler.run()

      self.processingViewIsHidden.assertValues([false, true])
      self.beginSCAFlowWithClientSecret.assertValues(["client-secret"])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        true,
        "CTA is enabled because update backing completed"
      )
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      self.vm.inputs.scaFlowCompleted(
        with: MockStripePaymentHandlerActionStatus(status: .succeeded), error: nil
      )

      self.beginSCAFlowWithClientSecret.assertValues(["client-secret"])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        true,
        "CTA is enabled because update backing completed"
      )
      self.goToThanksProject.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertValues([
        "Got it! Your changes have been saved."
      ])
      self.popToRootViewController.assertValueCount(1)
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
    }
  }

  func testChangePaymentMethod_RequiresSCA_Failed() {
    let reward = Reward.postcards
      |> Reward.lens.shipping.enabled .~ true

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ Backing.PaymentSource.template
          |> Backing.lens.status .~ .pledged
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.amount .~ 700.0
      )

    let updateBackingEnvelope = UpdateBackingEnvelope(
      updateBacking: .init(
        checkout: .init(
          id: "Q2hlY2tvdXQtMQ==",
          state: .successful,
          backing: .init(
            clientSecret: "client-secret",
            requiresAction: true
          )
        )
      )
    )

    let mockService = MockService(
      updateBackingResult: .success(updateBackingEnvelope)
    )

    withEnvironment(apiService: mockService, currentUser: .template) {
      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .discovery,
        context: .changePaymentMethod
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.creditCardSelected(with: .savedCreditCard("12345", "pm_fake"))

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        true,
        "CTA enabled because payment method is selected"
      )

      self.vm.inputs.submitButtonTapped()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        false,
        "CTA disabled because submit button tapped"
      )
      self.processingViewIsHidden.assertLastValue(false)

      self.scheduler.run()

      self.processingViewIsHidden.assertValues([false, true])
      self.beginSCAFlowWithClientSecret.assertValues(["client-secret"])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        true,
        "CTA enabled because update backing completed"
      )
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      self.vm.inputs.scaFlowCompleted(
        with: MockStripePaymentHandlerActionStatus(status: .failed), error: GraphError.invalidInput
      )

      self.beginSCAFlowWithClientSecret.assertValues(["client-secret"])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(
        true,
        "CTA still enabled because update backing completed"
      )
      self.goToThanksProject.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(
        ["The operation couldn’t be completed. (KsApi.GraphError error 5.)"]
      )
    }
  }

  func testChangePaymentMethod_RequiresSCA_Canceled() {
    let reward = Reward.postcards
      |> Reward.lens.shipping.enabled .~ true

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ Backing.PaymentSource.template
          |> Backing.lens.status .~ .pledged
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.amount .~ 700.0
      )

    let updateBackingEnvelope = UpdateBackingEnvelope(
      updateBacking: .init(
        checkout: .init(
          id: "Q2hlY2tvdXQtMQ==",
          state: .successful,
          backing: .init(
            clientSecret: "client-secret",
            requiresAction: true
          )
        )
      )
    )

    let mockService = MockService(
      updateBackingResult: .success(updateBackingEnvelope)
    )

    withEnvironment(apiService: mockService, currentUser: .template) {
      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .discovery,
        context: .changePaymentMethod
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.creditCardSelected(with: .savedCreditCard(
        "12345",
        "pm_fake"
      ))

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(true)

      self.vm.inputs.submitButtonTapped()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)

      self.scheduler.run()

      self.beginSCAFlowWithClientSecret.assertValues(["client-secret"])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(true)
      self.goToThanksProject.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
    }
  }

  func testLocalRewardViewHidden_IsVisible_RegularReward_Shipping_NoAddOns_RewardIsLocalPckup() {
    self.localPickupViewHidden.assertDidNotEmitValue()

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.shipping.preference .~ .local
      |> Reward.lens.localPickup .~ .losAngeles
    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedShippingRule: shippingRule,
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: nil,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.localPickupViewHidden.assertLastValue(false)
  }

  func testLocalRewardView_IsHidden_RegularReward_Shipping_HasAddOns_RewardIsNotLocalPickup() {
    self.localPickupViewHidden.assertDidNotEmitValue()

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.localPickup .~ .losAngeles
    let addOnReward1 = Reward.template
      |> Reward.lens.id .~ 2
    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]

    let data = PledgeViewData(
      project: project,
      rewards: [reward, addOnReward1],
      selectedShippingRule: shippingRule,
      selectedQuantities: [reward.id: 1, addOnReward1.id: 1],
      selectedLocationId: nil,
      refTag: nil,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.localPickupViewHidden.assertLastValue(true)
  }

  func testConfigureLocalPickupViewWithData_Success() {
    self.configureLocalPickupViewWithData.assertDidNotEmitValue()

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.localPickup .~ .losAngeles
      |> Reward.lens.shipping.preference .~ .local

    let addOnReward1 = Reward.template
      |> Reward.lens.id .~ 2
      |> Reward.lens.shipping.enabled .~ false
    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]

    let shippingRule = ShippingRule.template

    let data = PledgeViewData(
      project: project,
      rewards: [reward, addOnReward1],
      selectedShippingRule: shippingRule,
      selectedQuantities: [reward.id: 1, addOnReward1.id: 1],
      selectedLocationId: shippingRule.id,
      refTag: nil,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.configureLocalPickupViewWithData.assertValues([
      PledgeLocalPickupViewData(locationName: "Los Angeles, CA")
    ])
  }

  func testCreateBacking_WithNewPaymentSheetCard_TappedPledgeButton_Success() {
    let createBacking = CreateBackingEnvelope.CreateBacking(
      checkout: Checkout(
        id: "Q2hlY2tvdXQtMQ==",
        state: .verifying,
        backing: .init(clientSecret: nil, requiresAction: false)
      )
    )
    let mockService = MockService(
      createBackingResult:
      Result.success(CreateBackingEnvelope(createBacking: createBacking))
    )

    withEnvironment(apiService: mockService, currentUser: .template) {
      let project = Project.template
      let reward = Reward.template
        |> Reward.lens.hasAddOns .~ true
        |> Reward.lens.id .~ 99
      let addOnReward1 = Reward.template
        |> Reward.lens.id .~ 1
      let addOnReward2 = Reward.template
        |> Reward.lens.id .~ 2

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        bonusSupport: 25.00,
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1, addOnReward1.id: 2, addOnReward2.id: 1],
        selectedLocationId: nil,
        refTag: .activity,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      let paymentSourceSelected = PaymentSourceSelected.savedCreditCard("123", "pm_fake")

      self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

      self.processingViewIsHidden.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])

      self.vm.inputs.submitButtonTapped()

      self.processingViewIsHidden.assertLastValue(false)
      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      self.scheduler.run()

      self.processingViewIsHidden.assertValues([false, true])
      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false, true])

      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      let checkoutData = KSRAnalytics.CheckoutPropertiesData(
        addOnsCountTotal: 0,
        addOnsCountUnique: 0,
        addOnsMinimumUsd: 0.00,
        bonusAmountInUsd: 25.00,
        checkoutId: "1",
        estimatedDelivery: reward.estimatedDeliveryOn,
        paymentType: "credit_card",
        revenueInUsd: 35.00,
        rewardId: String(reward.id),
        rewardMinimumUsd: 10.00,
        rewardTitle: reward.title,
        shippingEnabled: reward.shipping.enabled,
        shippingAmountUsd: nil,
        userHasStoredApplePayCard: true
      )

      self.goToThanksProject.assertValues([.template])
      self.goToThanksReward.assertValues([reward])
      self.goToThanksCheckoutData.assertValues([checkoutData])

      XCTAssertEqual(
        ["Page Viewed", "CTA Clicked"],
        self.segmentTrackingClient.events
      )
    }
  }

  func testCreateBacking_WithNewPaymentSheetCard_TappedApplePayButton_Success() {
    let createBacking = CreateBackingEnvelope.CreateBacking(
      checkout: Checkout(
        id: "Q2hlY2tvdXQtMQ==",
        state: .successful,
        backing: .init(clientSecret: nil, requiresAction: false)
      )
    )
    let mockService = MockService(
      createBackingResult:
      Result.success(CreateBackingEnvelope(createBacking: createBacking))
    )

    withEnvironment(apiService: mockService, currentUser: .template) {
      let project = Project.template
      let reward = Reward.template
        |> Reward.lens.hasAddOns .~ true
        |> Reward.lens.id .~ 99
      let addOnReward1 = Reward.template
        |> Reward.lens.id .~ 1
      let addOnReward2 = Reward.template
        |> Reward.lens.id .~ 2

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        bonusSupport: 25.00,
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1, addOnReward1.id: 1, addOnReward2.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      let paymentSourceSelected = PaymentSourceSelected.savedCreditCard("123", "pm_fake")

      self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])

      self.processingViewIsHidden.assertDidNotEmitValue()

      self.vm.inputs.applePayButtonTapped()

      self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
        paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345")
      )

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.success,
        self.vm.inputs.stripeTokenCreated(token: "stripe_token", error: nil)
      )

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      self.scheduler.run()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])

      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      let checkoutData = KSRAnalytics.CheckoutPropertiesData(
        addOnsCountTotal: 0,
        addOnsCountUnique: 0,
        addOnsMinimumUsd: 0.00,
        bonusAmountInUsd: 25.00,
        checkoutId: "1",
        estimatedDelivery: reward.estimatedDeliveryOn,
        paymentType: "apple_pay",
        revenueInUsd: 35.00,
        rewardId: String(reward.id),
        rewardMinimumUsd: 10.00,
        rewardTitle: reward.title,
        shippingEnabled: reward.shipping.enabled,
        shippingAmountUsd: nil,
        userHasStoredApplePayCard: true
      )

      self.goToThanksProject.assertValues([project])
      self.goToThanksReward.assertValues([reward])
      self.goToThanksCheckoutData.assertValues([checkoutData])

      XCTAssertEqual(
        ["Page Viewed", "CTA Clicked"],
        self.segmentTrackingClient.events
      )
    }
  }

  // MARK: - Tracking

  func testTrackingEvents_CheckoutPaymentPageViewed_AdvertisingConsentNotAllowed_EventsNotTracked() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.shipping .~ (.template |> Reward.Shipping.lens.enabled .~ true)
      |> Reward.lens.endsAt .~ MockDate().addingTimeInterval(5).timeIntervalSince1970

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedShippingRule: shippingRule,
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: nil,
      context: .pledge
    )

    (self.appTrackingTransparency as? MockAppTrackingTransparency)?.shouldRequestAuthStatus = false
    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    XCTAssertNil(self.segmentTrackingClient.properties.last)
  }

  func testTrackingEvents_ChangePaymentMethod_AdvertisingConsentAllowed_EventsTracked() {
    let project = Project.template
    let reward = Reward.template

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedShippingRule: shippingRule,
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: nil,
      context: .changePaymentMethod
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual(["Page Viewed"], self.segmentTrackingClient.events)
    XCTAssertEqual(self.segmentTrackingClient.properties(forKey: "context_page"), ["change_payment"])

    self.vm.inputs.submitButtonTapped()

    XCTAssertEqual(["Page Viewed", "CTA Clicked"], self.segmentTrackingClient.events)
  }

  func testTrackingEvents_ContextIsUpdateReward() {
    let project = Project.template
    let reward = Reward.template

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedShippingRule: shippingRule,
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: nil,
      context: .updateReward
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    let segmentTrackingClientProps = self.segmentTrackingClient.properties.last

    XCTAssertEqual(["Page Viewed"], self.segmentTrackingClient.events)
    XCTAssertEqual("update_pledge", segmentTrackingClientProps?["context_page"] as? String)

    // Checkout properties

    XCTAssertEqual("credit_card", segmentTrackingClientProps?["checkout_payment_type"] as? String)
    XCTAssertEqual("My Reward", segmentTrackingClientProps?["checkout_reward_title"] as? String)
    XCTAssertEqual(10.00, segmentTrackingClientProps?["checkout_reward_minimum_usd"] as? Decimal)
    XCTAssertEqual("1", segmentTrackingClientProps?["checkout_reward_id"] as? String)
    XCTAssertEqual(10.00, segmentTrackingClientProps?["checkout_amount_total_usd"] as? Decimal)
    XCTAssertEqual(true, segmentTrackingClientProps?["checkout_reward_is_limited_quantity"] as? Bool)
    XCTAssertEqual(
      true,
      segmentTrackingClientProps?["checkout_user_has_eligible_stored_apple_pay_card"] as? Bool
    )

    self.vm.inputs.submitButtonTapped()

    XCTAssertEqual(
      ["Page Viewed", "CTA Clicked"],
      self.segmentTrackingClient.events
    )
  }

  func testTrackingEvents_PledgeScreenViewed_LoggedOut() {
    let project = Project.template
      |> \.category.analyticsName .~ Project.Category.illustration.name
      |> \.category.name .~ Project.Category.illustration.name
      |> \.category.parentId .~ Project.Category.art.id
      |> \.category.parentName .~ Project.Category.art.name

    let reward = Reward.template

    let segmentClient = MockTrackingClient()

    let ksrAnalytics = KSRAnalytics(
      config: .template,
      loggedInUser: nil,
      segmentClient: segmentClient,
      appTrackingTransparency: MockAppTrackingTransparency()
    )

    withEnvironment(currentUser: nil, ksrAnalytics: ksrAnalytics) {
      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .discovery,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)

      XCTAssertEqual([], self.segmentTrackingClient.events)
      self.vm.inputs.viewDidLoad()

      XCTAssertEqual(["Page Viewed"], segmentClient.events)

      XCTAssertEqual(segmentClient.properties(forKey: "session_ref_tag"), ["discovery"])

      XCTAssertEqual(segmentClient.properties(forKey: "session_user_is_logged_in", as: Bool.self), [false])
      XCTAssertEqual(segmentClient.properties(forKey: "user_uid", as: Int.self), [nil])

      XCTAssertEqual(segmentClient.properties(forKey: "project_subcategory"), ["Illustration"])
      XCTAssertEqual(segmentClient.properties(forKey: "project_category"), ["Art"])
    }
  }

  func testTrackingEvents_PledgeScreenViewed_LoggedIn() {
    let user = User.template
      |> \.location .~ Location.template
      |> \.stats.backedProjectsCount .~ 50
      |> \.stats.createdProjectsCount .~ 25
      |> \.facebookConnected .~ true

    let segmentClient = MockTrackingClient()
    let ksrAnalytics = KSRAnalytics(
      config: .template,
      loggedInUser: user,
      segmentClient: segmentClient,
      appTrackingTransparency: MockAppTrackingTransparency()
    )

    withEnvironment(currentUser: user, ksrAnalytics: ksrAnalytics) {
      let project = Project.template
        |> \.category.name .~ Project.Category.illustration.name
        |> \.category.analyticsName .~ Project.Category.illustration.name
        |> \.category.parentId .~ Project.Category.art.id
        |> \.category.parentName .~ Project.Category.art.name
        |> Project.lens.stats.currentCurrency .~ "USD"
        |> \.personalization.isStarred .~ true

      let reward = Reward.template

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .discovery,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)

      XCTAssertEqual([], self.segmentTrackingClient.events)
      self.vm.inputs.viewDidLoad()

      XCTAssertEqual(["Page Viewed"], segmentClient.events)

      XCTAssertEqual(segmentClient.properties(forKey: "session_ref_tag"), ["discovery"])
      XCTAssertEqual(
        segmentClient.properties(forKey: "session_user_is_logged_in", as: Bool.self),
        [true]
      )
      XCTAssertEqual(segmentClient.properties(forKey: "user_uid", as: String.self), ["1"])

      XCTAssertEqual(segmentClient.properties(forKey: "project_subcategory"), ["Illustration"])
      XCTAssertEqual(segmentClient.properties(forKey: "project_category"), ["Art"])
      XCTAssertEqual(segmentClient.properties(forKey: "project_country"), ["US"])
      XCTAssertEqual(
        segmentClient.properties(forKey: "project_user_has_watched", as: Bool.self),
        [true]
      )
    }
  }

  func testTrackingEvents_PledgeSubmitButtonClicked() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      bonusSupport: 40.0,
      selectedShippingRule: shippingRule,
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: .discovery,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual(["Page Viewed"], self.segmentTrackingClient.events)

    let paymentSourceSelected = PaymentSourceSelected.savedCreditCard("123", "pm_fake")

    self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

    self.vm.inputs.submitButtonTapped()

    XCTAssertEqual(
      ["Page Viewed", "CTA Clicked"],
      self.segmentTrackingClient.events
    )

    let segmentClientProps = self.segmentTrackingClient.properties.last

    // Checkout properties

    XCTAssertEqual("credit_card", segmentClientProps?["checkout_payment_type"] as? String)
    XCTAssertEqual("1", segmentClientProps?["checkout_reward_id"] as? String)
    XCTAssertEqual(55.00, segmentClientProps?["checkout_amount_total_usd"] as? Decimal)
    XCTAssertEqual(true, segmentClientProps?["checkout_reward_is_limited_quantity"] as? Bool)
    XCTAssertEqual(true, segmentClientProps?["checkout_reward_shipping_enabled"] as? Bool)
    XCTAssertEqual(true, segmentClientProps?["checkout_user_has_eligible_stored_apple_pay_card"] as? Bool)
    XCTAssertEqual(
      "2017-10-01T22:35:15Z",
      segmentClientProps?["checkout_reward_estimated_delivery_on"] as? String
    )
    XCTAssertEqual("My Reward", segmentClientProps?["checkout_reward_title"] as? String)

    // Project properties
    XCTAssertEqual("1", segmentClientProps?["project_pid"] as? String)

    XCTAssertEqual("discovery", segmentClientProps?["session_ref_tag"] as? String)

    // Context properties

    XCTAssertEqual(
      KSRAnalytics.CTAContext.pledgeSubmit.trackingString,
      segmentClientProps?["context_cta"] as? String
    )

    XCTAssertEqual(
      KSRAnalytics.TypeContext.creditCard.trackingString,
      segmentClientProps?["context_type"] as? String
    )
  }

  func testTrackingEvents_UpdatePledgeButtonSubmit_ContextIsFixPayment() {
    let mockService = MockService(serverConfig: ServerConfig.staging)

    withEnvironment(apiService: mockService, currentUser: .template) {
      let backing = Backing.template
        |> Backing.lens.amount .~ 100
        |> Backing.lens.locationId .~ .some(123)
        |> Backing.lens.status .~ .errored
      let project = Project.template
        |> Project.lens.personalization.backing .~ backing
      let reward = Reward.template
        |> Reward.lens.shipping.enabled .~ true
        |> Reward.lens.minimum .~ 10.00

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: nil,
        context: .fixPaymentMethod
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      let paymentSourceSelected = PaymentSourceSelected.savedCreditCard("12345", "pm_fake")

      self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

      XCTAssertEqual([], self.segmentTrackingClient.events)

      self.vm.inputs.submitButtonTapped()

      XCTAssertEqual(
        ["CTA Clicked"],
        self.segmentTrackingClient.events
      )
    }
  }

  func testShowPledgeOverTimeUI_False() {
    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.pledgeOverTime.rawValue: false
    ]

    withEnvironment(remoteConfigClient: mockConfigClient) {
      let project = Project.template
        |> Project.lens.isPledgeOverTimeAllowed .~ false
      let reward = Reward.template

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.showPledgeOverTimeUI.assertLastValue(false)
      self.pledgeOverTimeConfigData.assertDidNotEmitValue()
      self.plotSelectedPlan.assertDidNotEmitValue()
    }
  }

  func testPledgeOverTime_PledgeInFullSelected() {
    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.pledgeOverTime.rawValue: true
    ]

    let mockQuery = try! GraphAPI.BuildPaymentPlanQuery
      .Data(jsonString: buildPaymentPlanQueryJson(eligible: true))
    let mockService = MockService(buildPaymentPlanResult: .success(mockQuery))

    withEnvironment(apiService: mockService, remoteConfigClient: mockConfigClient) {
      let project = Project.template
        |> Project.lens.isPledgeOverTimeAllowed .~ true
      let reward = Reward.template

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.paymentPlanSelected(.pledgeInFull)
      self.vm.inputs.viewDidLoad()

      self.showPledgeOverTimeUI.assertLastValue(true)
      self.pledgeOverTimeConfigData.assertDidEmitValue()
      self.plotSelectedPlan.assertValues([.pledgeInFull, .pledgeInFull])
    }
  }

  func testPledgeOverTime_PledgeOverTimeSelected() {
    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.pledgeOverTime.rawValue: true
    ]

    let mockQuery = try! GraphAPI.BuildPaymentPlanQuery
      .Data(jsonString: buildPaymentPlanQueryJson(eligible: true))
    let mockService = MockService(buildPaymentPlanResult: .success(mockQuery))

    withEnvironment(apiService: mockService, remoteConfigClient: mockConfigClient) {
      let project = Project.template
        |> Project.lens.isPledgeOverTimeAllowed .~ true
      let reward = Reward.template

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.paymentPlanSelected(.pledgeOverTime)

      self.showPledgeOverTimeUI.assertLastValue(true)
      self.pledgeOverTimeConfigData.assertDidEmitValue()
      self.plotSelectedPlan.assertValues([.pledgeInFull, .pledgeOverTime])
    }
  }

  func testPledgeOverTimeConfigData_LoadsAfterBuildPledgeQuery() {
    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.pledgeOverTime.rawValue: true
    ]

    let mockQuery = try! GraphAPI.BuildPaymentPlanQuery
      .Data(jsonString: buildPaymentPlanQueryJson(eligible: true))
    let mockService = MockService(buildPaymentPlanResult: .success(mockQuery))

    withEnvironment(apiService: mockService, remoteConfigClient: mockConfigClient) {
      let project = Project.template
        |> Project.lens.isPledgeOverTimeAllowed .~ true
      let reward = Reward.template

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.paymentPlanSelected(.pledgeInFull)
      self.vm.inputs.viewDidLoad()

      self.showPledgeOverTimeUI.assertLastValue(true)
      self.pledgeOverTimeConfigData.assertDidEmitValue()

      let configValue = self.pledgeOverTimeConfigData.lastValue

      XCTAssertEqual(configValue!.selectedPlan, .pledgeInFull)
      XCTAssertFalse(configValue!.ineligible)
      XCTAssertEqual(configValue!.paymentIncrements.count, 1)

      let paymentSourceSelected = PaymentSourceSelected.savedCreditCard("123", "pm_fake")
      self.vm.inputs.creditCardSelected(with: paymentSourceSelected)
      // Should be true, since pledge over time loaded and everything else is correct
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(true)
    }
  }

  func testShowPledgeOverTimeUI_IsFalseWhenBuildPaymentPlanQueryFails() {
    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.pledgeOverTime.rawValue: true
    ]

    let mockService = MockService(buildPaymentPlanResult: .failure(.couldNotParseJSON))

    withEnvironment(apiService: mockService, remoteConfigClient: mockConfigClient) {
      let project = Project.template
        |> Project.lens.isPledgeOverTimeAllowed .~ true
      let reward = Reward.template

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.showPledgeOverTimeUI.assertValues([true, false])
      self.pledgeOverTimeConfigData.assertDidNotEmitValue()

      let paymentSourceSelected = PaymentSourceSelected.savedCreditCard("123", "pm_fake")
      self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

      // Should be true, since pledge over time never loaded and everything else is correct
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(true)
    }
  }

  func testPledgeIsDisabled_whenShowPledgeOverUIIsTrue_andPledgeOverTimeIsLoading() {
    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.pledgeOverTime.rawValue: true
    ]

    withEnvironment(remoteConfigClient: mockConfigClient) {
      let project = Project.template
        |> Project.lens.isPledgeOverTimeAllowed .~ true
      let reward = Reward.template

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.showPledgeOverTimeUI.assertLastValue(true)

      // Hasn't loaded yet
      self.pledgeOverTimeConfigData.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)

      let paymentSourceSelected = PaymentSourceSelected.savedCreditCard("123", "pm_fake")
      self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

      // Should still be disabled, since pledge over time never loaded
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
    }
  }

  func testCreateBacking_projectEligibleForPledgeOverTime_Success() {
    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.pledgeOverTime.rawValue: true
    ]

    let createBacking = CreateBackingEnvelope.CreateBacking(
      checkout: Checkout(
        id: "Q2hlY2tvdXQtMQ==",
        state: .verifying,
        backing: .init(clientSecret: nil, requiresAction: false)
      )
    )

    let buildPaymentPlan = try! GraphAPI.BuildPaymentPlanQuery
      .Data(jsonString: buildPaymentPlanQueryJson(eligible: true))

    let mockService = MockService(
      buildPaymentPlanResult: Result.success(buildPaymentPlan),
      createBackingResult: Result.success(CreateBackingEnvelope(createBacking: createBacking))
    )

    withEnvironment(apiService: mockService, currentUser: .template, remoteConfigClient: mockConfigClient) {
      let shippingRule = ShippingRule.template

      let reward = Reward.template
        |> Reward.lens.id .~ 1
        |> Reward.lens.hasAddOns .~ true
        |> Reward.lens.minimum .~ 10.0
        |> Reward.lens.shipping.enabled .~ true
        |> Reward.lens.shipping.preference .~ Reward.Shipping.Preference.unrestricted
        |> Reward.lens.shippingRules .~ [shippingRule]

      let addOn1 = Reward.template
        |> Reward.lens.id .~ 2
        |> Reward.lens.minimum .~ 5.0
        |> Reward.lens.shipping.enabled .~ true
        |> Reward.lens.shipping.preference .~ Reward.Shipping.Preference.restricted
        |> Reward.lens.shippingRules .~ [shippingRule]

      let addOn2 = Reward.template
        |> Reward.lens.id .~ 3
        |> Reward.lens.minimum .~ 8.0
        |> Reward.lens.shipping.enabled .~ false

      let project = Project.template
        |> Project.lens.rewardData.rewards .~ [reward]
        |> Project.lens.rewardData.addOns .~ [addOn1, addOn2]
        |> Project.lens.isPledgeOverTimeAllowed .~ true

      let data = PledgeViewData(
        project: project,
        rewards: [reward, addOn1, addOn2],
        bonusSupport: 15.00,
        selectedShippingRule: shippingRule,
        selectedQuantities: [reward.id: 1, addOn1.id: 2, addOn2.id: 1],
        selectedLocationId: shippingRule.location.id,
        refTag: .activity,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertLastValue(false)
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      let paymentSourceSelected = PaymentSourceSelected.savedCreditCard("123", "pm_fake")

      self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

      self.processingViewIsHidden.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])

      self.vm.inputs.paymentPlanSelected(.pledgeOverTime)

      self.vm.inputs.submitButtonTapped()

      self.processingViewIsHidden.assertLastValue(false)
      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      self.scheduler.run()

      self.processingViewIsHidden.assertValues([false, true])
      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false, true])

      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      let checkoutData = KSRAnalytics.CheckoutPropertiesData(
        addOnsCountTotal: 3,
        addOnsCountUnique: 2,
        addOnsMinimumUsd: 18.00,
        bonusAmountInUsd: 15.00,
        checkoutId: "1",
        estimatedDelivery: reward.estimatedDeliveryOn,
        paymentType: "credit_card",
        revenueInUsd: 58.00,
        rewardId: String(reward.id),
        rewardMinimumUsd: 10.00,
        rewardTitle: reward.title,
        shippingEnabled: true,
        shippingAmountUsd: 15.0,
        userHasStoredApplePayCard: true
      )

      self.goToThanksProject.assertValues([.template])
      self.goToThanksReward.assertValues([.template])
      self.goToThanksCheckoutData.assertValues([checkoutData])

      XCTAssertEqual(
        ["Page Viewed", "CTA Clicked"],
        self.segmentTrackingClient.events
      )
    }
  }
}
