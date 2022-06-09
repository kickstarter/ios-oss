@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class RewardAddOnSelectionViewModelTests: TestCase {
  private let vm: RewardAddOnSelectionViewModelType = RewardAddOnSelectionViewModel()

  private let configureContinueCTAViewWithDataIsLoading = TestObserver<Bool, Never>()
  private let configureContinueCTAViewWithDataIsValid = TestObserver<Bool, Never>()
  private let configureContinueCTAViewWithDataQuantity = TestObserver<Int, Never>()
  private let configurePledgeShippingLocationViewControllerWithDataProject = TestObserver<Project, Never>()
  private let configurePledgeShippingLocationViewControllerWithDataReward = TestObserver<Reward, Never>()
  private let configurePledgeShippingLocationViewControllerWithDataShowAmount = TestObserver<Bool, Never>()
  private let configurePledgeShippingLocationViewControllerWithDataSelectedLocationId
    = TestObserver<Int?, Never>()
  private let endRefreshing = TestObserver<(), Never>()
  private let goToPledge = TestObserver<PledgeViewData, Never>()
  private let loadAddOnRewardsIntoDataSource = TestObserver<[RewardAddOnSelectionDataSourceItem], Never>()
  private let loadAddOnRewardsIntoDataSourceAndReloadTableView
    = TestObserver<[RewardAddOnSelectionDataSourceItem], Never>()
  private let shippingLocationViewIsHidden = TestObserver<Bool, Never>()
  private let startRefreshing = TestObserver<(), Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.configureContinueCTAViewWithData.map(first)
      .observe(self.configureContinueCTAViewWithDataQuantity.observer)
    self.vm.outputs.configureContinueCTAViewWithData.map(second)
      .observe(self.configureContinueCTAViewWithDataIsValid.observer)
    self.vm.outputs.configureContinueCTAViewWithData.map(third)
      .observe(self.configureContinueCTAViewWithDataIsLoading.observer)
    self.vm.outputs.configurePledgeShippingLocationViewControllerWithData.map { $0.0 }
      .observe(self.configurePledgeShippingLocationViewControllerWithDataProject.observer)
    self.vm.outputs.configurePledgeShippingLocationViewControllerWithData.map { $0.1 }
      .observe(self.configurePledgeShippingLocationViewControllerWithDataReward.observer)
    self.vm.outputs.configurePledgeShippingLocationViewControllerWithData.map { $0.2 }
      .observe(self.configurePledgeShippingLocationViewControllerWithDataShowAmount.observer)
    self.vm.outputs.configurePledgeShippingLocationViewControllerWithData.map { $0.3 }
      .observe(self.configurePledgeShippingLocationViewControllerWithDataSelectedLocationId.observer)
    self.vm.outputs.endRefreshing.observe(self.endRefreshing.observer)
    self.vm.outputs.goToPledge.observe(self.goToPledge.observer)
    self.vm.outputs.loadAddOnRewardsIntoDataSource.observe(self.loadAddOnRewardsIntoDataSource.observer)
    self.vm.outputs.loadAddOnRewardsIntoDataSourceAndReloadTableView
      .observe(self.loadAddOnRewardsIntoDataSourceAndReloadTableView.observer)
    self.vm.outputs.shippingLocationViewIsHidden.observe(self.shippingLocationViewIsHidden.observer)
    self.vm.outputs.startRefreshing.observe(self.startRefreshing.observer)
  }

  func testConfigurePledgeShippingLocationViewControllerWithData_ShippingEnabled() {
    self.configurePledgeShippingLocationViewControllerWithDataProject.assertDidNotEmitValue()
    self.configurePledgeShippingLocationViewControllerWithDataReward.assertDidNotEmitValue()
    self.configurePledgeShippingLocationViewControllerWithDataShowAmount.assertDidNotEmitValue()
    self.configurePledgeShippingLocationViewControllerWithDataSelectedLocationId.assertDidNotEmitValue()

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true

    let project = Project.template

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedQuantities: [:],
      selectedLocationId: 2,
      refTag: nil,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.configurePledgeShippingLocationViewControllerWithDataProject.assertValues([project])
    self.configurePledgeShippingLocationViewControllerWithDataReward.assertValues([reward])
    self.configurePledgeShippingLocationViewControllerWithDataShowAmount.assertValues([false])
    self.configurePledgeShippingLocationViewControllerWithDataSelectedLocationId.assertValues([2])
  }

  func testConfigurePledgeShippingLocationViewControllerWithData_ShippingDisabled() {
    self.configurePledgeShippingLocationViewControllerWithDataProject.assertDidNotEmitValue()
    self.configurePledgeShippingLocationViewControllerWithDataReward.assertDidNotEmitValue()
    self.configurePledgeShippingLocationViewControllerWithDataShowAmount.assertDidNotEmitValue()
    self.configurePledgeShippingLocationViewControllerWithDataSelectedLocationId.assertDidNotEmitValue()

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ false

    let project = Project.template

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedQuantities: [:],
      selectedLocationId: 2,
      refTag: nil,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.configurePledgeShippingLocationViewControllerWithDataProject.assertDidNotEmitValue()
    self.configurePledgeShippingLocationViewControllerWithDataReward.assertDidNotEmitValue()
    self.configurePledgeShippingLocationViewControllerWithDataShowAmount.assertDidNotEmitValue()
    self.configurePledgeShippingLocationViewControllerWithDataSelectedLocationId.assertDidNotEmitValue()
  }

  func testConfigurePledgeShippingLocationViewControllerWithData_ShippingEnabled_FailedThenRefreshed() {
    self.configurePledgeShippingLocationViewControllerWithDataProject.assertDidNotEmitValue()
    self.configurePledgeShippingLocationViewControllerWithDataReward.assertDidNotEmitValue()
    self.configurePledgeShippingLocationViewControllerWithDataShowAmount.assertDidNotEmitValue()
    self.configurePledgeShippingLocationViewControllerWithDataSelectedLocationId.assertDidNotEmitValue()
    self.shippingLocationViewIsHidden.assertDidNotEmitValue()

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true

    let project = Project.template

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedQuantities: [:],
      selectedLocationId: 2,
      refTag: nil,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.configurePledgeShippingLocationViewControllerWithDataProject.assertValues([project])
    self.configurePledgeShippingLocationViewControllerWithDataReward.assertValues([reward])
    self.configurePledgeShippingLocationViewControllerWithDataShowAmount.assertValues([false])
    self.configurePledgeShippingLocationViewControllerWithDataSelectedLocationId.assertValues([2])
    self.shippingLocationViewIsHidden.assertValues([false])

    self.vm.inputs.shippingLocationViewDidFailToLoad()

    self.configurePledgeShippingLocationViewControllerWithDataProject.assertValues([project])
    self.configurePledgeShippingLocationViewControllerWithDataReward.assertValues([reward])
    self.configurePledgeShippingLocationViewControllerWithDataShowAmount.assertValues([false])
    self.configurePledgeShippingLocationViewControllerWithDataSelectedLocationId.assertValues([2])
    self.shippingLocationViewIsHidden.assertValues([false, true])

    self.vm.inputs.beginRefresh()

    self.configurePledgeShippingLocationViewControllerWithDataProject.assertValues([project, project])
    self.configurePledgeShippingLocationViewControllerWithDataReward.assertValues([reward, reward])
    self.configurePledgeShippingLocationViewControllerWithDataShowAmount.assertValues([false, false])
    self.configurePledgeShippingLocationViewControllerWithDataSelectedLocationId.assertValues([2, 2])
    self.shippingLocationViewIsHidden.assertValues([false, true, false])
  }

  func testLoadAddOnRewardsIntoDataSource() {
    self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertDidNotEmitValue()

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.shipping.preference .~ Reward.Shipping.Preference.none
    let project = Project.template
      |> Project.lens.rewardData.addOns .~ [reward]

    let expected = RewardAddOnCardViewData(
      project: project,
      reward: reward,
      context: .pledge,
      shippingRule: nil,
      selectedQuantities: [:]
    )

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .success(project))

    self.startRefreshing.assertDidNotEmitValue()
    self.endRefreshing.assertDidNotEmitValue()

    withEnvironment(apiService: mockService) {
      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedQuantities: [:],
        selectedLocationId: nil,
        refTag: nil,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.startRefreshing.assertValueCount(0)
      self.endRefreshing.assertValueCount(0)

      self.scheduler.advance()

      self.startRefreshing.assertValueCount(0)
      self.endRefreshing.assertValueCount(1)

      self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertValues([[.rewardAddOn(expected)]])
    }
  }

  func testLoadAddOnRewards_NotLoadedIntoDataSource_IfLocalPickupLocationsNotMatching_Success() {
    self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertDidNotEmitValue()

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ Reward.Shipping.Preference.local
      |> Reward.lens.localPickup .~ .brooklyn

    let addOn = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ Reward.Shipping.Preference.local
      |> Reward.lens.localPickup .~ .australia

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.rewardData.addOns .~ [addOn]

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .success(project))

    withEnvironment(apiService: mockService) {
      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedQuantities: [:],
        selectedLocationId: nil,
        refTag: nil,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertValues([])
    }
  }

  func testLoadAddOnRewardsIntoDataSource_Error() {
    self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertDidNotEmitValue()

    let reward = Reward.template
    let project = Project.template

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .failure(.couldNotParseJSON))

    withEnvironment(apiService: mockService) {
      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedQuantities: [:],
        selectedLocationId: nil,
        refTag: nil,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertValues([[.emptyState(.errorPullToRefresh)]])
    }
  }

  func testLoadAddOnRewardsIntoDataSource_Error_SuccessOnRefresh() {
    self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertDidNotEmitValue()

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.shipping.preference .~ Reward.Shipping.Preference.none
    let project = Project.template
      |> Project.lens.rewardData.addOns .~ [reward]

    let mockService1 = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .failure(.couldNotParseJSON))

    self.startRefreshing.assertDidNotEmitValue()
    self.endRefreshing.assertDidNotEmitValue()

    withEnvironment(apiService: mockService1) {
      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedQuantities: [:],
        selectedLocationId: nil,
        refTag: nil,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.startRefreshing.assertValueCount(0)
      self.endRefreshing.assertValueCount(0)

      self.scheduler.advance()

      self.startRefreshing.assertValueCount(0)
      self.endRefreshing.assertValueCount(1)

      self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertValues([[.emptyState(.errorPullToRefresh)]])
    }

    let expected = RewardAddOnCardViewData(
      project: project,
      reward: reward,
      context: .pledge,
      shippingRule: nil,
      selectedQuantities: [:]
    )

    let mockService2 = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .success(project))

    withEnvironment(apiService: mockService2) {
      self.vm.inputs.beginRefresh()

      self.startRefreshing.assertValueCount(1)
      self.endRefreshing.assertValueCount(1)

      self.scheduler.advance()

      self.startRefreshing.assertValueCount(1)
      self.endRefreshing.assertValueCount(2)

      self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertValues([
        [.emptyState(.errorPullToRefresh)],
        [.rewardAddOn(expected)]
      ])
    }
  }

  func testLoadAddOnRewardsIntoDataSource_DigitalOnlyBaseReward() {
    self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertDidNotEmitValue()

    let reward = Reward.template
      |> Reward.lens.id .~ 99
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.shipping.preference .~ Reward.Shipping.Preference.none

    let noShippingAddOn = Reward.template
      |> Reward.lens.id .~ 1
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.shipping.preference .~ Reward.Shipping.Preference.none

    let shippingAddOn1 = Reward.template
      |> Reward.lens.id .~ 2
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ Reward.Shipping.Preference.restricted

    let shippingAddOn2 = Reward.template
      |> Reward.lens.id .~ 3
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ Reward.Shipping.Preference.restricted

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.rewardData.addOns .~ [shippingAddOn1, noShippingAddOn, shippingAddOn2]

    let expected = RewardAddOnCardViewData(
      project: project,
      reward: noShippingAddOn,
      context: .pledge,
      shippingRule: nil,
      selectedQuantities: [:]
    )

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .success(project))

    withEnvironment(apiService: mockService) {
      let data = PledgeViewData(
        project: project,
        rewards: [reward, noShippingAddOn],
        selectedQuantities: [:],
        selectedLocationId: nil,
        refTag: nil,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertValues([[.rewardAddOn(expected)]])
      XCTAssertEqual(
        self.loadAddOnRewardsIntoDataSourceAndReloadTableView.values.last?.count, 1,
        "Only the single add-on reward without shipping is emitted for no-shipping base reward."
      )
    }
  }

  func testLoadAddOnRewardsIntoDataSource_FilteredOutUnavailableUnbackedAddOns() {
    self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertDidNotEmitValue()

    let baseReward = Reward.template
      |> Reward.lens.id .~ 99

    // regular, no limit add-on.
    let addOn1 = Reward.template
      |> Reward.lens.id .~ 1
      |> Reward.lens.limit .~ nil
      |> Reward.lens.remaining .~ nil
      |> Reward.lens.endsAt .~ nil

    // timebased add-on, ended 60 secs ago.
    let addOn2 = Reward.template
      |> Reward.lens.id .~ 2
      |> Reward.lens.limit .~ nil
      |> Reward.lens.remaining .~ nil
      |> Reward.lens.endsAt .~ (MockDate().timeIntervalSince1970 - 60)

    // timebased add-on, ended 60 secs ago (backed).
    let addOn3 = Reward.template
      |> Reward.lens.id .~ 3
      |> Reward.lens.endsAt .~ (MockDate().timeIntervalSince1970 - 60)

    // limited, unavailable add-on.
    let addOn4 = Reward.template
      |> Reward.lens.id .~ 4
      |> Reward.lens.limit .~ 5
      |> Reward.lens.remaining .~ 0

    // time-based, available add-on, ends in 60 secs.
    let addOn5 = Reward.template
      |> Reward.lens.id .~ 5
      |> Reward.lens.limit .~ nil
      |> Reward.lens.remaining .~ nil
      |> Reward.lens.endsAt .~ (MockDate().timeIntervalSince1970 + 60)

    // limited, available add-on.
    let addOn6 = Reward.template
      |> Reward.lens.id .~ 6
      |> Reward.lens.limit .~ 5
      |> Reward.lens.remaining .~ 2

    // timebased add-on, starts in 60 seconds
    let addOn7 = Reward.template
      |> Reward.lens.id .~ 7
      |> Reward.lens.limit .~ nil
      |> Reward.lens.remaining .~ nil
      |> Reward.lens.startsAt .~ (MockDate().timeIntervalSince1970 + 60)

    // timebased add-on, started 60 seconds ago.
    let addOn8 = Reward.template
      |> Reward.lens.id .~ 8
      |> Reward.lens.limit .~ nil
      |> Reward.lens.remaining .~ nil
      |> Reward.lens.startsAt .~ (MockDate().timeIntervalSince1970 - 60)

    // timebased add-on, both startsAt and endsAt are within a valid range
    let addOn9 = Reward.template
      |> Reward.lens.id .~ 9
      |> Reward.lens.limit .~ nil
      |> Reward.lens.remaining .~ nil
      |> Reward.lens.startsAt .~ (MockDate().timeIntervalSince1970 - 60)
      |> Reward.lens.endsAt .~ (MockDate().timeIntervalSince1970 + 60)

    // timebased add-on, invalid range
    let addOn10 = Reward.template
      |> Reward.lens.id .~ 10
      |> Reward.lens.limit .~ nil
      |> Reward.lens.remaining .~ nil
      |> Reward.lens.startsAt .~ (MockDate().timeIntervalSince1970 + 30)
      |> Reward.lens.endsAt .~ (MockDate().timeIntervalSince1970 + 60)

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [baseReward]
      |> Project.lens.rewardData
      .addOns .~ [addOn1, addOn2, addOn3, addOn4, addOn5, addOn6, addOn7, addOn8, addOn9, addOn10]
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.addOns .~ [addOn3]
          |> Backing.lens.reward .~ baseReward
          |> Backing.lens.rewardId .~ baseReward.id
      )

    let expectedAddOns = [addOn1, addOn3, addOn5, addOn6, addOn8, addOn9]

    let expected = expectedAddOns
      .map { reward in
        RewardAddOnCardViewData(
          project: project,
          reward: reward,
          context: .pledge,
          shippingRule: nil,
          selectedQuantities: [baseReward.id: 1, addOn3.id: 1]
        )
      }
      .map(RewardAddOnSelectionDataSourceItem.rewardAddOn)

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .success(project))

    withEnvironment(apiService: mockService) {
      let data = PledgeViewData(
        project: project,
        rewards: [baseReward],
        selectedQuantities: [:],
        selectedLocationId: nil,
        refTag: nil,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertValues([expected])
    }
  }

  func testLoadAddOnRewardsIntoDataSource_UnrestrictedShippingBaseReward() {
    self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertDidNotEmitValue()

    let shippingRule = ShippingRule.template
      |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 8)

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.id .~ 99

    let noShippingAddOn = Reward.template
      |> Reward.lens.id .~ 1
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.shipping.preference .~ Reward.Shipping.Preference.none

    let shippingAddOn1 = Reward.template
      |> Reward.lens.id .~ 2
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRulesExpanded .~ [
        shippingRule,
        shippingRule |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 99)
      ]

    let shippingAddOn2 = Reward.template
      |> Reward.lens.id .~ 3
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRulesExpanded .~ [
        shippingRule,
        shippingRule |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 99)
      ]

    let shippingAddOn3 = Reward.template
      |> Reward.lens.id .~ 4
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRulesExpanded .~ [
        shippingRule |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 3)
      ]

    let shippingAddOn4 = Reward.template
      |> Reward.lens.id .~ 5
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.rewardData.addOns .~ [
        shippingAddOn1,
        noShippingAddOn,
        shippingAddOn2,
        shippingAddOn3,
        shippingAddOn4
      ]

    let expectedAddOns = [shippingAddOn1, noShippingAddOn, shippingAddOn2, shippingAddOn4]

    let expected = expectedAddOns
      .map { reward in
        RewardAddOnCardViewData(
          project: project,
          reward: reward,
          context: .pledge,
          shippingRule: reward.shippingRulesExpanded?.first,
          selectedQuantities: [:]
        )
      }
      .map(RewardAddOnSelectionDataSourceItem.rewardAddOn)

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .success(project))

    withEnvironment(apiService: mockService) {
      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedQuantities: [:],
        selectedLocationId: nil,
        refTag: nil,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertDidNotEmitValue(
        "Nothing is emitted until a shipping location is selected"
      )

      self.scheduler.advance()

      self.vm.inputs.shippingRuleSelected(shippingRule)

      self.scheduler.advance()

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
      |> Reward.lens.id .~ 99

    let noShippingAddOn = Reward.template
      |> Reward.lens.id .~ 1
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.shipping.preference .~ Reward.Shipping.Preference.none

    let shippingAddOn1 = Reward.template
      |> Reward.lens.id .~ 2
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]

    let shippingAddOn2 = Reward.template
      |> Reward.lens.id .~ 3
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]

    let shippingAddOn3 = Reward.template
      |> Reward.lens.id .~ 4
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRulesExpanded .~ [
        shippingRule |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 3)
      ]

    let shippingAddOn4 = Reward.template
      |> Reward.lens.id .~ 5
      |> Reward.lens.shipping.enabled .~ true

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.rewardData.addOns .~ [
        shippingAddOn1,
        noShippingAddOn,
        shippingAddOn2,
        shippingAddOn3,
        shippingAddOn4
      ]

    let expectedAddOns = [shippingAddOn1, noShippingAddOn, shippingAddOn2]

    let expected = expectedAddOns
      .map { reward in
        RewardAddOnCardViewData(
          project: project,
          reward: reward,
          context: .pledge,
          shippingRule: reward.shippingRulesExpanded?.first,
          selectedQuantities: [:]
        )
      }
      .map(RewardAddOnSelectionDataSourceItem.rewardAddOn)

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .success(project))

    withEnvironment(apiService: mockService) {
      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedQuantities: [:],
        selectedLocationId: nil,
        refTag: nil,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertDidNotEmitValue(
        "Nothing is emitted until a shipping location is selected"
      )

      self.scheduler.advance()

      self.vm.inputs.shippingRuleSelected(shippingRule)

      self.scheduler.advance()

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

  func testLoadAddOnRewardsIntoDataSource_RestrictedShippingBaseReward_MatchBasedOnAddOnLocation() {
    self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertDidNotEmitValue()

    let shippingRule = ShippingRule.template
      |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 99)

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .restricted

    let shippingAddOn1 = Reward.template
      |> Reward.lens.id .~ 2
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRulesExpanded .~ [
        shippingRule |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 99)
      ]

    let shippingAddOn2 = Reward.template
      |> Reward.lens.id .~ 3
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRulesExpanded .~ [
        shippingRule |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 99)
      ]

    let shippingAddOn3 = Reward.template
      |> Reward.lens.id .~ 4
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRulesExpanded .~ [
        shippingRule |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 3)
      ]

    let shippingAddOn4 = Reward.template
      |> Reward.lens.id .~ 5
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRulesExpanded .~ [
        shippingRule |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 3)
      ]

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.rewardData.addOns .~ [
        shippingAddOn1,
        shippingAddOn2,
        shippingAddOn3,
        shippingAddOn4
      ]

    let expectedAddOns = [shippingAddOn1, shippingAddOn2]

    let expected = expectedAddOns
      .map { addOn in
        RewardAddOnCardViewData(
          project: project,
          reward: addOn,
          context: .pledge,
          shippingRule: shippingRule,
          selectedQuantities: [:]
        )
      }
      .map(RewardAddOnSelectionDataSourceItem.rewardAddOn)

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .success(project))

    withEnvironment(apiService: mockService) {
      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedQuantities: [:],
        selectedLocationId: nil,
        refTag: nil,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertDidNotEmitValue(
        "Nothing is emitted until a shipping location is selected"
      )

      self.scheduler.advance()

      self.vm.inputs.shippingRuleSelected(shippingRule)

      self.scheduler.advance()

      self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertValues([expected])
      XCTAssertEqual(
        self.loadAddOnRewardsIntoDataSourceAndReloadTableView.values.last?.count, 2,
        "Only addOns with the same location ID given from the shippingRulesExpanded should be visible"
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
      |> Reward.lens.id .~ 99

    let addOn1 = Reward.template
      |> Reward.lens.id .~ 1
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]

    let addOn2 = Reward.template
      |> Reward.lens.id .~ 2
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]

    let addOn3 = Reward.template
      |> Reward.lens.id .~ 3
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]

    let addOn4 = Reward.template
      |> Reward.lens.id .~ 4
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.rewardData.addOns .~ [addOn1, addOn2, addOn3, addOn4]

    let expected = [addOn1, addOn2, addOn3, addOn4].map { reward in
      RewardAddOnCardViewData(
        project: project,
        reward: reward,
        context: .pledge,
        shippingRule: shippingRule,
        selectedQuantities: [:]
      )
    }
    .map(RewardAddOnSelectionDataSourceItem.rewardAddOn)

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .success(project))

    self.configureContinueCTAViewWithDataQuantity.assertDidNotEmitValue()
    self.configureContinueCTAViewWithDataIsValid.assertDidNotEmitValue()
    self.configureContinueCTAViewWithDataIsLoading.assertDidNotEmitValue()
    self.loadAddOnRewardsIntoDataSource.assertDidNotEmitValue()
    self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertDidNotEmitValue()

    withEnvironment(apiService: mockService) {
      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedQuantities: [:],
        selectedLocationId: nil,
        refTag: nil,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertDidNotEmitValue(
        "Nothing is emitted until a shipping location is selected"
      )

      self.scheduler.advance()

      self.vm.inputs.shippingRuleSelected(shippingRule)

      self.scheduler.advance()

      self.loadAddOnRewardsIntoDataSource.assertDidNotEmitValue()
      self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertValues([expected])
      XCTAssertEqual(
        self.loadAddOnRewardsIntoDataSourceAndReloadTableView.values.last?.count, 4,
        "All rewards emit and tableView reloads"
      )
      self.configureContinueCTAViewWithDataQuantity.assertValues([0, 0])
      self.configureContinueCTAViewWithDataIsValid.assertValues([true, true])
      self.configureContinueCTAViewWithDataIsLoading.assertValues([true, false])

      self.vm.inputs.rewardAddOnCardViewDidSelectQuantity(quantity: 5, rewardId: 1)

      self.loadAddOnRewardsIntoDataSource.assertValueCount(1, "DataSource is updated")
      XCTAssertEqual(
        self.loadAddOnRewardsIntoDataSource.values[0][0]
          .rewardAddOnCardViewData?.selectedQuantities[1],
        5,
        "Add-on at index 1 with ID 1 has its quantity updated to 5"
      )
      self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertValues(
        [expected], "TableView does not reload again"
      )
      self.configureContinueCTAViewWithDataQuantity.assertValues([0, 0, 0, 5, 5])
      self.configureContinueCTAViewWithDataIsValid.assertValues([true, true, true, true, true])
      self.configureContinueCTAViewWithDataIsLoading.assertValues([true, false, false, false, false])
    }
  }

  func testUpdatingQuantities_ProjectBacked() {
    self.configureContinueCTAViewWithDataQuantity.assertDidNotEmitValue()
    self.configureContinueCTAViewWithDataIsValid.assertDidNotEmitValue()
    self.loadAddOnRewardsIntoDataSource.assertDidNotEmitValue()
    self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertDidNotEmitValue()

    let shippingRule = ShippingRule.template
      |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 99)

    let reward = Reward.template
      |> Reward.lens.id .~ 99
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted

    let addOn1 = Reward.template
      |> Reward.lens.id .~ 1
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]

    let addOn2 = Reward.template
      |> Reward.lens.id .~ 2
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]

    let addOn3 = Reward.template
      |> Reward.lens.id .~ 3
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]

    let addOn4 = Reward.template
      |> Reward.lens.id .~ 4
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.rewardData.addOns .~ [addOn1, addOn2, addOn3, addOn4]
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ Backing.PaymentSource.template
          |> Backing.lens.status .~ .pledged
          |> Backing.lens.addOns .~ [addOn1, addOn1, addOn2]
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.locationId .~ shippingRule.location.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.bonusAmount .~ 680.0
          |> Backing.lens.amount .~ 700.0
      )

    let expected = [addOn1, addOn2, addOn3, addOn4].map { addOn in
      RewardAddOnCardViewData(
        project: project,
        reward: addOn,
        context: .pledge,
        shippingRule: shippingRule,
        selectedQuantities: [
          addOn1.id: 2,
          addOn2.id: 1,
          reward.id: 1
        ]
      )
    }
    .map(RewardAddOnSelectionDataSourceItem.rewardAddOn)

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .success(project))

    self.configureContinueCTAViewWithDataQuantity.assertDidNotEmitValue()
    self.configureContinueCTAViewWithDataIsValid.assertDidNotEmitValue()
    self.configureContinueCTAViewWithDataIsLoading.assertDidNotEmitValue()
    self.loadAddOnRewardsIntoDataSource.assertDidNotEmitValue()
    self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertDidNotEmitValue()

    withEnvironment(apiService: mockService) {
      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedQuantities: [:],
        selectedLocationId: nil,
        refTag: nil,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertDidNotEmitValue(
        "Nothing is emitted until a shipping location is selected"
      )

      self.vm.inputs.shippingRuleSelected(shippingRule)

      self.scheduler.advance()

      self.loadAddOnRewardsIntoDataSource.assertDidNotEmitValue()
      self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertValues([expected])
      XCTAssertEqual(
        self.loadAddOnRewardsIntoDataSourceAndReloadTableView.values.last?.count, 4,
        "All rewards emit and tableView reloads"
      )
      self.configureContinueCTAViewWithDataQuantity.assertValues([0, 3])
      self.configureContinueCTAViewWithDataIsValid.assertValues([true, false])
      self.configureContinueCTAViewWithDataIsLoading.assertValues([true, false])

      self.vm.inputs.rewardAddOnCardViewDidSelectQuantity(quantity: 5, rewardId: 1)

      self.loadAddOnRewardsIntoDataSource.assertValueCount(1, "DataSource is updated")
      XCTAssertEqual(
        self.loadAddOnRewardsIntoDataSource.values[0][0]
          .rewardAddOnCardViewData?.selectedQuantities[1],
        5,
        "Add-on at index 1 with ID 1 has its quantity updated to 5"
      )
      self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertValues(
        [expected], "TableView does not reload again"
      )
      self.configureContinueCTAViewWithDataQuantity.assertValues([0, 3, 3, 6, 6])
      self.configureContinueCTAViewWithDataIsValid.assertValues([true, false, false, false, true])
      self.configureContinueCTAViewWithDataIsLoading.assertValues([true, false, false, false, false])
    }
  }

  func testShippingLocationViewIsHidden_RewardHasShipping() {
    self.shippingLocationViewIsHidden.assertDidNotEmitValue()

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
    let project = Project.template

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

    self.shippingLocationViewIsHidden.assertValues([false])
  }

  func testShippingLocationViewIsHidden_NoShipping() {
    self.shippingLocationViewIsHidden.assertDidNotEmitValue()

    let reward = Reward.template
      |> Reward.lens.shipping .~ (
        .template |> Reward.Shipping.lens.enabled .~ false
      )
    let project = Project.template

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

    self.shippingLocationViewIsHidden.assertValues([true])
  }

  func testGoToPledge_AddOnsSkipped() {
    let shippingRule = ShippingRule.template
      |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 99)

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.id .~ 99

    let addOn1 = Reward.template
      |> Reward.lens.id .~ 1
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]

    let addOn2 = Reward.template
      |> Reward.lens.id .~ 2
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]

    let addOn3 = Reward.template
      |> Reward.lens.id .~ 3
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]

    let addOn4 = Reward.template
      |> Reward.lens.id .~ 4
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.rewardData.addOns .~ [addOn1, addOn2, addOn3, addOn4]

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .success(project))

    AppEnvironment.login(.init(accessToken: "deadbeef", user: User.brando))
    AppEnvironment.replaceCurrentEnvironment(apiService: mockService)

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

    self.scheduler.advance()
    self.vm.inputs.shippingRuleSelected(shippingRule)
    self.scheduler.advance()

    XCTAssertEqual(["Page Viewed"], self.segmentTrackingClient.events)
    XCTAssertEqual("add_ons", self.segmentTrackingClient.properties.last?["context_page"] as? String)

    self.vm.inputs.continueButtonTapped()

    XCTAssertEqual(
      ["Page Viewed", "CTA Clicked"],
      self.segmentTrackingClient.events
    )
    XCTAssertTrue(self.segmentTrackingClient.containsKeyPrefix("context_"))
    XCTAssertTrue(self.segmentTrackingClient.containsKeyPrefix("session_"))
    XCTAssertTrue(self.segmentTrackingClient.containsKeyPrefix("project_"))
    XCTAssertTrue(self.segmentTrackingClient.containsKeyPrefix("user_"))

    let expectedGoToPledgeData = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedQuantities: [reward.id: 1],
      selectedLocationId: shippingRule.location.id,
      refTag: nil,
      context: .pledge
    )

    self.goToPledge.assertValues([expectedGoToPledgeData])
  }

  func testGoToPledge_AddOnsIncluded() {
    let shippingRule = ShippingRule.template
      |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 99)

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.id .~ 99

    let addOn1 = Reward.template
      |> Reward.lens.id .~ 1
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]

    let addOn2 = Reward.template
      |> Reward.lens.id .~ 2
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]

    let addOn3 = Reward.template
      |> Reward.lens.id .~ 3
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]

    let addOn4 = Reward.template
      |> Reward.lens.id .~ 4
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.rewardData.addOns .~ [addOn1, addOn2, addOn3, addOn4]

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .success(project))

    AppEnvironment.login(.init(accessToken: "deadbeef", user: User.brando))
    AppEnvironment.replaceCurrentEnvironment(apiService: mockService)

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

    self.scheduler.advance()
    self.vm.inputs.shippingRuleSelected(shippingRule)
    self.scheduler.advance()

    XCTAssertEqual(["Page Viewed"], self.segmentTrackingClient.events)
    XCTAssertEqual("add_ons", self.segmentTrackingClient.properties.last?["context_page"] as? String)

    self.vm.inputs.rewardAddOnCardViewDidSelectQuantity(quantity: 3, rewardId: 2)
    self.vm.inputs.rewardAddOnCardViewDidSelectQuantity(quantity: 2, rewardId: 1)
    self.vm.inputs.rewardAddOnCardViewDidSelectQuantity(quantity: 4, rewardId: 4)

    self.goToPledge.assertValueCount(0)

    self.vm.inputs.continueButtonTapped()

    XCTAssertEqual(
      ["Page Viewed", "CTA Clicked"],
      self.segmentTrackingClient.events
    )
    XCTAssertTrue(self.segmentTrackingClient.containsKeyPrefix("context_"))
    XCTAssertTrue(self.segmentTrackingClient.containsKeyPrefix("session_"))
    XCTAssertTrue(self.segmentTrackingClient.containsKeyPrefix("project_"))
    XCTAssertTrue(self.segmentTrackingClient.containsKeyPrefix("user_"))

    self.goToPledge.assertValueCount(1)
    XCTAssertEqual(self.goToPledge.values.last?.project, project)
    XCTAssertEqual(
      self.goToPledge.values.last?.rewards.count,
      4
    )
    XCTAssertEqual(self.goToPledge.values.last?.selectedQuantities[reward.id], 1)
    XCTAssertEqual(self.goToPledge.values.last?.selectedQuantities[addOn2.id], 3)
    XCTAssertEqual(self.goToPledge.values.last?.selectedQuantities[addOn1.id], 2)
    XCTAssertEqual(self.goToPledge.values.last?.selectedQuantities[addOn4.id], 4)
    XCTAssertEqual(self.goToPledge.values.last?.selectedLocationId, shippingRule.location.id)
    XCTAssertEqual(self.goToPledge.values.last?.refTag, .activity)
    XCTAssertEqual(self.goToPledge.values.last?.context, .pledge)
  }
}
