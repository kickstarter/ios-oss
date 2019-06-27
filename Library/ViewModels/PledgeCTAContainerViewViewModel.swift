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
  var rewardTitle: Signal<String, Never> { get }
  var spacerIsHidden: Signal<Bool, Never> { get }
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
    let project = projectAndUser.map(first)

    let pledgeState = project
      .map(pledgeStateButton(project:))

    let backingEvent = projectAndUser
      .switchMap { project, user in
        AppEnvironment.current.apiService.fetchBacking(forProject: project, forUser: user)
          .materialize()
      }
    let backing = backingEvent.values()
    let projectAndBacking = Signal.combineLatest(project, backing)
    let stackViewAndSpacerAreHidden = pledgeState.map { $0.stackViewAndSpacerAreHidden }

    self.buttonTitleText = pledgeState.map { $0.buttonTitle }
    self.buttonBackgroundColor = pledgeState.map { $0.buttonBackgroundColor }
    self.spacerIsHidden = stackViewAndSpacerAreHidden
    self.stackViewIsHidden = stackViewAndSpacerAreHidden

    self.rewardTitle = projectAndBacking
      .map { (project, backing) -> String in
        let basicPledge = formattedAmount(for: backing)
        let amount = Format.formattedCurrency(
          basicPledge,
          country: project.country,
          omitCurrencyCode: project.stats.omitUSCurrencyCode
        ).trimmed()
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
  public let rewardTitle: Signal<String, Never>
  public let spacerIsHidden: Signal<Bool, Never>
  public let stackViewIsHidden: Signal<Bool, Never>
}

// MARK: - Functions

private func pledgeStateButton(project: Project) -> PledgeStateCTAType {
  guard let projectIsBacked = project.personalization.isBacking else { return .viewRewards }
  switch project.state {
  case .live:
    return projectIsBacked ? .manage : .pledge
  case .canceled, .failed, .suspended, .successful:
    return projectIsBacked ? .viewBacking : .viewRewards
  default:
    return .viewRewards
  }
}

private func formattedAmount(for backing: Backing) -> String {
  let amount = backing.amount - Double(backing.shippingAmount ?? 0)
  let backingAmount = floor(amount) == amount
    ? String(Int(amount))
    : String(format: "%.2f", backing.amount)
  return backingAmount
}
