import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions

public protocol PledgeCTAContainerViewViewModelInputs {
  func configureWith(project: Project, user: User)
}

public protocol PledgeCTAContainerViewViewModelOutputs {
  var buttonBackgroundColor: Signal<UIColor, Never> { get }
  var buttonTitleText: Signal<String, Never> { get }
  var rewardTitle: Signal<String, Never> { get }
  var stackViewIsHidden: Signal<Bool, Never> { get }
}

public protocol PledgeCTAContainerViewViewModelType {
  var inputs: PledgeCTAContainerViewViewModelInputs { get }
  var outputs: PledgeCTAContainerViewViewModelOutputs { get }
}

public final class PledgeCTAContainerViewViewModel: PledgeCTAContainerViewViewModelType,
  PledgeCTAContainerViewViewModelInputs, PledgeCTAContainerViewViewModelOutputs {

  public init() {
    let projectAndUser = self.projectAndUserProperty.signal.skipNil()

    let projectState = projectAndUser
      .map { project, user in projectStateButton(backer: user, project: project) }

    let backingEvent = projectAndUser
      .switchMap { project, user in
        AppEnvironment.current.apiService.fetchBacking(forProject: project, forUser: user)
        .materialize()
    }

    let backing = backingEvent.values()
    let project = projectAndUser.map { $0.0 }
    let projectAndBacking = Signal.combineLatest(project, backing)

    self.buttonTitleText = projectState.map { $0.buttonTitle }
    self.buttonBackgroundColor = projectState.map { $0.buttonBackgroundColor }
    self.stackViewIsHidden = projectState.map { $0.stackViewIsHidden }

    self.rewardTitle = projectAndBacking
      .map { (arg) -> String in

        let (project, backing) = arg
        let basicPledge = formattedAmount(for: backing)
        let amount = Format.formattedCurrency(
          basicPledge,
          country: project.country,
          omitCurrencyCode: project.stats.omitUSCurrencyCode
        )
        guard let rewardTitle = backing.reward?.title else { return "\(amount)" }
        return "\(amount) • \(rewardTitle)" }
  }

  fileprivate let projectAndUserProperty = MutableProperty<(Project, User)?>(nil)
  public func configureWith(project: Project, user: User) {
    self.projectAndUserProperty.value = (project, user)
  }

  public var inputs: PledgeCTAContainerViewViewModelInputs { return self }
  public var outputs: PledgeCTAContainerViewViewModelOutputs { return self }

  public let buttonTitleText: Signal<String, Never>
  public let buttonBackgroundColor: Signal<UIColor, Never>
  public let stackViewIsHidden: Signal<Bool, Never>
  public let rewardTitle: Signal<String, Never>
}

private func projectStateButton(backer: User, project: Project) -> PledgeStateCTAType {
  guard let projectIsBacked = project.personalization.isBacking
    else { return PledgeStateCTAType.viewRewards }

  switch project.state {
  case .live:
    return projectIsBacked ? PledgeStateCTAType.manage : PledgeStateCTAType.pledge
  case .canceled, .failed, .suspended, .successful:
    return projectIsBacked ? PledgeStateCTAType.viewBacking : PledgeStateCTAType.viewRewards
  default:
    return PledgeStateCTAType.viewRewards
  }
}

private func formattedAmount(for backing: Backing) -> String {
  let amount = backing.amount - Double(backing.shippingAmount ?? 0)
  let backingAmount = floor(amount) == amount
    ? String(Int(amount))
    : String(format: "%.2f", backing.amount)
  return backingAmount
}
