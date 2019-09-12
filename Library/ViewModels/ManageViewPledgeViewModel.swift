import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol ManageViewPledgeViewModelInputs {
  func configureWith(_ project: Project, reward: Reward)
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

    self.title = self.projectAndRewardSignal
      .map(first)
      .map(title(with:))

    self.configurePaymentMethodView = self.projectAndRewardSignal
      .map(first)

    self.configurePledgeSummaryView = self.projectAndRewardSignal
      .map(first)

    self.configureRewardSummaryView = self.projectAndRewardSignal
      .map(second)
  }

  private let (projectAndRewardSignal, projectAndRewardObserver) = Signal<(Project, Reward), Never>.pipe()
  public func configureWith(_ project: Project, reward: Reward) {
    self.projectAndRewardObserver.send(value: (project, reward))
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
