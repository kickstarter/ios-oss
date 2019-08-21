import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol PledgeCTAContainerViewViewModelInputs {
  func configureWith(value: (projectOrError: Either<Project, ErrorEnvelope>, isLoading: Bool))
}

public protocol PledgeCTAContainerViewViewModelOutputs {
  var activityIndicatorIsHidden: Signal<Bool, Never> { get }
  var buttonStyleType: Signal<ButtonStyleType, Never> { get }
  var buttonTitleText: Signal<String, Never> { get }
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
    let projectOrError = self.projectOrErrorProperty.signal
      .skipNil()
      .filter(second >>> isFalse)
      .map(first)

    let isLoading = self.projectOrErrorProperty.signal
      .skipNil()
      .map(second)

    let project = projectOrError
      .map(Either.left)
      .skipNil()

    let projectError = projectOrError
      .map(Either.right)
      .skipNil()

    self.activityIndicatorIsHidden = isLoading
      .negate()

    let backing = project.map { $0.personalization.backing }
    let pledgeState = Signal.combineLatest(project, backing)
      .map(pledgeCTA(project:backing:))

    let inError = Signal.merge(
      projectError.ignoreValues().mapConst(true),
      project.ignoreValues().mapConst(false)
    )

    let updateButtonStates = Signal.merge(
      projectOrError.ignoreValues(),
      isLoading.filter(isFalse).ignoreValues()
    )

    self.pledgeRetryButtonIsHidden = inError
      .map(isFalse)
      .takeWhen(updateButtonStates)
      .merge(with: isLoading.filter(isTrue).mapConst(true))
      .skipRepeats()

    self.pledgeCTAButtonIsHidden = inError
      .map(isTrue)
      .takeWhen(updateButtonStates)
      .merge(with: isLoading.filter(isTrue).mapConst(true))
      .skipRepeats()

    self.buttonStyleType = pledgeState.map { $0.buttonStyle }
    self.buttonTitleText = pledgeState.map { $0.buttonTitle }
    let stackViewAndSpacerAreHidden = pledgeState.map { $0.stackViewAndSpacerAreHidden }
    self.spacerIsHidden = stackViewAndSpacerAreHidden
    self.stackViewIsHidden = stackViewAndSpacerAreHidden
    self.titleText = pledgeState.map { $0.titleLabel }.skipNil()
    self.subtitleText = Signal.combineLatest(project, pledgeState)
      .map(subtitle(project:pledgeState:))
  }

  fileprivate let projectOrErrorProperty =
    MutableProperty<(Either<Project, ErrorEnvelope>, isLoading: Bool)?>(nil)
  public func configureWith(value: (projectOrError: Either<Project, ErrorEnvelope>, isLoading: Bool)) {
    self.projectOrErrorProperty.value = value
  }

  public var inputs: PledgeCTAContainerViewViewModelInputs { return self }
  public var outputs: PledgeCTAContainerViewViewModelOutputs { return self }

  public let activityIndicatorIsHidden: Signal<Bool, Never>
  public let buttonStyleType: Signal<ButtonStyleType, Never>
  public let buttonTitleText: Signal<String, Never>
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

  let amount = formattedAmountForRewardOrBacking(
    project: project,
    rewardOrBacking: .right(backing)
  )

  let reward = backing.reward
    ?? project.rewards.filter { $0.id == backing.rewardId }.first
    ?? Reward.noReward

  guard let rewardTitle = reward.title else { return "\(amount)" }
  return "\(amount) • \(rewardTitle)"
}
