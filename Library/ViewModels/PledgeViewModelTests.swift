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

final class PledgeViewModelTests: TestCase {
  private let vm: PledgeViewModelType = PledgeViewModel()

  private let beginSCAFlowWithClientSecret = TestObserver<String, Never>()

  private let configureExpandableRewardsHeaderWithDataRewards = TestObserver<[Reward], Never>()
  private let configureExpandableRewardsHeaderWithDataSelectedQuantities
    = TestObserver<SelectedRewardQuantities, Never>()
  private let configureExpandableRewardsHeaderWithDataProjectCurrencyCountry = TestObserver<
    Project.Country,
    Never
  >()
  private let configureExpandableRewardsHeaderWithDataOmitCurrencyCode = TestObserver<Bool, Never>()
  private let configureLocalPickupViewWithData = TestObserver<PledgeLocalPickupViewData, Never>()
  private let configurePaymentMethodsViewControllerWithUser = TestObserver<User, Never>()
  private let configurePaymentMethodsViewControllerWithProject = TestObserver<Project, Never>()
  private let configurePaymentMethodsViewControllerWithReward = TestObserver<Reward, Never>()
  private let configurePaymentMethodsViewControllerWithContext = TestObserver<PledgeViewContext, Never>()

  private let configurePledgeViewCTAContainerViewIsLoggedIn = TestObserver<Bool, Never>()
  private let configurePledgeViewCTAContainerViewIsEnabled = TestObserver<Bool, Never>()
  private let configurePledgeViewCTAContainerViewContext = TestObserver<PledgeViewContext, Never>()
  private let configurePledgeViewCTAContainerViewWillRetryPaymentMethod = TestObserver<Bool, Never>()

  private let configureShippingSummaryViewWithData = TestObserver<PledgeShippingSummaryViewData, Never>()

  private let configureStripeIntegrationMerchantId = TestObserver<String, Never>()
  private let configureStripeIntegrationPublishableKey = TestObserver<String, Never>()

  private let configureSummaryViewControllerWithDataConfirmationLabelHidden = TestObserver<Bool, Never>()
  private let configureSummaryViewControllerWithDataPledgeTotal = TestObserver<Double, Never>()
  private let configureSummaryViewControllerWithDataProject = TestObserver<Project, Never>()

  private let configureShippingLocationViewWithDataProject = TestObserver<Project, Never>()
  private let configureShippingLocationViewWithDataReward = TestObserver<Reward, Never>()
  private let configureShippingLocationViewWithDataShowAmount = TestObserver<Bool, Never>()

  private let descriptionSectionSeparatorHidden = TestObserver<Bool, Never>()
  private let expandableRewardsHeaderViewHidden = TestObserver<Bool, Never>()

  private let goToApplePayPaymentAuthorizationProject = TestObserver<Project, Never>()
  private let goToApplePayPaymentAuthorizationReward = TestObserver<Reward, Never>()
  private let goToApplePayPaymentAuthorizationAllRewardsTotal = TestObserver<Double, Never>()
  private let goToApplePayPaymentAuthorizationAdditionalPledgeAmount = TestObserver<Double, Never>()
  private let goToApplePayPaymentAuthorizationShippingTotal = TestObserver<Double, Never>()
  private let goToApplePayPaymentAuthorizationMerchantId = TestObserver<String, Never>()
  private let goToRiskMessagingModal = TestObserver<Bool, Never>()
  private let goToThanksCheckoutData = TestObserver<KSRAnalytics.CheckoutPropertiesData?, Never>()
  private let goToThanksProject = TestObserver<Project, Never>()
  private let goToThanksReward = TestObserver<Reward, Never>()
  private let localPickupViewHidden = TestObserver<Bool, Never>()
  private let notifyDelegateUpdatePledgeDidSucceedWithMessage = TestObserver<String, Never>()

  private let paymentMethodsViewHidden = TestObserver<Bool, Never>()
  private let pledgeAmountViewHidden = TestObserver<Bool, Never>()
  private let pledgeAmountSummaryViewHidden = TestObserver<Bool, Never>()
  private let popToRootViewController = TestObserver<(), Never>()
  private let processingViewIsHidden = TestObserver<Bool, Never>()
  private let projectTitle = TestObserver<String, Never>()
  private let projectTitleLabelHidden = TestObserver<Bool, Never>()
  private let shippingLocationViewHidden = TestObserver<Bool, Never>()
  private let shippingSummaryViewHidden = TestObserver<Bool, Never>()
  private let showApplePayAlertMessage = TestObserver<String, Never>()
  private let showApplePayAlertTitle = TestObserver<String, Never>()
  private let showErrorBannerWithMessage = TestObserver<String, Never>()
  private let showWebHelp = TestObserver<HelpType, Never>()
  private let summarySectionSeparatorHidden = TestObserver<Bool, Never>()
  private let rootStackViewLayoutMargins = TestObserver<UIEdgeInsets, Never>()
  private let title = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.beginSCAFlowWithClientSecret.observe(self.beginSCAFlowWithClientSecret.observer)

    self.vm.outputs.configureExpandableRewardsHeaderWithData.map(\.rewards)
      .observe(self.configureExpandableRewardsHeaderWithDataRewards.observer)
    self.vm.outputs.configureExpandableRewardsHeaderWithData.map(\.selectedQuantities)
      .observe(self.configureExpandableRewardsHeaderWithDataSelectedQuantities.observer)
    self.vm.outputs.configureExpandableRewardsHeaderWithData.map(\.projectCountry)
      .observe(self.configureExpandableRewardsHeaderWithDataProjectCurrencyCountry.observer)
    self.vm.outputs.configureExpandableRewardsHeaderWithData.map(\.omitCurrencyCode)
      .observe(self.configureExpandableRewardsHeaderWithDataOmitCurrencyCode.observer)
    self.vm.outputs.configureLocalPickupViewWithData.observe(self.configureLocalPickupViewWithData.observer)
    self.vm.outputs.configurePaymentMethodsViewControllerWithValue.map { $0.0 }
      .observe(self.configurePaymentMethodsViewControllerWithUser.observer)
    self.vm.outputs.configurePaymentMethodsViewControllerWithValue.map { $0.1 }
      .observe(self.configurePaymentMethodsViewControllerWithProject.observer)
    self.vm.outputs.configurePaymentMethodsViewControllerWithValue.map { $0.2 }
      .observe(self.configurePaymentMethodsViewControllerWithReward.observer)
    self.vm.outputs.configurePaymentMethodsViewControllerWithValue.map { $0.3 }
      .observe(self.configurePaymentMethodsViewControllerWithContext.observer)

    self.vm.outputs.configurePledgeViewCTAContainerView.map { $0.0 }
      .observe(self.configurePledgeViewCTAContainerViewIsLoggedIn.observer)
    self.vm.outputs.configurePledgeViewCTAContainerView.map { $0.1 }
      .observe(self.configurePledgeViewCTAContainerViewIsEnabled.observer)
    self.vm.outputs.configurePledgeViewCTAContainerView.map { $0.2 }
      .observe(self.configurePledgeViewCTAContainerViewContext.observer)
    self.vm.outputs.configurePledgeViewCTAContainerView.map { $0.3 }
      .observe(self.configurePledgeViewCTAContainerViewWillRetryPaymentMethod.observer)

    self.vm.outputs.configureSummaryViewControllerWithData.map { $0.2 }
      .observe(self.configureSummaryViewControllerWithDataConfirmationLabelHidden.observer)
    self.vm.outputs.configureSummaryViewControllerWithData.map { $0.1 }
      .observe(self.configureSummaryViewControllerWithDataPledgeTotal.observer)
    self.vm.outputs.configureSummaryViewControllerWithData.map { $0.0 }
      .observe(self.configureSummaryViewControllerWithDataProject.observer)

    self.vm.outputs.configureShippingLocationViewWithData.map { $0.project }
      .observe(self.configureShippingLocationViewWithDataProject.observer)
    self.vm.outputs.configureShippingLocationViewWithData.map { $0.reward }
      .observe(self.configureShippingLocationViewWithDataReward.observer)
    self.vm.outputs.configureShippingLocationViewWithData.map { $0.showAmount }
      .observe(self.configureShippingLocationViewWithDataShowAmount.observer)

    self.vm.outputs.configureShippingSummaryViewWithData
      .observe(self.configureShippingSummaryViewWithData.observer)

    self.vm.outputs.configureStripeIntegration.map(first)
      .observe(self.configureStripeIntegrationMerchantId.observer)
    self.vm.outputs.configureStripeIntegration.map(second)
      .observe(self.configureStripeIntegrationPublishableKey.observer)

    self.vm.outputs.projectTitle.observe(self.projectTitle.observer)
    self.vm.outputs.projectTitleLabelHidden.observe(self.projectTitleLabelHidden.observer)
    self.vm.outputs.descriptionSectionSeparatorHidden.observe(self.descriptionSectionSeparatorHidden.observer)
    self.vm.outputs.expandableRewardsHeaderViewHidden.observe(self.expandableRewardsHeaderViewHidden.observer)

    self.vm.outputs.goToApplePayPaymentAuthorization.map { $0.project }
      .observe(self.goToApplePayPaymentAuthorizationProject.observer)
    self.vm.outputs.goToApplePayPaymentAuthorization.map { $0.reward }
      .observe(self.goToApplePayPaymentAuthorizationReward.observer)
    self.vm.outputs.goToApplePayPaymentAuthorization.map { $0.allRewardsTotal }
      .observe(self.goToApplePayPaymentAuthorizationAllRewardsTotal.observer)
    self.vm.outputs.goToApplePayPaymentAuthorization.map { $0.additionalPledgeAmount }
      .observe(self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.observer)
    self.vm.outputs.goToApplePayPaymentAuthorization.map { $0.allRewardsShippingTotal }
      .observe(self.goToApplePayPaymentAuthorizationShippingTotal.observer)
    self.vm.outputs.goToApplePayPaymentAuthorization.map { $0.merchantIdentifier }
      .observe(self.goToApplePayPaymentAuthorizationMerchantId.observer)

    self.vm.outputs.goToRiskMessagingModal.observe(self.goToRiskMessagingModal.observer)

    self.vm.outputs.goToThanks.map(first).observe(self.goToThanksProject.observer)
    self.vm.outputs.goToThanks.map(second).observe(self.goToThanksReward.observer)
    self.vm.outputs.goToThanks.map(third).observe(self.goToThanksCheckoutData.observer)
    self.vm.outputs.localPickupViewHidden.observe(self.localPickupViewHidden.observer)

    self.vm.outputs.notifyDelegateUpdatePledgeDidSucceedWithMessage
      .observe(self.notifyDelegateUpdatePledgeDidSucceedWithMessage.observer)

    self.vm.outputs.paymentMethodsViewHidden.observe(self.paymentMethodsViewHidden.observer)
    self.vm.outputs.pledgeAmountViewHidden.observe(self.pledgeAmountViewHidden.observer)
    self.vm.outputs.pledgeAmountSummaryViewHidden.observe(self.pledgeAmountSummaryViewHidden.observer)
    self.vm.outputs.popToRootViewController.observe(self.popToRootViewController.observer)
    self.vm.outputs.processingViewIsHidden.observe(self.processingViewIsHidden.observer)

    self.vm.outputs.rootStackViewLayoutMargins.observe(self.rootStackViewLayoutMargins.observer)

    self.vm.outputs.summarySectionSeparatorHidden.observe(self.summarySectionSeparatorHidden.observer)
    self.vm.outputs.shippingLocationViewHidden.observe(self.shippingLocationViewHidden.observer)
    self.vm.outputs.shippingSummaryViewHidden.observe(self.shippingSummaryViewHidden.observer)
    self.vm.outputs.showApplePayAlert.map(second).observe(self.showApplePayAlertMessage.observer)
    self.vm.outputs.showApplePayAlert.map(first).observe(self.showApplePayAlertTitle.observer)
    self.vm.outputs.showWebHelp.observe(self.showWebHelp.observer)
    self.vm.outputs.showErrorBannerWithMessage.observe(self.showErrorBannerWithMessage.observer)

    self.vm.outputs.title.observe(self.title.observer)
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
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.title.assertValues(["Back this project"])

      self.configureExpandableRewardsHeaderWithDataRewards.assertValues([[reward]])
      self.configureExpandableRewardsHeaderWithDataProjectCurrencyCountry.assertValues([.us])
      self.configureExpandableRewardsHeaderWithDataOmitCurrencyCode.assertValues([true])

      self.configurePaymentMethodsViewControllerWithUser.assertValues([User.template])
      self.configurePaymentMethodsViewControllerWithProject.assertValues([project])
      self.configurePaymentMethodsViewControllerWithReward.assertValues([reward])
      self.configurePaymentMethodsViewControllerWithContext.assertValues([.pledge])

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertValues([true])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.configurePledgeViewCTAContainerViewContext.assertValues([.pledge])

      self.configureStripeIntegrationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])
      self.configureStripeIntegrationPublishableKey.assertValues([Secrets.StripePublishableKey.staging])

      self.configureSummaryViewControllerWithDataConfirmationLabelHidden.assertValues([false])

      self.projectTitle.assertValues(["The Project"])
      self.projectTitleLabelHidden.assertValues([true])
      self.expandableRewardsHeaderViewHidden.assertValues([false])
      self.rootStackViewLayoutMargins.assertValues([.init(bottom: Styles.grid(3))])

      self.configureShippingLocationViewWithDataProject.assertValues([project])
      self.configureShippingLocationViewWithDataReward.assertValues([reward])
      self.configureShippingLocationViewWithDataShowAmount.assertValues([true])

      self.paymentMethodsViewHidden.assertValues([false])
      self.pledgeAmountViewHidden.assertValues([false])
      self.pledgeAmountSummaryViewHidden.assertValues([true])
      self.descriptionSectionSeparatorHidden.assertValues([true])
      self.summarySectionSeparatorHidden.assertValues([false])
      self.shippingLocationViewHidden.assertValues([false])
      self.configureSummaryViewControllerWithDataPledgeTotal.assertValues([reward.minimum])
      self.configureSummaryViewControllerWithDataProject.assertValues([project])
    }
  }

  func testPledgeContext_NonUS_ProjectCurrency_US_ProjectCountry_LoggedIn() {
    let mockService = MockService(serverConfig: ServerConfig.staging)

    withEnvironment(apiService: mockService, currentUser: .template) {
      let project = Project.template
        |> Project.lens.country .~ .us
        |> Project.lens.stats.currency .~ Project.Country.mx.currencyCode
      let reward = Reward.template
        |> Reward.lens.shipping.enabled .~ true

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.title.assertValues(["Back this project"])

      self.configureExpandableRewardsHeaderWithDataProjectCurrencyCountry.assertValues([.mx])
      self.configureExpandableRewardsHeaderWithDataOmitCurrencyCode.assertValues([true])
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
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.title.assertValues(["Back this project"])

      self.configureExpandableRewardsHeaderWithDataRewards.assertValues([[reward]])
      self.configureExpandableRewardsHeaderWithDataProjectCurrencyCountry.assertValues([.us])
      self.configureExpandableRewardsHeaderWithDataOmitCurrencyCode.assertValues([true])

      self.configurePaymentMethodsViewControllerWithUser.assertDidNotEmitValue()
      self.configurePaymentMethodsViewControllerWithProject.assertDidNotEmitValue()
      self.configurePaymentMethodsViewControllerWithReward.assertDidNotEmitValue()
      self.configurePaymentMethodsViewControllerWithContext.assertDidNotEmitValue()

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertValues([false])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.configurePledgeViewCTAContainerViewContext.assertValues([.pledge])

      self.configureStripeIntegrationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])
      self.configureStripeIntegrationPublishableKey.assertValues([Secrets.StripePublishableKey.staging])

      self.configureSummaryViewControllerWithDataConfirmationLabelHidden.assertValues([false])

      self.projectTitle.assertValues(["The Project"])
      self.projectTitleLabelHidden.assertValues([true])
      self.expandableRewardsHeaderViewHidden.assertValues([false])
      self.rootStackViewLayoutMargins.assertValues([.init(bottom: Styles.grid(3))])

      self.configureShippingLocationViewWithDataProject.assertValues([project])
      self.configureShippingLocationViewWithDataReward.assertValues([reward])
      self.configureShippingLocationViewWithDataShowAmount.assertValues([true])

      self.paymentMethodsViewHidden.assertValues([true])
      self.pledgeAmountViewHidden.assertValues([false])
      self.pledgeAmountSummaryViewHidden.assertValues([true])
      self.descriptionSectionSeparatorHidden.assertValues([true])
      self.summarySectionSeparatorHidden.assertValues([false])
      self.shippingLocationViewHidden.assertValues([false])
      self.configureSummaryViewControllerWithDataPledgeTotal.assertValues([reward.minimum])
      self.configureSummaryViewControllerWithDataProject.assertValues([project])
    }
  }

  func testUpdateContext() {
    let mockService = MockService(serverConfig: ServerConfig.staging)

    withEnvironment(apiService: mockService, currentUser: .template) {
      let project = Project.template
      let reward = Reward.template
        |> Reward.lens.shipping.enabled .~ true

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .update
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.title.assertValues(["Update pledge"])

      self.configureExpandableRewardsHeaderWithDataRewards.assertValues([[reward]])
      self.configureExpandableRewardsHeaderWithDataProjectCurrencyCountry.assertValues([.us])
      self.configureExpandableRewardsHeaderWithDataOmitCurrencyCode.assertValues([true])

      self.configurePaymentMethodsViewControllerWithUser.assertDidNotEmitValue()
      self.configurePaymentMethodsViewControllerWithProject.assertDidNotEmitValue()
      self.configurePaymentMethodsViewControllerWithReward.assertDidNotEmitValue()
      self.configurePaymentMethodsViewControllerWithContext.assertDidNotEmitValue()

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertValues([true])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.configurePledgeViewCTAContainerViewContext.assertValues([.update])

      self.configureStripeIntegrationMerchantId.assertDidNotEmitValue()
      self.configureStripeIntegrationPublishableKey.assertDidNotEmitValue()

      self.configureSummaryViewControllerWithDataConfirmationLabelHidden.assertValues([false])

      self.projectTitle.assertValues(["The Project"])
      self.projectTitleLabelHidden.assertValues([true])
      self.expandableRewardsHeaderViewHidden.assertValues([true])
      self.rootStackViewLayoutMargins.assertValues([.init(topBottom: Styles.grid(3))])

      self.configureShippingLocationViewWithDataProject.assertValues([project])
      self.configureShippingLocationViewWithDataReward.assertValues([reward])
      self.configureShippingLocationViewWithDataShowAmount.assertValues([true])

      self.paymentMethodsViewHidden.assertValues([true])
      self.pledgeAmountViewHidden.assertValues([false])
      self.pledgeAmountSummaryViewHidden.assertValues([false])
      self.descriptionSectionSeparatorHidden.assertValues([true])
      self.summarySectionSeparatorHidden.assertValues([false])
      self.shippingLocationViewHidden.assertValues([false])
      self.configureSummaryViewControllerWithDataPledgeTotal.assertValues([reward.minimum])
      self.configureSummaryViewControllerWithDataProject.assertValues([project])
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
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .updateReward
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.title.assertValues(["Update pledge"])

      self.configureExpandableRewardsHeaderWithDataRewards.assertValues([[reward]])
      self.configureExpandableRewardsHeaderWithDataProjectCurrencyCountry.assertValues([.us])
      self.configureExpandableRewardsHeaderWithDataOmitCurrencyCode.assertValues([true])

      self.configurePaymentMethodsViewControllerWithUser.assertDidNotEmitValue()
      self.configurePaymentMethodsViewControllerWithProject.assertDidNotEmitValue()
      self.configurePaymentMethodsViewControllerWithReward.assertDidNotEmitValue()
      self.configurePaymentMethodsViewControllerWithContext.assertDidNotEmitValue()

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertValues([true])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.configurePledgeViewCTAContainerViewContext.assertValues([.updateReward])

      self.configureStripeIntegrationMerchantId.assertDidNotEmitValue()
      self.configureStripeIntegrationPublishableKey.assertDidNotEmitValue()

      self.configureSummaryViewControllerWithDataConfirmationLabelHidden.assertValues([true])

      self.projectTitle.assertValues(["The Project"])
      self.projectTitleLabelHidden.assertValues([true])
      self.expandableRewardsHeaderViewHidden.assertValues([false])
      self.rootStackViewLayoutMargins.assertValues([.init(bottom: Styles.grid(3))])

      self.configureShippingLocationViewWithDataProject.assertValues([project])
      self.configureShippingLocationViewWithDataReward.assertValues([reward])
      self.configureShippingLocationViewWithDataShowAmount.assertValues([true])

      self.paymentMethodsViewHidden.assertValues([true])
      self.pledgeAmountViewHidden.assertValues([false])
      self.pledgeAmountSummaryViewHidden.assertValues([true])
      self.descriptionSectionSeparatorHidden.assertValues([true])
      self.summarySectionSeparatorHidden.assertValues([false])
      self.shippingLocationViewHidden.assertValues([false])
      self.configureSummaryViewControllerWithDataPledgeTotal.assertValues([reward.minimum])
      self.configureSummaryViewControllerWithDataProject.assertValues([project])
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
        selectedQuantities: [reward.id: 1],
        selectedLocationId: shippingRule.location.id,
        refTag: .projectPage,
        context: .changePaymentMethod
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.title.assertValues(["Change payment method"])

      self.configureExpandableRewardsHeaderWithDataRewards.assertValues([[reward]])
      self.configureExpandableRewardsHeaderWithDataProjectCurrencyCountry.assertValues([.us])
      self.configureExpandableRewardsHeaderWithDataOmitCurrencyCode.assertValues([true])

      self.configurePaymentMethodsViewControllerWithUser.assertValues([User.template])
      self.configurePaymentMethodsViewControllerWithProject.assertValues([project])
      self.configurePaymentMethodsViewControllerWithReward.assertValues([reward])
      self.configurePaymentMethodsViewControllerWithContext.assertValues([.changePaymentMethod])

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertValues([true])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.configurePledgeViewCTAContainerViewContext.assertValues([.changePaymentMethod])

      self.configureSummaryViewControllerWithDataProject.assertValues([project])
      self.configureSummaryViewControllerWithDataPledgeTotal.assertValues([100.00])

      self.configureStripeIntegrationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])
      self.configureStripeIntegrationPublishableKey.assertValues([Secrets.StripePublishableKey.staging])

      self.configureSummaryViewControllerWithDataConfirmationLabelHidden.assertValues([true])

      self.projectTitle.assertValues(["The Project"])
      self.projectTitleLabelHidden.assertValues([true])
      self.expandableRewardsHeaderViewHidden.assertValues([true])
      self.rootStackViewLayoutMargins.assertValues([.init(topBottom: Styles.grid(3))])

      self.configureShippingLocationViewWithDataProject.assertDidNotEmitValue()
      self.configureShippingLocationViewWithDataReward.assertDidNotEmitValue()
      self.configureShippingLocationViewWithDataShowAmount.assertDidNotEmitValue()

      self.paymentMethodsViewHidden.assertValues([false])
      self.pledgeAmountViewHidden.assertValues([true])
      self.pledgeAmountSummaryViewHidden.assertValues([false])
      self.descriptionSectionSeparatorHidden.assertValues([true])
      self.summarySectionSeparatorHidden.assertValues([true])
      self.shippingLocationViewHidden.assertValues([true])

      let pledgeAmountData: PledgeAmountData = (amount: 70, min: 10.00, max: 10_000, isValid: true)
      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: pledgeAmountData)

      self.configureSummaryViewControllerWithDataPledgeTotal.assertValues([100, 90])
      self.configureSummaryViewControllerWithDataProject.assertValues([project, project])

      let newShippingRule = ShippingRule.template
        |> ShippingRule.lens.cost .~ 20

      self.vm.inputs.shippingRuleSelected(newShippingRule)

      self.configureSummaryViewControllerWithDataPledgeTotal.assertValues([100, 90, 100])
      self.configureSummaryViewControllerWithDataProject.assertValues([project, project, project])
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
        selectedQuantities: [reward.id: 1],
        selectedLocationId: shippingRule.location.id,
        refTag: .projectPage,
        context: .fixPaymentMethod
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.title.assertValues(["Fix payment method"])

      self.configureExpandableRewardsHeaderWithDataRewards.assertValues([[reward]])
      self.configureExpandableRewardsHeaderWithDataProjectCurrencyCountry.assertValues([.us])
      self.configureExpandableRewardsHeaderWithDataOmitCurrencyCode.assertValues([true])

      self.configurePaymentMethodsViewControllerWithUser.assertValues([User.template])
      self.configurePaymentMethodsViewControllerWithProject.assertValues([project])
      self.configurePaymentMethodsViewControllerWithReward.assertValues([reward])
      self.configurePaymentMethodsViewControllerWithContext.assertValues([.fixPaymentMethod])

      self.configureSummaryViewControllerWithDataProject.assertValues([project])
      self.configureSummaryViewControllerWithDataPledgeTotal.assertValues([100.00])

      self.configureStripeIntegrationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])
      self.configureStripeIntegrationPublishableKey.assertValues([Secrets.StripePublishableKey.staging])

      self.configurePledgeViewCTAContainerViewWillRetryPaymentMethod.assertValues([false])

      self.projectTitle.assertValues(["The Project"])
      self.projectTitleLabelHidden.assertValues([true])
      self.expandableRewardsHeaderViewHidden.assertValues([true])
      self.rootStackViewLayoutMargins.assertValues([.init(topBottom: Styles.grid(3))])

      self.configureShippingLocationViewWithDataProject.assertDidNotEmitValue()
      self.configureShippingLocationViewWithDataReward.assertDidNotEmitValue()
      self.configureShippingLocationViewWithDataShowAmount.assertDidNotEmitValue()

      self.configurePledgeViewCTAContainerViewWillRetryPaymentMethod.assertValues([false])
      self.paymentMethodsViewHidden.assertValues([false])
      self.pledgeAmountViewHidden.assertValues([true])
      self.pledgeAmountSummaryViewHidden.assertValues([false])
      self.descriptionSectionSeparatorHidden.assertValues([true])
      self.summarySectionSeparatorHidden.assertValues([true])
      self.shippingLocationViewHidden.assertValues([true])

      let paymentSourceSelected = PaymentSourceSelected(
        paymentSourceId: backing.paymentSource?.id ?? "",
        isSetupIntentClientSecret: false
      )

      self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

      self.configurePledgeViewCTAContainerViewWillRetryPaymentMethod.assertValues([false, true])

      let pledgeAmountData: PledgeAmountData = (amount: 70, min: 10.00, max: 10_000, isValid: true)
      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: pledgeAmountData)

      self.configureSummaryViewControllerWithDataPledgeTotal.assertValues([100, 90])
      self.configureSummaryViewControllerWithDataProject.assertValues([project, project])

      let newShippingRule = ShippingRule.template
        |> ShippingRule.lens.cost .~ 20

      self.vm.inputs.shippingRuleSelected(newShippingRule)

      self.configureSummaryViewControllerWithDataPledgeTotal.assertValues([100, 90, 100])
      self.configureSummaryViewControllerWithDataProject.assertValues([project, project, project])
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
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .changePaymentMethod
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.title.assertValues(["Change payment method"])

      self.configureExpandableRewardsHeaderWithDataRewards.assertDidNotEmitValue()
      self.configureExpandableRewardsHeaderWithDataProjectCurrencyCountry.assertDidNotEmitValue()
      self.configureExpandableRewardsHeaderWithDataOmitCurrencyCode.assertDidNotEmitValue()

      self.configurePaymentMethodsViewControllerWithUser.assertValues([User.template])
      self.configurePaymentMethodsViewControllerWithProject.assertValues([project])
      self.configurePaymentMethodsViewControllerWithReward.assertValues([reward])
      self.configurePaymentMethodsViewControllerWithContext.assertValues([.changePaymentMethod])

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertValues([true])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.configurePledgeViewCTAContainerViewContext.assertValues([.changePaymentMethod])

      self.configureSummaryViewControllerWithDataProject.assertValues([project])
      self.configureSummaryViewControllerWithDataPledgeTotal.assertValues([10])

      self.configureStripeIntegrationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])
      self.configureStripeIntegrationPublishableKey.assertValues([Secrets.StripePublishableKey.staging])

      self.configureSummaryViewControllerWithDataConfirmationLabelHidden.assertValues([true])

      self.projectTitle.assertValues(["The Project"])
      self.projectTitleLabelHidden.assertValues([true])
      self.expandableRewardsHeaderViewHidden.assertValues([true])
      self.rootStackViewLayoutMargins.assertValues([.init(topBottom: Styles.grid(3))])

      self.configureShippingLocationViewWithDataProject.assertDidNotEmitValue()
      self.configureShippingLocationViewWithDataReward.assertDidNotEmitValue()
      self.configureShippingLocationViewWithDataShowAmount.assertDidNotEmitValue()

      self.paymentMethodsViewHidden.assertValues([false])
      self.pledgeAmountViewHidden.assertValues([true])
      self.pledgeAmountSummaryViewHidden.assertValues([false])
      self.descriptionSectionSeparatorHidden.assertValues([true])
      self.summarySectionSeparatorHidden.assertValues([true])
      self.shippingLocationViewHidden.assertValues([true])

      let pledgeAmountData: PledgeAmountData = (amount: 12.0, min: 1.0, max: 10_000, isValid: true)

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: pledgeAmountData)

      self.configureSummaryViewControllerWithDataPledgeTotal.assertValues([10, 12])
      self.configureSummaryViewControllerWithDataProject.assertValues([project, project])
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

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertValues([false])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.configurePledgeViewCTAContainerViewContext.assertValues([.pledge])

      self.configureShippingLocationViewWithDataProject.assertDidNotEmitValue()
      self.configureShippingLocationViewWithDataReward.assertDidNotEmitValue()
      self.configureShippingLocationViewWithDataShowAmount.assertDidNotEmitValue()

      self.paymentMethodsViewHidden.assertValues([true])
      self.pledgeAmountViewHidden.assertValues([false])
      self.pledgeAmountSummaryViewHidden.assertValues([true])
      self.shippingLocationViewHidden.assertValues([true])
      self.configureSummaryViewControllerWithDataPledgeTotal.assertValues([reward.minimum])
      self.configureSummaryViewControllerWithDataProject.assertValues([project])
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

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertValues([false])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.configurePledgeViewCTAContainerViewContext.assertValues([.pledge])

      self.configureShippingLocationViewWithDataProject.assertValues([project])
      self.configureShippingLocationViewWithDataReward.assertValues([reward])
      self.configureShippingLocationViewWithDataShowAmount.assertValues([true])

      self.paymentMethodsViewHidden.assertValues([true])
      self.pledgeAmountViewHidden.assertValues([false])
      self.pledgeAmountSummaryViewHidden.assertValues([true])
      self.shippingLocationViewHidden.assertValues([false])

      self.configureSummaryViewControllerWithDataPledgeTotal.assertValues([reward.minimum])
      self.configureSummaryViewControllerWithDataProject.assertValues([project])
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

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertValues([true])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.configurePledgeViewCTAContainerViewContext.assertValues([.pledge])

      self.configureShippingLocationViewWithDataProject.assertDidNotEmitValue()
      self.configureShippingLocationViewWithDataReward.assertDidNotEmitValue()
      self.configureShippingLocationViewWithDataShowAmount.assertDidNotEmitValue()

      self.paymentMethodsViewHidden.assertValues([false])
      self.pledgeAmountViewHidden.assertValues([false])
      self.pledgeAmountSummaryViewHidden.assertValues([true])
      self.shippingLocationViewHidden.assertValues([true])
      self.configureSummaryViewControllerWithDataPledgeTotal.assertValues([reward.minimum])
      self.configureSummaryViewControllerWithDataProject.assertValues([project])
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

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertValues([true])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.configurePledgeViewCTAContainerViewContext.assertValues([.pledge])

      self.configureShippingLocationViewWithDataProject.assertValues([project])
      self.configureShippingLocationViewWithDataReward.assertValues([reward])
      self.configureShippingLocationViewWithDataShowAmount.assertValues([true])

      self.paymentMethodsViewHidden.assertValues([false])
      self.pledgeAmountViewHidden.assertValues([false])
      self.pledgeAmountSummaryViewHidden.assertValues([true])
      self.shippingLocationViewHidden.assertValues([false])
      self.configureSummaryViewControllerWithDataPledgeTotal.assertValues([reward.minimum])
      self.configureSummaryViewControllerWithDataProject.assertValues([project])
    }
  }

  func testShippingRuleSelectedDefaultShippingRule() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.shipping .~ (.template |> Reward.Shipping.lens.enabled .~ true)

    withEnvironment(currentUser: .template) {
      let data = PledgeViewData(
        project: project,
        rewards: [reward],
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

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertValues([true])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.configurePledgeViewCTAContainerViewContext.assertValues([.pledge])

      self.configureShippingLocationViewWithDataProject.assertValues([project])
      self.configureShippingLocationViewWithDataReward.assertValues([reward])
      self.configureShippingLocationViewWithDataShowAmount.assertValues([true])

      self.paymentMethodsViewHidden.assertValues([false])
      self.pledgeAmountViewHidden.assertValues([false])
      self.pledgeAmountSummaryViewHidden.assertValues([true])
      self.shippingLocationViewHidden.assertValues([false])
      self.configureSummaryViewControllerWithDataPledgeTotal.assertValues([reward.minimum])
      self.configureSummaryViewControllerWithDataProject.assertValues([project])

      let defaultShippingRule = ShippingRule.template
        |> ShippingRule.lens.cost .~ 5

      self.vm.inputs.shippingRuleSelected(defaultShippingRule)

      self.configureSummaryViewControllerWithDataPledgeTotal
        .assertValues([reward.minimum, reward.minimum + defaultShippingRule.cost])
      self.configureSummaryViewControllerWithDataProject.assertValues([project, project])
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

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertValues([true])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.configurePledgeViewCTAContainerViewContext.assertValues([.pledge])

      self.configureShippingLocationViewWithDataProject.assertValues([project])
      self.configureShippingLocationViewWithDataReward.assertValues([reward])
      self.configureShippingLocationViewWithDataShowAmount.assertValues([true])

      self.paymentMethodsViewHidden.assertValues([false])
      self.pledgeAmountViewHidden.assertValues([false])
      self.pledgeAmountSummaryViewHidden.assertValues([true])
      self.shippingLocationViewHidden.assertValues([false])
      self.configureSummaryViewControllerWithDataPledgeTotal.assertValues([reward.minimum])
      self.configureSummaryViewControllerWithDataProject.assertValues([project])

      let defaultShippingRule = ShippingRule.template
        |> ShippingRule.lens.cost .~ 5

      self.vm.inputs.shippingRuleSelected(defaultShippingRule)

      self.configureSummaryViewControllerWithDataPledgeTotal
        .assertValues([reward.minimum, reward.minimum + defaultShippingRule.cost])
      self.configureSummaryViewControllerWithDataProject.assertValues([project, project])

      let selectedShippingRule = ShippingRule.template
        |> ShippingRule.lens.cost .~ 5
        |> ShippingRule.lens.location .~ .australia

      self.vm.inputs.shippingRuleSelected(selectedShippingRule)

      self.configureSummaryViewControllerWithDataPledgeTotal.assertValues([
        reward.minimum,
        reward.minimum + defaultShippingRule.cost,
        reward.minimum + selectedShippingRule.cost
      ])
      self.configureSummaryViewControllerWithDataProject.assertValues([project, project, project])
    }
  }

  func testPledgeAmountUpdates() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true

    withEnvironment(currentUser: .template) {
      let data = PledgeViewData(
        project: project,
        rewards: [reward],
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

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertValues([true])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.configurePledgeViewCTAContainerViewContext.assertValues([.pledge])

      self.configureShippingLocationViewWithDataProject.assertValues([project])
      self.configureShippingLocationViewWithDataReward.assertValues([reward])
      self.configureShippingLocationViewWithDataShowAmount.assertValues([true])

      self.paymentMethodsViewHidden.assertValues([false])
      self.pledgeAmountViewHidden.assertValues([false])
      self.pledgeAmountSummaryViewHidden.assertValues([true])
      self.shippingLocationViewHidden.assertValues([false])

      self.configureSummaryViewControllerWithDataPledgeTotal.assertValues([reward.minimum])
      self.configureSummaryViewControllerWithDataProject.assertValues([project])

      let data1 = (amount: 66.0, min: 10.0, max: 10_000.0, isValid: true)

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: data1)

      self.configureShippingLocationViewWithDataProject.assertValues([project])
      self.configureShippingLocationViewWithDataReward.assertValues([reward])
      self.configureShippingLocationViewWithDataShowAmount.assertValues([true])

      self.configureSummaryViewControllerWithDataPledgeTotal.assertValues([10, 76])
      self.configureSummaryViewControllerWithDataProject.assertValues([project, project])

      let data2 = (amount: 93.0, min: 10.0, max: 10_000.0, isValid: true)

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: data2)

      self.configureShippingLocationViewWithDataProject.assertValues([project])
      self.configureShippingLocationViewWithDataReward.assertValues([reward])
      self.configureShippingLocationViewWithDataShowAmount.assertValues([true])

      self.configureSummaryViewControllerWithDataPledgeTotal.assertValues([10, 76, 103])
      self.configureSummaryViewControllerWithDataProject.assertValues([project, project, project])
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

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertValues([false])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.configurePledgeViewCTAContainerViewContext.assertValues([.pledge])

      self.configureShippingLocationViewWithDataProject.assertDidNotEmitValue()
      self.configureShippingLocationViewWithDataReward.assertDidNotEmitValue()
      self.configureShippingLocationViewWithDataShowAmount.assertDidNotEmitValue()

      self.paymentMethodsViewHidden.assertValues([true])
      self.pledgeAmountViewHidden.assertValues([false])
      self.pledgeAmountSummaryViewHidden.assertValues([true])
      self.shippingLocationViewHidden.assertValues([true])

      withEnvironment(currentUser: user) {
        self.vm.inputs.userSessionStarted()

        self.configurePaymentMethodsViewControllerWithUser.assertValues([user])
        self.configurePaymentMethodsViewControllerWithProject.assertValues([project])
        self.configurePaymentMethodsViewControllerWithReward.assertValues([reward])
        self.configurePaymentMethodsViewControllerWithContext.assertValues([.pledge])

        self.configurePledgeViewCTAContainerViewIsLoggedIn.assertValues([false, true])
        self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, false])
        self.configurePledgeViewCTAContainerViewContext.assertValues([.pledge, .pledge])

        self.configureShippingLocationViewWithDataProject.assertDidNotEmitValue()
        self.configureShippingLocationViewWithDataReward.assertDidNotEmitValue()
        self.configureShippingLocationViewWithDataShowAmount.assertDidNotEmitValue()

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
      let data = PledgeViewData(
        project: project,
        rewards: [reward],
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

      self.configureShippingLocationViewWithDataProject.assertValues([project])
      self.configureShippingLocationViewWithDataReward.assertValues([reward])
      self.configureShippingLocationViewWithDataShowAmount.assertValues([true])

      self.paymentMethodsViewHidden.assertValues([false])
      self.pledgeAmountViewHidden.assertValues([false])
      self.pledgeAmountSummaryViewHidden.assertValues([true])
      self.shippingLocationViewHidden.assertValues([false])

      self.configureSummaryViewControllerWithDataPledgeTotal.assertValues([reward.minimum])
      self.configureSummaryViewControllerWithDataProject.assertValues([project])

      let shippingRule1 = ShippingRule.template
        |> ShippingRule.lens.cost .~ 20.0

      self.vm.inputs.shippingRuleSelected(shippingRule1)

      self.configureShippingLocationViewWithDataProject.assertValues([project])
      self.configureShippingLocationViewWithDataReward.assertValues([reward])
      self.configureShippingLocationViewWithDataShowAmount.assertValues([true])

      self.configureSummaryViewControllerWithDataPledgeTotal.assertValues([
        reward.minimum,
        reward.minimum + shippingRule1.cost
      ])
      self.configureSummaryViewControllerWithDataProject.assertValues([project, project])

      let data1 = (amount: 200.0, min: 10.0, max: 10_000.0, isValid: true)

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: data1)

      self.configureShippingLocationViewWithDataProject.assertValues([project])
      self.configureShippingLocationViewWithDataReward.assertValues([reward])
      self.configureShippingLocationViewWithDataShowAmount.assertValues([true])

      self.configureSummaryViewControllerWithDataPledgeTotal.assertValues(
        [
          reward.minimum,
          reward.minimum + shippingRule1.cost,
          reward.minimum + shippingRule1.cost + data1.amount
        ]
      )
      self.configureSummaryViewControllerWithDataProject.assertValues([project, project, project])

      let shippingRule2 = ShippingRule.template
        |> ShippingRule.lens.cost .~ 123.0

      self.vm.inputs.shippingRuleSelected(shippingRule2)

      self.configureShippingLocationViewWithDataProject.assertValues([project])
      self.configureShippingLocationViewWithDataReward.assertValues([reward])
      self.configureShippingLocationViewWithDataShowAmount.assertValues([true])

      self.configureSummaryViewControllerWithDataPledgeTotal.assertValues(
        [
          reward.minimum,
          reward.minimum + shippingRule1.cost,
          reward.minimum + shippingRule1.cost + data1.amount,
          reward.minimum + shippingRule2.cost + data1.amount
        ]
      )
      self.configureSummaryViewControllerWithDataProject.assertValues([project, project, project, project])

      let data2 = (amount: 1_999.0, min: 10.0, max: 10_000.0, isValid: true)

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: data2)

      self.configureShippingLocationViewWithDataProject.assertValues([project])
      self.configureShippingLocationViewWithDataReward.assertValues([reward])
      self.configureShippingLocationViewWithDataShowAmount.assertValues([true])

      self.configureSummaryViewControllerWithDataPledgeTotal.assertValues(
        [
          reward.minimum,
          reward.minimum + shippingRule1.cost,
          reward.minimum + shippingRule1.cost + data1.amount,
          reward.minimum + shippingRule2.cost + data1.amount,
          reward.minimum + shippingRule2.cost + data2.amount
        ]
      )
      self.configureSummaryViewControllerWithDataProject
        .assertValues([project, project, project, project, project])
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
    let pledgeAmountData = (amount: 5.0, min: 1.0, max: 10_000.0, isValid: true)

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: .projectPage,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: pledgeAmountData)

    self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationShippingTotal.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

    self.vm.inputs.applePayButtonTapped()

    self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationProject.assertValues([project])
    self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
    self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([0])
    self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([0])
    self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([5])
    self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])
  }

  func testGoToApplePayPaymentAuthorization_WhenApplePayButtonTapped_ShippingEnabled() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.minimum .~ 20
      |> Reward.lens.shipping.enabled .~ true
    let shippingRule = ShippingRule.template
    let pledgeAmountData = (amount: 25.0, min: 25.0, max: 10_000.0, isValid: true)

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
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
    self.goToApplePayPaymentAuthorizationShippingTotal.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

    self.vm.inputs.shippingRuleSelected(shippingRule)

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: pledgeAmountData)

    self.vm.inputs.applePayButtonTapped()

    self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationProject.assertValues([project])
    self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
    self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([shippingRule.cost])
    self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([20])
    self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([25])
    self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])
  }

  func testOutputGoToRiskMessagingModal_OptimizelyClientControl_SubmitButtonTapped() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.experiments
      .~ [
        OptimizelyExperiment.Key.nativeRiskMessaging.rawValue:
          OptimizelyExperiment.Variant.control.rawValue
      ]
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.minimum .~ 20
      |> Reward.lens.shipping.enabled .~ true
    let shippingRule = ShippingRule.template

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: .projectPage,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.goToRiskMessagingModal.assertDidNotEmitValue()

    self.vm.inputs.shippingRuleSelected(shippingRule)

    withEnvironment(optimizelyClient: mockOptimizelyClient) {
      self.vm.inputs.submitButtonTapped()

      self.scheduler.advance()

      self.goToRiskMessagingModal.assertDidNotEmitValue()
    }
  }

  func testOutputGoToRiskMessagingModal_OptimizelyClientVariant1() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.experiments
      .~ [
        OptimizelyExperiment.Key.nativeRiskMessaging.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.minimum .~ 20
      |> Reward.lens.shipping.enabled .~ true
    let shippingRule = ShippingRule.template

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: .projectPage,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.goToRiskMessagingModal.assertDidNotEmitValue()

    self.vm.inputs.shippingRuleSelected(shippingRule)

    withEnvironment(optimizelyClient: mockOptimizelyClient) {
      self.vm.inputs.submitButtonTapped()

      self.scheduler.advance()

      self.goToRiskMessagingModal.assertDidEmitValue()
      self.goToRiskMessagingModal.assertValue(false)
    }
  }

  func testShowApplePayAlert_WhenApplePayButtonTapped_PledgeInputAmount_AboveMax_US_ProjectCurrency_US_ProjectCountry() {
    let project = Project.template
      |> Project.lens.country .~ Project.Country.us
      |> Project.lens.stats.currency .~ Project.Country.us.currencyCode
    let reward = Reward.template
      |> Reward.lens.minimum .~ 25
    let pledgeAmountData = (amount: 20_000.0, min: 25.0, max: 10_000.0, isValid: false)

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: .projectPage,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
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

  func testShowApplePayAlert_WhenApplePayButtonTapped_PledgeInputAmount_AboveMax_NonUS_ProjectCurrency_US_ProjectCountry() {
    let project = Project.template
      |> Project.lens.country .~ Project.Country.us
      |> Project.lens.stats.currency .~ Project.Country.mx.currencyCode

    let reward = Reward.template
      |> Reward.lens.minimum .~ 25
    let pledgeAmountData = (amount: 20_000.0, min: 25.0, max: 10_000.0, isValid: false)

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: .projectPage,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: pledgeAmountData)
    self.vm.inputs.viewDidLoad()

    self.showApplePayAlertMessage.assertDidNotEmitValue()
    self.showApplePayAlertTitle.assertDidNotEmitValue()

    self.vm.inputs.applePayButtonTapped()

    self.showApplePayAlertMessage.assertValues(
      ["Please enter a pledge amount between MX$ 25 and MX$ 10,000."]
    )
    self.showApplePayAlertTitle.assertValues(["Almost there!"])
  }

  func testShowApplePayAlert_WhenApplePayButtonTapped_PledgeInputAmount_BellowMin() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.minimum .~ 25
    let pledgeAmountData = (amount: 10.0, min: 25.0, max: 10_000.0, isValid: false)

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: .projectPage,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
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
      |> Reward.lens.minimum .~ 20
      |> Reward.lens.shipping.enabled .~ true
    let shippingRule = ShippingRule.template
    let pledgeAmountData = (amount: 25.0, min: 25.0, max: 10_000.0, isValid: true)

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: .projectPage,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.shippingRuleSelected(shippingRule)

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: pledgeAmountData)

    self.vm.inputs.applePayButtonTapped()

    self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationProject.assertValues([project])
    self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
    self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([shippingRule.cost])
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

  func testApplePay_GoToThanks_NativeRiskMessagingEnabled_Control() {
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

      let pledgeAmountData = (amount: 10.0, min: 5.0, max: 10_000.0, isValid: true)
      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: pledgeAmountData)

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.success,
        self.vm.inputs.stripeTokenCreated(token: "stripe_token", error: nil)
      )

      self.goToThanksProject.assertDidNotEmitValue()

      self.processingViewIsHidden.assertValues([false])

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.processingViewIsHidden.assertValues([false])
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

  func testApplePay_GoToThanks_NativeRiskMessagingEnabled_Variant() {
    let createBacking = CreateBackingEnvelope.CreateBacking(
      checkout: Checkout(
        id: "Q2hlY2tvdXQtMQ==",
        state: .successful,
        backing: .init(clientSecret: nil, requiresAction: false)
      )
    )
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.experiments
      .~ [
        OptimizelyExperiment.Key.nativeRiskMessaging.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]
    let mockService = MockService(
      createBackingResult:
      Result.success(CreateBackingEnvelope(createBacking: createBacking))
    )

    withEnvironment(apiService: mockService, currentUser: .template, optimizelyClient: mockOptimizelyClient) {
      let project = Project.template
      let reward = Reward.template
        |> Reward.lens.minimum .~ 5

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.applePayButtonTapped()

      self.vm.inputs.riskMessagingViewControllerDismissed(isApplePay: true)

      self.goToThanksProject.assertDidNotEmitValue()
      self.processingViewIsHidden.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
        paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345")
      )

      let pledgeAmountData = (amount: 10.0, min: 5.0, max: 10_000.0, isValid: true)
      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: pledgeAmountData)

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.success,
        self.vm.inputs.stripeTokenCreated(token: "stripe_token", error: nil)
      )

      self.goToThanksProject.assertDidNotEmitValue()

      self.processingViewIsHidden.assertValues([false])

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.processingViewIsHidden.assertValues([false])
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
        ["Page Viewed", "CTA Clicked", "CTA Clicked"],
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

      let pledgeAmountData = (amount: 10.0, min: 5.0, max: 10_000.0, isValid: true)
      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: pledgeAmountData)

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.success,
        self.vm.inputs.stripeTokenCreated(token: "stripe_token", error: nil)
      )

      self.goToThanksProject.assertDidNotEmitValue()

      self.processingViewIsHidden.assertValues([false])

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.processingViewIsHidden.assertValues([false])
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
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: nil,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.shippingRuleSelected(shippingRule)

      self.configurePaymentMethodsViewControllerWithUser.assertValues([User.template])
      self.configurePaymentMethodsViewControllerWithProject.assertValues([project])
      self.configurePaymentMethodsViewControllerWithReward.assertValues([reward])
      self.configurePaymentMethodsViewControllerWithContext.assertValues([.pledge])

      self.configureShippingLocationViewWithDataProject.assertValues([project])
      self.configureShippingLocationViewWithDataReward.assertValues([reward])
      self.configureShippingLocationViewWithDataShowAmount.assertValues([true])

      self.configureSummaryViewControllerWithDataPledgeTotal.assertValues([5, 10])
      self.configureSummaryViewControllerWithDataProject.assertValues([project, project])

      self.paymentMethodsViewHidden.assertValues([false])
      self.shippingLocationViewHidden.assertValues([false])

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
        revenueInUsd: 10.00,
        rewardId: "1",
        rewardMinimumUsd: 5.00,
        rewardTitle: "My Reward",
        shippingEnabled: true,
        shippingAmountUsd: 5.00,
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

      self.processingViewIsHidden.assertValues([false])
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

  func testCreateBacking_Success_NativeRiskMessaging_Control() {
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
        selectedQuantities: [reward.id: 1, addOn1.id: 2, addOn2.id: 1],
        selectedLocationId: shippingRule.location.id,
        refTag: .activity,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      let paymentSourceSelected = PaymentSourceSelected(
        paymentSourceId: "123",
        isSetupIntentClientSecret: false
      )

      self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(
        with: (amount: 15.0, min: 10.0, max: 10_000.0, isValid: true)
      )

      self.vm.inputs.shippingRuleSelected(shippingRule)

      self.processingViewIsHidden.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])

      self.vm.inputs.submitButtonTapped()

      self.processingViewIsHidden.assertValues([false])
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
        shippingAmountUsd: 15.00,
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

  func testCreateBacking_Success_NativeRiskMessaging_Variant() {
    let createBacking = CreateBackingEnvelope.CreateBacking(
      checkout: Checkout(
        id: "Q2hlY2tvdXQtMQ==",
        state: .verifying,
        backing: .init(clientSecret: nil, requiresAction: false)
      )
    )
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.experiments
      .~ [
        OptimizelyExperiment.Key.nativeRiskMessaging.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]
    let mockService = MockService(
      createBackingResult:
      Result.success(CreateBackingEnvelope(createBacking: createBacking))
    )

    withEnvironment(apiService: mockService, currentUser: .template, optimizelyClient: mockOptimizelyClient) {
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
        |> Reward.lens.shipping.preference .~ Reward.Shipping.Preference.unrestricted
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
        selectedQuantities: [reward.id: 1, addOn1.id: 2, addOn2.id: 1],
        selectedLocationId: shippingRule.location.id,
        refTag: .activity,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      let paymentSourceSelected = PaymentSourceSelected(
        paymentSourceId: "123",
        isSetupIntentClientSecret: false
      )

      self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(
        with: (amount: 15.0, min: 10.0, max: 10_000.0, isValid: true)
      )

      self.vm.inputs.shippingRuleSelected(shippingRule)

      self.processingViewIsHidden.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])

      self.vm.inputs.submitButtonTapped()

      self.vm.inputs.riskMessagingViewControllerDismissed(isApplePay: false)

      self.processingViewIsHidden.assertValues([false])
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
        shippingAmountUsd: 15.00,
        userHasStoredApplePayCard: true
      )

      self.goToThanksProject.assertValues([.template])
      self.goToThanksReward.assertValues([.template])
      self.goToThanksCheckoutData.assertValues([checkoutData])

      XCTAssertEqual(
        ["Page Viewed", "CTA Clicked", "CTA Clicked"],
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
        selectedQuantities: [reward.id: 1, addOnReward1.id: 2, addOnReward2.id: 1],
        selectedLocationId: nil,
        refTag: .activity,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      let paymentSourceSelected = PaymentSourceSelected(
        paymentSourceId: "123",
        isSetupIntentClientSecret: false
      )

      self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(
        with: (amount: 25.0, min: 10.0, max: 10_000.0, isValid: true)
      )

      self.processingViewIsHidden.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])

      self.vm.inputs.submitButtonTapped()

      self.processingViewIsHidden.assertValues([false])
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
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .activity,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.processingViewIsHidden.assertDidNotEmitValue()

      let paymentSourceSelected = PaymentSourceSelected(
        paymentSourceId: "123",
        isSetupIntentClientSecret: false
      )

      self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(
        with: (amount: 25.0, min: 10.0, max: 10_000.0, isValid: true)
      )

      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])

      self.vm.inputs.submitButtonTapped()

      self.processingViewIsHidden.assertValues([false])
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

  func testUpdateBacking_Success() {
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
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .discovery,
        context: .update
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.processingViewIsHidden.assertDidNotEmitValue()

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(
        with: (amount: 25.0, min: 25.0, max: 10_000.0, isValid: true)
      )

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.processingViewIsHidden.assertDidNotEmitValue()

      self.vm.inputs.shippingRuleSelected(.template)

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.processingViewIsHidden.assertDidNotEmitValue()

      self.vm.inputs.submitButtonTapped()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false])
      self.processingViewIsHidden.assertValues([false])

      self.scheduler.run()

      self.processingViewIsHidden.assertValues([false, true])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false, true])
      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertValues([
        "Got it! Your changes have been saved."
      ])
      self.popToRootViewController.assertValueCount(1)
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
    }
  }

  func testUpdateBacking_Success_OptimizelyClientVariant1() {
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

    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.experiments
      .~ [
        OptimizelyExperiment.Key.nativeRiskMessaging.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]

    let mockService = MockService(
      updateBackingResult: .success(updateBackingEnvelope)
    )

    withEnvironment(apiService: mockService, currentUser: .template, optimizelyClient: mockOptimizelyClient) {
      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .discovery,
        context: .update
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.processingViewIsHidden.assertDidNotEmitValue()

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(
        with: (amount: 25.0, min: 25.0, max: 10_000.0, isValid: true)
      )

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.processingViewIsHidden.assertDidNotEmitValue()

      self.vm.inputs.shippingRuleSelected(.template)

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.processingViewIsHidden.assertDidNotEmitValue()

      self.vm.inputs.submitButtonTapped()

      self.goToRiskMessagingModal.assertDidNotEmitValue()
      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false])
      self.processingViewIsHidden.assertValues([false])

      self.scheduler.run()

      self.processingViewIsHidden.assertValues([false, true])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false, true])
      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertValues([
        "Got it! Your changes have been saved."
      ])
      self.popToRootViewController.assertValueCount(1)
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
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
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .discovery,
        context: .update
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.processingViewIsHidden.assertDidNotEmitValue()

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(
        with: (amount: 25.0, min: 25.0, max: 10_000.0, isValid: true)
      )

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.processingViewIsHidden.assertDidNotEmitValue()

      self.vm.inputs.shippingRuleSelected(.template)

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.processingViewIsHidden.assertDidNotEmitValue()

      self.vm.inputs.submitButtonTapped()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false])
      self.processingViewIsHidden.assertValues([false])

      self.scheduler.run()

      self.processingViewIsHidden.assertValues([false, true])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false, true])
      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValueCount(1)
    }
  }

  func testUpdatingSubmitButtonEnabled_BackingHasAddOns() {
    let addOn = Reward.template
      |> Reward.lens.id .~ 55

    let reward = Reward.postcards
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.minimum .~ 10.0
      |> Reward.lens.hasAddOns .~ true

    let shippingRule = ShippingRule.template
      |> ShippingRule.lens.location .~ .brooklyn
      |> ShippingRule.lens.cost .~ 10

    let project = Project.cosmicSurgery
      |> Project.lens.rewardData.addOns .~ [addOn]
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ Backing.PaymentSource.template
          |> Backing.lens.status .~ .pledged
          |> Backing.lens.addOns .~ [addOn]
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.locationId .~ shippingRule.location.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.bonusAmount .~ 680.0
          |> Backing.lens.amount .~ 700.0
      )

    self.configurePledgeViewCTAContainerViewIsEnabled.assertDidNotEmitValue()

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedQuantities: [reward.id: 1],
      selectedLocationId: shippingRule.location.id,
      refTag: .discovery,
      context: .update
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(
      with: (amount: 680, min: 25.0, max: 10_000.0, isValid: true)
    )

    self.configurePledgeViewCTAContainerViewIsEnabled.assertValues(
      [false, true],
      "Amount unchanged, but is enabled because Reward has add-ons"
    )

    self.vm.inputs.shippingRuleSelected(shippingRule)

    self.configurePledgeViewCTAContainerViewIsEnabled
      .assertValues(
        [false, true],
        "Shipping rule and amount unchanged, but is enabled because Reward has add-ons"
      )

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(
      with: (amount: 680, min: 25.0, max: 10_000.0, isValid: true)
    )

    self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true], "Amount unchanged")

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(
      with: (amount: 550, min: 25.0, max: 10_000.0, isValid: true)
    )

    self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true], "Amount changed")

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(
      with: (amount: 680, min: 25.0, max: 10_000.0, isValid: true)
    )

    self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true], "Amount unchanged")

    self.vm.inputs.shippingRuleSelected(.template)

    self.configurePledgeViewCTAContainerViewIsEnabled
      .assertValues([false, true], "Shipping rule changed")

    self.vm.inputs.shippingRuleSelected(.init(cost: 10, id: 1, location: .brooklyn))

    self.configurePledgeViewCTAContainerViewIsEnabled
      .assertValues([false, true], "Shipping rule unchanged")
  }

  func testUpdatingSubmitButtonEnabled_ShippingEnabled() {
    let reward = Reward.postcards
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.minimum .~ 10.0

    let shippingRule = ShippingRule.template
      |> ShippingRule.lens.location .~ .brooklyn
      |> ShippingRule.lens.cost .~ 10

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ Backing.PaymentSource.template
          |> Backing.lens.status .~ .pledged
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.locationId .~ shippingRule.location.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.bonusAmount .~ 680.0
          |> Backing.lens.amount .~ 700.0
      )

    self.configurePledgeViewCTAContainerViewIsEnabled.assertDidNotEmitValue()

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedQuantities: [reward.id: 1],
      selectedLocationId: shippingRule.location.id,
      refTag: .discovery,
      context: .update
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(
      with: (amount: 680, min: 25.0, max: 10_000.0, isValid: true)
    )

    self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false], "Amount unchanged")

    self.vm.inputs.shippingRuleSelected(shippingRule)

    self.configurePledgeViewCTAContainerViewIsEnabled
      .assertValues([false], "Shipping rule and amount unchanged")

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(
      with: (amount: 680, min: 25.0, max: 10_000.0, isValid: true)
    )

    self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false], "Amount unchanged")

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(
      with: (amount: 550, min: 25.0, max: 10_000.0, isValid: true)
    )

    self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true], "Amount changed")

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(
      with: (amount: 680, min: 25.0, max: 10_000.0, isValid: true)
    )

    self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false], "Amount unchanged")

    self.vm.inputs.shippingRuleSelected(.template)

    self.configurePledgeViewCTAContainerViewIsEnabled
      .assertValues([false, true, false, true], "Shipping rule changed")

    self.vm.inputs.shippingRuleSelected(.init(cost: 10, id: 1, location: .brooklyn))

    self.configurePledgeViewCTAContainerViewIsEnabled
      .assertValues([false, true, false, true, false], "Shipping rule unchanged")
  }

  func testUpdatingSubmitButtonEnabled_NoShipping() {
    let reward = Reward.postcards
      |> Reward.lens.shipping.enabled .~ false
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
          |> Backing.lens.shippingAmount .~ nil
          |> Backing.lens.bonusAmount .~ 690.0
          |> Backing.lens.amount .~ 700
      )

    self.configurePledgeViewCTAContainerViewIsEnabled.assertDidNotEmitValue()

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: .discovery,
      context: .update
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(
      with: (amount: 690, min: 25.0, max: 10_000.0, isValid: true)
    )

    self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false], "Amount unchanged")

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(
      with: (amount: 550, min: 25.0, max: 10_000.0, isValid: true)
    )

    self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true], "Amount changed")

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(
      with: (amount: 690, min: 25.0, max: 10_000.0, isValid: true)
    )

    self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false], "Amount unchanged")
  }

  func testUpdatingRewardSubmitButtonEnabled_ShippingEnabled() {
    let reward = Reward.postcards
      |> Reward.lens.shipping.enabled .~ true

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ Backing.PaymentSource.template
          |> Backing.lens.status .~ .pledged
          |> Backing.lens.reward .~ Reward.otherReward
          |> Backing.lens.rewardId .~ Reward.otherReward.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.amount .~ 700.0
      )

    self.configurePledgeViewCTAContainerViewIsEnabled.assertDidNotEmitValue()

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
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: nil,
        context: .updateReward
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(
        with: (amount: 690, min: 25.0, max: 10_000.0, isValid: true)
      )

      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false], "Amount unchanged")
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      self.vm.inputs.shippingRuleSelected(.init(cost: 1, id: 1, location: .brooklyn))

      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues(
        [false, true], "Shipping rule and amount unchanged, button enabled due to different reward"
      )
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      self.vm.inputs.submitButtonTapped()

      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false])
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      self.scheduler.run()

      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false, true])
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertValues([
        "Got it! Your changes have been saved."
      ])
      self.popToRootViewController.assertValueCount(1)
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
    }
  }

  func testChangingPaymentMethodSubmitButtonEnabled_ShippingEnabled() {
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

    let defaultShippingRule = ShippingRule(cost: 10, id: 1, location: .brooklyn)

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedQuantities: [reward.id: 1],
      selectedLocationId: defaultShippingRule.location.id,
      refTag: .discovery,
      context: .update
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(
      with: (amount: 680, min: 25.0, max: 10_000.0, isValid: true)
    )

    self.vm.inputs.shippingRuleSelected(defaultShippingRule)

    self.configurePledgeViewCTAContainerViewIsEnabled
      .assertValues([false], "Shipping rule and amount unchanged")

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(
      with: (amount: 680, min: 25.0, max: 10_000.0, isValid: true)
    )

    self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false], "Amount unchanged")

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(
      with: (amount: 550, min: 25.0, max: 10_000.0, isValid: true)
    )

    self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true], "Amount changed")

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(
      with: (amount: 680, min: 25.0, max: 10_000.0, isValid: true)
    )

    self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false], "Amount unchanged")

    self.vm.inputs.shippingRuleSelected(.template)

    self.configurePledgeViewCTAContainerViewIsEnabled
      .assertValues([false, true, false, true], "Shipping rule changed")

    self.vm.inputs.shippingRuleSelected(defaultShippingRule)

    self.configurePledgeViewCTAContainerViewIsEnabled.assertValues(
      [false, true, false, true, false],
      "Amount and shipping rule unchanged"
    )

    var paymentSourceSelected = PaymentSourceSelected(
      paymentSourceId: "12345",
      isSetupIntentClientSecret: false
    )

    self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

    self.configurePledgeViewCTAContainerViewIsEnabled.assertValues(
      [false, true, false, true, false, true],
      "Payment method changed"
    )

    paymentSourceSelected = PaymentSourceSelected(
      paymentSourceId: Backing.PaymentSource.template.id ?? "",
      isSetupIntentClientSecret: false
    )

    self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

    self.configurePledgeViewCTAContainerViewIsEnabled.assertValues(
      [false, true, false, true, false, true, false],
      "Payment method unchanged"
    )
  }

  func testGoToApplePayPaymentAuthorization_HasAddOns() {
    self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationShippingTotal.assertDidNotEmitValue()
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
      selectedQuantities: [reward.id: 1, addOnReward1.id: 2, addOnReward2.id: 1],
      selectedLocationId: shippingRule.location.id,
      refTag: .projectPage,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.shippingRuleSelected(shippingRule)

    let pledgeAmountData = (amount: 15.0, min: 5.0, max: 10_000.0, isValid: true)
    self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: pledgeAmountData)

    self.vm.inputs.applePayButtonTapped()

    self.goToApplePayPaymentAuthorizationProject.assertValues([project])
    self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
    self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
    self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([40])
    self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
    self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])
  }

  func testChangePaymentMethod_OptimizelyClientControl_ApplePay_Success() {
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
    self.goToApplePayPaymentAuthorizationShippingTotal.assertDidNotEmitValue()
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

      let defaultShippingRule = ShippingRule(cost: 10, id: 1, location: .brooklyn)

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedQuantities: [reward.id: 1],
        selectedLocationId: defaultShippingRule.location.id,
        refTag: .projectPage,
        context: .changePaymentMethod
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      let pledgeAmountData = (amount: 15.0, min: 5.0, max: 10_000.0, isValid: true)
      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: pledgeAmountData)

      self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationShippingTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.applePayButtonTapped()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
        paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345")
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.success,
        self.vm.inputs.stripeTokenCreated(token: "stripe_token", error: nil)
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()

      self.scheduler.run()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertValues([
        "Got it! Your changes have been saved."
      ])
      self.popToRootViewController.assertValueCount(1)
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.goToThanksProject.assertDidNotEmitValue()
    }
  }

  func testChangePaymentMethod_OptimizelyClientVariant_ApplePay_Success() {
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

    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.experiments
      .~ [
        OptimizelyExperiment.Key.nativeRiskMessaging.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]

    let mockService = MockService(
      updateBackingResult: .success(updateBackingEnvelope)
    )

    self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationShippingTotal.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

    self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
    self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
    self.popToRootViewController.assertDidNotEmitValue()
    self.showErrorBannerWithMessage.assertDidNotEmitValue()
    self.configurePledgeViewCTAContainerViewIsEnabled.assertDidNotEmitValue()
    self.goToThanksProject.assertDidNotEmitValue()

    withEnvironment(apiService: mockService, optimizelyClient: mockOptimizelyClient) {
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

      let defaultShippingRule = ShippingRule(cost: 10, id: 1, location: .brooklyn)

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedQuantities: [reward.id: 1],
        selectedLocationId: defaultShippingRule.location.id,
        refTag: .projectPage,
        context: .changePaymentMethod
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      let pledgeAmountData = (amount: 15.0, min: 5.0, max: 10_000.0, isValid: true)
      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: pledgeAmountData)

      self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationShippingTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.applePayButtonTapped()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
        paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345")
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.success,
        self.vm.inputs.stripeTokenCreated(token: "stripe_token", error: nil)
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()

      self.scheduler.run()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertValues([
        "Got it! Your changes have been saved."
      ])
      self.popToRootViewController.assertValueCount(1)
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.goToThanksProject.assertDidNotEmitValue()
    }
  }

  func testChangePaymentMethod_OptimizelyClientControl_ApplePay_StripeTokenFailure() {
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
    self.goToApplePayPaymentAuthorizationShippingTotal.assertDidNotEmitValue()
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
        )

      let defaultShippingRule = ShippingRule(cost: 10, id: 1, location: .brooklyn)

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedQuantities: [reward.id: 1],
        selectedLocationId: defaultShippingRule.location.id,
        refTag: .projectPage,
        context: .changePaymentMethod
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      let pledgeAmountData = (amount: 15.0, min: 5.0, max: 10_000.0, isValid: true)
      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: pledgeAmountData)

      self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationShippingTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.applePayButtonTapped()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.failure,
        self.vm.inputs.stripeTokenCreated(token: nil, error: GraphError.invalidInput)
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()

      self.scheduler.run()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()
    }
  }

  func testChangePaymentMethod_OptimizelyClientVariant_ApplePay_StripeTokenFailure() {
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

    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.experiments
      .~ [
        OptimizelyExperiment.Key.nativeRiskMessaging.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]

    let mockService = MockService(
      updateBackingResult: .success(updateBackingEnvelope)
    )

    self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationShippingTotal.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

    self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
    self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
    self.popToRootViewController.assertDidNotEmitValue()
    self.showErrorBannerWithMessage.assertDidNotEmitValue()
    self.configurePledgeViewCTAContainerViewIsEnabled.assertDidNotEmitValue()
    self.goToThanksProject.assertDidNotEmitValue()

    withEnvironment(apiService: mockService, optimizelyClient: mockOptimizelyClient) {
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

      let defaultShippingRule = ShippingRule(cost: 10, id: 1, location: .brooklyn)

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedQuantities: [reward.id: 1],
        selectedLocationId: defaultShippingRule.location.id,
        refTag: .projectPage,
        context: .changePaymentMethod
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      let pledgeAmountData = (amount: 15.0, min: 5.0, max: 10_000.0, isValid: true)
      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: pledgeAmountData)

      self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationShippingTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.applePayButtonTapped()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.failure,
        self.vm.inputs.stripeTokenCreated(token: nil, error: GraphError.invalidInput)
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()

      self.scheduler.run()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()
    }
  }

  func testChangePaymentMethod_OptimizelyClientControl_ApplePay_Failure() {
    let mockService = MockService(
      updateBackingResult: .failure(.couldNotParseJSON)
    )

    self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationShippingTotal.assertDidNotEmitValue()
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
        )

      let defaultShippingRule = ShippingRule(cost: 10, id: 1, location: .brooklyn)

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedQuantities: [reward.id: 1],
        selectedLocationId: defaultShippingRule.location.id,
        refTag: .projectPage,
        context: .changePaymentMethod
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      let pledgeAmountData = (amount: 15.0, min: 5.0, max: 10_000.0, isValid: true)
      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: pledgeAmountData)

      self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationShippingTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.applePayButtonTapped()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
        paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345")
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.success,
        self.vm.inputs.stripeTokenCreated(token: "stripe_token", error: nil)
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()

      self.scheduler.run()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.goToThanksProject.assertDidNotEmitValue()
    }
  }

  func testChangePaymentMethod_OptimizelyClientVariant_ApplePay_Failure() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.experiments
      .~ [
        OptimizelyExperiment.Key.nativeRiskMessaging.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]

    let mockService = MockService(
      updateBackingResult: .failure(.couldNotParseJSON)
    )

    self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationShippingTotal.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

    self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
    self.popToRootViewController.assertDidNotEmitValue()
    self.showErrorBannerWithMessage.assertDidNotEmitValue()
    self.configurePledgeViewCTAContainerViewIsEnabled.assertDidNotEmitValue()
    self.goToThanksProject.assertDidNotEmitValue()

    withEnvironment(apiService: mockService, optimizelyClient: mockOptimizelyClient) {
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

      let defaultShippingRule = ShippingRule(cost: 10, id: 1, location: .brooklyn)

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedQuantities: [reward.id: 1],
        selectedLocationId: defaultShippingRule.location.id,
        refTag: .projectPage,
        context: .changePaymentMethod
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      let pledgeAmountData = (amount: 15.0, min: 5.0, max: 10_000.0, isValid: true)
      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: pledgeAmountData)

      self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationShippingTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.applePayButtonTapped()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
        paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345")
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.success,
        self.vm.inputs.stripeTokenCreated(token: "stripe_token", error: nil)
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()

      self.scheduler.run()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.goToThanksProject.assertDidNotEmitValue()
    }
  }

  func testApplePayBackingFails_ThenSucceeds_SignalsDoNotOverlap_UpdateContext() {
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
    self.goToApplePayPaymentAuthorizationShippingTotal.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

    self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
    self.popToRootViewController.assertDidNotEmitValue()
    self.showErrorBannerWithMessage.assertDidNotEmitValue()
    self.configurePledgeViewCTAContainerViewIsEnabled.assertDidNotEmitValue()
    self.goToThanksProject.assertDidNotEmitValue()

    withEnvironment(apiService: mockService1) {
      let defaultShippingRule = ShippingRule(cost: 10, id: 1, location: .brooklyn)

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedQuantities: [reward.id: 1],
        selectedLocationId: defaultShippingRule.location.id,
        refTag: .projectPage,
        context: .update
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      let pledgeAmountData = (amount: 15.0, min: 5.0, max: 10_000.0, isValid: true)
      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: pledgeAmountData)

      self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationShippingTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.applePayButtonTapped()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
        paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345")
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.goToThanksProject.assertDidNotEmitValue()

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.success,
        self.vm.inputs.stripeTokenCreated(token: "stripe_token", error: nil)
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.goToThanksProject.assertDidNotEmitValue()

      self.scheduler.run()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
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
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10, 10])
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
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10, 10])
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
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.goToThanksProject.assertDidNotEmitValue()

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.success,
        self.vm.inputs.stripeTokenCreated(token: "stripe_token", error: nil)
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project, project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward, reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10, 10])
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
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.goToThanksProject.assertDidNotEmitValue()

      self.scheduler.run()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project, project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward, reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10, 10])
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
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project, project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward, reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10, 10])
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
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.goToThanksProject.assertDidNotEmitValue()
    }
  }

  func testApplePayBackingFails_ThenStoredCardSucceeds_SignalsDoNotOverlap_UpdateContext() {
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
    self.goToApplePayPaymentAuthorizationShippingTotal.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

    self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
    self.popToRootViewController.assertDidNotEmitValue()
    self.showErrorBannerWithMessage.assertDidNotEmitValue()
    self.configurePledgeViewCTAContainerViewIsEnabled.assertDidNotEmitValue()
    self.goToThanksProject.assertDidNotEmitValue()

    withEnvironment(apiService: mockService1) {
      let defaultShippingRule = ShippingRule(cost: 10, id: 1, location: .brooklyn)

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedQuantities: [reward.id: 1],
        selectedLocationId: defaultShippingRule.location.id,
        refTag: .projectPage,
        context: .update
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      let pledgeAmountData = (amount: 15.0, min: 5.0, max: 10_000.0, isValid: true)
      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: pledgeAmountData)

      self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationShippingTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.applePayButtonTapped()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
        paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345")
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.goToThanksProject.assertDidNotEmitValue()

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.success,
        self.vm.inputs.stripeTokenCreated(token: "stripe_token", error: nil)
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.goToThanksProject.assertDidNotEmitValue()

      self.scheduler.run()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
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
      let paymentSourceSelected = PaymentSourceSelected(
        paymentSourceId: "123",
        isSetupIntentClientSecret: false
      )

      self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.submitButtonTapped()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false])
      self.goToThanksProject.assertDidNotEmitValue()

      self.scheduler.run()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertValues([
        "Got it! Your changes have been saved."
      ])
      self.popToRootViewController.assertValueCount(1)
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false, true])
      self.goToThanksProject.assertDidNotEmitValue()
    }
  }

  func testStoredCardFails_ThenApplePaySucceeds_SignalsDoNotOverlap_UpdateContext() {
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
    self.goToApplePayPaymentAuthorizationShippingTotal.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

    self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
    self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
    self.popToRootViewController.assertDidNotEmitValue()
    self.showErrorBannerWithMessage.assertDidNotEmitValue()
    self.configurePledgeViewCTAContainerViewIsEnabled.assertDidNotEmitValue()
    self.goToThanksProject.assertDidNotEmitValue()

    withEnvironment(apiService: mockService1) {
      let defaultShippingRule = ShippingRule(cost: 10, id: 1, location: .brooklyn)

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedQuantities: [reward.id: 1],
        selectedLocationId: defaultShippingRule.location.id,
        refTag: .projectPage,
        context: .update
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      let pledgeAmountData = (amount: 15.0, min: 5.0, max: 10_000.0, isValid: true)
      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: pledgeAmountData)

      let paymentSourceSelected = PaymentSourceSelected(
        paymentSourceId: "123",
        isSetupIntentClientSecret: false
      )

      self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

      self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationShippingTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.submitButtonTapped()

      self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationShippingTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false])
      self.goToThanksProject.assertDidNotEmitValue()

      self.scheduler.run()

      self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationShippingTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false, true])
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
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false, true])
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
        paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345")
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false, true])
      self.goToThanksProject.assertDidNotEmitValue()

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.success,
        self.vm.inputs.stripeTokenCreated(token: "stripe_token", error: nil)
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false, true])
      self.goToThanksProject.assertDidNotEmitValue()

      self.scheduler.run()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false, true])
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertValues([
        "Got it! Your changes have been saved."
      ])
      self.popToRootViewController.assertValueCount(1)
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false, true])
      self.goToThanksProject.assertDidNotEmitValue()
    }
  }

  func testStoredCardFails_ThenApplePayFails_SignalsDoNotOverlap_UpdateContext() {
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
      )

    self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationShippingTotal.assertDidNotEmitValue()
    self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

    self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
    self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
    self.popToRootViewController.assertDidNotEmitValue()
    self.showErrorBannerWithMessage.assertDidNotEmitValue()
    self.configurePledgeViewCTAContainerViewIsEnabled.assertDidNotEmitValue()
    self.goToThanksProject.assertDidNotEmitValue()

    withEnvironment(apiService: mockService) {
      let defaultShippingRule = ShippingRule(cost: 10, id: 1, location: .brooklyn)

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedQuantities: [reward.id: 1],
        selectedLocationId: defaultShippingRule.location.id,
        refTag: .projectPage,
        context: .update
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      let pledgeAmountData = (amount: 15.0, min: 5.0, max: 10_000.0, isValid: true)
      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: pledgeAmountData)

      let paymentSourceSelected = PaymentSourceSelected(
        paymentSourceId: "123",
        isSetupIntentClientSecret: false
      )

      self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

      self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationShippingTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.submitButtonTapped()

      self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationShippingTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false])
      self.goToThanksProject.assertDidNotEmitValue()

      self.scheduler.run()

      self.goToApplePayPaymentAuthorizationProject.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationReward.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationShippingTotal.assertDidNotEmitValue()
      self.goToApplePayPaymentAuthorizationMerchantId.assertDidNotEmitValue()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false, true])
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.applePayButtonTapped()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false, true])
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
        paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345")
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false, true])
      self.goToThanksProject.assertDidNotEmitValue()

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.success,
        self.vm.inputs.stripeTokenCreated(token: "stripe_token", error: nil)
      )

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false, true])
      self.goToThanksProject.assertDidNotEmitValue()

      self.scheduler.run()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
      self.goToApplePayPaymentAuthorizationAllRewardsTotal.assertValues([6])
      self.goToApplePayPaymentAuthorizationAdditionalPledgeAmount.assertValues([15])
      self.goToApplePayPaymentAuthorizationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(["Something went wrong."])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false, true])
      self.goToThanksProject.assertDidNotEmitValue()

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.goToApplePayPaymentAuthorizationProject.assertValues([project])
      self.goToApplePayPaymentAuthorizationReward.assertValues([reward])
      self.goToApplePayPaymentAuthorizationShippingTotal.assertValues([10])
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
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false, true])
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

      let defaultShippingRule = ShippingRule(cost: 10, id: 1, location: .brooklyn)

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedQuantities: [reward.id: 1],
        selectedLocationId: defaultShippingRule.location.id,
        refTag: .activity,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.shippingRuleSelected(defaultShippingRule)

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      let paymentSourceSelected = PaymentSourceSelected(
        paymentSourceId: "123",
        isSetupIntentClientSecret: false
      )

      self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(
        with: (amount: 15.0, min: 10.0, max: 10_000.0, isValid: true)
      )

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      self.vm.inputs.submitButtonTapped()

      self.processingViewIsHidden.assertValues([false])
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
        revenueInUsd: 35.00,
        rewardId: String(reward.id),
        rewardMinimumUsd: 10.00,
        rewardTitle: reward.title,
        shippingEnabled: reward.shipping.enabled,
        shippingAmountUsd: 10.00,
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

      let defaultShippingRule = ShippingRule(cost: 10, id: 1, location: .brooklyn)

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedQuantities: [reward.id: 1],
        selectedLocationId: defaultShippingRule.location.id,
        refTag: .activity,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      let paymentSourceSelected = PaymentSourceSelected(
        paymentSourceId: "123",
        isSetupIntentClientSecret: false
      )

      self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(
        with: (amount: 25.0, min: 10.0, max: 10_000.0, isValid: true)
      )

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.processingViewIsHidden.assertDidNotEmitValue()

      self.vm.inputs.submitButtonTapped()

      self.processingViewIsHidden.assertValues([false])
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
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .activity,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      let paymentSourceSelected = PaymentSourceSelected(
        paymentSourceId: "123",
        isSetupIntentClientSecret: false
      )

      self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(
        with: (amount: 25.0, min: 10.0, max: 10_000.0, isValid: true)
      )

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

  func testUpdateBacking_RequiresSCA_Success() {
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
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .discovery,
        context: .update
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(
        with: (amount: 25.0, min: 25.0, max: 10_000.0, isValid: true)
      )

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])

      self.vm.inputs.shippingRuleSelected(.template)

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.processingViewIsHidden.assertDidNotEmitValue()

      self.vm.inputs.submitButtonTapped()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false])
      self.processingViewIsHidden.assertValues([false])

      self.scheduler.run()

      self.processingViewIsHidden.assertValues([false, true])
      self.beginSCAFlowWithClientSecret.assertValues(["client-secret"])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false, true])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      self.vm.inputs.scaFlowCompleted(
        with: MockStripePaymentHandlerActionStatus(status: .succeeded), error: nil
      )

      self.beginSCAFlowWithClientSecret.assertValues(["client-secret"])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false, true])
      self.goToThanksProject.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertValues([
        "Got it! Your changes have been saved."
      ])
      self.popToRootViewController.assertValueCount(1)
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
    }
  }

  func testUpdateBacking_RequiresSCA_Failed() {
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
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .discovery,
        context: .update
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(
        with: (amount: 25.0, min: 25.0, max: 10_000.0, isValid: true)
      )

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])

      self.vm.inputs.shippingRuleSelected(.template)

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.processingViewIsHidden.assertDidNotEmitValue()

      self.vm.inputs.submitButtonTapped()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false])
      self.processingViewIsHidden.assertValues([false])

      self.scheduler.run()

      self.processingViewIsHidden.assertValues([false, true])
      self.beginSCAFlowWithClientSecret.assertValues(["client-secret"])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false, true])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      self.vm.inputs.scaFlowCompleted(
        with: MockStripePaymentHandlerActionStatus(status: .failed), error: GraphError.invalidInput
      )

      self.beginSCAFlowWithClientSecret.assertValues(["client-secret"])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false, true])
      self.goToThanksProject.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues(
        ["The operation couldn’t be completed. (KsApi.GraphError error 5.)"]
      )
    }
  }

  func testUpdateBacking_RequiresSCA_Canceled() {
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
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .discovery,
        context: .update
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(
        with: (amount: 25.0, min: 25.0, max: 10_000.0, isValid: true)
      )

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])

      self.vm.inputs.shippingRuleSelected(.template)

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])

      self.vm.inputs.submitButtonTapped()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false])

      self.scheduler.run()

      self.beginSCAFlowWithClientSecret.assertValues(["client-secret"])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true, false, true])
      self.goToThanksProject.assertDidNotEmitValue()
      self.notifyDelegateUpdatePledgeDidSucceedWithMessage.assertDidNotEmitValue()
      self.popToRootViewController.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
    }
  }

  func testShippingSummaryViewHidden_IsHidden_NoReward() {
    self.shippingSummaryViewHidden.assertDidNotEmitValue()
    self.shippingLocationViewHidden.assertDidNotEmitValue()

    let reward = Reward.noReward
    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: nil,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.shippingLocationViewHidden.assertValues([true])
    self.shippingSummaryViewHidden.assertValues([true])
  }

  func testShippingSummaryViewHidden_IsHidden_RegularReward_NoShipping() {
    self.shippingSummaryViewHidden.assertDidNotEmitValue()
    self.shippingLocationViewHidden.assertDidNotEmitValue()

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ false
    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: nil,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.shippingLocationViewHidden.assertValues([true])
    self.shippingSummaryViewHidden.assertValues([true])
  }

  func testShippingSummaryViewHidden_IsHidden_RegularReward_Shipping_NoAddOns() {
    self.shippingSummaryViewHidden.assertDidNotEmitValue()
    self.shippingLocationViewHidden.assertDidNotEmitValue()

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: nil,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.shippingLocationViewHidden.assertValues([false])
    self.shippingSummaryViewHidden.assertValues([true])
  }

  func testShippingSummaryViewHidden_IsHidden_RegularReward_Shipping_HasAddOns_ChangePaymentContext() {
    self.shippingSummaryViewHidden.assertDidNotEmitValue()
    self.shippingLocationViewHidden.assertDidNotEmitValue()

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
    let addOnReward1 = Reward.template
      |> Reward.lens.id .~ 2
    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]

    let data = PledgeViewData(
      project: project,
      rewards: [reward, addOnReward1],
      selectedQuantities: [reward.id: 1, addOnReward1.id: 1],
      selectedLocationId: nil,
      refTag: nil,
      context: .changePaymentMethod
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.shippingLocationViewHidden.assertValues(
      [true],
      "All shipping location views are hidden in this context"
    )
    self.shippingSummaryViewHidden.assertValues([true])
  }

  func testShippingSummaryViewHidden_IsVisible_RegularReward_Shipping_HasAddOns() {
    self.shippingSummaryViewHidden.assertDidNotEmitValue()
    self.shippingLocationViewHidden.assertDidNotEmitValue()

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
    let addOnReward1 = Reward.template
      |> Reward.lens.id .~ 2
    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]

    let data = PledgeViewData(
      project: project,
      rewards: [reward, addOnReward1],
      selectedQuantities: [reward.id: 1, addOnReward1.id: 1],
      selectedLocationId: nil,
      refTag: nil,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.shippingLocationViewHidden.assertValues([true])
    self.shippingSummaryViewHidden.assertValues([false])
  }

  func testShippingLocationViewHidden_IsHidden_RegularReward_Shipping_NoAddOns_RewardIsLocalPckup() {
    self.shippingSummaryViewHidden.assertDidNotEmitValue()
    self.shippingLocationViewHidden.assertDidNotEmitValue()

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.shipping.preference .~ .local
      |> Reward.lens.localPickup .~ .losAngeles
    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: nil,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.shippingLocationViewHidden.assertValues([true])
    self.shippingSummaryViewHidden.assertValues([true])
  }

  func testLocalRewardViewHidden_IsVisible_RegularReward_Shipping_NoAddOns_RewardIsLocalPckup() {
    self.shippingSummaryViewHidden.assertDidNotEmitValue()
    self.shippingLocationViewHidden.assertDidNotEmitValue()
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
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: nil,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.shippingLocationViewHidden.assertValues([true])
    self.shippingSummaryViewHidden.assertValues([true])
    self.localPickupViewHidden.assertValues([false])
  }

  func testLocalRewardView_IsHidden_RegularReward_Shipping_HasAddOns_RewardIsNotLocalPickup() {
    self.shippingSummaryViewHidden.assertDidNotEmitValue()
    self.shippingLocationViewHidden.assertDidNotEmitValue()
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
      selectedQuantities: [reward.id: 1, addOnReward1.id: 1],
      selectedLocationId: nil,
      refTag: nil,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.shippingLocationViewHidden.assertValues([true])
    self.shippingSummaryViewHidden.assertValues([false])
    self.localPickupViewHidden.assertValues([true])
  }

  func testConfigureShippingSummaryViewWithData_HasAddOns() {
    self.configureShippingSummaryViewWithData.assertDidNotEmitValue()

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
    let addOnReward1 = Reward.template
      |> Reward.lens.id .~ 2
      |> Reward.lens.shipping.enabled .~ true
    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]

    let shippingRule = ShippingRule.template

    let data = PledgeViewData(
      project: project,
      rewards: [reward, addOnReward1],
      selectedQuantities: [reward.id: 1, addOnReward1.id: 1],
      selectedLocationId: shippingRule.id,
      refTag: nil,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.shippingRuleSelected(shippingRule)

    self.configureShippingSummaryViewWithData.assertValues([
      PledgeShippingSummaryViewData(
        locationName: "Brooklyn, NY",
        omitUSCurrencyCode: true,
        projectCountry: .us,
        total: 10
      )
    ])
  }

  func testConfigureShippingSummaryViewWithData_HasAddOns_NonUS_ProjectCurrency_US_ProjectCountry() {
    self.configureShippingSummaryViewWithData.assertDidNotEmitValue()

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
    let addOnReward1 = Reward.template
      |> Reward.lens.id .~ 2
      |> Reward.lens.shipping.enabled .~ true
    let project = Project.template
      |> Project.lens.country .~ .us
      |> Project.lens.stats.currency .~ Project.Country.mx.currencyCode
      |> Project.lens.rewardData.rewards .~ [reward]

    let shippingRule = ShippingRule.template

    let data = PledgeViewData(
      project: project,
      rewards: [reward, addOnReward1],
      selectedQuantities: [reward.id: 1, addOnReward1.id: 1],
      selectedLocationId: shippingRule.id,
      refTag: nil,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.shippingRuleSelected(shippingRule)

    self.configureShippingSummaryViewWithData.assertValues([
      PledgeShippingSummaryViewData(
        locationName: "Brooklyn, NY",
        omitUSCurrencyCode: true,
        projectCountry: .mx,
        total: 10
      )
    ])
  }

  func testConfigureShippingSummaryViewWithData_HasAddOns_OnlyOneHasShipping() {
    self.configureShippingSummaryViewWithData.assertDidNotEmitValue()

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ Reward.Shipping.Preference.restricted
    let addOnReward1 = Reward.template
      |> Reward.lens.id .~ 2
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ Reward.Shipping.Preference.unrestricted
    let addOnReward2 = Reward.template
      |> Reward.lens.id .~ 3
      |> Reward.lens.shipping.enabled .~ false

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]

    let shippingRule = ShippingRule.template

    let data = PledgeViewData(
      project: project,
      rewards: [reward, addOnReward1, addOnReward2],
      selectedQuantities: [reward.id: 1, addOnReward1.id: 1, addOnReward2.id: 2],
      selectedLocationId: shippingRule.location.id,
      refTag: nil,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.shippingRuleSelected(shippingRule)

    self.configureShippingSummaryViewWithData.assertValues([
      PledgeShippingSummaryViewData(
        locationName: "Brooklyn, NY",
        omitUSCurrencyCode: true,
        projectCountry: .us,
        total: 10
      )
    ])
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

  func testPledgeAmountSummaryViewHidden_UpdateContext_NoReward_IsHidden() {
    self.pledgeAmountSummaryViewHidden.assertDidNotEmitValue()

    let project = Project.template
    let reward = Reward.noReward

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: .projectPage,
      context: .update
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.pledgeAmountSummaryViewHidden.assertValues([true])
  }

  func testPledgeAmountSummaryViewHidden_UpdateContext_RegularReward_IsNotHidden() {
    self.pledgeAmountSummaryViewHidden.assertDidNotEmitValue()

    let project = Project.template
    let reward = Reward.template

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: .projectPage,
      context: .update
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.pledgeAmountSummaryViewHidden.assertValues([false])
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
        selectedQuantities: [reward.id: 1, addOnReward1.id: 2, addOnReward2.id: 1],
        selectedLocationId: nil,
        refTag: .activity,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      let paymentSourceSelected = PaymentSourceSelected(
        paymentSourceId: "123",
        isSetupIntentClientSecret: true
      )

      self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(
        with: (amount: 25.0, min: 10.0, max: 10_000.0, isValid: true)
      )

      self.processingViewIsHidden.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])

      self.vm.inputs.submitButtonTapped()

      self.processingViewIsHidden.assertValues([false])
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
        selectedQuantities: [reward.id: 1, addOnReward1.id: 1, addOnReward2.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      let paymentSourceSelected = PaymentSourceSelected(
        paymentSourceId: "123",
        isSetupIntentClientSecret: true
      )

      self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])

      self.processingViewIsHidden.assertDidNotEmitValue()

      self.vm.inputs.applePayButtonTapped()

      self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
        paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345")
      )

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(
        with: (amount: 25.0, min: 10.0, max: 10_000.0, isValid: true)
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

  func testTrackingEvents_CheckoutPaymentPageViewed() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.shipping .~ (.template |> Reward.Shipping.lens.enabled .~ true)
      |> Reward.lens.endsAt .~ MockDate().addingTimeInterval(5).timeIntervalSince1970

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: nil,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual(["Page Viewed"], self.segmentTrackingClient.events)

    let segmentTrackingClientProps = self.segmentTrackingClient.properties.last

    // Context properties

    XCTAssertEqual("checkout", segmentTrackingClientProps?["context_page"] as? String)

    // Checkout properties

    XCTAssertEqual("credit_card", segmentTrackingClientProps?["checkout_payment_type"] as? String)
    XCTAssertEqual("My Reward", segmentTrackingClientProps?["checkout_reward_title"] as? String)
    XCTAssertEqual(10.00, segmentTrackingClientProps?["checkout_reward_minimum_usd"] as? Decimal)
    XCTAssertEqual("1", segmentTrackingClientProps?["checkout_reward_id"] as? String)
    XCTAssertEqual(10.00, segmentTrackingClientProps?["checkout_amount_total_usd"] as? Decimal)
    XCTAssertEqual(true, segmentTrackingClientProps?["checkout_reward_is_limited_quantity"] as? Bool)
    XCTAssertEqual(true, segmentTrackingClientProps?["checkout_reward_is_limited_time"] as? Bool)
    XCTAssertEqual(true, segmentTrackingClientProps?["checkout_reward_shipping_enabled"] as? Bool)
    XCTAssertEqual(
      true,
      segmentTrackingClientProps?["checkout_user_has_eligible_stored_apple_pay_card"] as? Bool
    )
  }

  func testTrackingEvents_ChangePaymentMethod() {
    let project = Project.template
    let reward = Reward.template

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
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

  func testTrackingEvents_ContextIsUpdate() {
    let project = Project.template
    let reward = Reward.template

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: nil,
      context: .update
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    let segmentTrackingClientProps = self.segmentTrackingClient.properties.last

    XCTAssertEqual(["Page Viewed"], self.segmentTrackingClient.events)
    XCTAssertEqual("update_pledge", segmentTrackingClientProps?["context_page"] as? String)
    XCTAssertEqual("update_pledge", segmentTrackingClient.properties.last?["context_page"] as? String)

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

  func testTrackingEvents_ContextIsUpdateReward() {
    let project = Project.template
    let reward = Reward.template

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
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
      segmentClient: segmentClient
    )

    withEnvironment(currentUser: nil, ksrAnalytics: ksrAnalytics) {
      let data = PledgeViewData(
        project: project,
        rewards: [reward],
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
      segmentClient: segmentClient
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
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: .discovery,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual(["Page Viewed"], self.segmentTrackingClient.events)

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: (
      amount: 40.0,
      min: 10.0,
      max: 100.0,
      isValid: true
    ))
    self.vm.inputs.shippingRuleSelected(.template)

    let paymentSourceSelected = PaymentSourceSelected(
      paymentSourceId: "123",
      isSetupIntentClientSecret: false
    )

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

  func testTrackingEvents_PledgeConfirmButtonClicked() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.experiments
      .~ [
        OptimizelyExperiment.Key.nativeRiskMessaging.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: .discovery,
      context: .pledge
    )

    withEnvironment(optimizelyClient: mockOptimizelyClient) {
      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      XCTAssertEqual(["Page Viewed"], self.segmentTrackingClient.events)

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: (
        amount: 40.0,
        min: 10.0,
        max: 100.0,
        isValid: true
      ))
      self.vm.inputs.shippingRuleSelected(.template)

      let paymentSourceSelected = PaymentSourceSelected(
        paymentSourceId: "123",
        isSetupIntentClientSecret: false
      )

      self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

      self.vm.inputs.submitButtonTapped()

      XCTAssertEqual(
        ["Page Viewed", "CTA Clicked"],
        self.segmentTrackingClient.events
      )

      self.vm.inputs.riskMessagingViewControllerDismissed(isApplePay: false)

      XCTAssertEqual(
        ["Page Viewed", "CTA Clicked", "CTA Clicked"],
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
        KSRAnalytics.CTAContext.pledgeConfirm.trackingString,
        segmentClientProps?["context_cta"] as? String
      )

      XCTAssertEqual(
        KSRAnalytics.TypeContext.creditCard.trackingString,
        segmentClientProps?["context_type"] as? String
      )
    }
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
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: nil,
        context: .fixPaymentMethod
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      let paymentSourceSelected = PaymentSourceSelected(
        paymentSourceId: "12345",
        isSetupIntentClientSecret: false
      )

      self.vm.inputs.creditCardSelected(with: paymentSourceSelected)

      XCTAssertEqual([], self.segmentTrackingClient.events)

      self.vm.inputs.submitButtonTapped()

      XCTAssertEqual(
        ["CTA Clicked"],
        self.segmentTrackingClient.events
      )
    }
  }
}
