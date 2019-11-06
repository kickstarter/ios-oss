import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol PledgeCTAContainerViewViewModelInputs {
  func configureWith(value: (projectOrError: Either<Project, ErrorEnvelope>, isLoading: Bool))
  func pledgeCTAButtonTapped()
}

public protocol PledgeCTAContainerViewViewModelOutputs {
  var activityIndicatorIsHidden: Signal<Bool, Never> { get }
  var buttonStyleType: Signal<ButtonStyleType, Never> { get }
  var buttonTitleText: Signal<String, Never> { get }
  var notifyDelegateCTATapped: Signal<PledgeStateCTAType, Never> { get }
  var pledgeCTAButtonIsHidden: Signal<Bool, Never> { get }
  var retryStackViewIsHidden: Signal<Bool, Never> { get }
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

    self.notifyDelegateCTATapped = pledgeState
      .takeWhen(self.pledgeCTAButtonTappedProperty.signal)

    self.retryStackViewIsHidden = inError
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

    let pledgeTypeAndProject = Signal.combineLatest(pledgeState, project)

    // Tracking
    pledgeTypeAndProject
      .takeWhen(self.pledgeCTAButtonTappedProperty.signal)
      .observeValues {
        AppEnvironment.current.koala.trackPledgeCTAButtonClicked(
          stateType: $0,
          project: $1,
          screen: .projectPage
        )
      }
  }

  fileprivate let projectOrErrorProperty =
    MutableProperty<(Either<Project, ErrorEnvelope>, isLoading: Bool)?>(nil)
  public func configureWith(value: (projectOrError: Either<Project, ErrorEnvelope>, isLoading: Bool)) {
    self.projectOrErrorProperty.value = value
  }

  fileprivate let pledgeCTAButtonTappedProperty = MutableProperty(())
  public func pledgeCTAButtonTapped() {
    self.pledgeCTAButtonTappedProperty.value = ()
  }

  public var inputs: PledgeCTAContainerViewViewModelInputs { return self }
  public var outputs: PledgeCTAContainerViewViewModelOutputs { return self }

  public let activityIndicatorIsHidden: Signal<Bool, Never>
  public let buttonStyleType: Signal<ButtonStyleType, Never>
  public let buttonTitleText: Signal<String, Never>
  public let notifyDelegateCTATapped: Signal<PledgeStateCTAType, Never>
  public let pledgeCTAButtonIsHidden: Signal<Bool, Never>
  public let retryStackViewIsHidden: Signal<Bool, Never>
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

  // NB: Add error case back once correctly returned
  switch (project.state, projectBacking.status) {
  case (.live, _):
    return .manage
  case (_, _):
    return .viewBacking
  }
}

private func subtitle(project: Project, pledgeState: PledgeStateCTAType) -> String {
  guard let backing = project.personalization.backing else { return "" }

  if pledgeState == .fix { return pledgeState.subtitleLabel ?? "" }

  let amount = formattedPledge(amount: backing.amount, project: project)

  let reward = backing.reward
    ?? project.rewards.filter { $0.id == backing.rewardId }.first
    ?? Reward.noReward

  guard let rewardTitle = reward.title else { return "\(amount)" }
  return "\(amount) • \(rewardTitle)"
}

private func formattedPledge(amount: Double, project: Project) -> String {
  let numberOfDecimalPlaces = amount.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 2
  let formattedAmount = String(format: "%.\(numberOfDecimalPlaces)f", amount)

  return Format.formattedCurrency(
    formattedAmount,
    country: project.country,
    omitCurrencyCode: project.stats.omitUSCurrencyCode
  )
}
