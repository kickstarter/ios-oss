import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol PledgeCTAContainerViewViewModelInputs {
  func configureWith(value: (project: Project, isLoading: Bool))
}

public protocol PledgeCTAContainerViewViewModelOutputs {
  var activityIndicatorIsAnimating: Signal<Bool, Never> { get }
  var buttonStyleType: Signal<ButtonStyleType, Never> { get }
  var buttonTitleText: Signal<String, Never> { get }
  var rootStackViewAnimateIsHidden: Signal<Bool, Never> { get }
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
    let project = self.configureWithValueProperty.signal
      .skipNil()
      .filter(second >>> isFalse)
      .map(first)

    self.activityIndicatorIsAnimating = self.configureWithValueProperty.signal
      .skipNil()
      .map(second)

    self.rootStackViewAnimateIsHidden = self.activityIndicatorIsAnimating

    let backing = project.map { $0.personalization.backing }
    let pledgeState = Signal.combineLatest(project, backing)
      .map(pledgeCTA(project:backing:))

    self.buttonStyleType = pledgeState.map { $0.buttonStyle }
    self.buttonTitleText = pledgeState.map { $0.buttonTitle }
    let stackViewAndSpacerAreHidden = pledgeState.map { $0.stackViewAndSpacerAreHidden }
    self.spacerIsHidden = stackViewAndSpacerAreHidden
    self.stackViewIsHidden = stackViewAndSpacerAreHidden
    self.titleText = pledgeState.map { $0.titleLabel }.skipNil()
    self.subtitleText = Signal.combineLatest(project, pledgeState)
      .map(subtitle(project:pledgeState:))
  }

  fileprivate let configureWithValueProperty = MutableProperty<(project: Project, isLoading: Bool)?>(nil)
  public func configureWith(value: (project: Project, isLoading: Bool)) {
    self.configureWithValueProperty.value = value
  }

  public var inputs: PledgeCTAContainerViewViewModelInputs { return self }
  public var outputs: PledgeCTAContainerViewViewModelOutputs { return self }

  public let activityIndicatorIsAnimating: Signal<Bool, Never>
  public let buttonStyleType: Signal<ButtonStyleType, Never>
  public let buttonTitleText: Signal<String, Never>
  public let rootStackViewAnimateIsHidden: Signal<Bool, Never>
  public let spacerIsHidden: Signal<Bool, Never>
  public let stackViewIsHidden: Signal<Bool, Never>
  public let subtitleText: Signal<String, Never>
  public let titleText: Signal<String, Never>
}

// MARK: - Functions

private func pledgeCTA(project: Project, backing: Backing?) -> PledgeStateCTAType {
  guard let projectBacking = backing, project.personalization.isBacking == .some(true) else {
    return project.state == .live ? PledgeStateCTAType.pledge : PledgeStateCTAType.viewRewards
  }

  switch (project.state, projectBacking.status) {
  case (.live, .errored):
    return .fix
  case (.live, _):
    return .manage
  case (_, _):
    return .viewBacking
  }
}

private func subtitle(project: Project, pledgeState: PledgeStateCTAType) -> String {
  guard let backing = project.personalization.backing else { return "" }

  if pledgeState == .fix { return pledgeState.subtitleLabel ?? "" }

  let basicPledge = formattedAmount(for: backing)
  let amount = Format.formattedCurrency(
    basicPledge,
    country: project.country,
    omitCurrencyCode: project.stats.omitUSCurrencyCode
  )

  let reward = backing.reward
    ?? project.rewards.filter { $0.id == backing.rewardId }.first
    ?? Reward.noReward

  guard let rewardTitle = reward.title else { return "\(amount)" }
  return "\(amount) • \(rewardTitle)"
}

private func formattedAmount(for backing: Backing) -> String {
  let amount = backing.amount - Double(backing.shippingAmount ?? 0)
  let backingAmount = floor(amount) == amount
    ? String(Int(amount))
    : String(format: "%.2f", backing.amount)
  return backingAmount
}
