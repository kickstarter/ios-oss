import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol ManageViewPledgeViewModelInputs {
  func configureWith(_ project: Project, reward: Reward)
  func viewDidLoad()
}

public protocol ManageViewPledgeViewModelOutputs {
  var configurePaymentMethodView: Signal<Project, Never> { get }
  var configurePledgeSummaryView: Signal<Project, Never> { get }
  var configureRewardSummaryView: Signal<Reward, Never> { get }
  var title: Signal<String, Never> { get }
}

public protocol ManageViewPledgeViewModelType {
  var inputs: ManageViewPledgeViewModelInputs { get }
  var outputs: ManageViewPledgeViewModelOutputs { get }
}

public final class ManageViewPledgeViewModel:
  ManageViewPledgeViewModelType, ManageViewPledgeViewModelInputs, ManageViewPledgeViewModelOutputs {

  public init() {

    let projectAndReward = self.projectAndRewardSignal
      .takeWhen(self.viewDidLoadSignal.ignoreValues())

    self.title = projectAndReward
      .map(first)
      .map(title(with:))

    self.configurePaymentMethodView = projectAndReward
      .map(first)

    self.configurePledgeSummaryView = projectAndReward
      .map(first)

    self.configureRewardSummaryView = projectAndReward
      .map(second)
  }

  private let (projectAndRewardSignal, projectAndRewardObserver) = Signal<(Project, Reward), Never>.pipe()
  public func configureWith(_ project: Project, reward: Reward) {
    self.projectAndRewardObserver.send(value: (project, reward))
  }

  private let (viewDidLoadSignal, viewDidLoadObserver) = Signal<(), Never>.pipe()
  public func viewDidLoad() {
    self.viewDidLoadObserver.send(value: ())
  }

  public let configurePaymentMethodView: Signal<Project, Never>
  public let configurePledgeSummaryView: Signal<Project, Never>
  public let configureRewardSummaryView: Signal<Reward, Never>
  public let title: Signal<String, Never>

  public var inputs: ManageViewPledgeViewModelInputs { return self }
  public var outputs: ManageViewPledgeViewModelOutputs { return self }
}

private func title(with project: Project) -> String {
  return project.state == .live ? Strings.Manage_your_pledge() : Strings.View_your_pledge()
}
