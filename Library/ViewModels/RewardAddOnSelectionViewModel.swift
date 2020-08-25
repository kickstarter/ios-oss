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

    self.configurePledgeShippingLocationViewControllerWithData = Signal
      .zip(project, baseReward, initialLocationId)
      .map { project, reward, initialLocationId in (project, reward, false, initialLocationId) }

    let slug = project.map(\.slug)

    let fetchAddOnsWithSlug = Signal.merge(
      slug,
      slug.takeWhen(self.beginRefreshSignal)
    )

    let projectEvent = fetchAddOnsWithSlug.switchMap { slug in
      AppEnvironment.current.apiService.fetchRewardAddOnsSelectionViewRewards(
        query: rewardAddOnSelectionViewAddOnsQuery(withProjectSlug: slug)
      )
      .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
      .materialize()
    }

    self.startRefreshing = self.beginRefreshSignal
    self.endRefreshing = projectEvent.filter { $0.isTerminating }.ignoreValues()

    let addOns = projectEvent.values().map(\.rewardData.addOns).skipNil()
    let requestErrored = projectEvent.map(\.error).map(isNotNil)

    let shippingRule = Signal.merge(
      self.shippingRuleSelectedProperty.signal,
      baseReward.filter { reward in !reward.shipping.enabled }.mapConst(nil)
    )

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

    self.shippingLocationViewIsHidden = baseReward.map(\.shipping.enabled)
      .negate()

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
  let addOnsFilteredByShippingRule = filteredAddOns(
    addOns,
    filteredBy: shippingRule,
    baseReward: baseReward
  )

  guard !addOnsFilteredByShippingRule.isEmpty else {
    return [.emptyState(.addOnsUnavailable)]
  }

  return addOnsFilteredByShippingRule
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

private func filteredAddOns(
  _ addOns: [Reward],
  filteredBy shippingRule: ShippingRule?,
  baseReward: Reward
) -> [Reward] {
  return addOns.filter { addOn in
    // For digital-only base rewards only return add-ons that are also digital-only.
    if baseReward.shipping.enabled == false {
      return addOn.shipping.enabled == false
    }

    /**
     For restricted or unrestricted shipping base rewards, unrestricted shipping
     or digital-only add-ons are available.
     */
    let addOnIsDigitalOrUnrestricted = addOn.shipping.preference
      .isAny(of: Reward.Shipping.Preference.none, .unrestricted)

    return addOnIsDigitalOrUnrestricted || addOnReward(addOn, shipsTo: shippingRule?.location.id)
  }
}

/**
 For base rewards that have restricted shipping, only return
 add-ons that can ship to the selected shipping location.
 */
private func addOnReward(
  _ addOn: Reward,
  shipsTo locationId: Int?
) -> Bool {
  guard let selectedLocationId = locationId else { return false }

  let addOnShippingLocationIds: Set<Int> = Set(
    addOn.shippingRules?.map(\.location).map(\.id) ?? []
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
