import Foundation
import KsApi
import Prelude
import ReactiveSwift

public typealias PledgeViewData = (project: Project, reward: Reward)

public protocol PledgeViewModelInputs {
  func configureWith(project: Project, reward: Reward)
  func pledgeAmountDidUpdate(to amount: Double)
  func shippingRuleSelected(_ shippingRule: ShippingRule)
  func userSessionStarted()
  func viewDidLoad()
}

public protocol PledgeViewModelOutputs {
  var configureSummaryCellWithData: Signal<(Project, Double), Never> { get }
  var configureWithPledgeViewData: Signal<PledgeViewData, Never> { get }
  var continueViewHidden: Signal<Bool, Never> { get }
  var paymentMethodsViewHidden: Signal<Bool, Never> { get }
  var shippingLocationViewHidden: Signal<Bool, Never> { get }
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
    let isLoggedIn = Signal.merge(projectAndReward.ignoreValues(), self.userSessionStartedSignal)
      .map { _ in AppEnvironment.current.currentUser }
      .map(isNotNil)

    let pledgeAmount = Signal.merge(
      self.pledgeAmountSignal,
      projectAndReward.map { $1.minimum }
    )

    let initialShippingAmount = projectAndReward.mapConst(0.0)
    let shippingAmount = self.shippingRuleSelectedSignal
      .map { $0.cost }
    let shippingCost = Signal.merge(shippingAmount, initialShippingAmount)

    let pledgeTotal = Signal.combineLatest(pledgeAmount, shippingCost).map(+)

    self.configureWithPledgeViewData = projectAndReward
      .map { PledgeViewData(project: $0.0, reward: $0.1) }

    self.configureSummaryCellWithData = project
      .takePairWhen(pledgeTotal)
      .map { project, total in (project, total) }

    self.continueViewHidden = isLoggedIn
    self.paymentMethodsViewHidden = isLoggedIn.negate()
    self.shippingLocationViewHidden = reward
      .map { $0.shipping.enabled }
      .negate()
  }

  private let configureProjectAndRewardProperty = MutableProperty<(Project, Reward)?>(nil)
  public func configureWith(project: Project, reward: Reward) {
    self.configureProjectAndRewardProperty.value = (project, reward)
  }

  private let (pledgeAmountSignal, pledgeAmountObserver) = Signal<Double, Never>.pipe()
  public func pledgeAmountDidUpdate(to amount: Double) {
    self.pledgeAmountObserver.send(value: amount)
  }

  private let (shippingRuleSelectedSignal, shippingRuleSelectedObserver) = Signal<ShippingRule, Never>.pipe()
  public func shippingRuleSelected(_ shippingRule: ShippingRule) {
    self.shippingRuleSelectedObserver.send(value: shippingRule)
  }

  private let (userSessionStartedSignal, userSessionStartedObserver) = Signal<Void, Never>.pipe()
  public func userSessionStarted() {
    self.userSessionStartedObserver.send(value: ())
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let configureSummaryCellWithData: Signal<(Project, Double), Never>
  public let continueViewHidden: Signal<Bool, Never>
  public let configureWithPledgeViewData: Signal<PledgeViewData, Never>
  public let paymentMethodsViewHidden: Signal<Bool, Never>
  public let shippingLocationViewHidden: Signal<Bool, Never>

  public var inputs: PledgeViewModelInputs { return self }
  public var outputs: PledgeViewModelOutputs { return self }
}
