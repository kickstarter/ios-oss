import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol PledgeShippingLocationViewModelInputs {
  func configureWith(project: Project, reward: Reward)
  func shippingLocationButtonTapped()
  func shippingRulesCancelButtonTapped()
  func shippingRuleUpdated(to rule: ShippingRule)
  func viewDidLoad()
}

public protocol PledgeShippingLocationViewModelOutputs {
  var adaptableStackViewIsHidden: Signal<Bool, Never> { get }
  var amountAttributedText: Signal<NSAttributedString, Never> { get }
  var dismissShippingRules: Signal<Void, Never> { get }
  var presentShippingRules: Signal<(Project, [ShippingRule], ShippingRule), Never> { get }
  var notifyDelegateOfSelectedShippingRule: Signal<ShippingRule, Never> { get }
  var shimmerLoadingViewIsHidden: Signal<Bool, Never> { get }
  var shippingLocationButtonTitle: Signal<String, Never> { get }
  var shippingRulesError: Signal<String, Never> { get }
}

public protocol PledgeShippingLocationViewModelType {
  var inputs: PledgeShippingLocationViewModelInputs { get }
  var outputs: PledgeShippingLocationViewModelOutputs { get }
}

public final class PledgeShippingLocationViewModel: PledgeShippingLocationViewModelType,
  PledgeShippingLocationViewModelInputs, PledgeShippingLocationViewModelOutputs {
  public init() {
    let projectAndReward = Signal.combineLatest(
      self.configDataProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    )
    .map(first)

    let project = projectAndReward
      .map(first)
    let reward = projectAndReward
      .map(second)

    let shippingShouldBeginLoading = reward
      .map { $0.shipping.enabled }

    let shippingRulesEvent = projectAndReward
      .filter { _, reward in reward.shipping.enabled }
      .switchMap { (project, reward) -> SignalProducer<Signal<[ShippingRule], ErrorEnvelope>.Event, Never> in
        AppEnvironment.current.apiService.fetchRewardShippingRules(projectId: project.id, rewardId: reward.id)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .map(ShippingRulesEnvelope.lens.shippingRules.view)
          .retry(upTo: 3)
          .materialize()
      }

    let shippingRulesLoadingCompleted = shippingRulesEvent
      .filter { $0.isTerminating }
      .mapConst(false)
      .ksr_debounce(.seconds(1), on: AppEnvironment.current.scheduler)

    let isLoading = Signal.merge(
      shippingShouldBeginLoading,
      shippingRulesLoadingCompleted
    )

    self.adaptableStackViewIsHidden = isLoading
    self.shimmerLoadingViewIsHidden = isLoading.negate()

    let shippingRules = shippingRulesEvent.values()

    let initialShippingRule = Signal.combineLatest(
      project,
      shippingRules
    )
    .map(determineShippingRule(with:shippingRules:))

    self.shippingRulesError = shippingRulesEvent.errors().map { _ in
      Strings.We_were_unable_to_load_the_shipping_destinations()
    }

    self.notifyDelegateOfSelectedShippingRule = Signal.merge(
      initialShippingRule.skipNil(),
      self.shippingRuleUpdatedSignal
    )

    let shippingAmount = Signal.merge(
      self.notifyDelegateOfSelectedShippingRule.map { $0.cost },
      projectAndReward.mapConst(0)
    )

    self.presentShippingRules = Signal.combineLatest(
      project,
      shippingRulesEvent.values(),
      self.notifyDelegateOfSelectedShippingRule
    )
    .takeWhen(self.shippingLocationButtonTappedSignal)

    self.amountAttributedText = Signal.combineLatest(project, shippingAmount)
      .map { project, shippingAmount in shippingValue(of: project, with: shippingAmount) }
      .skipNil()

    self.shippingLocationButtonTitle = self.notifyDelegateOfSelectedShippingRule
      .map { $0.location.localizedName }

    self.dismissShippingRules = Signal.merge(
      self.shippingRulesCancelButtonTappedProperty.signal,
      self.shippingRuleUpdatedSignal.signal
        .ignoreValues()
        .ksr_debounce(.milliseconds(300), on: AppEnvironment.current.scheduler)
    )
  }

  private let configDataProperty = MutableProperty<(Project, Reward)?>(nil)
  public func configureWith(project: Project, reward: Reward) {
    self.configDataProperty.value = (project, reward)
  }

  private let (shippingLocationButtonTappedSignal, shippingLocationButtonTappedObserver)
    = Signal<Void, Never>.pipe()
  public func shippingLocationButtonTapped() {
    self.shippingLocationButtonTappedObserver.send(value: ())
  }

  private let shippingRulesCancelButtonTappedProperty = MutableProperty(())
  public func shippingRulesCancelButtonTapped() {
    self.shippingRulesCancelButtonTappedProperty.value = ()
  }

  private let (shippingRuleUpdatedSignal, shippingRuleUpdatedObserver) = Signal<ShippingRule, Never>.pipe()
  public func shippingRuleUpdated(to rule: ShippingRule) {
    self.shippingRuleUpdatedObserver.send(value: rule)
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let adaptableStackViewIsHidden: Signal<Bool, Never>
  public let amountAttributedText: Signal<NSAttributedString, Never>
  public let dismissShippingRules: Signal<Void, Never>
  public let presentShippingRules: Signal<(Project, [ShippingRule], ShippingRule), Never>
  public let notifyDelegateOfSelectedShippingRule: Signal<ShippingRule, Never>
  public let shimmerLoadingViewIsHidden: Signal<Bool, Never>
  public let shippingLocationButtonTitle: Signal<String, Never>
  public let shippingRulesError: Signal<String, Never>

  public var inputs: PledgeShippingLocationViewModelInputs { return self }
  public var outputs: PledgeShippingLocationViewModelOutputs { return self }
}

// MARK: - Functions

private func shippingValue(of project: Project, with shippingRuleCost: Double) -> NSAttributedString? {
  let defaultAttributes = checkoutCurrencyDefaultAttributes()
  let superscriptAttributes = checkoutCurrencySuperscriptAttributes()
  guard
    let attributedCurrency = Format.attributedCurrency(
      shippingRuleCost,
      country: project.country,
      omitCurrencyCode: project.stats.omitUSCurrencyCode,
      defaultAttributes: defaultAttributes,
      superscriptAttributes: superscriptAttributes
    ) else { return nil }

  let combinedAttributes = defaultAttributes.merging(superscriptAttributes) { _, new in new }

  return Format.attributedPlusSign(combinedAttributes) + attributedCurrency
}

private func determineShippingRule(with project: Project, shippingRules: [ShippingRule]) -> ShippingRule? {
  guard
    let backing = project.personalization.backing,
    let selectedRule = shippingRules.filter({ $0.location.id == backing.locationId }).first
  else { return defaultShippingRule(fromShippingRules: shippingRules) }

  return selectedRule
}
