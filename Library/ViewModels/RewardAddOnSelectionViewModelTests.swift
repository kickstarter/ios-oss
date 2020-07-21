@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class RewardAddOnSelectionViewModelTests: TestCase {
  private let vm: RewardAddOnSelectionViewModelType = RewardAddOnSelectionViewModel()

  private let configureContinueCTAViewWithDataIsValid = TestObserver<Bool, Never>()
  private let configureContinueCTAViewWithDataQuantity = TestObserver<Int, Never>()
  private let configurePledgeShippingLocationViewControllerWithDataProject = TestObserver<Project, Never>()
  private let configurePledgeShippingLocationViewControllerWithDataReward = TestObserver<Reward, Never>()
  private let configurePledgeShippingLocationViewControllerWithDataShowAmount = TestObserver<Bool, Never>()
  private let loadAddOnRewardsIntoDataSource = TestObserver<[RewardAddOnCardViewData], Never>()
  private let loadAddOnRewardsIntoDataSourceAndReloadTableView
    = TestObserver<[RewardAddOnCardViewData], Never>()
  private let shippingLocationViewIsHidden = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.configureContinueCTAViewWithData.map(first)
      .observe(self.configureContinueCTAViewWithDataQuantity.observer)
    self.vm.outputs.configureContinueCTAViewWithData.map(second)
      .observe(self.configureContinueCTAViewWithDataIsValid.observer)
    self.vm.outputs.configurePledgeShippingLocationViewControllerWithData.map(first)
      .observe(self.configurePledgeShippingLocationViewControllerWithDataProject.observer)
    self.vm.outputs.configurePledgeShippingLocationViewControllerWithData.map(second)
      .observe(self.configurePledgeShippingLocationViewControllerWithDataReward.observer)
    self.vm.outputs.configurePledgeShippingLocationViewControllerWithData.map(third)
      .observe(self.configurePledgeShippingLocationViewControllerWithDataShowAmount.observer)
    self.vm.outputs.loadAddOnRewardsIntoDataSource.observe(self.loadAddOnRewardsIntoDataSource.observer)
    self.vm.outputs.loadAddOnRewardsIntoDataSourceAndReloadTableView
      .observe(self.loadAddOnRewardsIntoDataSourceAndReloadTableView.observer)
    self.vm.outputs.shippingLocationViewIsHidden.observe(self.shippingLocationViewIsHidden.observer)
  }

  func testConfigurePledgeShippingLocationViewControllerWithData() {
    self.configurePledgeShippingLocationViewControllerWithDataProject.assertDidNotEmitValue()
    self.configurePledgeShippingLocationViewControllerWithDataReward.assertDidNotEmitValue()
    self.configurePledgeShippingLocationViewControllerWithDataShowAmount.assertDidNotEmitValue()

    let reward = Reward.template
    let project = Project.template

    self.vm.inputs.configureWith(project: project, reward: reward, refTag: nil, context: .pledge)
    self.vm.inputs.viewDidLoad()

    self.configurePledgeShippingLocationViewControllerWithDataProject.assertValues([project])
    self.configurePledgeShippingLocationViewControllerWithDataReward.assertValues([reward])
    self.configurePledgeShippingLocationViewControllerWithDataShowAmount.assertValues([false])
  }

  func testLoadAddOnRewardsIntoDataSource() {
    self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertDidNotEmitValue()

    let reward = Reward.template
    let project = Project.template

    let noShippingAddOn = RewardAddOnSelectionViewEnvelope.Project.Reward.template
      |> \.shippingPreference .~ .noShipping

    let env = RewardAddOnSelectionViewEnvelope.template
      |> \.project.addOns .~ (
        .template |> \.nodes .~ [noShippingAddOn]
      )

    guard
      let addOnReward = Reward.addOnReward(
        from: noShippingAddOn,
        project: project,
        selectedAddOnQuantities: [:],
        dateFormatter: DateFormatter()
      ) else {
      XCTFail("Should have an add-on")
      return
    }

    let expected = RewardAddOnCardViewData(
      project: project,
      reward: addOnReward,
      context: .pledge,
      shippingRule: nil
    )

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .success(env))

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith(project: project, reward: reward, refTag: nil, context: .pledge)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertValues([[expected]])
    }
  }

  func testLoadAddOnRewardsIntoDataSource_DigitalOnlyBaseReward() {
    self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertDidNotEmitValue()

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ false

    let noShippingAddOn = RewardAddOnSelectionViewEnvelope.Project.Reward.template
      |> \.shippingPreference .~ .noShipping

    let shippingAddOn1 = RewardAddOnSelectionViewEnvelope.Project.Reward.template
      |> \.shippingPreference .~ .restricted

    let shippingAddOn2 = RewardAddOnSelectionViewEnvelope.Project.Reward.template
      |> \.shippingPreference .~ .restricted

    let project = Project.template
    let env = RewardAddOnSelectionViewEnvelope.template
      |> \.project.addOns .~ (
        .template |> \.nodes .~ [shippingAddOn1, noShippingAddOn, shippingAddOn2]
      )

    guard
      let addOnReward = Reward.addOnReward(
        from: noShippingAddOn,
        project: project,
        selectedAddOnQuantities: [:],
        dateFormatter: DateFormatter()
      ) else {
      XCTFail("Should have an add-on")
      return
    }

    let expected = RewardAddOnCardViewData(
      project: project,
      reward: addOnReward,
      context: .pledge,
      shippingRule: nil
    )

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .success(env))

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith(project: project, reward: reward, refTag: nil, context: .pledge)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertValues([[expected]])
      XCTAssertEqual(
        self.loadAddOnRewardsIntoDataSourceAndReloadTableView.values.last?.count, 1,
        "Only the single add-on reward without shipping is emitted for no-shipping base reward."
      )
    }
  }

  func testLoadAddOnRewardsIntoDataSource_UnrestrictedShippingBaseReward() {
    self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertDidNotEmitValue()

    let shippingRule = ShippingRule.template
      |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 99)

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted

    let noShippingAddOn = RewardAddOnSelectionViewEnvelope.Project.Reward.template
      |> \.shippingPreference .~ .noShipping

    let shippingAddOn1 = RewardAddOnSelectionViewEnvelope.Project.Reward.template
      |> \.shippingPreference .~ .restricted
      |> \.shippingRules .~ [
        .template |> (\.location.id .~ "Location-99".toBase64())
      ]

    let shippingAddOn2 = RewardAddOnSelectionViewEnvelope.Project.Reward.template
      |> \.shippingPreference .~ .restricted
      |> \.shippingRules .~ [
        .template |> (\.location.id .~ "Location-99".toBase64())
      ]

    let shippingAddOn3 = RewardAddOnSelectionViewEnvelope.Project.Reward.template
      |> \.shippingPreference .~ .restricted
      |> \.shippingRules .~ [
        .template |> (\.location.id .~ "Location-3".toBase64())
      ]

    let shippingAddOn4 = RewardAddOnSelectionViewEnvelope.Project.Reward.template
      |> \.shippingPreference .~ .unrestricted

    let project = Project.template
    let env = RewardAddOnSelectionViewEnvelope.template
      |> \.project.addOns .~ (
        .template |> \.nodes .~ [
          shippingAddOn1,
          noShippingAddOn,
          shippingAddOn2,
          shippingAddOn3,
          shippingAddOn4
        ]
      )

    let expected = [shippingAddOn1, noShippingAddOn, shippingAddOn2, shippingAddOn4].compactMap { addOn in
      Reward.addOnReward(
        from: addOn,
        project: project,
        selectedAddOnQuantities: [:],
        dateFormatter: DateFormatter()
      )
    }
    .compactMap { reward in
      RewardAddOnCardViewData(
        project: project,
        reward: reward,
        context: .pledge,
        shippingRule: shippingRule
      )
    }

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .success(env))

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith(project: project, reward: reward, refTag: nil, context: .pledge)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertDidNotEmitValue(
        "Nothing is emitted until a shipping location is selected"
      )

      self.vm.inputs.shippingRuleSelected(shippingRule)

      self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertValues([expected])
      XCTAssertEqual(
        self.loadAddOnRewardsIntoDataSourceAndReloadTableView.values.last?.count, 4,
        """
        Digital and restricted shipping add-on rewards that ship to the
        selected shipping location are emitted for unrestricted shipping base reward."
        """
      )
    }
  }

  func testLoadAddOnRewardsIntoDataSource_RestrictedShippingBaseReward() {
    self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertDidNotEmitValue()

    let shippingRule = ShippingRule.template
      |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 99)

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .restricted

    let noShippingAddOn = RewardAddOnSelectionViewEnvelope.Project.Reward.template
      |> \.shippingPreference .~ .noShipping

    let shippingAddOn1 = RewardAddOnSelectionViewEnvelope.Project.Reward.template
      |> \.shippingPreference .~ .restricted
      |> \.shippingRules .~ [
        .template |> (\.location.id .~ "Location-99".toBase64())
      ]

    let shippingAddOn2 = RewardAddOnSelectionViewEnvelope.Project.Reward.template
      |> \.shippingPreference .~ .restricted
      |> \.shippingRules .~ [
        .template |> (\.location.id .~ "Location-99".toBase64())
      ]

    let shippingAddOn3 = RewardAddOnSelectionViewEnvelope.Project.Reward.template
      |> \.shippingPreference .~ .restricted
      |> \.shippingRules .~ [
        .template |> (\.location.id .~ "Location-3".toBase64())
      ]

    let project = Project.template
    let env = RewardAddOnSelectionViewEnvelope.template
      |> \.project.addOns .~ (
        .template |> \.nodes .~ [shippingAddOn1, noShippingAddOn, shippingAddOn2, shippingAddOn3]
      )

    let expected = [noShippingAddOn, shippingAddOn1, shippingAddOn2].compactMap { addOn in
      Reward.addOnReward(
        from: addOn,
        project: project,
        selectedAddOnQuantities: [:],
        dateFormatter: DateFormatter()
      )
    }
    .compactMap { reward in
      RewardAddOnCardViewData(
        project: project,
        reward: reward,
        context: .pledge,
        shippingRule: shippingRule
      )
    }

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .success(env))

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith(project: project, reward: reward, refTag: nil, context: .pledge)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertDidNotEmitValue(
        "Nothing is emitted until a shipping location is selected"
      )

      self.vm.inputs.shippingRuleSelected(shippingRule)

      self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertValues([expected])
      XCTAssertEqual(
        self.loadAddOnRewardsIntoDataSourceAndReloadTableView.values.last?.count, 3,
        """
        Only the two shipping add-on rewards that match on location ID and
        the digital add-on are emitted for restricted shipping base reward.
        """
      )
    }
  }

  func testUpdatingQuantities() {
    self.configureContinueCTAViewWithDataQuantity.assertDidNotEmitValue()
    self.configureContinueCTAViewWithDataIsValid.assertDidNotEmitValue()
    self.loadAddOnRewardsIntoDataSource.assertDidNotEmitValue()
    self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertDidNotEmitValue()

    let shippingRule = ShippingRule.template
      |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 99)

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted

    let addOn1 = RewardAddOnSelectionViewEnvelope.Project.Reward.template
      |> \.id .~ "Reward-1".toBase64()
      |> \.shippingPreference .~ .unrestricted

    let addOn2 = RewardAddOnSelectionViewEnvelope.Project.Reward.template
      |> \.id .~ "Reward-2".toBase64()
      |> \.shippingPreference .~ .unrestricted

    let addOn3 = RewardAddOnSelectionViewEnvelope.Project.Reward.template
      |> \.id .~ "Reward-3".toBase64()
      |> \.shippingPreference .~ .unrestricted

    let addOn4 = RewardAddOnSelectionViewEnvelope.Project.Reward.template
      |> \.id .~ "Reward-4".toBase64()
      |> \.shippingPreference .~ .unrestricted

    let project = Project.template
    let env = RewardAddOnSelectionViewEnvelope.template
      |> \.project.addOns .~ (
        .template |> \.nodes .~ [addOn1, addOn2, addOn3, addOn4]
      )

    let expected = [addOn1, addOn2, addOn3, addOn4].compactMap { addOn in
      Reward.addOnReward(
        from: addOn,
        project: project,
        selectedAddOnQuantities: [:],
        dateFormatter: DateFormatter()
      )
    }
    .compactMap { reward in
      RewardAddOnCardViewData(
        project: project,
        reward: reward,
        context: .pledge,
        shippingRule: shippingRule
      )
    }

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .success(env))

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith(project: project, reward: reward, refTag: nil, context: .pledge)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertDidNotEmitValue(
        "Nothing is emitted until a shipping location is selected"
      )

      self.vm.inputs.shippingRuleSelected(shippingRule)

      self.loadAddOnRewardsIntoDataSource.assertDidNotEmitValue()
      self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertValues([expected])
      XCTAssertEqual(
        self.loadAddOnRewardsIntoDataSourceAndReloadTableView.values.last?.count, 4,
        "All rewards emit and tableView reloads"
      )
      self.configureContinueCTAViewWithDataQuantity.assertValues([0, 0])
      self.configureContinueCTAViewWithDataIsValid.assertValues([true, true])

      self.vm.inputs.rewardAddOnCardViewDidSelectQuantity(quantity: 5, rewardId: 1)

      self.loadAddOnRewardsIntoDataSource.assertValueCount(1, "DataSource is updated")
      XCTAssertEqual(
        self.loadAddOnRewardsIntoDataSource.values[0][0].reward.addOnData?.selectedQuantity,
        5,
        "Add-on at index 1 with ID 1 has its quantity updated to 5"
      )
      self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertValues(
        [expected], "TableView does not reload again"
      )
      self.configureContinueCTAViewWithDataQuantity.assertValues([0, 0, 5])
      self.configureContinueCTAViewWithDataIsValid.assertValues([true, true, true])
    }
  }

  func testShippingLocationViewIsHidden_RewardHasShipping() {
    self.shippingLocationViewIsHidden.assertDidNotEmitValue()

    let reward = Reward.template
      |> Reward.lens.shipping .~ (
        .template |> Reward.Shipping.lens.enabled .~ true
      )
    let project = Project.template

    self.vm.inputs.configureWith(project: project, reward: reward, refTag: nil, context: .pledge)
    self.vm.inputs.viewDidLoad()

    self.shippingLocationViewIsHidden.assertValues([false])
  }

  func testShippingLocationViewIsHidden_NoShipping() {
    self.shippingLocationViewIsHidden.assertDidNotEmitValue()

    let reward = Reward.template
      |> Reward.lens.shipping .~ (
        .template |> Reward.Shipping.lens.enabled .~ false
      )
    let project = Project.template

    self.vm.inputs.configureWith(project: project, reward: reward, refTag: nil, context: .pledge)
    self.vm.inputs.viewDidLoad()

    self.shippingLocationViewIsHidden.assertValues([true])
  }
}
