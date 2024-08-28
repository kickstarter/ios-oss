@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class RewardAddOnSelectionNoShippingViewModelTests: TestCase {
  private let vm: RewardAddOnSelectionNoShippingViewModelType = RewardAddOnSelectionNoShippingViewModel()

  private let configureContinueCTAViewWithDataIsLoading = TestObserver<Bool, Never>()
  private let configureContinueCTAViewWithDataIsValid = TestObserver<Bool, Never>()
  private let configureContinueCTAViewWithDataQuantity = TestObserver<Int, Never>()
  private let configurePledgeAmountViewWithData = TestObserver<PledgeAmountViewConfigData, Never>()
  private let endRefreshing = TestObserver<(), Never>()
  private let goToPledge = TestObserver<PledgeViewData, Never>()
  private let loadAddOnRewardsIntoDataSource = TestObserver<[RewardAddOnSelectionDataSourceItem], Never>()
  private let loadAddOnRewardsIntoDataSourceAndReloadTableView
    = TestObserver<[RewardAddOnSelectionDataSourceItem], Never>()
  private let startRefreshing = TestObserver<(), Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.configureContinueCTAViewWithData.map(\.selectedQuantity)
      .observe(self.configureContinueCTAViewWithDataQuantity.observer)
    self.vm.outputs.configureContinueCTAViewWithData.map(\.isValid)
      .observe(self.configureContinueCTAViewWithDataIsValid.observer)
    self.vm.outputs.configureContinueCTAViewWithData.map(\.isLoading)
      .observe(self.configureContinueCTAViewWithDataIsLoading.observer)
    self.vm.outputs.configurePledgeAmountViewWithData
      .observe(self.configurePledgeAmountViewWithData.observer)
    self.vm.outputs.endRefreshing.observe(self.endRefreshing.observer)
    self.vm.outputs.goToPledge.observe(self.goToPledge.observer)
    self.vm.outputs.loadAddOnRewardsIntoDataSource.observe(self.loadAddOnRewardsIntoDataSource.observer)
    self.vm.outputs.loadAddOnRewardsIntoDataSourceAndReloadTableView
      .observe(self.loadAddOnRewardsIntoDataSourceAndReloadTableView.observer)
    self.vm.outputs.startRefreshing.observe(self.startRefreshing.observer)
  }

  func testLoadAddOnRewardsIntoDataSource() {
    self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertDidNotEmitValue()

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.shipping.preference .~ Reward.Shipping.Preference.none
      |> Reward.lens.isAvailable .~ true
      |> Reward.lens.hasAddOns .~ true

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
        selectedShippingRule: ShippingRule.template,
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
      self.endRefreshing.assertValueCount(2)

      self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertValues([
        [.rewardAddOn(expected)],
        [.rewardAddOn(expected)]
      ])
    }
  }

  func testLoadAddOnRewards_NotLoadedIntoDataSource_IfLocalPickupLocationsNotMatching_Success() {
    self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertDidNotEmitValue()

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ Reward.Shipping.Preference.local
      |> Reward.lens.localPickup .~ .brooklyn
      |> Reward.lens.hasAddOns .~ true

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
        selectedShippingRule: ShippingRule.template,
        selectedQuantities: [:],
        selectedLocationId: nil,
        refTag: nil,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertValues([[.emptyState(.addOnsUnavailable)]])
    }
  }

  func testLoadAddOnRewardsIntoDataSource_Error() {
    self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertDidNotEmitValue()

    let reward = Reward.template
      |> Reward.lens.hasAddOns .~ true

    let project = Project.template

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .failure(.couldNotParseJSON))

    withEnvironment(apiService: mockService) {
      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: ShippingRule.template,
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
      |> Reward.lens.isAvailable .~ true
      |> Reward.lens.hasAddOns .~ true

    let project = Project.template
      |> Project.lens.rewardData.addOns .~ [reward]

    let mockService1 = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .failure(.couldNotParseJSON))

    self.startRefreshing.assertDidNotEmitValue()
    self.endRefreshing.assertDidNotEmitValue()

    withEnvironment(apiService: mockService1) {
      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedShippingRule: ShippingRule.template,
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
      self.endRefreshing.assertValueCount(2)

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
      self.endRefreshing.assertValueCount(2)

      self.scheduler.advance()

      self.startRefreshing.assertValueCount(1)
      self.endRefreshing.assertValueCount(3)

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
      |> Reward.lens.isAvailable .~ true
      |> Reward.lens.hasAddOns .~ true

    let noShippingAddOn = Reward.template
      |> Reward.lens.id .~ 1
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.shipping.preference .~ Reward.Shipping.Preference.none
      |> Reward.lens.isAvailable .~ true

    let shippingAddOn1 = Reward.template
      |> Reward.lens.id .~ 2
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ Reward.Shipping.Preference.restricted
      |> Reward.lens.isAvailable .~ true

    let shippingAddOn2 = Reward.template
      |> Reward.lens.id .~ 3
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ Reward.Shipping.Preference.restricted
      |> Reward.lens.isAvailable .~ true

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
        selectedShippingRule: ShippingRule.template,
        selectedQuantities: [:],
        selectedLocationId: nil,
        refTag: nil,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertValues([
        [.rewardAddOn(expected)],
        [.rewardAddOn(expected)]
      ])
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
      |> Reward.lens.hasAddOns .~ true

    // regular, no limit add-on.
    let addOn1 = Reward.template
      |> Reward.lens.id .~ 1
      |> Reward.lens.limit .~ nil
      |> Reward.lens.remaining .~ nil
      |> Reward.lens.endsAt .~ nil
      |> Reward.lens.isAvailable .~ true

    // timebased add-on, ended 60 secs ago.
    let addOn2 = Reward.template
      |> Reward.lens.id .~ 2
      |> Reward.lens.limit .~ nil
      |> Reward.lens.remaining .~ nil
      |> Reward.lens.endsAt .~ (MockDate().timeIntervalSince1970 - 60)
      |> Reward.lens.isAvailable .~ false

    // timebased add-on, ended 60 secs ago (backed).
    let addOn3 = Reward.template
      |> Reward.lens.id .~ 3
      |> Reward.lens.endsAt .~ (MockDate().timeIntervalSince1970 - 60)
      |> Reward.lens.isAvailable .~ false

    // limited, unavailable add-on.
    let addOn4 = Reward.template
      |> Reward.lens.id .~ 4
      |> Reward.lens.limit .~ 5
      |> Reward.lens.remaining .~ 0
      |> Reward.lens.isAvailable .~ false

    // time-based, available add-on, ends in 60 secs.
    let addOn5 = Reward.template
      |> Reward.lens.id .~ 5
      |> Reward.lens.limit .~ nil
      |> Reward.lens.remaining .~ nil
      |> Reward.lens.endsAt .~ (MockDate().timeIntervalSince1970 + 60)
      |> Reward.lens.isAvailable .~ true

    // limited, available add-on.
    let addOn6 = Reward.template
      |> Reward.lens.id .~ 6
      |> Reward.lens.limit .~ 5
      |> Reward.lens.remaining .~ 2
      |> Reward.lens.isAvailable .~ true

    // timebased add-on, starts in 60 seconds
    let addOn7 = Reward.template
      |> Reward.lens.id .~ 7
      |> Reward.lens.limit .~ nil
      |> Reward.lens.remaining .~ nil
      |> Reward.lens.startsAt .~ (MockDate().timeIntervalSince1970 + 60)
      |> Reward.lens.isAvailable .~ false

    // timebased add-on, started 60 seconds ago.
    let addOn8 = Reward.template
      |> Reward.lens.id .~ 8
      |> Reward.lens.limit .~ nil
      |> Reward.lens.remaining .~ nil
      |> Reward.lens.startsAt .~ (MockDate().timeIntervalSince1970 - 60)
      |> Reward.lens.isAvailable .~ true

    // timebased add-on, both startsAt and endsAt are within a valid range
    let addOn9 = Reward.template
      |> Reward.lens.id .~ 9
      |> Reward.lens.limit .~ nil
      |> Reward.lens.remaining .~ nil
      |> Reward.lens.startsAt .~ (MockDate().timeIntervalSince1970 - 60)
      |> Reward.lens.endsAt .~ (MockDate().timeIntervalSince1970 + 60)
      |> Reward.lens.isAvailable .~ true

    // timebased add-on, invalid range
    let addOn10 = Reward.template
      |> Reward.lens.id .~ 10
      |> Reward.lens.limit .~ nil
      |> Reward.lens.remaining .~ nil
      |> Reward.lens.startsAt .~ (MockDate().timeIntervalSince1970 + 30)
      |> Reward.lens.endsAt .~ (MockDate().timeIntervalSince1970 + 60)
      |> Reward.lens.isAvailable .~ false

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
        selectedShippingRule: ShippingRule.template,
        selectedQuantities: [:],
        selectedLocationId: nil,
        refTag: nil,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertValues([expected, expected])
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
      |> Reward.lens.hasAddOns .~ true

    let noShippingAddOn = Reward.template
      |> Reward.lens.id .~ 1
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.shipping.preference .~ Reward.Shipping.Preference.none
      |> Reward.lens.isAvailable .~ true

    let shippingAddOn1 = Reward.template
      |> Reward.lens.id .~ 2
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRulesExpanded .~ [
        shippingRule,
        shippingRule |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 99)
      ]
      |> Reward.lens.isAvailable .~ true

    let shippingAddOn2 = Reward.template
      |> Reward.lens.id .~ 3
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRulesExpanded .~ [
        shippingRule,
        shippingRule |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 99)
      ]
      |> Reward.lens.isAvailable .~ true

    let shippingAddOn3 = Reward.template
      |> Reward.lens.id .~ 4
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRulesExpanded .~ [
        shippingRule |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 3)
      ]
      |> Reward.lens.isAvailable .~ true

    let shippingAddOn4 = Reward.template
      |> Reward.lens.id .~ 5
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]
      |> Reward.lens.isAvailable .~ true

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
        selectedShippingRule: shippingRule,
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
      |> Reward.lens.isAvailable .~ true
      |> Reward.lens.hasAddOns .~ true

    let noShippingAddOn = Reward.template
      |> Reward.lens.id .~ 1
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.shipping.preference .~ Reward.Shipping.Preference.none
      |> Reward.lens.isAvailable .~ true

    let shippingAddOn1 = Reward.template
      |> Reward.lens.id .~ 2
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]
      |> Reward.lens.isAvailable .~ true

    let shippingAddOn2 = Reward.template
      |> Reward.lens.id .~ 3
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]
      |> Reward.lens.isAvailable .~ true
      |> Reward.lens.isAvailable .~ true

    let shippingAddOn3 = Reward.template
      |> Reward.lens.id .~ 4
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRulesExpanded .~ [
        shippingRule |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 3)
      ]
      |> Reward.lens.isAvailable .~ true

    let shippingAddOn4 = Reward.template
      |> Reward.lens.id .~ 5
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.isAvailable .~ true

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
        selectedShippingRule: shippingRule,
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
      |> Reward.lens.isAvailable .~ true
      |> Reward.lens.hasAddOns .~ true

    let shippingAddOn1 = Reward.template
      |> Reward.lens.id .~ 2
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRulesExpanded .~ [
        shippingRule |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 99)
      ]
      |> Reward.lens.isAvailable .~ true

    let shippingAddOn2 = Reward.template
      |> Reward.lens.id .~ 3
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRulesExpanded .~ [
        shippingRule |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 99)
      ]
      |> Reward.lens.isAvailable .~ true

    let shippingAddOn3 = Reward.template
      |> Reward.lens.id .~ 4
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRulesExpanded .~ [
        shippingRule |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 3)
      ]
      |> Reward.lens.isAvailable .~ true

    let shippingAddOn4 = Reward.template
      |> Reward.lens.id .~ 5
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRulesExpanded .~ [
        shippingRule |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 3)
      ]
      |> Reward.lens.isAvailable .~ true

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
        selectedShippingRule: shippingRule,
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
      |> Reward.lens.isAvailable .~ true
      |> Reward.lens.hasAddOns .~ true

    let addOn1 = Reward.template
      |> Reward.lens.id .~ 1
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]
      |> Reward.lens.isAvailable .~ true

    let addOn2 = Reward.template
      |> Reward.lens.id .~ 2
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]
      |> Reward.lens.isAvailable .~ true

    let addOn3 = Reward.template
      |> Reward.lens.id .~ 3
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]
      |> Reward.lens.isAvailable .~ true

    let addOn4 = Reward.template
      |> Reward.lens.id .~ 4
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]
      |> Reward.lens.isAvailable .~ true

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
        selectedShippingRule: shippingRule,
        selectedQuantities: [:],
        selectedLocationId: nil,
        refTag: nil,
        context: .pledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      // Set pledge amount data so that data validation can occur.
      let pledgeAmountData = PledgeAmountData(amount: 0, min: 0, max: 10_000, isValid: true)
      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: pledgeAmountData)

      self.loadAddOnRewardsIntoDataSourceAndReloadTableView.assertDidNotEmitValue(
        "Nothing is emitted until a shipping location is selected"
      )

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

    let bonusAmount = 680.0

    let shippingRule = ShippingRule.template
      |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 99)

    let reward = Reward.template
      |> Reward.lens.id .~ 99
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.isAvailable .~ true
      |> Reward.lens.hasAddOns .~ true

    let addOn1 = Reward.template
      |> Reward.lens.id .~ 1
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]
      |> Reward.lens.isAvailable .~ true

    let addOn2 = Reward.template
      |> Reward.lens.id .~ 2
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]
      |> Reward.lens.isAvailable .~ true

    let addOn3 = Reward.template
      |> Reward.lens.id .~ 3
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]
      |> Reward.lens.isAvailable .~ true

    let addOn4 = Reward.template
      |> Reward.lens.id .~ 4
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]
      |> Reward.lens.isAvailable .~ true

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
          |> Backing.lens.bonusAmount .~ bonusAmount
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
        selectedShippingRule: shippingRule,
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

      // Validate and set bonus support
      XCTAssertEqual(self.configurePledgeAmountViewWithData.lastValue?.currentAmount, bonusAmount)
      let pledgeAmountData =
        PledgeAmountData(amount: bonusAmount, min: 0, max: 10_000, isValid: true)
      self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: pledgeAmountData)

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
      selectedShippingRule: shippingRule,
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: nil,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

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
      bonusSupport: 0.0,
      selectedShippingRule: shippingRule,
      selectedQuantities: [reward.id: 1],
      selectedLocationId: shippingRule.location.id,
      refTag: nil,
      context: .pledge
    )

    self.goToPledge.assertValues([expectedGoToPledgeData])
  }

  func testGoToPledge_AddOnsAndBonus() {
    let shippingRule = ShippingRule.template
      |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 99)

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.id .~ 99
      |> Reward.lens.hasAddOns .~ true

    let addOn1 = Reward.template
      |> Reward.lens.id .~ 1
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]
      |> Reward.lens.isAvailable .~ true

    let addOn2 = Reward.template
      |> Reward.lens.id .~ 2
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]
      |> Reward.lens.isAvailable .~ true

    let addOn3 = Reward.template
      |> Reward.lens.id .~ 3
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]
      |> Reward.lens.isAvailable .~ true

    let addOn4 = Reward.template
      |> Reward.lens.id .~ 4
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]
      |> Reward.lens.isAvailable .~ true

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.rewardData.addOns .~ [addOn1, addOn2, addOn3, addOn4]

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .success(project))

    AppEnvironment.login(.init(accessToken: "deadbeef", user: User.brando))
    AppEnvironment.replaceCurrentEnvironment(apiService: mockService)

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

    self.scheduler.advance()

    XCTAssertEqual(["Page Viewed"], self.segmentTrackingClient.events)
    XCTAssertEqual("add_ons", self.segmentTrackingClient.properties.last?["context_page"] as? String)

    self.vm.inputs.rewardAddOnCardViewDidSelectQuantity(quantity: 3, rewardId: 2)
    self.vm.inputs.rewardAddOnCardViewDidSelectQuantity(quantity: 2, rewardId: 1)
    self.vm.inputs.rewardAddOnCardViewDidSelectQuantity(quantity: 4, rewardId: 4)

    let bonusAmount = 20.0
    let pledgeAmountData = PledgeAmountData(
      amount: bonusAmount,
      min: bonusAmount,
      max: bonusAmount,
      isValid: true
    )
    self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: pledgeAmountData)

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
    XCTAssertEqual(self.goToPledge.values.last?.bonusSupport, bonusAmount)
    XCTAssertEqual(self.goToPledge.values.last?.selectedQuantities[reward.id], 1)
    XCTAssertEqual(self.goToPledge.values.last?.selectedQuantities[addOn2.id], 3)
    XCTAssertEqual(self.goToPledge.values.last?.selectedQuantities[addOn1.id], 2)
    XCTAssertEqual(self.goToPledge.values.last?.selectedQuantities[addOn4.id], 4)
    XCTAssertEqual(self.goToPledge.values.last?.selectedLocationId, shippingRule.location.id)
    XCTAssertEqual(self.goToPledge.values.last?.refTag, .activity)
    XCTAssertEqual(self.goToPledge.values.last?.context, .pledge)
  }

  func testGoToPledge_NoReward() {
    let reward = Reward.noReward

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .success(project))

    AppEnvironment.login(.init(accessToken: "deadbeef", user: User.brando))
    AppEnvironment.replaceCurrentEnvironment(apiService: mockService)

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      selectedShippingRule: nil,
      selectedQuantities: [:],
      selectedLocationId: nil,
      refTag: .activity,
      context: .pledge
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.scheduler.advance()

    self.goToPledge.assertValueCount(0)

    self.vm.inputs.continueButtonTapped()

    self.goToPledge.assertValueCount(1)
    XCTAssertEqual(self.goToPledge.values.last?.project, project)
    XCTAssertEqual(self.goToPledge.values.last?.rewards.count, 1)
  }

  func testGoToPledge_NoAddOns() {
    let shippingRule = ShippingRule.template
      |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 99)

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.id .~ 99

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .success(project))

    AppEnvironment.login(.init(accessToken: "deadbeef", user: User.brando))
    AppEnvironment.replaceCurrentEnvironment(apiService: mockService)

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

    self.scheduler.advance()

    let bonusAmount = 20.0
    let pledgeAmountData = PledgeAmountData(
      amount: bonusAmount,
      min: bonusAmount,
      max: bonusAmount,
      isValid: true
    )

    self.vm.inputs.pledgeAmountViewControllerDidUpdate(with: pledgeAmountData)

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
      self.goToPledge.values.last?.rewards.count, 1
    )
    XCTAssertEqual(self.goToPledge.values.last?.bonusSupport, bonusAmount)
    XCTAssertEqual(self.goToPledge.values.last?.selectedQuantities[reward.id], 1)
    XCTAssertEqual(self.goToPledge.values.last?.selectedLocationId, shippingRule.location.id)
    XCTAssertEqual(self.goToPledge.values.last?.refTag, .activity)
    XCTAssertEqual(self.goToPledge.values.last?.context, .pledge)
  }
}
