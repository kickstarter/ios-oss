import KsApi
import Foundation
import Prelude
import ReactiveSwift
import Result

public protocol PledgeViewModelInputs {
  func configure(with reward: Reward)
  func viewDidLoad()
}

public protocol PledgeViewModelOutputs {
  var reward: Signal<Reward, NoError> { get }
}

public protocol PledgeViewModelType {
  var inputs: PledgeViewModelInputs { get }
  var outputs: PledgeViewModelOutputs { get }
}

public class PledgeViewModel: PledgeViewModelType, PledgeViewModelInputs, PledgeViewModelOutputs {
  public init() {
    let reward = self.configureRewardProperty.signal
      .skipNil()

    self.reward = Signal.combineLatest(reward.signal, self.viewDidLoadProperty.signal)
      .map(first)
  }

  private let configureRewardProperty = MutableProperty<Reward?>(nil)
  public func configure(with reward: Reward) {
    self.configureRewardProperty.value = reward
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let reward: Signal<Reward, NoError>

  public var inputs: PledgeViewModelInputs { return self }
  public var outputs: PledgeViewModelOutputs { return self }
}
