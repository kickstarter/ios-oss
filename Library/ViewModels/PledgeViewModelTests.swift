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
  private let configureExpandableRewardsHeaderWithDataProjectCountry = TestObserver<Project.Country, Never>()
  private let configureExpandableRewardsHeaderWithDataOmitCurrencyCode = TestObserver<Bool, Never>()

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

  private let goToThanksCheckoutData = TestObserver<Koala.CheckoutPropertiesData?, Never>()
  private let goToThanksProject = TestObserver<Project, Never>()
  private let goToThanksReward = TestObserver<Reward, Never>()

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
      .observe(self.configureExpandableRewardsHeaderWithDataProjectCountry.observer)
    self.vm.outputs.configureExpandableRewardsHeaderWithData.map(\.omitCurrencyCode)
      .observe(self.configureExpandableRewardsHeaderWithDataOmitCurrencyCode.observer)

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

    self.vm.outputs.goToThanks.map(first).observe(self.goToThanksProject.observer)
    self.vm.outputs.goToThanks.map(second).observe(self.goToThanksReward.observer)
    self.vm.outputs.goToThanks.map(third).observe(self.goToThanksCheckoutData.observer)

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
      self.configureExpandableRewardsHeaderWithDataProjectCountry.assertValues([.us])
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
      self.configureExpandableRewardsHeaderWithDataProjectCountry.assertValues([.us])
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
      self.configureExpandableRewardsHeaderWithDataProjectCountry.assertValues([.us])
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
      self.configureExpandableRewardsHeaderWithDataProjectCountry.assertValues([.us])
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
      self.configureExpandableRewardsHeaderWithDataProjectCountry.assertValues([.us])
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
      self.configureExpandableRewardsHeaderWithDataProjectCountry.assertValues([.us])
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

      self.vm.inputs.creditCardSelected(with: backing.paymentSource?.id ?? "")

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
      self.configureExpandableRewardsHeaderWithDataProjectCountry.assertDidNotEmitValue()
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

  func testShowApplePayAlert_WhenApplePayButtonTapped_PledgeInputAmount_AboveMax() {
    let project = Project.template
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

      let checkoutData = Koala.CheckoutPropertiesData(
        amount: "15.00",
        bonusAmount: "10.00",
        bonusAmountInUsd: "10.00",
        checkoutId: 1,
        estimatedDelivery: 1_506_897_315.0,
        paymentType: "APPLE_PAY",
        revenueInUsdCents: 1_500,
        rewardId: 1,
        rewardTitle: "My Reward",
        shippingEnabled: false,
        shippingAmount: nil,
        userHasStoredApplePayCard: true
      )

      self.processingViewIsHidden.assertValues([false, true])
      self.goToThanksProject.assertValues([project])
      self.goToThanksReward.assertValues([reward])
      self.goToThanksCheckoutData.assertValues([checkoutData])

      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      XCTAssertEqual(
        ["Checkout Payment Page Viewed"],
        self.trackingClient.events
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

      let checkoutData = Koala.CheckoutPropertiesData(
        amount: "15.00",
        bonusAmount: "10.00",
        bonusAmountInUsd: "13.09",
        checkoutId: 1,
        estimatedDelivery: 1_506_897_315.0,
        paymentType: "APPLE_PAY",
        revenueInUsdCents: 1_965,
        rewardId: 1,
        rewardTitle: "My Reward",
        shippingEnabled: false,
        shippingAmount: nil,
        userHasStoredApplePayCard: true
      )

      self.processingViewIsHidden.assertValues([false, true])
      self.goToThanksProject.assertValues([project])
      self.goToThanksReward.assertValues([reward])
      self.goToThanksCheckoutData.assertValues([checkoutData])

      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      XCTAssertEqual(
        ["Checkout Payment Page Viewed"],
        self.trackingClient.events
      )
    }
  }

  func testApplePay_OptimizelyExperimentTracking() {
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

    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.pledgeCTACopy.rawValue: OptimizelyExperiment.Variant.variant1.rawValue
      ]

    withEnvironment(apiService: mockService, currentUser: .template, optimizelyClient: optimizelyClient) {
      let project = Project.template
      let reward = Reward.noReward
        |> Reward.lens.minimum .~ 5

      XCTAssertNil(optimizelyClient.trackedAttributes)

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

      XCTAssertEqual(optimizelyClient.trackedEventKey, "Pledge Screen Viewed")

      self.vm.inputs.applePayButtonTapped()

      self.vm.inputs.paymentAuthorizationDidAuthorizePayment(
        paymentData: (displayName: "Visa 123", network: "Visa", transactionIdentifier: "12345")
      )

      XCTAssertEqual(
        PKPaymentAuthorizationStatus.success,
        self.vm.inputs.stripeTokenCreated(token: "stripe_token", error: nil)
      )

      self.vm.inputs.paymentAuthorizationViewControllerDidFinish()

      self.scheduler.run()

      XCTAssertEqual(optimizelyClient.trackedUserId, "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF")
      XCTAssertEqual(optimizelyClient.trackedEventKey, "App Completed Checkout")

      XCTAssertEqual(optimizelyClient.trackedAttributes?["user_backed_projects_count"] as? Int, nil)
      XCTAssertEqual(optimizelyClient.trackedAttributes?["user_launched_projects_count"] as? Int, nil)
      XCTAssertEqual(optimizelyClient.trackedAttributes?["user_country"] as? String, "us")
      XCTAssertEqual(optimizelyClient.trackedAttributes?["user_facebook_account"] as? Bool, nil)
      XCTAssertEqual(optimizelyClient.trackedAttributes?["user_display_language"] as? String, "en")
      XCTAssertEqual(
        optimizelyClient.trackedAttributes?["session_os_version"] as? String, "MockSystemVersion"
      )
      XCTAssertEqual(optimizelyClient.trackedAttributes?["session_user_is_logged_in"] as? Bool, true)
      XCTAssertEqual(
        optimizelyClient.trackedAttributes?["session_app_release_version"] as? String, "1.2.3.4.5.6.7.8.9.0"
      )
      XCTAssertEqual(optimizelyClient.trackedAttributes?["session_apple_pay_device"] as? Bool, true)
      XCTAssertEqual(optimizelyClient.trackedAttributes?["session_device_format"] as? String, "phone")
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
      let reward = Reward.template
        |> Reward.lens.minimum .~ 5
        |> Reward.lens.shipping.enabled .~ true

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

      self.configurePaymentMethodsViewControllerWithUser.assertValues([User.template])
      self.configurePaymentMethodsViewControllerWithProject.assertValues([project])
      self.configurePaymentMethodsViewControllerWithReward.assertValues([reward])
      self.configurePaymentMethodsViewControllerWithContext.assertValues([.pledge])

      self.configureShippingLocationViewWithDataProject.assertValues([project])
      self.configureShippingLocationViewWithDataReward.assertValues([reward])
      self.configureShippingLocationViewWithDataShowAmount.assertValues([true])

      self.configureSummaryViewControllerWithDataPledgeTotal.assertValues([reward.minimum])
      self.configureSummaryViewControllerWithDataProject.assertValues([project])

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

      let checkoutData = Koala.CheckoutPropertiesData(
        amount: "5.00",
        bonusAmount: "0.00",
        bonusAmountInUsd: "0.00",
        checkoutId: 1,
        estimatedDelivery: 1_506_897_315.0,
        paymentType: "APPLE_PAY",
        revenueInUsdCents: 500,
        rewardId: 1,
        rewardTitle: "My Reward",
        shippingEnabled: true,
        shippingAmount: nil,
        userHasStoredApplePayCard: true
      )

      self.goToThanksProject.assertValues([project])
      self.goToThanksReward.assertValues([reward])
      self.goToThanksCheckoutData.assertValues([checkoutData])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      XCTAssertEqual(
        ["Checkout Payment Page Viewed"],
        self.trackingClient.events
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
        ["Checkout Payment Page Viewed"],
        self.trackingClient.events
      )
      XCTAssertEqual([nil], self.trackingClient.properties(forKey: "pledge_context"))
    }
  }

  func testCreateApplePayBackingError() {
    let mockService = MockService(createBackingResult: .failure(.invalidInput))

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
        ["Checkout Payment Page Viewed"],
        self.trackingClient.events
      )
      XCTAssertEqual([nil], self.trackingClient.properties(forKey: "pledge_context"))
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

      self.vm.inputs.creditCardSelected(with: "123")

      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(
        with: (amount: 15.0, min: 10.0, max: 10_000.0, isValid: true)
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

      let checkoutData = Koala.CheckoutPropertiesData(
        amount: "25.00",
        bonusAmount: "15.00",
        bonusAmountInUsd: "15.00",
        checkoutId: 1,
        estimatedDelivery: Reward.template.estimatedDeliveryOn,
        paymentType: "CREDIT_CARD",
        revenueInUsdCents: 2_500,
        rewardId: Reward.template.id,
        rewardTitle: Reward.template.title,
        shippingEnabled: Reward.template.shipping.enabled,
        shippingAmount: nil,
        userHasStoredApplePayCard: true
      )

      self.goToThanksProject.assertValues([.template])
      self.goToThanksReward.assertValues([.template])
      self.goToThanksCheckoutData.assertValues([checkoutData])

      XCTAssertEqual(
        ["Checkout Payment Page Viewed", "Pledge Submit Button Clicked"],
        self.trackingClient.events
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

      self.vm.inputs.creditCardSelected(with: "123")

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

      let checkoutData = Koala.CheckoutPropertiesData(
        amount: "35.00",
        bonusAmount: "25.00",
        bonusAmountInUsd: "25.00",
        checkoutId: 1,
        estimatedDelivery: reward.estimatedDeliveryOn,
        paymentType: "CREDIT_CARD",
        revenueInUsdCents: 3_500,
        rewardId: reward.id,
        rewardTitle: reward.title,
        shippingEnabled: reward.shipping.enabled,
        shippingAmount: nil,
        userHasStoredApplePayCard: true
      )

      self.goToThanksProject.assertValues([.template])
      self.goToThanksReward.assertValues([reward])
      self.goToThanksCheckoutData.assertValues([checkoutData])

      XCTAssertEqual(
        ["Checkout Payment Page Viewed", "Pledge Submit Button Clicked"],
        self.trackingClient.events
      )
    }
  }

  func testCreateBacking_Success_OptimizelyExperimentTracking() {
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

    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.pledgeCTACopy.rawValue: OptimizelyExperiment.Variant.variant1.rawValue
      ]

    withEnvironment(apiService: mockService, currentUser: .template, optimizelyClient: optimizelyClient) {
      XCTAssertNil(optimizelyClient.trackedAttributes)

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

      XCTAssertEqual(optimizelyClient.trackedEventKey, "Pledge Screen Viewed")

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(
        with: (amount: 25.0, min: 10.0, max: 10_000.0, isValid: true)
      )

      self.vm.inputs.submitButtonTapped()

      self.scheduler.run()

      XCTAssertEqual(optimizelyClient.trackedUserId, "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF")
      XCTAssertEqual(optimizelyClient.trackedEventKey, "App Completed Checkout")

      XCTAssertEqual(optimizelyClient.trackedAttributes?["user_backed_projects_count"] as? Int, nil)
      XCTAssertEqual(optimizelyClient.trackedAttributes?["user_launched_projects_count"] as? Int, nil)
      XCTAssertEqual(optimizelyClient.trackedAttributes?["user_country"] as? String, "us")
      XCTAssertEqual(optimizelyClient.trackedAttributes?["user_facebook_account"] as? Bool, nil)
      XCTAssertEqual(optimizelyClient.trackedAttributes?["user_display_language"] as? String, "en")
      XCTAssertEqual(
        optimizelyClient.trackedAttributes?["session_os_version"] as? String, "MockSystemVersion"
      )
      XCTAssertEqual(optimizelyClient.trackedAttributes?["session_user_is_logged_in"] as? Bool, true)
      XCTAssertEqual(
        optimizelyClient.trackedAttributes?["session_app_release_version"] as? String, "1.2.3.4.5.6.7.8.9.0"
      )
      XCTAssertEqual(optimizelyClient.trackedAttributes?["session_apple_pay_device"] as? Bool, true)
      XCTAssertEqual(optimizelyClient.trackedAttributes?["session_device_format"] as? String, "phone")
    }
  }

  func testCreateBacking_Failure() {
    let mockService = MockService(
      createBackingResult:
      Result.failure(GraphError.invalidInput)
    )

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

      self.vm.inputs.creditCardSelected(with: "123")

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
        ["Checkout Payment Page Viewed", "Pledge Submit Button Clicked"],
        self.trackingClient.events
      )
      XCTAssertEqual([nil, nil], self.trackingClient.properties(forKey: "pledge_context"))
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
      updateBackingResult: .failure(.invalidInput)
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

    self.vm.inputs.creditCardSelected(with: "12345")

    self.configurePledgeViewCTAContainerViewIsEnabled.assertValues(
      [false, true, false, true, false, true],
      "Payment method changed"
    )

    self.vm.inputs.creditCardSelected(with: Backing.PaymentSource.template.id ?? "")

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

  func testChangePaymentMethod_ApplePay_Failure() {
    let mockService = MockService(
      updateBackingResult: .failure(.invalidInput)
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

  func testApplePayBackingFails_ThenSucceeds_SignalsDoNotOverlap_UpdateContext() {
    let mockService1 = MockService(
      updateBackingResult: .failure(.invalidInput)
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
      updateBackingResult: .failure(.invalidInput)
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
      self.vm.inputs.creditCardSelected(with: "123")

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
      updateBackingResult: .failure(.invalidInput)
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

      self.vm.inputs.creditCardSelected(with: "123")

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
      updateBackingResult: .failure(.invalidInput)
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

      self.vm.inputs.creditCardSelected(with: "123")

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

      self.vm.inputs.shippingRuleSelected(defaultShippingRule)

      self.beginSCAFlowWithClientSecret.assertDidNotEmitValue()
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.goToThanksProject.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      self.vm.inputs.creditCardSelected(with: "123")

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

      let checkoutData = Koala.CheckoutPropertiesData(
        amount: "25.00",
        bonusAmount: "15.00",
        bonusAmountInUsd: "15.00",
        checkoutId: 1,
        estimatedDelivery: Reward.template.estimatedDeliveryOn,
        paymentType: "CREDIT_CARD",
        revenueInUsdCents: 2_500,
        rewardId: Reward.template.id,
        rewardTitle: Reward.template.title,
        shippingEnabled: Reward.template.shipping.enabled,
        shippingAmount: 10,
        userHasStoredApplePayCard: true
      )

      self.goToThanksProject.assertValues([.template])
      self.goToThanksReward.assertValues([.template])
      self.goToThanksCheckoutData.assertValues([checkoutData])

      XCTAssertEqual(
        ["Checkout Payment Page Viewed", "Pledge Submit Button Clicked"],
        self.trackingClient.events
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

      self.vm.inputs.creditCardSelected(with: "123")

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
        ["Checkout Payment Page Viewed", "Pledge Submit Button Clicked"],
        self.trackingClient.events
      )
      XCTAssertEqual([nil, nil], self.trackingClient.properties(forKey: "pledge_context"))
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

      self.vm.inputs.creditCardSelected(with: "123")

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
        ["Checkout Payment Page Viewed", "Pledge Submit Button Clicked"],
        self.trackingClient.events
      )
      XCTAssertEqual([nil, nil], self.trackingClient.properties(forKey: "pledge_context"))
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

  func testConfigureShippingSummaryViewWithData_HasAddOns_OnlyOneHasShipping() {
    self.configureShippingSummaryViewWithData.assertDidNotEmitValue()

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
    let addOnReward1 = Reward.template
      |> Reward.lens.id .~ 2
      |> Reward.lens.shipping.enabled .~ true
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

  func testTrackingEvents_CheckoutPaymentPageViewed() {
    let project = Project.template
    let reward = Reward.template

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

    XCTAssertEqual(["Checkout Payment Page Viewed"], self.trackingClient.events)

    XCTAssertEqual(self.trackingClient.properties(forKey: "context_pledge_flow"), ["new_pledge"])

    let properties = self.trackingClient.properties.last

    XCTAssertNotNil(properties?["optimizely_api_key"], "Event includes Optimizely properties")
    XCTAssertNotNil(properties?["optimizely_environment"], "Event includes Optimizely properties")
    XCTAssertNotNil(properties?["optimizely_experiments"], "Event includes Optimizely properties")
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

    XCTAssertEqual(["Checkout Payment Page Viewed"], self.trackingClient.events)
    XCTAssertEqual(self.trackingClient.properties(forKey: "context_pledge_flow"), ["manage_reward"])

    self.vm.inputs.submitButtonTapped()

    XCTAssertEqual([
      "Checkout Payment Page Viewed",
      "Update Payment Method Button Clicked"
    ], self.trackingClient.events)
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

    XCTAssertEqual(["Checkout Payment Page Viewed"], self.trackingClient.events)
    XCTAssertEqual(self.trackingClient.properties(forKey: "context_pledge_flow"), ["manage_reward"])

    self.vm.inputs.submitButtonTapped()

    XCTAssertEqual(
      ["Checkout Payment Page Viewed", "Update Pledge Button Clicked"],
      self.trackingClient.events
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

    XCTAssertEqual(["Checkout Payment Page Viewed"], self.trackingClient.events)
    XCTAssertEqual(self.trackingClient.properties(forKey: "context_pledge_flow"), ["change_reward"])

    self.vm.inputs.submitButtonTapped()

    XCTAssertEqual(
      ["Checkout Payment Page Viewed", "Update Pledge Button Clicked"],
      self.trackingClient.events
    )
  }

  func testTrackingEvents_PledgeScreenViewed_LoggedOut() {
    let project = Project.template
      |> \.category.name .~ Project.Category.illustration.name
      |> \.category.parentId .~ Project.Category.art.id
      |> \.category.parentName .~ Project.Category.art.name

    let reward = Reward.template

    let trackingClient = MockTrackingClient()
    let koala = Koala(client: trackingClient, config: .template, loggedInUser: nil)

    withEnvironment(currentUser: nil, koala: koala) {
      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .discovery,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)

      XCTAssertEqual([], self.trackingClient.events)
      self.vm.inputs.viewDidLoad()

      XCTAssertEqual(["Checkout Payment Page Viewed"], trackingClient.events)

      XCTAssertEqual(trackingClient.properties(forKey: "context_pledge_flow"), ["new_pledge"])
      XCTAssertEqual(trackingClient.properties(forKey: "session_ref_tag"), ["discovery"])
      XCTAssertEqual(
        trackingClient.properties(forKey: "session_referrer_credit"),
        ["discovery"]
      )

      XCTAssertEqual(trackingClient.properties(forKey: "session_user_logged_in", as: Bool.self), [false])
      XCTAssertEqual(trackingClient.properties(forKey: "user_country"), ["US"])
      XCTAssertEqual(trackingClient.properties(forKey: "user_uid", as: Int.self), [nil])

      XCTAssertEqual(trackingClient.properties(forKey: "project_subcategory"), ["Illustration"])
      XCTAssertEqual(trackingClient.properties(forKey: "project_category"), ["Art"])
      XCTAssertEqual(trackingClient.properties(forKey: "project_country"), ["US"])
      XCTAssertEqual(trackingClient.properties(forKey: "project_user_has_watched", as: Bool.self), [nil])
    }
  }

  func testTrackingEvents_OptimizelyClient_PledgeScreenViewed_LoggedOut() {
    let project = Project.template
      |> \.category.parentId .~ Project.Category.art.id
      |> \.category.parentName .~ Project.Category.art.name

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

    XCTAssertEqual([], self.trackingClient.events)
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual(["Checkout Payment Page Viewed"], self.trackingClient.events)

    XCTAssertEqual(self.optimizelyClient.trackedUserId, "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF")
    XCTAssertEqual(self.optimizelyClient.trackedEventKey, "Pledge Screen Viewed")

    XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_backed_projects_count"] as? Int, nil)
    XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_launched_projects_count"] as? Int, nil)
    XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_country"] as? String, "us")
    XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_facebook_account"] as? Bool, nil)
    XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_display_language"] as? String, "en")

    XCTAssertEqual(self.optimizelyClient.trackedAttributes?["session_ref_tag"] as? String, nil)
    XCTAssertEqual(self.optimizelyClient.trackedAttributes?["session_referrer_credit"] as? String, nil)
    XCTAssertEqual(
      self.optimizelyClient.trackedAttributes?["session_os_version"] as? String,
      "MockSystemVersion"
    )
    XCTAssertEqual(self.optimizelyClient.trackedAttributes?["session_user_is_logged_in"] as? Bool, false)
    XCTAssertEqual(
      self.optimizelyClient.trackedAttributes?["session_app_release_version"] as? String,
      "1.2.3.4.5.6.7.8.9.0"
    )
    XCTAssertEqual(self.optimizelyClient.trackedAttributes?["session_apple_pay_device"] as? Bool, true)
    XCTAssertEqual(self.optimizelyClient.trackedAttributes?["session_device_format"] as? String, "phone")
  }

  func testTrackingEvents_OptimizelyClient_PledgeScreenViewed_LoggedIn() {
    let user = User.template
      |> \.location .~ Location.template
      |> \.stats.backedProjectsCount .~ 50
      |> \.stats.createdProjectsCount .~ 25
      |> \.facebookConnected .~ true

    withEnvironment(currentUser: user) {
      let project = Project.template
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

      XCTAssertEqual([], self.trackingClient.events)
      self.vm.inputs.viewDidLoad()

      XCTAssertEqual(["Checkout Payment Page Viewed"], self.trackingClient.events)

      XCTAssertEqual(self.optimizelyClient.trackedUserId, "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF")
      XCTAssertEqual(self.optimizelyClient.trackedEventKey, "Pledge Screen Viewed")

      XCTAssertNil(self.optimizelyClient.trackedAttributes?["user_distinct_id"] as? String)
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_backed_projects_count"] as? Int, 50)
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_launched_projects_count"] as? Int, 25)
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_country"] as? String, "us")
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_facebook_account"] as? Bool, true)
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["user_display_language"] as? String, "en")
      XCTAssertEqual(
        self.optimizelyClient.trackedAttributes?["session_os_version"] as? String,
        "MockSystemVersion"
      )
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["session_user_is_logged_in"] as? Bool, true)
      XCTAssertEqual(
        self.optimizelyClient.trackedAttributes?["session_app_release_version"] as? String,
        "1.2.3.4.5.6.7.8.9.0"
      )
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["session_apple_pay_device"] as? Bool, true)
      XCTAssertEqual(self.optimizelyClient.trackedAttributes?["session_device_format"] as? String, "phone")
    }
  }

  func testTrackingEvents_PledgeScreenViewed_LoggedIn() {
    let user = User.template
      |> \.location .~ Location.template
      |> \.stats.backedProjectsCount .~ 50
      |> \.stats.createdProjectsCount .~ 25
      |> \.facebookConnected .~ true

    let trackingClient = MockTrackingClient()
    let koala = Koala(client: trackingClient, config: .template, loggedInUser: user)

    withEnvironment(currentUser: user, koala: koala) {
      let project = Project.template
        |> \.category.name .~ Project.Category.illustration.name
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

      XCTAssertEqual([], self.trackingClient.events)
      self.vm.inputs.viewDidLoad()

      XCTAssertEqual(["Checkout Payment Page Viewed"], trackingClient.events)

      XCTAssertEqual(trackingClient.properties(forKey: "session_ref_tag"), ["discovery"])
      XCTAssertEqual(
        trackingClient.properties(forKey: "session_referrer_credit"),
        ["discovery"]
      )

      XCTAssertEqual(trackingClient.properties(forKey: "session_user_logged_in", as: Bool.self), [true])
      XCTAssertEqual(trackingClient.properties(forKey: "user_country"), ["US"])
      XCTAssertEqual(trackingClient.properties(forKey: "user_uid", as: Int.self), [1])

      XCTAssertEqual(trackingClient.properties(forKey: "project_subcategory"), ["Illustration"])
      XCTAssertEqual(trackingClient.properties(forKey: "project_category"), ["Art"])
      XCTAssertEqual(trackingClient.properties(forKey: "project_country"), ["US"])
      XCTAssertEqual(trackingClient.properties(forKey: "project_user_has_watched", as: Bool.self), [true])
    }
  }

  func testTrackingEvents_PledgeScreenViewed_DistinctID_LoggedIn_Beta_Staging() {
    let user = User.template
      |> \.location .~ Location.template
      |> \.stats.backedProjectsCount .~ 50
      |> \.stats.createdProjectsCount .~ 25
      |> \.facebookConnected .~ true

    let mockBundle = MockBundle(
      bundleIdentifier: KickstarterBundleIdentifier.beta.rawValue,
      lang: Language.en.rawValue
    )

    let mockService = MockService(serverConfig: ServerConfig.staging)

    withEnvironment(apiService: mockService, currentUser: user, mainBundle: mockBundle) {
      let project = Project.template
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

      XCTAssertEqual([], self.trackingClient.events)
      self.vm.inputs.viewDidLoad()

      XCTAssertEqual(
        self.optimizelyClient.trackedAttributes?["user_distinct_id"] as? String,
        "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF"
      )
    }
  }

  func testTrackingEvents_PledgeScreenViewed_DistinctID_LoggedIn_Release_Production() {
    let user = User.template
      |> \.location .~ Location.template
      |> \.stats.backedProjectsCount .~ 50
      |> \.stats.createdProjectsCount .~ 25
      |> \.facebookConnected .~ true

    let mockBundle = MockBundle(
      bundleIdentifier: KickstarterBundleIdentifier.release.rawValue,
      lang: Language.en.rawValue
    )

    let mockService = MockService(serverConfig: ServerConfig.production)

    withEnvironment(apiService: mockService, currentUser: user, mainBundle: mockBundle) {
      let project = Project.template
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

      XCTAssertEqual([], self.trackingClient.events)
      self.vm.inputs.viewDidLoad()

      XCTAssertNil(self.optimizelyClient.trackedAttributes?["user_distinct_id"] as? String)
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

    XCTAssertEqual(["Checkout Payment Page Viewed"], self.trackingClient.events)

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: (
      amount: 40.0,
      min: 10.0,
      max: 100.0,
      isValid: true
    ))
    self.vm.inputs.shippingRuleSelected(.template)
    self.vm.inputs.creditCardSelected(with: "123")

    self.vm.inputs.submitButtonTapped()

    XCTAssertEqual(
      ["Checkout Payment Page Viewed", "Pledge Submit Button Clicked"],
      self.trackingClient.events
    )

    let props = self.trackingClient.properties.last

    // Checkout properties
    XCTAssertEqual("55.00", props?["checkout_amount"] as? String)
    XCTAssertEqual("CREDIT_CARD", props?["checkout_payment_type"] as? String)
    XCTAssertEqual(1, props?["checkout_reward_id"] as? Int)
    XCTAssertEqual(5_500, props?["checkout_revenue_in_usd_cents"] as? Int)
    XCTAssertEqual(true, props?["checkout_reward_shipping_enabled"] as? Bool)
    XCTAssertEqual(true, props?["checkout_user_has_eligible_stored_apple_pay_card"] as? Bool)
    XCTAssertEqual(5.0, props?["checkout_shipping_amount"] as? Double)
    XCTAssertEqual(1_506_897_315.0, props?["checkout_reward_estimated_delivery_on"] as? TimeInterval)
    XCTAssertEqual("My Reward", props?["checkout_reward_title"] as? String)

    // Pledge properties
    XCTAssertEqual(true, props?["pledge_backer_reward_has_items"] as? Bool)
    XCTAssertEqual(1, props?["pledge_backer_reward_id"] as? Int)
    XCTAssertEqual(true, props?["pledge_backer_reward_is_limited_quantity"] as? Bool)
    XCTAssertEqual(false, props?["pledge_backer_reward_is_limited_time"] as? Bool)
    XCTAssertEqual(10.00, props?["pledge_backer_reward_minimum"] as? Double)
    XCTAssertEqual(true, props?["pledge_backer_reward_shipping_enabled"] as? Bool)

    XCTAssertNil(props?["pledge_backer_reward_shipping_preference"] as? String)

    // Project properties
    XCTAssertEqual(1, props?["project_pid"] as? Int)

    XCTAssertEqual("discovery", props?["session_ref_tag"] as? String)
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
      self.vm.inputs.creditCardSelected(with: "12345")

      XCTAssertEqual(["Checkout Payment Page Viewed"], self.trackingClient.events)

      self.vm.inputs.submitButtonTapped()

      XCTAssertEqual(
        ["Checkout Payment Page Viewed", "Update Pledge Button Clicked"],
        self.trackingClient.events
      )
    }
  }
}
