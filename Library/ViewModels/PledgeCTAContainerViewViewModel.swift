import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public enum PledgeCTAContainerViewContext {
  case projectPamphlet
  case projectDescription
}

public typealias PledgeCTAContainerViewData = (
  projectOrError: Either<(Project, RefTag?), ErrorEnvelope>,
  isLoading: Bool,
  context: PledgeCTAContainerViewContext
)

public protocol PledgeCTAContainerViewViewModelInputs {
  func configureWith(value: PledgeCTAContainerViewData)
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
    let projectOrError = self.configData.signal
      .skipNil()
      .filter(second >>> isFalse)
      .map(first)

    let isLoading = self.configData.signal
      .skipNil()
      .map(second)

    let project = projectOrError
      .map(Either.left)
      .skipNil()
      .map(first)

    let refTag = projectOrError
      .map(Either.left)
      .skipNil()
      .map(second)

    let projectError = projectOrError
      .map(Either.right)
      .skipNil()

    self.activityIndicatorIsHidden = isLoading
      .negate()

    let backing = project.map { $0.personalization.backing }
    let pledgeState = Signal.combineLatest(project, refTag, backing)
      .map(pledgeCTA(project:refTag:backing:))

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
      .observeValues { state, project in
        let optimizelyProps = optimizelyProperties() ?? [:]

        AppEnvironment.current.koala.trackPledgeCTAButtonClicked(
          stateType: state,
          project: project,
          optimizelyProperties: optimizelyProps
        )
      }
  }

  fileprivate let configData = MutableProperty<PledgeCTAContainerViewData?>(nil)
  public func configureWith(value: PledgeCTAContainerViewData) {
    self.configData.value = value
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

private func pledgeCTA(project: Project, refTag: RefTag?, backing: Backing?) -> PledgeStateCTAType {
  guard let projectBacking = backing, project.personalization.isBacking == .some(true) else {
    if currentUserIsCreator(of: project) {
      return PledgeStateCTAType.viewYourRewards
    }

    let optimizelyVariant = AppEnvironment.current.optimizelyClient?
      .variant(
        for: OptimizelyExperiment.Key.pledgeCTACopy,
        userAttributes: optimizelyUserAttributes(with: project, refTag: refTag)
      )

    if let variant = optimizelyVariant, project.state == .live {
      switch variant {
      case .variant1:
        return PledgeStateCTAType.seeTheRewards
      case .variant2:
        return PledgeStateCTAType.viewTheRewards
      case .control:
        return PledgeStateCTAType.pledge
      }
    }

    return project.state == .live ? PledgeStateCTAType.pledge : PledgeStateCTAType.viewRewards
  }

  // NB: Add error case back once correctly returned
  switch (project.state, projectBacking.status) {
  case (.live, _):
    return .manage
  case (.successful, .errored):
    return .fix
  case (_, _):
    return .viewBacking
  }
}

private func subtitle(project: Project, pledgeState: PledgeStateCTAType) -> String {
  guard let backing = project.personalization.backing else { return "" }

  if pledgeState == .fix { return pledgeState.subtitleLabel ?? "" }

  let amount = formattedPledge(amount: backing.amount, project: project)

  let reward = backing.reward
    ?? project.rewards.first { $0.id == backing.rewardId }
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
