import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol PledgeCTAContainerViewViewModelInputs {
  func configureWith(value: (projectOrError: Either<Project, ErrorEnvelope>, isLoading: Bool))
}

public protocol PledgeCTAContainerViewViewModelOutputs {
  var activityIndicatorIsHidden: Signal<Bool, Never> { get }
  var buttonBackgroundColor: Signal<UIColor, Never> { get }
  var buttonTitleText: Signal<String, Never> { get }
  var buttonTitleTextColor: Signal<UIColor, Never> { get }
  var pledgeCTAButtonIsHidden: Signal<Bool, Never> { get }
  var pledgeRetryButtonIsHidden: Signal<Bool, Never> { get }
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

    let projectOrError = self.configureWithValueProperty.signal
      .skipNil()
      .filter(second >>> isFalse)
      .map { $0.0 }

    let project = projectOrError
      .map(Either.left)
      .skipNil()

    let projectError = projectOrError
      .map(Either.right)
      .skipNil()

    self.activityIndicatorIsHidden = self.configureWithValueProperty.signal
      .skipNil()
      .map(second)
      .negate()

    let backing = project.map { $0.personalization.backing }
    let pledgeState = Signal.combineLatest(project, backing)
      .map(pledgeCTA(project:backing:))

    self.pledgeRetryButtonIsHidden = Signal
      .merge(
        projectError.ignoreValues().mapConst(false),
        project.ignoreValues().mapConst(true),
        self.activityIndicatorIsHidden.filter(isFalse).mapConst(true)
    )

    self.pledgeCTAButtonIsHidden = Signal
      .merge(
        project.ignoreValues().mapConst(false),
        projectError.ignoreValues().mapConst(true),
        self.activityIndicatorIsHidden.filter(isFalse).mapConst(true)
    )

    self.buttonTitleText = pledgeState.map { $0.buttonTitle }
    self.buttonTitleTextColor = pledgeState.map { $0.buttonTitleTextColor }
    self.buttonBackgroundColor = pledgeState.map { $0.buttonBackgroundColor }
    let stackViewAndSpacerAreHidden = pledgeState.map { $0.stackViewAndSpacerAreHidden }
    self.spacerIsHidden = stackViewAndSpacerAreHidden
    self.stackViewIsHidden = stackViewAndSpacerAreHidden
    self.titleText = pledgeState.map { $0.titleLabel }.skipNil()
    self.subtitleText = Signal.combineLatest(project, pledgeState)
      .map(subtitle(project:pledgeState:))
  }

  fileprivate let configureWithValueProperty =
    MutableProperty<(Either<Project, ErrorEnvelope>, isLoading: Bool)?>(nil)
  public func configureWith(value: (projectOrError: Either<Project, ErrorEnvelope>, isLoading: Bool)) {
    self.configureWithValueProperty.value = value
  }

  public var inputs: PledgeCTAContainerViewViewModelInputs { return self }
  public var outputs: PledgeCTAContainerViewViewModelOutputs { return self }

  public let activityIndicatorIsHidden: Signal<Bool, Never>
  public let buttonBackgroundColor: Signal<UIColor, Never>
  public let buttonTitleText: Signal<String, Never>
  public let buttonTitleTextColor: Signal<UIColor, Never>
  public let pledgeCTAButtonIsHidden: Signal<Bool, Never>
  public let pledgeRetryButtonIsHidden: Signal<Bool, Never>
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
