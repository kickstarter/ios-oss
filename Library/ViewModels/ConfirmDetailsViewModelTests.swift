import Foundation
@testable import KsApi
@testable import Library
import PassKit
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class ConfirmDetailsViewModelTests: TestCase {
  private let vm: ConfirmDetailsViewModelType = ConfirmDetailsViewModel()

  private let configurePledgeSummaryViewControllerWithDataConfirmationLabelHidden = TestObserver<
    Bool,
    Never
  >()
  private let configurePledgeSummaryViewControllerWithDataPledgeTotal = TestObserver<Double, Never>()
  private let configurePledgeSummaryViewControllerWithDataProject = TestObserver<Project, Never>()

  private let configureLocalPickupViewWithData = TestObserver<PledgeLocalPickupViewData, Never>()
  private let configureShippingSummaryViewWithData = TestObserver<PledgeShippingSummaryViewData, Never>()
  private let configureShippingLocationViewWithDataProject = TestObserver<Project, Never>()
  private let configureShippingLocationViewWithDataReward = TestObserver<Reward, Never>()
  private let configureShippingLocationViewWithDataShowAmount = TestObserver<Bool, Never>()

  private let createCheckoutSuccess = TestObserver<PostCampaignCheckoutData, Never>()

  private let localPickupViewHidden = TestObserver<Bool, Never>()
  private let pledgeAmountViewHidden = TestObserver<Bool, Never>()
  private let shippingLocationViewHidden = TestObserver<Bool, Never>()
  private let shippingSummaryViewHidden = TestObserver<Bool, Never>()

  private let showErrorBannerWithMessage = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.configureLocalPickupViewWithData.observe(self.configureLocalPickupViewWithData.observer)

    self.vm.outputs.configureShippingLocationViewWithData.map { $0.project }
      .observe(self.configureShippingLocationViewWithDataProject.observer)
    self.vm.outputs.configureShippingLocationViewWithData.map { $0.reward }
      .observe(self.configureShippingLocationViewWithDataReward.observer)
    self.vm.outputs.configureShippingLocationViewWithData.map { $0.showAmount }
      .observe(self.configureShippingLocationViewWithDataShowAmount.observer)

    self.vm.outputs.configureShippingSummaryViewWithData
      .observe(self.configureShippingSummaryViewWithData.observer)

    self.vm.outputs.configurePledgeSummaryViewControllerWithData.map { $0.2 }
      .observe(self.configurePledgeSummaryViewControllerWithDataConfirmationLabelHidden.observer)
    self.vm.outputs.configurePledgeSummaryViewControllerWithData.map { $0.1 }
      .observe(self.configurePledgeSummaryViewControllerWithDataPledgeTotal.observer)
    self.vm.outputs.configurePledgeSummaryViewControllerWithData.map { $0.0 }
      .observe(self.configurePledgeSummaryViewControllerWithDataProject.observer)

    self.vm.outputs.createCheckoutSuccess.observe(self.createCheckoutSuccess.observer)

    self.vm.outputs.localPickupViewHidden.observe(self.localPickupViewHidden.observer)
    self.vm.outputs.pledgeAmountViewHidden.observe(self.pledgeAmountViewHidden.observer)
    self.vm.outputs.shippingLocationViewHidden.observe(self.shippingLocationViewHidden.observer)
    self.vm.outputs.shippingSummaryViewHidden.observe(self.shippingSummaryViewHidden.observer)

    self.vm.outputs.showErrorBannerWithMessage.observe(self.showErrorBannerWithMessage.observer)
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

      self.configurePledgeSummaryViewControllerWithDataConfirmationLabelHidden.assertValues([false])
      self.configurePledgeSummaryViewControllerWithDataPledgeTotal.assertValues([reward.minimum])
      self.configurePledgeSummaryViewControllerWithDataProject.assertValues([project])

      self.configureShippingLocationViewWithDataProject.assertValues([project])
      self.configureShippingLocationViewWithDataReward.assertValues([reward])
      self.configureShippingLocationViewWithDataShowAmount.assertValues([true])

      self.pledgeAmountViewHidden.assertValues([false])
      self.shippingLocationViewHidden.assertValues([false])
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

      self.configurePledgeSummaryViewControllerWithDataConfirmationLabelHidden.assertValues([false])
      self.configurePledgeSummaryViewControllerWithDataPledgeTotal.assertValues([reward.minimum])
      self.configurePledgeSummaryViewControllerWithDataProject.assertValues([project])

      self.configureShippingLocationViewWithDataProject.assertValues([project])
      self.configureShippingLocationViewWithDataReward.assertValues([reward])
      self.configureShippingLocationViewWithDataShowAmount.assertValues([true])

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
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.configurePledgeSummaryViewControllerWithDataPledgeTotal.assertValues([reward.minimum])
      self.configurePledgeSummaryViewControllerWithDataProject.assertValues([project])

      self.configureShippingLocationViewWithDataProject.assertDidNotEmitValue()
      self.configureShippingLocationViewWithDataReward.assertDidNotEmitValue()
      self.configureShippingLocationViewWithDataShowAmount.assertDidNotEmitValue()

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
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.configurePledgeSummaryViewControllerWithDataPledgeTotal.assertValues([reward.minimum])
      self.configurePledgeSummaryViewControllerWithDataProject.assertValues([project])

      self.configureShippingLocationViewWithDataProject.assertValues([project])
      self.configureShippingLocationViewWithDataReward.assertValues([reward])
      self.configureShippingLocationViewWithDataShowAmount.assertValues([true])
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

      self.configurePledgeSummaryViewControllerWithDataPledgeTotal.assertValues([reward.minimum])
      self.configurePledgeSummaryViewControllerWithDataProject.assertValues([project])

      self.configureShippingLocationViewWithDataProject.assertDidNotEmitValue()
      self.configureShippingLocationViewWithDataReward.assertDidNotEmitValue()
      self.configureShippingLocationViewWithDataShowAmount.assertDidNotEmitValue()
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

      self.configurePledgeSummaryViewControllerWithDataPledgeTotal.assertValues([reward.minimum])
      self.configurePledgeSummaryViewControllerWithDataProject.assertValues([project])

      self.configureShippingLocationViewWithDataProject.assertValues([project])
      self.configureShippingLocationViewWithDataReward.assertValues([reward])
      self.configureShippingLocationViewWithDataShowAmount.assertValues([true])
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

      self.configurePledgeSummaryViewControllerWithDataPledgeTotal.assertValues([reward.minimum])
      self.configurePledgeSummaryViewControllerWithDataProject.assertValues([project])

      self.configureShippingLocationViewWithDataProject.assertValues([project])
      self.configureShippingLocationViewWithDataReward.assertValues([reward])
      self.configureShippingLocationViewWithDataShowAmount.assertValues([true])

      let defaultShippingRule = ShippingRule.template
        |> ShippingRule.lens.cost .~ 5

      self.vm.inputs.shippingRuleSelected(defaultShippingRule)

      self.configurePledgeSummaryViewControllerWithDataPledgeTotal
        .assertValues([reward.minimum, reward.minimum + defaultShippingRule.cost])
      self.configurePledgeSummaryViewControllerWithDataProject.assertValues([project, project])
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

      self.configurePledgeSummaryViewControllerWithDataPledgeTotal.assertValues([reward.minimum])
      self.configurePledgeSummaryViewControllerWithDataProject.assertValues([project])

      self.configureShippingLocationViewWithDataProject.assertValues([project])
      self.configureShippingLocationViewWithDataReward.assertValues([reward])
      self.configureShippingLocationViewWithDataShowAmount.assertValues([true])

      let defaultShippingRule = ShippingRule.template
        |> ShippingRule.lens.cost .~ 5

      self.vm.inputs.shippingRuleSelected(defaultShippingRule)

      self.configurePledgeSummaryViewControllerWithDataPledgeTotal
        .assertValues([reward.minimum, reward.minimum + defaultShippingRule.cost])
      self.configurePledgeSummaryViewControllerWithDataProject.assertValues([project, project])

      let selectedShippingRule = ShippingRule.template
        |> ShippingRule.lens.cost .~ 5
        |> ShippingRule.lens.location .~ .australia

      self.vm.inputs.shippingRuleSelected(selectedShippingRule)

      self.configurePledgeSummaryViewControllerWithDataPledgeTotal.assertValues([
        reward.minimum,
        reward.minimum + defaultShippingRule.cost,
        reward.minimum + selectedShippingRule.cost
      ])
      self.configurePledgeSummaryViewControllerWithDataProject.assertValues([project, project, project])
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

      self.configurePledgeSummaryViewControllerWithDataPledgeTotal.assertValues([reward.minimum])
      self.configurePledgeSummaryViewControllerWithDataProject.assertValues([project])

      self.configureShippingLocationViewWithDataProject.assertValues([project])
      self.configureShippingLocationViewWithDataReward.assertValues([reward])
      self.configureShippingLocationViewWithDataShowAmount.assertValues([true])

      self.pledgeAmountViewHidden.assertValues([false])
      self.shippingLocationViewHidden.assertValues([false])

      let data1 = (amount: 66.0, min: 10.0, max: 10_000.0, isValid: true)

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: data1)

      self.configurePledgeSummaryViewControllerWithDataPledgeTotal.assertValues([10, 76])
      self.configurePledgeSummaryViewControllerWithDataProject.assertValues([project, project])

      self.configureShippingLocationViewWithDataProject.assertValues([project])
      self.configureShippingLocationViewWithDataReward.assertValues([reward])
      self.configureShippingLocationViewWithDataShowAmount.assertValues([true])

      let data2 = (amount: 93.0, min: 10.0, max: 10_000.0, isValid: true)

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: data2)

      self.configurePledgeSummaryViewControllerWithDataPledgeTotal.assertValues([10, 76, 103])
      self.configurePledgeSummaryViewControllerWithDataProject.assertValues([project, project, project])

      self.configureShippingLocationViewWithDataProject.assertValues([project])
      self.configureShippingLocationViewWithDataReward.assertValues([reward])
      self.configureShippingLocationViewWithDataShowAmount.assertValues([true])
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

      self.configureShippingLocationViewWithDataProject.assertValues([project])
      self.configureShippingLocationViewWithDataReward.assertValues([reward])
      self.configureShippingLocationViewWithDataShowAmount.assertValues([true])

      self.pledgeAmountViewHidden.assertValues([false])
      self.shippingLocationViewHidden.assertValues([false])

      let shippingRule1 = ShippingRule.template
        |> ShippingRule.lens.cost .~ 20.0

      self.vm.inputs.shippingRuleSelected(shippingRule1)

      self.configureShippingLocationViewWithDataProject.assertValues([project])
      self.configureShippingLocationViewWithDataReward.assertValues([reward])
      self.configureShippingLocationViewWithDataShowAmount.assertValues([true])

      let data1 = (amount: 200.0, min: 10.0, max: 10_000.0, isValid: true)

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: data1)

      self.configureShippingLocationViewWithDataProject.assertValues([project])
      self.configureShippingLocationViewWithDataReward.assertValues([reward])
      self.configureShippingLocationViewWithDataShowAmount.assertValues([true])

      let shippingRule2 = ShippingRule.template
        |> ShippingRule.lens.cost .~ 123.0

      self.vm.inputs.shippingRuleSelected(shippingRule2)

      self.configureShippingLocationViewWithDataProject.assertValues([project])
      self.configureShippingLocationViewWithDataReward.assertValues([reward])
      self.configureShippingLocationViewWithDataShowAmount.assertValues([true])

      let data2 = (amount: 1_999.0, min: 10.0, max: 10_000.0, isValid: true)

      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: data2)

      self.configureShippingLocationViewWithDataProject.assertValues([project])
      self.configureShippingLocationViewWithDataReward.assertValues([reward])
      self.configureShippingLocationViewWithDataShowAmount.assertValues([true])
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

  func testContinueButton_CallsCreateBackingMutation_Success() {
    let expectedId = "Q2hlY2tvdXQtMTk4MzM2NjQ2"
    let createCheckout = CreateCheckoutEnvelope.Checkout(id: expectedId, paymentUrl: "paymentUrl")

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
      self.vm.inputs.shippingRuleSelected(
        ShippingRule(cost: expectedShipping.total, id: nil, location: .losAngeles)
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
        rewards: expectedRewards,
        selectedQuantities: selectedQuantities,
        bonusAmount: expectedBonus,
        total: 28,
        shipping: expectedShipping,
        refTag: nil,
        context: .pledge,
        checkoutId: "198336646"
      )
      self.createCheckoutSuccess.assertValue(expectedValue)
    }
  }

  func testContinueButton_CallsCreateBackingMutation_Failure_ShowsErrorMessageBanner() {
    let createCheckout = CreateCheckoutEnvelope.Checkout(id: "id", paymentUrl: "paymentUrl")
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
