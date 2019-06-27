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
  var subtitleText: Signal<String, Never> { get }
  var stackViewIsHidden: Signal<Bool, Never> { get }
  var titleText: Signal<String, Never> { get }
}

public protocol PledgeCTAContainerViewViewModelType {
  var inputs: PledgeCTAContainerViewViewModelInputs { get }
  var outputs: PledgeCTAContainerViewViewModelOutputs { get }
}

public final class PledgeCTAContainerViewViewModel: PledgeCTAContainerViewViewModelType,
PledgeCTAContainerViewViewModelInputs, PledgeCTAContainerViewViewModelOutputs {
  public init() {
    let projectAndUser = self.projectAndUserProperty.signal.skipNil()
    let project = projectAndUser.map { $0.0 }

    let backingEvent = projectAndUser
      .switchMap { project, user in
        AppEnvironment.current.apiService.fetchBacking(forProject: project, forUser: user)
          .materialize()
    }

    let backing = backingEvent.values()
    let projectAndBacking = Signal.combineLatest(project, backing)

    let projectIsBacking = projectAndBacking.map(pledgeCTA(project:backing:))

    let projectIsNotBacking = project.map(pledgeStateButton(project:))

    let pledgeState = Signal.merge(projectIsBacking, projectIsNotBacking)

    self.buttonTitleText = pledgeState.map { $0.buttonTitle }
    self.buttonTitleTextColor = pledgeState.map { $0.buttonTitleTextColor }
    self.buttonBackgroundColor = pledgeState.map { $0.buttonBackgroundColor }
    self.stackViewIsHidden = pledgeState.map { $0.stackViewIsHidden }
    self.titleText = pledgeState.map { $0.titleLabel }.skipNil()

    let text = Signal.combineLatest(project, backing, pledgeState)
    self.subtitleText = text.map(subtitle(project:backing:pledgeState:))
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
  public let subtitleText: Signal<String, Never>
  public let stackViewIsHidden: Signal<Bool, Never>
  public let titleText: Signal<String, Never>
}

private func pledgeCTA(project: Project, backing: Backing) -> PledgeStateCTAType {
  switch (project.state, backing.status) {
  case (.live, .errored):
    return .fix
  case (.live, _):
    return .manage
  case (_, _):
    return .viewBacking
  default:
    return .viewBacking
  }

//  if backing.status == .errored { return PledgeStateCTAType.fix }
//  else { return PledgeStateCTAType.manage }
}

private func pledgeStateButton(project: Project) -> PledgeStateCTAType {
  switch project.state {
  case .live:
    return .pledge
  case .canceled, .failed, .suspended, .successful:
    return .viewRewards
  default:
    return .viewRewards
  }

//  switch (projectState, backingState) {
//  case (.live, .errored?):
//    return projectIsBacked ? PledgeStateCTAType.fix : PledgeStateCTAType.pledge
//  case (.live, _):
//    return projectIsBacked ? PledgeStateCTAType.manage : PledgeStateCTAType.pledge
//  case (.canceled, _):
//    return projectIsBacked ? PledgeStateCTAType.viewBacking : PledgeStateCTAType.viewRewards
//  case (.failed, _):
//    return projectIsBacked ? PledgeStateCTAType.viewBacking : PledgeStateCTAType.viewRewards
//  case (.suspended, _):
//    return projectIsBacked ? PledgeStateCTAType.viewBacking : PledgeStateCTAType.viewRewards
//  case (.successful, _):
//    return projectIsBacked ? PledgeStateCTAType.viewBacking : PledgeStateCTAType.viewRewards
//  default:
//    return PledgeStateCTAType.viewRewards
//  }
}

private func subtitle(project: Project, backing: Backing, pledgeState: PledgeStateCTAType) -> String {
  if pledgeState == .fix { return pledgeState.subtitleLabel ?? "" }

  let basicPledge = formattedAmount(for: backing)
  let amount = Format.formattedCurrency(
    basicPledge,
    country: project.country,
    omitCurrencyCode: project.stats.omitUSCurrencyCode
  )

  guard let rewardTitle = backing.reward?.title else { return "\(amount)" }
  return "\(amount) • \(rewardTitle)"
}

private func formattedAmount(for backing: Backing) -> String {
  let amount = backing.amount - Double(backing.shippingAmount ?? 0)
  let backingAmount = floor(amount) == amount
    ? String(Int(amount))
    : String(format: "%.2f", backing.amount)
  return backingAmount
}
