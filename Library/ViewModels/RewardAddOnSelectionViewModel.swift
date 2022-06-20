import KsApi
import Prelude
import ReactiveSwift

public typealias SelectedRewardId = Int
public typealias SelectedRewardQuantity = Int
public typealias SelectedRewardQuantities = [SelectedRewardId: SelectedRewardQuantity]

public enum RewardAddOnSelectionDataSourceItem: Equatable {
  case rewardAddOn(RewardAddOnCardViewData)
  case emptyState(EmptyStateViewType)

  public var rewardAddOnCardViewData: RewardAddOnCardViewData? {
    switch self {
    case let .rewardAddOn(data): return data
    case .emptyState: return nil
    }
  }

  public var emptyStateViewType: EmptyStateViewType? {
    switch self {
    case .rewardAddOn: return nil
    case let .emptyState(viewType): return viewType
    }
  }
}

public protocol RewardAddOnSelectionViewModelInputs {
  func beginRefresh()
  func configure(with data: PledgeViewData)
  func continueButtonTapped()
  func rewardAddOnCardViewDidSelectQuantity(quantity: Int, rewardId: Int)
  func shippingLocationViewDidFailToLoad()
  func shippingRuleSelected(_ shippingRule: ShippingRule)
  func viewDidLoad()
}

public protocol RewardAddOnSelectionViewModelOutputs {
  var configureContinueCTAViewWithData: Signal<RewardAddOnSelectionContinueCTAViewData, Never> { get }
  var configurePledgeShippingLocationViewControllerWithData:
    Signal<PledgeShippingLocationViewData, Never> { get }
  var endRefreshing: Signal<(), Never> { get }
  var goToPledge: Signal<PledgeViewData, Never> { get }
  var loadAddOnRewardsIntoDataSource: Signal<[RewardAddOnSelectionDataSourceItem], Never> { get }
  var loadAddOnRewardsIntoDataSourceAndReloadTableView:
    Signal<[RewardAddOnSelectionDataSourceItem], Never> { get }
  var shippingLocationViewIsHidden: Signal<Bool, Never> { get }
  var startRefreshing: Signal<(), Never> { get }
}

public protocol RewardAddOnSelectionViewModelType {
  var inputs: RewardAddOnSelectionViewModelInputs { get }
  var outputs: RewardAddOnSelectionViewModelOutputs { get }
}

public final class RewardAddOnSelectionViewModel: RewardAddOnSelectionViewModelType,
  RewardAddOnSelectionViewModelInputs, RewardAddOnSelectionViewModelOutputs {
  public init() {
    let configData = Signal.combineLatest(
      self.configureWithDataProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    )
    .map(first)

    let project = configData.map(\.project)
    let baseReward = configData.map(\.rewards).map(\.first).skipNil()
    let baseRewardQuantities = configData.map(\.selectedQuantities)
    let refTag = configData.map(\.refTag)
    let context = configData.map(\.context)
    let initialLocationId = configData.map(\.selectedLocationId)

    let shippingLocationViewConfigData = Signal.zip(project, baseReward, initialLocationId)

    let fetchShippingLocations = Signal.merge(
      shippingLocationViewConfigData,
      shippingLocationViewConfigData.takeWhen(self.beginRefreshSignal)
    )
    .filter { _, reward, _ in reward.shipping.enabled }

    self.configurePledgeShippingLocationViewControllerWithData = fetchShippingLocations
      .map { project, reward, initialLocationId in (project, reward, false, initialLocationId) }

    let slug = project.map(\.slug)

    let fetchAddOnsWithSlug = Signal.merge(
      slug,
      slug.takeWhen(self.beginRefreshSignal)
    )

    let shippingRule = Signal.merge(
      self.shippingRuleSelectedProperty.signal,
      baseReward.filter { reward in !reward.shipping.enabled }.mapConst(nil)
    )

    let slugAndShippingRule = Signal.combineLatest(fetchAddOnsWithSlug, shippingRule)

    let projectEvent = slugAndShippingRule.switchMap { slug, shippingRule in
      AppEnvironment.current.apiService.fetchRewardAddOnsSelectionViewRewards(
        slug: slug,
        shippingEnabled: shippingRule?.location.graphID != nil,
        locationId: shippingRule?.location.graphID
      )
      .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
      .materialize()
    }

    self.startRefreshing = self.beginRefreshSignal
    self.endRefreshing = projectEvent.filter { $0.isTerminating }.ignoreValues()

    let addOns = projectEvent.values().map(\.rewardData.addOns).skipNil()

    let requestErrored = projectEvent.map(\.error).map(isNotNil)

    // Quantities updated as the user selects them, merged with an empty initial value.
    let updatedSelectedQuantities = Signal.merge(
      self.rewardAddOnCardViewDidSelectQuantityProperty.signal
        .skipNil()
        .scan([:]) { current, new -> SelectedRewardQuantities in
          let (quantity, rewardId) = new
          var mutableCurrent = current
          mutableCurrent[rewardId] = quantity
          return mutableCurrent
        },
      configData.mapConst([:])
    )

    let backedQuantities = project.map { project -> SelectedRewardQuantities in
      guard let backing = project.personalization.backing else { return [:] }

      return selectedRewardQuantities(in: backing)
    }

    // Backed quantities overwritten by user-selected quantities.
    let selectedAddOnQuantities = Signal.combineLatest(
      updatedSelectedQuantities,
      backedQuantities
    )
    .map { updatedSelectedQuantities, backedQuantities in
      backedQuantities.withAllValuesFrom(updatedSelectedQuantities)
    }

    // User-selected and backed quantities combined with the base reward selection.
    let selectedQuantities = Signal.combineLatest(
      selectedAddOnQuantities,
      baseRewardQuantities
    )
    .map { selectedAddOnQuantities, baseRewardQuantities in
      selectedAddOnQuantities.withAllValuesFrom(baseRewardQuantities)
    }

    let latestSelectedQuantities = Signal.merge(
      baseRewardQuantities,
      selectedQuantities
    )

    let rewardAddOnCardsViewData = Signal.combineLatest(
      addOns,
      project,
      baseReward,
      context,
      shippingRule
    )

    let reloadRewardsIntoDataSource = rewardAddOnCardsViewData
      .withLatest(from: latestSelectedQuantities)
      .map(unpack)
      .map(rewardsData)

    self.loadAddOnRewardsIntoDataSourceAndReloadTableView = Signal.merge(
      reloadRewardsIntoDataSource,
      requestErrored.filter(isTrue).mapConst([.emptyState(.errorPullToRefresh)])
    )

    self.loadAddOnRewardsIntoDataSource = rewardAddOnCardsViewData
      .takePairWhen(latestSelectedQuantities)
      .map(unpack)
      .map(rewardsData)

    self.shippingLocationViewIsHidden = Signal.merge(
      baseReward.map(\.shipping.enabled).negate(),
      self.shippingLocationViewDidFailToLoadProperty.signal.mapConst(true),
      fetchShippingLocations.mapConst(false)
    )
    .combineLatest(with: baseReward)
    .switchMap { flag, baseReward -> SignalProducer<Bool, Never> in
      let shippingLocationViewHidden = isRewardLocalPickup(baseReward) ? true : flag

      return SignalProducer(value: shippingLocationViewHidden)
    }
    .skipRepeats()

    let dataSourceItems = Signal.merge(
      self.loadAddOnRewardsIntoDataSourceAndReloadTableView,
      self.loadAddOnRewardsIntoDataSource
    )

    let allRewards = dataSourceItems.map { items in
      items.compactMap { item -> Reward? in item.rewardAddOnCardViewData?.reward }
    }

    let baseRewardAndAddOnRewards = Signal.combineLatest(
      baseReward,
      dataSourceItems.map { items in
        items.compactMap { item -> Reward? in item.rewardAddOnCardViewData?.reward }
      }
    )

    let totalSelectedAddOnsQuantity = Signal.combineLatest(
      latestSelectedQuantities,
      baseReward.map(\.id),
      allRewards.map { $0.map(\.id) }
    )
    .map { quantities, baseRewardId, addOnRewardIds in
      quantities
        // Filter out the base reward for determining the add-on quantities
        .filter { key, _ in key != baseRewardId && addOnRewardIds.contains(key) }
        .reduce(0) { accum, keyValue in
          let (_, value) = keyValue
          return accum + value
        }
    }

    let selectionChanged = Signal.combineLatest(project, latestSelectedQuantities, shippingRule)
      .map(isValid)

    self.configureContinueCTAViewWithData = Signal.merge(
      Signal.combineLatest(totalSelectedAddOnsQuantity, selectionChanged)
        .map { qty, isValid in (qty, isValid, false) },
      configData.mapConst((0, true, true))
    )

    let selectedRewards = baseRewardAndAddOnRewards
      .combineLatest(with: latestSelectedQuantities)
      .map(unpack)
      .map { baseReward, addOnRewards, selectedQuantities -> [Reward] in
        let selectedRewardIds = selectedQuantities
          .filter { _, qty in qty > 0 }
          .keys

        return [baseReward] + addOnRewards
          .filter { reward in selectedRewardIds.contains(reward.id) }
      }

    let selectedLocationId = Signal.merge(
      initialLocationId,
      shippingRule.map { $0?.location.id }
    )

    self.goToPledge = Signal.combineLatest(
      project,
      selectedRewards,
      selectedQuantities,
      selectedLocationId,
      refTag,
      context
    )
    .map(PledgeViewData.init)
    .takeWhen(self.continueButtonTappedProperty.signal)

    let shippingTotal = Signal.combineLatest(
      shippingRule.skipNil(),
      selectedRewards,
      selectedQuantities
    )
    .map(calculateShippingTotal)

    let baseRewardShippingTotal = Signal.zip(project, baseReward, shippingRule)
      .map(getBaseRewardShippingTotal)

    let allRewardsShippingTotal = Signal.merge(
      baseRewardShippingTotal,
      shippingTotal
    )

    // Additional pledge amount is zero if not backed.
    let additionalPledgeAmount = Signal.merge(
      configData.filter { $0.project.personalization.backing == nil }.mapConst(0.0),
      project.map { $0.personalization.backing }.skipNil().map(\.bonusAmount)
    )

    let allRewardsTotal = Signal.combineLatest(
      selectedRewards,
      selectedQuantities
    )
    .map(calculateAllRewardsTotal)

    let combinedPledgeTotal = Signal.combineLatest(
      additionalPledgeAmount,
      allRewardsShippingTotal,
      allRewardsTotal
    )
    .map(calculatePledgeTotal)

    let pledgeTotal = Signal.merge(
      project.map { $0.personalization.backing }.skipNil().map(\.amount),
      combinedPledgeTotal
    )

    // MARK: - Tracking

    // shippingRule needs to be set for the event is fired
    Signal.zip(
      project,
      baseReward,
      selectedRewards,
      refTag,
      configData,
      additionalPledgeAmount,
      allRewardsShippingTotal,
      pledgeTotal
    )
    .take(first: 1)
    .observeForUI()
    .observeValues { project, baseReward, selectedRewards, refTag, configData, additionalPledgeAmount, shippingTotal, pledgeTotal in
      let checkoutPropertiesData = checkoutProperties(
        from: project,
        baseReward: baseReward,
        addOnRewards: selectedRewards,
        selectedQuantities: configData.selectedQuantities,
        additionalPledgeAmount: additionalPledgeAmount,
        pledgeTotal: pledgeTotal,
        shippingTotal: shippingTotal,
        isApplePay: nil
      )

      AppEnvironment.current.ksrAnalytics.trackAddOnsPageViewed(
        project: project,
        reward: baseReward,
        checkoutData: checkoutPropertiesData,
        refTag: refTag
      )
    }

    // Send updated checkout data with add-ons continue event
    Signal.combineLatest(
      project,
      baseReward,
      selectedRewards,
      selectedQuantities,
      additionalPledgeAmount,
      pledgeTotal,
      allRewardsShippingTotal,
      refTag
    ).takeWhen(self.continueButtonTappedProperty.signal)
      .observeValues { project, baseReward, selectedRewards, selectedQuantities, additionalPledgeAmount, pledgeTotal, shippingTotal, refTag in

        let checkoutData = checkoutProperties(
          from: project,
          baseReward: baseReward,
          addOnRewards: selectedRewards,
          selectedQuantities: selectedQuantities,
          additionalPledgeAmount: additionalPledgeAmount,
          pledgeTotal: pledgeTotal,
          shippingTotal: shippingTotal,
          isApplePay: nil
        )

        AppEnvironment.current.ksrAnalytics.trackAddOnsContinueButtonClicked(
          project: project,
          reward: baseReward,
          checkoutData: checkoutData,
          refTag: refTag
        )
      }
  }

  private let (beginRefreshSignal, beginRefreshObserver) = Signal<Void, Never>.pipe()
  public func beginRefresh() {
    self.beginRefreshObserver.send(value: ())
  }

  private let configureWithDataProperty = MutableProperty<PledgeViewData?>(nil)
  public func configure(with data: PledgeViewData) {
    self.configureWithDataProperty.value = data
  }

  private let continueButtonTappedProperty = MutableProperty(())
  public func continueButtonTapped() {
    self.continueButtonTappedProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let rewardAddOnCardViewDidSelectQuantityProperty
    = MutableProperty<(SelectedRewardQuantity, SelectedRewardId)?>(nil)
  public func rewardAddOnCardViewDidSelectQuantity(
    quantity: SelectedRewardQuantity,
    rewardId: SelectedRewardId
  ) {
    self.rewardAddOnCardViewDidSelectQuantityProperty.value = (quantity, rewardId)
  }

  private let shippingLocationViewDidFailToLoadProperty = MutableProperty(())
  public func shippingLocationViewDidFailToLoad() {
    self.shippingLocationViewDidFailToLoadProperty.value = ()
  }

  private let shippingRuleSelectedProperty = MutableProperty<ShippingRule?>(nil)
  public func shippingRuleSelected(_ shippingRule: ShippingRule) {
    self.shippingRuleSelectedProperty.value = shippingRule
  }

  public let configureContinueCTAViewWithData: Signal<RewardAddOnSelectionContinueCTAViewData, Never>
  public let configurePledgeShippingLocationViewControllerWithData:
    Signal<PledgeShippingLocationViewData, Never>
  public let endRefreshing: Signal<(), Never>
  public let goToPledge: Signal<PledgeViewData, Never>
  public let loadAddOnRewardsIntoDataSource: Signal<[RewardAddOnSelectionDataSourceItem], Never>
  public let loadAddOnRewardsIntoDataSourceAndReloadTableView:
    Signal<[RewardAddOnSelectionDataSourceItem], Never>
  public let shippingLocationViewIsHidden: Signal<Bool, Never>
  public let startRefreshing: Signal<(), Never>

  public var inputs: RewardAddOnSelectionViewModelInputs { return self }
  public var outputs: RewardAddOnSelectionViewModelOutputs { return self }
}

// MARK: - Functions

private func unpack(
  rewardsData: ([Reward], Project, Reward, PledgeViewContext, ShippingRule?),
  selectedQuantities: SelectedRewardQuantities
) -> ([Reward], Project, Reward, PledgeViewContext, ShippingRule?, SelectedRewardQuantities) {
  return (rewardsData.0, rewardsData.1, rewardsData.2, rewardsData.3, rewardsData.4, selectedQuantities)
}

private func rewardsData(
  addOns: [Reward],
  project: Project,
  baseReward: Reward,
  context: PledgeViewContext,
  shippingRule: ShippingRule?,
  selectedQuantities: SelectedRewardQuantities
) -> [RewardAddOnSelectionDataSourceItem] {
  let addOnsFilteredByAvailability = addOns.filter { addOnIsAvailable($0, in: project) }

  let addOnsFilteredByExpandedShippingRule = filteredAddOns(
    addOnsFilteredByAvailability,
    filteredBy: shippingRule,
    baseReward: baseReward
  )

  guard !addOnsFilteredByExpandedShippingRule.isEmpty else {
    return [.emptyState(.addOnsUnavailable)]
  }

  return addOnsFilteredByExpandedShippingRule
    .map { reward in
      RewardAddOnCardViewData(
        project: project,
        reward: reward,
        context: context == .pledge ? .pledge : .manage,
        shippingRule: reward.shipping.enabled
          ? reward.shippingRule(matching: shippingRule)
          : nil,
        selectedQuantities: selectedQuantities
      )
    }
    .map(RewardAddOnSelectionDataSourceItem.rewardAddOn)
}

private func addOnIsAvailable(_ addOn: Reward, in project: Project) -> Bool {
  // If the user is backing this addOn, it's available for editing
  if let backedAddOns = project.personalization.backing?.addOns, backedAddOns.map(\.id).contains(addOn.id) {
    return true
  }

  let isUnlimitedOrAvailable = addOn.limit == nil || addOn.remaining ?? 0 > 0

  // Assuming the user has not backed the addOn, we only display if it's within range of the start and end date
  let hasNoTimeLimitOrIsWithinRange = isStartDateBeforeToday(for: addOn) && isEndDateAfterToday(for: addOn)

  return [
    project.state == .live,
    hasNoTimeLimitOrIsWithinRange,
    isUnlimitedOrAvailable
  ]
  .allSatisfy(isTrue)
}

private func filteredAddOns(
  _ addOns: [Reward],
  filteredBy shippingRule: ShippingRule?,
  baseReward: Reward
) -> [Reward] {
  let isBaseRewardDigital = isRewardDigital(baseReward)
  let isBaseRewardLocalPickup = isRewardLocalPickup(baseReward)

  return addOns.filter { addOn in
    var isValidAddonToDisplay = false
    let isAddOnDigital = isRewardDigital(addOn)
    let isAddOnLocalPickup = isRewardLocalPickup(addOn)
    let isAddOnLocalOrDigital = isAddOnDigital || isAddOnLocalPickup
    // For digital-only base rewards only return add-ons that are also digital-only.
    if isBaseRewardDigital, isAddOnDigital {
      isValidAddonToDisplay = true
    } else if isBaseRewardLocalPickup, isAddOnLocalOrDigital {
      isValidAddonToDisplay = true // return all addons that are digital for local base reward

      if isAddOnLocalPickup {
        if let addOnLocationId = addOn.localPickup?.id,
          let baseRewardLocationId = baseReward.localPickup?.id,
          addOnLocationId ==
          baseRewardLocationId {
          // if add on is local for local base, ensure locations are equal before displaying
          isValidAddonToDisplay = true
        } else {
          isValidAddonToDisplay = false
        }
      }
    } else if !isBaseRewardDigital, !isBaseRewardLocalPickup {
      /**
       For restricted or unrestricted shipping base rewards, unrestricted shipping
       or digital-only add-ons are available.
       */
      isValidAddonToDisplay = isAddOnDigital || addOnReward(addOn, shipsTo: shippingRule?.location.id)
    }

    return isValidAddonToDisplay
  }
}

/**
 For base rewards that have restricted or unrestricted shipping, only return
 add-ons that can ship to the selected shipping location.
 */
private func addOnReward(
  _ addOn: Reward,
  shipsTo locationId: Int?
) -> Bool {
  guard let selectedLocationId = locationId else { return false }

  let addOnShippingLocationIds: Set<Int> = Set(
    addOn.shippingRulesExpanded?.map(\.location).map(\.id) ?? []
  )

  return addOnShippingLocationIds.contains(selectedLocationId)
}

private func isValid(
  project: Project,
  latestSelectedQuantities: SelectedRewardQuantities,
  selectedShippingRule: ShippingRule?
) -> Bool {
  guard let backing = project.personalization.backing else { return true }

  return latestSelectedQuantities != selectedRewardQuantities(in: backing)
    || backing.locationId != selectedShippingRule?.location.id
}
