import Foundation
@testable import KsApi
@testable import Library
import PassKit
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class NoShippingConfirmDetailsViewModelTests: TestCase {
  private let vm: NoShippingConfirmDetailsViewModelType = NoShippingConfirmDetailsViewModel()

  private let configurePledgeSummaryViewControllerWithDataConfirmationLabelHidden = TestObserver<
    Bool,
    Never
  >()
  private let configurePledgeSummaryViewControllerWithDataPledgeTotal = TestObserver<Double, Never>()
  private let configurePledgeSummaryViewControllerWithDataProject = TestObserver<Project, Never>()

  private let configureLocalPickupViewWithData = TestObserver<PledgeLocalPickupViewData, Never>()

  private let createCheckoutSuccess = TestObserver<PostCampaignCheckoutData, Never>()

  private let goToLoginSignup = TestObserver<(LoginIntent, Project, Reward?), Never>()

  private let localPickupViewHidden = TestObserver<Bool, Never>()
  private let pledgeAmountViewHidden = TestObserver<Bool, Never>()

  private let showErrorBannerWithMessage = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.configureLocalPickupViewWithData.observe(self.configureLocalPickupViewWithData.observer)

    self.vm.outputs.configurePledgeSummaryViewControllerWithData.map { $0.2 }
      .observe(self.configurePledgeSummaryViewControllerWithDataConfirmationLabelHidden.observer)
    self.vm.outputs.configurePledgeSummaryViewControllerWithData.map { $0.1 }
      .observe(self.configurePledgeSummaryViewControllerWithDataPledgeTotal.observer)
    self.vm.outputs.configurePledgeSummaryViewControllerWithData.map { $0.0 }
      .observe(self.configurePledgeSummaryViewControllerWithDataProject.observer)

    self.vm.outputs.createCheckoutSuccess.observe(self.createCheckoutSuccess.observer)

    self.vm.outputs.goToLoginSignup.observe(self.goToLoginSignup.observer)

    self.vm.outputs.localPickupViewHidden.observe(self.localPickupViewHidden.observer)
    self.vm.outputs.pledgeAmountViewHidden.observe(self.pledgeAmountViewHidden.observer)

    self.vm.outputs.showErrorBannerWithMessage.observe(self.showErrorBannerWithMessage.observer)
  }

  // MARK: - Login/Signup

  func testGoToLoginSignup_emitsWhenLoggedOut_createCheckoutSuccessDoesNotEmit() {
    withEnvironment(currentUser: nil) {
      let data = PledgeViewData(
        project: Project.template,
        rewards: [Reward.template],
        selectedShippingRule: nil,
        selectedQuantities: [Reward.template.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .latePledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.continueCTATapped()

      self.goToLoginSignup.assertDidEmitValue()
      self.createCheckoutSuccess.assertDidNotEmitValue()
    }
  }

  func testGoToLoginSignup_doesNotEmitWhenLoggedIn_createCheckoutIsSuccessful() {
    let expectedId = "Q2hlY2tvdXQtMTk4MzM2NjQ2"
    let createCheckout = CreateCheckoutEnvelope.Checkout(
      id: expectedId,
      paymentUrl: "paymentUrl",
      backingId: "backingId"
    )
    let mockService = MockService(
      createCheckoutResult:
      Result.success(CreateCheckoutEnvelope(checkout: createCheckout))
    )

    withEnvironment(apiService: mockService, currentUser: User.template) {
      let data = PledgeViewData(
        project: Project.template,
        rewards: [Reward.template],
        selectedShippingRule: nil,
        selectedQuantities: [Reward.template.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .latePledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.userSessionStarted()

      let expectedShipping = PledgeShippingSummaryViewData(
        locationName: "Los Angeles, CA",
        omitUSCurrencyCode: true,
        projectCountry: .us,
        total: 3
      )

      let expectedBonus = 5.0
      self.vm.inputs.pledgeAmountViewControllerDidUpdate(
        with: (amount: expectedBonus, min: 0, max: 100, isValid: true)
      )

      self.vm.inputs.continueCTATapped()

      self.scheduler.run()

      self.goToLoginSignup.assertDidNotEmitValue()

      self.createCheckoutSuccess.assertDidEmitValue()
    }
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
        selectedShippingRule: nil,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.configurePledgeSummaryViewControllerWithDataConfirmationLabelHidden.assertValues([false])
      self.configurePledgeSummaryViewControllerWithDataPledgeTotal.assertValues([reward.minimum])
      self.configurePledgeSummaryViewControllerWithDataProject.assertValues([project])

      self.pledgeAmountViewHidden.assertValues([false])
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
        selectedShippingRule: nil,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.configurePledgeSummaryViewControllerWithDataConfirmationLabelHidden.assertValues([false])
      self.configurePledgeSummaryViewControllerWithDataPledgeTotal.assertValues([reward.minimum])
      self.configurePledgeSummaryViewControllerWithDataProject.assertValues([project])

      self.pledgeAmountViewHidden.assertValues([false])
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
        selectedShippingRule: nil,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.configurePledgeSummaryViewControllerWithDataPledgeTotal.assertValues([reward.minimum])
      self.configurePledgeSummaryViewControllerWithDataProject.assertValues([project])

      self.pledgeAmountViewHidden.assertValues([false])
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
        selectedShippingRule: nil,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.configurePledgeSummaryViewControllerWithDataPledgeTotal.assertValues([reward.minimum])
      self.configurePledgeSummaryViewControllerWithDataProject.assertValues([project])
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
        selectedShippingRule: nil,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.configurePledgeSummaryViewControllerWithDataPledgeTotal.assertValues([reward.minimum])
      self.configurePledgeSummaryViewControllerWithDataProject.assertValues([project])
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
        selectedShippingRule: nil,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.configurePledgeSummaryViewControllerWithDataPledgeTotal.assertValues([reward.minimum])
      self.configurePledgeSummaryViewControllerWithDataProject.assertValues([project])
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
        bonusSupport: 10.0,
        selectedShippingRule: nil,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.configurePledgeSummaryViewControllerWithDataPledgeTotal.assertValues([reward.minimum + 10.0])
      self.configurePledgeSummaryViewControllerWithDataProject.assertValues([project])

      self.pledgeAmountViewHidden.assertValues([false])

      let data1 = (amount: 66.0, min: 10.0, max: 10_000.0, isValid: true)

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: data1)

      self.configurePledgeSummaryViewControllerWithDataPledgeTotal.assertValues([20, 76])
      self.configurePledgeSummaryViewControllerWithDataProject.assertValues([project, project])

      let data2 = (amount: 93.0, min: 10.0, max: 10_000.0, isValid: true)

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: data2)

      self.configurePledgeSummaryViewControllerWithDataPledgeTotal.assertValues([20, 76, 103])
      self.configurePledgeSummaryViewControllerWithDataProject.assertValues([project, project, project])
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
      selectedShippingRule: nil,
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: nil,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.localPickupViewHidden.assertValues([false])
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
      selectedShippingRule: nil,
      selectedQuantities: [reward.id: 1, addOnReward1.id: 1],
      selectedLocationId: nil,
      refTag: nil,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.localPickupViewHidden.assertValues([true])
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
      selectedShippingRule: nil,
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

  // TODO(MBL-1687): This test should be fixed when the corresponding flow works.
  func testContinueButton_CallsCreateBackingMutation_Success() throws {
    throw XCTSkip()
    let expectedId = "Q2hlY2tvdXQtMTk4MzM2NjQ2"
    let createCheckout = CreateCheckoutEnvelope.Checkout(
      id: expectedId,
      paymentUrl: "paymentUrl",
      backingId: "backingId"
    )

    let mockService = MockService(
      createCheckoutResult:
      Result.success(CreateCheckoutEnvelope(checkout: createCheckout))
    )

    withEnvironment(apiService: mockService, currentUser: .template) {
      let reward = Reward.template
        |> Reward.lens.shipping.enabled .~ true
        |> Reward.lens.shipping.preference .~ .unrestricted
        |> Reward.lens.localPickup .~ .losAngeles
      let addOnReward1 = Reward.template
        |> Reward.lens.id .~ 2
      let project = Project.template
        |> Project.lens.rewardData.rewards .~ [reward]

      let expectedRewards = [reward, addOnReward1]
      let selectedQuantities = [reward.id: 1, addOnReward1.id: 1]
      let data = PledgeViewData(
        project: project,
        rewards: expectedRewards,
        selectedShippingRule: nil,
        selectedQuantities: selectedQuantities,
        selectedLocationId: ShippingRule.template.id,
        refTag: nil,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      let expectedShipping = PledgeShippingSummaryViewData(
        locationName: "Los Angeles, CA",
        omitUSCurrencyCode: true,
        projectCountry: .us,
        total: 3
      )

      let selectedShippingRule = ShippingRule(
        cost: expectedShipping.total,
        id: nil,
        location: .losAngeles,
        estimatedMin: Money(amount: 1.0),
        estimatedMax: Money(amount: 10.0)
      )

      let expectedBonus = 5.0
      self.vm.inputs.pledgeAmountViewControllerDidUpdate(
        with: (amount: expectedBonus, min: 0, max: 100, isValid: true)
      )

      self.vm.inputs.continueCTATapped()

      self.scheduler.run()

      self.showErrorBannerWithMessage.assertDidNotEmitValue()

      self.createCheckoutSuccess.assertDidEmitValue()
      let expectedValue = PostCampaignCheckoutData(
        project: project,
        baseReward: reward,
        rewards: expectedRewards,
        selectedQuantities: selectedQuantities,
        bonusAmount: expectedBonus,
        total: 28,
        shipping: expectedShipping,
        refTag: nil,
        context: .pledge,
        checkoutId: "198336646",
        backingId: "backingId",
        selectedShippingRule: selectedShippingRule
      )
      self.createCheckoutSuccess.assertValue(expectedValue)
    }
  }

  func testContinueButton_CallsCreateBackingMutation_Failure_ShowsErrorMessageBanner() {
    let createCheckout = CreateCheckoutEnvelope.Checkout(
      id: "id",
      paymentUrl: "paymentUrl",
      backingId: "backingId"
    )
    let errorUnknown = ErrorEnvelope(
      errorMessages: ["Something went wrong yo."],
      ksrCode: .UnknownCode,
      httpCode: 400,
      exception: nil
    )

    let mockService = MockService(createCheckoutResult: Result.failure(errorUnknown))

    withEnvironment(apiService: mockService, currentUser: .template) {
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
        selectedShippingRule: nil,
        selectedQuantities: [reward.id: 1, addOnReward1.id: 1],
        selectedLocationId: ShippingRule.template.id,
        refTag: nil,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.continueCTATapped()

      self.scheduler.run()

      self.createCheckoutSuccess.assertDidNotEmitValue()

      self.showErrorBannerWithMessage.assertValue(Strings.Something_went_wrong_please_try_again())
    }
  }
}
