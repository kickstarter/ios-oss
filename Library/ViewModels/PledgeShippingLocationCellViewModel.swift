import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol PledgeShippingLocationCellViewModelInputs {
  func configureWith(project: Project, reward: Reward)
}

public protocol PledgeShippingLocationCellViewModelOutputs {
  var amount: Signal<NSAttributedString, Never> { get }
  var location: Signal<String, Never> { get }
  var selectedShippingRule: Signal<ShippingRule, Never> { get }
  var shippingIsLoading: Signal<Bool, Never> { get }
  var shippingRulesError: Signal<String, Never> { get }
}

public protocol PledgeShippingLocationCellViewModelType {
  var inputs: PledgeShippingLocationCellViewModelInputs { get }
  var outputs: PledgeShippingLocationCellViewModelOutputs { get }
}

public final class PledgeShippingLocationCellViewModel: PledgeShippingLocationCellViewModelType,
  PledgeShippingLocationCellViewModelInputs, PledgeShippingLocationCellViewModelOutputs {
  public init() {
    let project = self.projectAndRewardProperty.signal.skipNil().map(first)
    let reward = self.projectAndRewardProperty.signal.skipNil().map(second)

    let shouldLoadShippingRules = reward.map { $0.shipping.enabled }

    let shippingRulesEvent = self.projectAndRewardProperty.signal
      .skipNil()
      .filter { _, reward in reward.shipping.enabled }
      .switchMap { (project, reward) -> SignalProducer<Signal<[ShippingRule], ErrorEnvelope>.Event, Never> in
        AppEnvironment.current.apiService.fetchRewardShippingRules(projectId: project.id, rewardId: reward.id)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .map(ShippingRulesEnvelope.lens.shippingRules.view)
          .retry(upTo: 3)
          .materialize()
      }

    let defaultSelectedShippingRule = shippingRulesEvent.values()
      .map(defaultShippingRule(fromShippingRules:))
      .skipNil()

    let amount = Signal.combineLatest(project, defaultSelectedShippingRule)

    self.selectedShippingRule = amount.map { _, shippingRule in shippingRule }

    self.amount = amount
      .map { project, shippingRule in shippingValue(of: project, with: shippingRule.cost) }
      .skipNil()

    self.location = defaultSelectedShippingRule
      .map { $0.location.localizedName }

    let shippingShouldBeginLoading = shouldLoadShippingRules
      .filter(isTrue)

    self.shippingIsLoading = Signal.merge(
      shippingShouldBeginLoading,
      shippingRulesEvent.filter { $0.isTerminating }.mapConst(false)
    )

    self.shippingRulesError = shippingRulesEvent.errors().map { _ in
      Strings.We_were_unable_to_load_the_shipping_destinations()
    }
  }

  private let projectAndRewardProperty = MutableProperty<(Project, Reward)?>(nil)
  public func configureWith(project: Project, reward: Reward) {
    self.projectAndRewardProperty.value = (project, reward)
  }

  public let amount: Signal<NSAttributedString, Never>
  public let location: Signal<String, Never>
  public let selectedShippingRule: Signal<ShippingRule, Never>
  public let shippingIsLoading: Signal<Bool, Never>
  public let shippingRulesError: Signal<String, Never>

  public var inputs: PledgeShippingLocationCellViewModelInputs { return self }
  public var outputs: PledgeShippingLocationCellViewModelOutputs { return self }
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
