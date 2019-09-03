import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol ManagePledgeViewModelInputs {
  func configureWith(_ project: Project, reward: Reward)
}

public protocol ManagePledgeViewModelOutputs {
}

public protocol ManagePledgeViewModelType {
  var inputs: ManagePledgeViewModelInputs { get }
  var outputs: ManagePledgeViewModelOutputs { get }
}

public final class ManagePledgeViewModel:
ManagePledgeViewModelType, ManagePledgeViewModelInputs, ManagePledgeViewModelOutputs {

  public init() {

  }

  private let projectAndReward = MutableProperty<(Project, Reward)?>(nil)
  public func configureWith(_ project: Project, reward: Reward) {
    self.projectAndReward.value = (project, reward)
  }

  public var inputs: ManagePledgeViewModelInputs { return self }
  public var outputs: ManagePledgeViewModelOutputs { return self }
}
