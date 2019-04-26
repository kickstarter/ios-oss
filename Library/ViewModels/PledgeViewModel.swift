import KsApi
import Foundation
import Prelude
import ReactiveSwift
import Result

public typealias PledgeTableViewData = (amount: Double, currency: String, isLoggedIn: Bool)

public protocol PledgeViewModelInputs {
  func configureWith(project: Project, reward: Reward)
  func viewDidLoad()
}

public protocol PledgeViewModelOutputs {
  var reloadWithData: Signal<PledgeTableViewData, NoError> { get }
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

    let isLoggedIn = projectAndReward
      .map { AppEnvironment.current.currentUser }
      .map(isNil)
      .negate()

    let amountAndCurrency = projectAndReward.signal
      .map { (project, reward) in
        (reward.minimum, currencySymbol(forCountry: project.country).trimmed())
    }

    self.reloadWithData = Signal.combineLatest(amountAndCurrency, isLoggedIn)
      .map(unpack)
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

  public var inputs: PledgeViewModelInputs { return self }
  public var outputs: PledgeViewModelOutputs { return self }
}
