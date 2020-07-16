import KsApi
import Prelude
import ReactiveSwift

public struct RewardAddOnCellData: Equatable {
  public let project: Project
  public let reward: Reward
  public let shippingRule: ShippingRule?
}

public protocol RewardAddOnSelectionViewModelInputs {
  func configureWith(project: Project, reward: Reward, refTag: RefTag?, context: PledgeViewContext)
  func shippingRuleSelected(_ shippingRule: ShippingRule)
  func viewDidLoad()
}

public protocol RewardAddOnSelectionViewModelOutputs {
  var configurePledgeShippingLocationViewControllerWithData:
    Signal<PledgeShippingLocationViewData, Never> { get }
  var loadAddOnRewardsIntoDataSource: Signal<[RewardAddOnCellData], Never> { get }
  var shippingLocationViewIsHidden: Signal<Bool, Never> { get }
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

    let project = configData.map { $0.0 }
    let reward = configData.map { $0.1 }

    self.configurePledgeShippingLocationViewControllerWithData = Signal.zip(project, reward)
      .map { project, reward in (project, reward, false) }

    let addOnsEvent = project.map(\.slug).flatMap { slug in
      AppEnvironment.current.apiService.fetchRewardAddOnsSelectionViewRewards(
        query: rewardAddOnSelectionViewAddOnsQuery(withProjectSlug: slug)
      )
      .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
      .materialize()
    }

    let addOns = addOnsEvent.values()

    let shippingRule = Signal.merge(
      self.shippingRuleSelectedProperty.signal,
      reward.filter { reward in !reward.shipping.enabled }.mapConst(nil)
    )

    self.loadAddOnRewardsIntoDataSource = Signal.combineLatest(
      addOns,
      project,
      reward,
      shippingRule
    )
    .map(rewardsData)

    self.shippingLocationViewIsHidden = reward.map(\.shipping.enabled)
      .negate()
  }

  private let configureWithDataProperty = MutableProperty<(Project, Reward, RefTag?, PledgeViewContext)?>(nil)
  public func configureWith(project: Project, reward: Reward, refTag: RefTag?, context: PledgeViewContext) {
    self.configureWithDataProperty.value = (project, reward, refTag, context)
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let shippingRuleSelectedProperty = MutableProperty<ShippingRule?>(nil)
  public func shippingRuleSelected(_ shippingRule: ShippingRule) {
    self.shippingRuleSelectedProperty.value = shippingRule
  }

  public let configurePledgeShippingLocationViewControllerWithData:
    Signal<PledgeShippingLocationViewData, Never>
  public let loadAddOnRewardsIntoDataSource: Signal<[RewardAddOnCellData], Never>
  public let shippingLocationViewIsHidden: Signal<Bool, Never>

  public var inputs: RewardAddOnSelectionViewModelInputs { return self }
  public var outputs: RewardAddOnSelectionViewModelOutputs { return self }
}

// MARK: - Functions

private func rewardsData(
  from envelope: RewardAddOnSelectionViewEnvelope,
  with project: Project,
  baseReward: Reward,
  shippingRule: ShippingRule?
) -> [RewardAddOnCellData] {
  guard let addOnNodes = envelope.project.addOns?.nodes else { return [] }

  let filteredAddOns = addOns(
    addOnNodes,
    filteredBy: shippingRule,
    baseReward: baseReward
  )

  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "yyyy-MM-DD"

  return filteredAddOns.compactMap { addOn in
    Reward.addOnReward(
      from: addOn,
      project: project,
      selectedAddOnQuantities: [:],
      dateFormatter: dateFormatter
    )
  }
  .map { reward in .init(project: project, reward: reward, shippingRule: shippingRule) }
}

private func addOns(
  _ addOns: [RewardAddOnSelectionViewEnvelope.Project.Reward],
  filteredBy shippingRule: ShippingRule?,
  baseReward: Reward
) -> [RewardAddOnSelectionViewEnvelope.Project.Reward] {
  return addOns.filter { addOn in
    // For digital-only base rewards only return add-ons that are also digital-only.
    if baseReward.shipping.enabled == false {
      return addOn.shippingPreference == .noShipping
    }

    // For restricted shipping base rewards, unrestricted shipping or digital-only add-ons are available.
    let addOnIsDigitalOrUnrestricted = addOn.shippingPreference.isAny(of: .noShipping, .unrestricted)

    return addOnIsDigitalOrUnrestricted || addOnReward(addOn, shipsTo: shippingRule?.location.id)
  }
}

/**
 For base rewards that have restricted shipping, only return
 add-ons that can ship to the selected shipping location.
 */
private func addOnReward(
  _ addOn: RewardAddOnSelectionViewEnvelope.Project.Reward,
  shipsTo locationId: Int?
) -> Bool {
  guard let selectedLocationId = locationId else { return false }

  let addOnShippingLocationIds: Set<Int> = Set(
    addOn.shippingRules?.map(\.location).map(\.id).compactMap(decompose(id:)) ?? []
  )

  return addOnShippingLocationIds.contains(selectedLocationId)
}
