import KsApi
import Foundation
import Prelude
import ReactiveSwift
import Result

public typealias PledgeTableViewData = (amount: Double, currency: String, delivery: String, isLoggedIn: Bool,
  requiresShippingRules: Bool)

public protocol PledgeViewModelInputs {
  func configureWith(project: Project, reward: Reward)
  func viewDidLoad()
}

public protocol PledgeViewModelOutputs {
  var reloadWithData: Signal<PledgeTableViewData, NoError> { get }
  var selectedShippingRule: Signal<ShippingRule, NoError> { get }
  var shippingIsLoading: Signal<Bool, NoError> { get }
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

    let reward = projectAndReward.map(second)

    let amountCurrencyDelivery = projectAndReward.signal
      .map { (project, reward) in
        (reward.minimum,
         currencySymbol(forCountry: project.country).trimmed(),
         reward.estimatedDeliveryOn
          .map { Format.date(secondsInUTC: $0, template: "MMMMyyyy", timeZone: UTCTimeZone) } ?? "") }

    let isLoggedIn = projectAndReward
      .map { _ in AppEnvironment.current.currentUser }
      .map(isNotNil)

    let shouldLoadShippingRules = reward.map { $0.shipping.enabled }

    let pledgeViewData: Signal<PledgeTableViewData, NoError> = Signal.combineLatest(amountCurrencyDelivery, isLoggedIn, shouldLoadShippingRules)
      .map { amountCurrencyDelivery, isLoggedIn, requiresShippingRules in
        let (amount, currency, delivery) = amountCurrencyDelivery

        return (amount, currency, delivery, isLoggedIn, requiresShippingRules)
    }

    self.reloadWithData = pledgeViewData.logEvents(identifier: "**RELOAD WITH DATA**")

    // Shipping Rules network request should begin as a soon as `reloadWithData` has fired
    // Reminder that `reloadWithData` populates the table view
    let shippingRulesEvent = self.reloadWithData
      .flatMap { _ in projectAndReward }
//      .takeWhen(pledgeViewData.ignoreValues())
      .logEvents(identifier: "**SHIPPING RULES FIRING**")
      .filter { _, reward in reward.shipping.enabled }
      .switchMap { (project, reward)
        -> SignalProducer<Signal<[ShippingRule], ErrorEnvelope>.Event, NoError> in
        return AppEnvironment.current.apiService.fetchRewardShippingRules(projectId: project.id,
                                                                          rewardId: reward.id)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .map(ShippingRulesEnvelope.lens.shippingRules.view)
          .retry(upTo: 3)
          .materialize()
      }.logEvents(identifier: "**SHIPPING RULES EVENT**")

    shippingRulesEvent.observeValues { _ in
      print("**HERE**")
    }

    let defaultShippingRule = shippingRulesEvent.values()
      .map(defaultShippingRule(fromShippingRules:))

    self.selectedShippingRule = defaultShippingRule.skipNil()

    let shippingShouldBeginLoading = pledgeViewData.signal
      .map { $0.requiresShippingRules }
      .filter(isTrue)
      .logEvents(identifier: "**SHIPPING SHOULD BEGIN LOADING**")

    self.shippingIsLoading = Signal.merge(shippingShouldBeginLoading,
                                          shippingRulesEvent.filter { $0.isTerminating }.mapConst(false))
  }

  private let configureProjectAndRewardProperty = MutableProperty<(Project, Reward)?>(nil)
  public func configureWith(project: Project, reward: Reward) {
    self.configureProjectAndRewardProperty.value = (project, reward)
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let reloadWithData: Signal<PledgeTableViewData, NoError>
  public let selectedShippingRule: Signal<ShippingRule, NoError>
  public let shippingIsLoading: Signal<Bool, NoError>

  public var inputs: PledgeViewModelInputs { return self }
  public var outputs: PledgeViewModelOutputs { return self }
}
