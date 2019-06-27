import Foundation
import KsApi
import Prelude
import ReactiveSwift

public typealias PledgeViewData = (
  project: Project,
  reward: Reward,
  isLoggedIn: Bool,
  isShippingEnabled: Bool,
  pledgeTotal: Double
)

public protocol PledgeViewModelInputs {
  func configureWith(project: Project, reward: Reward)
  func pledgeAmountDidUpdate(to amount: Double)
  func shippingRuleDidUpdate(to rule: ShippingRule)
  func viewDidLoad()
}

public protocol PledgeViewModelOutputs {
  var configureSummaryCellWithProjectAndPledgeTotal: Signal<(Project, Double), Never> { get }
  var pledgeViewDataAndReload: Signal<(PledgeViewData, Bool), Never> { get }
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
    let isLoggedIn = projectAndReward
      .map { _ in AppEnvironment.current.currentUser }
      .map(isNotNil)

    let shippingAmount = Signal.merge(
      self.shippingRuleSignal.map { $0.cost },
      projectAndReward.mapConst(0)
    )

    let pledgeAmount = Signal.merge(
      self.pledgeAmountSignal,
      projectAndReward.map { $1.minimum }
    )

    let total = Signal.combineLatest(pledgeAmount, shippingAmount).map(+)

    let data = Signal.combineLatest(project, reward, isLoggedIn, total)
      .map { project, reward, isLoggedIn, total -> PledgeViewData in
        (project, reward, isLoggedIn, reward.shipping.enabled, total)
      }

    self.pledgeViewDataAndReload = Signal.merge(
      data.take(first: 1).map { data in (data, true) },
      data.skip(first: 1).map { data in (data, false) }
    )

    self.configureSummaryCellWithProjectAndPledgeTotal = self.pledgeViewDataAndReload
      .filter(second >>> isFalse)
      .map(first)
      .map { ($0.project, $0.pledgeTotal) }
  }

  private let configureProjectAndRewardProperty = MutableProperty<(Project, Reward)?>(nil)
  public func configureWith(project: Project, reward: Reward) {
    self.configureProjectAndRewardProperty.value = (project, reward)
  }

  private let (pledgeAmountSignal, pledgeAmountObserver) = Signal<Double, Never>.pipe()
  public func pledgeAmountDidUpdate(to amount: Double) {
    self.pledgeAmountObserver.send(value: amount)
  }

  private let (shippingRuleSignal, shippingRuleObserver) = Signal<ShippingRule, Never>.pipe()
  public func shippingRuleDidUpdate(to rule: ShippingRule) {
    self.shippingRuleObserver.send(value: rule)
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let configureSummaryCellWithProjectAndPledgeTotal: Signal<(Project, Double), Never>
  public let pledgeViewDataAndReload: Signal<(PledgeViewData, Bool), Never>

  public var inputs: PledgeViewModelInputs { return self }
  public var outputs: PledgeViewModelOutputs { return self }
}
