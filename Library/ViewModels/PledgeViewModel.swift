import Foundation
import KsApi
import Prelude
import ReactiveSwift

public typealias PledgeTableViewData = (
  amount: Double,
  currencySymbol: String,
  estimatedDelivery: String,
  shippingLocation: String,
  shippingCost: Double,
  project: Project,
  isLoggedIn: Bool,
  requiresShippingRules: Bool
)

public typealias SelectedShippingRuleData = (location: String, shippingCost: Double, project: Project)

public protocol PledgeViewModelInputs {
  func configureWith(project: Project, reward: Reward)
  func didReloadData()
  func viewDidLoad()
}

public protocol PledgeViewModelOutputs {
  var reloadWithData: Signal<PledgeTableViewData, Never> { get }
  var selectedShippingRuleData: Signal<SelectedShippingRuleData, Never> { get }
  var shippingIsLoading: Signal<Bool, Never> { get }
  var shippingRulesError: Signal<String, Never> { get }
}

public protocol PledgeViewModelType {
  var inputs: PledgeViewModelInputs { get }
  var outputs: PledgeViewModelOutputs { get }
}

public class PledgeViewModel: PledgeViewModelType, PledgeViewModelInputs, PledgeViewModelOutputs {
  public init() {
    let projectAndReward = Signal.combineLatest(
      self.configureProjectAndRewardProperty.signal, self.viewDidLoadProperty.signal
    )
    .map(first)
    .skipNil()

    let project = projectAndReward.map(first)
    let reward = projectAndReward.map(second)

    let amountCurrencySymbolDeliveryShipping = projectAndReward.signal
      .map { project, reward in
        projectAndRewardData(project: project, reward: reward)
      }

    let isLoggedIn = projectAndReward
      .map { _ in AppEnvironment.current.currentUser }
      .map(isNotNil)

    let shouldLoadShippingRules = reward.map { $0.shipping.enabled }

    let pledgeViewData: Signal<PledgeTableViewData, Never> = Signal
      .combineLatest(project, amountCurrencySymbolDeliveryShipping, isLoggedIn, shouldLoadShippingRules)
      .map { project, amountCurrencySymbolDeliveryShipping, isLoggedIn, requiresShippingRules in
        let (amount, currencySymbol, estimatedDelivery, shippingLocation, shippingAmount)
          = amountCurrencySymbolDeliveryShipping

        return (
          amount,
          currencySymbol,
          estimatedDelivery,
          shippingLocation,
          shippingAmount,
          project,
          isLoggedIn,
          requiresShippingRules
        )
      }

    self.reloadWithData = pledgeViewData

    let shippingRulesEvent = projectAndReward
      .filter { _, reward in reward.shipping.enabled }
      .switchMap { (project, reward)
        -> SignalProducer<Signal<[ShippingRule], ErrorEnvelope>.Event, Never> in
        AppEnvironment.current.apiService.fetchRewardShippingRules(
          projectId: project.id,
          rewardId: reward.id
        )
        .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
        .map(ShippingRulesEnvelope.lens.shippingRules.view)
        .retry(upTo: 3)
        .materialize()
      }

    let defaultSelectedShippingRule = shippingRulesEvent.values()
      .map(defaultShippingRule(fromShippingRules:))

    self.selectedShippingRuleData = Signal.combineLatest(
      project,
      defaultSelectedShippingRule.skipNil(),
      self.didReloadDataProperty.signal
    )
    .map { project, shippingRule, _ -> SelectedShippingRuleData in
      (shippingRule.location.localizedName, shippingRule.cost, project)
    }

    let shippingShouldBeginLoading = shouldLoadShippingRules
      .filter(isTrue)

    let shippingIsLoading = Signal.merge(
      shippingShouldBeginLoading,
      shippingRulesEvent.filter { $0.isTerminating }.mapConst(false)
    )

    // Ensure that table view's reloadData has completed at least once before triggering loading events
    self.shippingIsLoading = Signal.combineLatest(self.didReloadDataProperty.signal, shippingIsLoading)
      .map(second)

    self.shippingRulesError = shippingRulesEvent.errors().map { _ in
      Strings.We_were_unable_to_load_the_shipping_destinations()
    }
  }

  private let configureProjectAndRewardProperty = MutableProperty<(Project, Reward)?>(nil)
  public func configureWith(project: Project, reward: Reward) {
    self.configureProjectAndRewardProperty.value = (project, reward)
  }

  private let didReloadDataProperty = MutableProperty<Void>(())
  public func didReloadData() {
    self.didReloadDataProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let reloadWithData: Signal<PledgeTableViewData, Never>
  public let selectedShippingRuleData: Signal<SelectedShippingRuleData, Never>
  public let shippingIsLoading: Signal<Bool, Never>
  public let shippingRulesError: Signal<String, Never>

  public var inputs: PledgeViewModelInputs { return self }
  public var outputs: PledgeViewModelOutputs { return self }
}

// MARK: - Functions

private func projectAndRewardData(project: Project, reward: Reward)
  -> (Double, String, String, String, Double) {
  let amount = reward.minimum
  let currency = currencySymbol(forCountry: project.country).trimmed()
  let estimatedDelivery = reward.estimatedDeliveryOn
    .map { Format.date(secondsInUTC: $0, template: "MMMMyyyy", timeZone: UTCTimeZone) } ?? ""
  let shippingLocation = ""
  let shippingAmount = 0.0

  return (amount, currency, estimatedDelivery, shippingLocation, shippingAmount)
}
