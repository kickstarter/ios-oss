import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol PledgeCTAContainerViewViewModelInputs {
  func configureWith(project: Project)
}

public protocol PledgeCTAContainerViewViewModelOutputs {
  var buttonBackgroundColor: Signal<UIColor, Never> { get }
  var buttonTitleText: Signal<String, Never> { get }
  var buttonTitleTextColor: Signal<UIColor, Never> { get }
  var spacerIsHidden: Signal<Bool, Never> { get }
  var stackViewIsHidden: Signal<Bool, Never> { get }
  var subtitleText: Signal<String, Never> { get }
  var titleText: Signal<String, Never> { get }
}

public protocol PledgeCTAContainerViewViewModelType {
  var inputs: PledgeCTAContainerViewViewModelInputs { get }
  var outputs: PledgeCTAContainerViewViewModelOutputs { get }
}

public final class PledgeCTAContainerViewViewModel: PledgeCTAContainerViewViewModelType,
  PledgeCTAContainerViewViewModelInputs, PledgeCTAContainerViewViewModelOutputs {
  public init() {
    let project = self.projectProperty.signal.skipNil()

    let backing = project.map { $0.personalization.backing }.skipNil()

    let projectAndBacking = Signal.combineLatest(project, backing)

    let backedProject = projectAndBacking
      .filter { isTrue($0.0.personalization.isBacking ?? false) }
      .map(pledgeCTA(project:backing:))

    let nonBackedProject = project
      .filter { isFalse($0.personalization.isBacking ?? true) }
      .map(pledgeCTA(project:))

    let pledgeState = Signal.merge(backedProject, nonBackedProject).map { $0 }

    self.buttonTitleText = pledgeState.map { $0.buttonTitle }
    self.buttonTitleTextColor = pledgeState.map { $0.buttonTitleTextColor }
    self.buttonBackgroundColor = pledgeState.map { $0.buttonBackgroundColor }
    let stackViewAndSpacerAreHidden = pledgeState.map { $0.stackViewAndSpacerAreHidden }
    self.spacerIsHidden = stackViewAndSpacerAreHidden
    self.stackViewIsHidden = stackViewAndSpacerAreHidden
    self.titleText = pledgeState.map { $0.titleLabel }.skipNil()

    let text = Signal.combineLatest(project, backing, pledgeState)
    self.subtitleText = text.map(subtitle(project:backing:pledgeState:))
  }

  fileprivate let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project: Project) {
    self.projectProperty.value = project
  }

  public var inputs: PledgeCTAContainerViewViewModelInputs { return self }
  public var outputs: PledgeCTAContainerViewViewModelOutputs { return self }

  public let buttonBackgroundColor: Signal<UIColor, Never>
  public let buttonTitleText: Signal<String, Never>
  public let buttonTitleTextColor: Signal<UIColor, Never>
  public let spacerIsHidden: Signal<Bool, Never>
  public let stackViewIsHidden: Signal<Bool, Never>
  public let subtitleText: Signal<String, Never>
  public let titleText: Signal<String, Never>
}

// MARK: - Functions

private func pledgeCTA(project: Project, backing: Backing) -> PledgeStateCTAType {
  switch (project.state, backing.status) {
  case (.live, .errored):
    return .fix
  case (.live, _):
    return .manage
  case (_, _):
    return .viewBacking
  }
}

private func pledgeCTA(project: Project) -> PledgeStateCTAType {
  switch project.state {
  case .live:
    return .pledge
  case .canceled, .failed, .suspended, .successful:
    return .viewRewards
  default:
    return .viewRewards
  }
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
