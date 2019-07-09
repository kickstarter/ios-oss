import Foundation
import KsApi
import Prelude
import ReactiveSwift

public typealias PledgeViewShippingRulesData = (
  isEnabled: Bool,
  isLoading: Bool,
  selectedRule: ShippingRule?
)

public typealias PledgeViewData = (
  project: Project,
  reward: Reward,
  isLoggedIn: Bool,
  shipping: PledgeViewShippingRulesData,
  pledgeTotal: Double
)

public protocol PledgeViewModelInputs {
  func configureWith(project: Project, reward: Reward)
  func pledgeAmountDidUpdate(to amount: Double)
  func pledgeShippingCellWillPresentShippingRules(with rule: ShippingRule)
  func shippingRuleDidUpdate(to rule: ShippingRule)
  func viewDidLoad()
}

public protocol PledgeViewModelOutputs {
  var configureShippingLocationCellWithData: Signal<(Bool, Project, ShippingRule?), Never> { get }
  var configureSummaryCellWithData: Signal<(Project, Double), Never> { get }

  /**
   Emits the initial data for this view model along with a `Bool` indicating whether the table view should
   be reloaded (currently only the first time but probably during login as well). Every time any of the
   combined data of `PledgeViewData` changes, this signal will emit all of its data in order to ensure that
   the data source has the current state of the data that the cells have. This ensures that if a cell is
   recycled it will be reloaded with its most recent data.
   */
  var pledgeViewDataAndReload: Signal<(PledgeViewData, Bool), Never> { get }
  var presentShippingRules: Signal<(Project, [ShippingRule], ShippingRule), Never> { get }
  var shippingRulesError: Signal<String, Never> { get }
}

public protocol PledgeViewModelType {
  var inputs: PledgeViewModelInputs { get }
  var outputs: PledgeViewModelOutputs { get }
}

public class PledgeViewModel: PledgeViewModelType, PledgeViewModelInputs, PledgeViewModelOutputs {
  public init() {
    let projectAndReward = Signal.combineLatest(
      self.configureProjectAndRewardProperty.signal,
      self.viewDidLoadProperty.signal
    )
    .map(first)
    .skipNil()

    let project = projectAndReward.map(first)
    let reward = projectAndReward.map(second)
    let isLoggedIn = projectAndReward.map { _ in AppEnvironment.current.currentUser }.map(isNotNil)

    let pledgeAmount = Signal.merge(
      self.pledgeAmountSignal,
      projectAndReward.map { $1.minimum }
    )

    let shippingRulesEvent = projectAndReward
      .filter { _, reward in reward.shipping.enabled }
      .switchMap { (project, reward) -> SignalProducer<Signal<[ShippingRule], ErrorEnvelope>.Event, Never> in
        AppEnvironment.current.apiService.fetchRewardShippingRules(projectId: project.id, rewardId: reward.id)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .map(ShippingRulesEnvelope.lens.shippingRules.view)
          .retry(upTo: 3)
          .prefix(value: [])
          .materialize()
      }

    let defaultShippingRule = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(nil),
      shippingRulesEvent.values().map(defaultShippingRule(fromShippingRules:))
    )

    self.presentShippingRules = Signal.combineLatest(
      project,
      shippingRulesEvent.values(),
      defaultShippingRule.skipNil()
    )
    .takeWhen(self.pledgeShippingCellWillPresentShippingRulesProperty.signal)

    let shippingAmount = Signal.merge(
      defaultShippingRule.skipNil().map { $0.cost },
      self.selectedShippingRuleSignal.map { $0.cost },
      projectAndReward.mapConst(0)
    )

    let shippingShouldBeginLoading = reward
      .map { $0.shipping.enabled }

    let isShippingLoading = Signal.merge(
      shippingShouldBeginLoading,
      shippingRulesEvent.filter { $0.isTerminating }.mapConst(false)
    )

    self.shippingRulesError = shippingRulesEvent.errors().map { _ in
      Strings.We_were_unable_to_load_the_shipping_destinations()
    }

    let pledgeTotal = Signal.combineLatest(pledgeAmount, shippingAmount).map(+)

    let data = Signal
      .combineLatest(project, reward, isLoggedIn, isShippingLoading, defaultShippingRule, pledgeTotal)
      .map(pledgeViewData(with:reward:isLoggedIn:isShippingLoading:selectedShippingRule:pledgeTotal:))

    self.pledgeViewDataAndReload = Signal.merge(
      data.take(first: 1).map { data in (data, true) },
      data.skip(first: 1).map { data in (data, false) }
    )

    let updatedData = self.pledgeViewDataAndReload
      .filter(second >>> isFalse)
      .map(first)

    self.configureSummaryCellWithData = updatedData
      .takePairWhen(pledgeTotal)
      .map { data, total in (data.project, total) }

    let isShippingLoadingAndSelectedShippingRule = Signal.combineLatest(
      isShippingLoading,
      defaultShippingRule
    )

    self.configureShippingLocationCellWithData = updatedData
      .takePairWhen(isShippingLoadingAndSelectedShippingRule)
      .map(unpack)
      .map { data, isShippingLoading, selectedShippingRule in
        (isShippingLoading, data.project, selectedShippingRule)
      }
  }

  private let configureProjectAndRewardProperty = MutableProperty<(Project, Reward)?>(nil)
  public func configureWith(project: Project, reward: Reward) {
    self.configureProjectAndRewardProperty.value = (project, reward)
  }

  private let (pledgeAmountSignal, pledgeAmountObserver) = Signal<Double, Never>.pipe()
  public func pledgeAmountDidUpdate(to amount: Double) {
    self.pledgeAmountObserver.send(value: amount)
  }

  private let pledgeShippingCellWillPresentShippingRulesProperty = MutableProperty<(ShippingRule)?>(nil)
  public func pledgeShippingCellWillPresentShippingRules(with rule: ShippingRule) {
    self.pledgeShippingCellWillPresentShippingRulesProperty.value = rule
  }

  private let (selectedShippingRuleSignal, shippingRuleObserver) = Signal<ShippingRule, Never>.pipe()
  public func shippingRuleDidUpdate(to rule: ShippingRule) {
    self.shippingRuleObserver.send(value: rule)
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let configureShippingLocationCellWithData: Signal<(Bool, Project, ShippingRule?), Never>
  public let configureSummaryCellWithData: Signal<(Project, Double), Never>
  public let pledgeViewDataAndReload: Signal<(PledgeViewData, Bool), Never>
  public let presentShippingRules: Signal<(Project, [ShippingRule], ShippingRule), Never>
  public let shippingRulesError: Signal<String, Never>

  public var inputs: PledgeViewModelInputs { return self }
  public var outputs: PledgeViewModelOutputs { return self }
}

// MARK: - Functions

private func pledgeViewData(
  with project: Project,
  reward: Reward,
  isLoggedIn: Bool,
  isShippingLoading: Bool,
  selectedShippingRule: ShippingRule?,
  pledgeTotal: Double
) -> PledgeViewData {
  return (
    project,
    reward,
    isLoggedIn,
    pledgeViewShippingRulesData(
      with: reward.shipping.enabled,
      isShippingLoading: isShippingLoading,
      selectedShippingRule: selectedShippingRule
    ),
    pledgeTotal
  )
}

private func pledgeViewShippingRulesData(
  with isShippingEnabled: Bool,
  isShippingLoading: Bool,
  selectedShippingRule: ShippingRule?
) -> PledgeViewShippingRulesData {
  return (isShippingEnabled, isShippingLoading, selectedShippingRule)
}
