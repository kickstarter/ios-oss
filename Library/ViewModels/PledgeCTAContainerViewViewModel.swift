import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol PledgeCTAContainerViewViewModelInputs {
  func configureWith(project: Project, user: User)
}

public protocol PledgeCTAContainerViewViewModelOutputs {
  var buttonBackgroundColor: Signal<UIColor, Never> { get }
  var buttonTitleText: Signal<String, Never> { get }
  var buttonTitleTextColor: Signal<UIColor, Never> { get }
  var rewardTitle: Signal<String, Never> { get }
  var stackViewIsHidden: Signal<Bool, Never> { get }
  var subtitleText: Signal<String, Never> { get }
}

public protocol PledgeCTAContainerViewViewModelType {
  var inputs: PledgeCTAContainerViewViewModelInputs { get }
  var outputs: PledgeCTAContainerViewViewModelOutputs { get }
}

public final class PledgeCTAContainerViewViewModel: PledgeCTAContainerViewViewModelType,
  PledgeCTAContainerViewViewModelInputs, PledgeCTAContainerViewViewModelOutputs {
  public init() {
    let projectAndUser = self.projectAndUserProperty.signal.skipNil()

    let backingEvent = projectAndUser
      .switchMap { project, user in
        AppEnvironment.current.apiService.fetchBacking(forProject: project, forUser: user)
          .materialize()
    }

    let backing = backingEvent.values()
    let project = projectAndUser.map { $0.0 }
    let projectAndBacking = Signal.combineLatest(project, backing)

    let projectState = projectAndBacking
      .map { project, backing in projectStateButton(project: project, backing: backing) }

    self.buttonTitleText = projectState.map { $0.buttonTitle }
    self.buttonBackgroundColor = projectState.map { $0.buttonBackgroundColor }
    self.stackViewIsHidden = projectState.map { $0.stackViewIsHidden }
    self.buttonTitleTextColor = projectState.map { $0.buttonTitleTextColor }
    self.subtitleText = projectState.map { $0.subtitleLabel }.skipNil()

    self.rewardTitle = projectAndBacking
      .map { (arg) -> String in

        let (project, backing) = arg
        let basicPledge = formattedAmount(for: backing)
        let amount = Format.formattedCurrency(
          basicPledge,
          country: project.country,
          omitCurrencyCode: project.stats.omitUSCurrencyCode
        )

        if backing.status == .errored {
          return "We couldn't process your pledge"
        }

        guard let rewardTitle = backing.reward?.title else { return "\(amount)" }
        return "\(amount) • \(rewardTitle)"
      }
  }

  fileprivate let projectAndUserProperty = MutableProperty<(Project, User)?>(nil)
  public func configureWith(project: Project, user: User) {
    self.projectAndUserProperty.value = (project, user)
  }

  public var inputs: PledgeCTAContainerViewViewModelInputs { return self }
  public var outputs: PledgeCTAContainerViewViewModelOutputs { return self }

  public let buttonBackgroundColor: Signal<UIColor, Never>
  public let buttonTitleText: Signal<String, Never>
  public let buttonTitleTextColor: Signal<UIColor, Never>
  public let rewardTitle: Signal<String, Never>
  public let stackViewIsHidden: Signal<Bool, Never>
  public let subtitleText: Signal<String, Never>
}

private func projectStateButton(project: Project, backing: Backing) -> PledgeStateCTAType {
  guard let projectIsBacked = project.personalization.isBacking
  else { return PledgeStateCTAType.viewRewards }

  switch project.state {
  case .live:
    let pledgeFailed = backing.status == .errored
    return (projectIsBacked && pledgeFailed) ? PledgeStateCTAType.fix : PledgeStateCTAType.pledge
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
