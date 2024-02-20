import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public typealias PledgeCTAPrelaunchState = (
  prelaunch: Bool,
  saved: Bool,
  watchesCount: Int
)

public typealias PledgeCTAContainerViewData = (
  projectOrError: Either<(Project, RefTag?), ErrorEnvelope>,
  isLoading: Bool
)

public protocol PledgeCTAContainerViewViewModelInputs {
  func configureWith(value: PledgeCTAContainerViewData)
  func pledgeCTAButtonTapped()
  func savedProjectFromNotification(project: Project?)
}

public protocol PledgeCTAContainerViewViewModelOutputs {
  var activityIndicatorIsHidden: Signal<Bool, Never> { get }
  var buttonStyleType: Signal<ButtonStyleType, Never> { get }
  var buttonTitleText: Signal<String, Never> { get }
  var notifyDelegateCTATapped: Signal<PledgeStateCTAType, Never> { get }
  var pledgeCTAButtonIsHidden: Signal<Bool, Never> { get }
  var watchesLabelIsHidden: Signal<Bool, Never> { get }
  var prelaunchCTASaved: Signal<PledgeCTAPrelaunchState, Never> { get }
  var retryStackViewIsHidden: Signal<Bool, Never> { get }
  var spacerIsHidden: Signal<Bool, Never> { get }
  var stackViewIsHidden: Signal<Bool, Never> { get }
  var subtitleText: Signal<String, Never> { get }
  var titleText: Signal<String, Never> { get }
  var watchesCountText: Signal<String, Never> { get }
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

    let projectError = projectOrError
      .map(Either.right)
      .skipNil()

    self.activityIndicatorIsHidden = isLoading
      .negate()

    let backing = project.map { $0.personalization.backing }

    let savedProjectFromNotificationAfterDebounce = self.savedProjectFromNotificationProperty.signal.skipNil()
      .ksr_debounce(.milliseconds(100), on: AppEnvironment.current.scheduler)

    self.pledgeState <~ Signal
      .merge(
        Signal.combineLatest(project, backing),
        savedProjectFromNotificationAfterDebounce
      )
      .map(pledgeCTA(project:backing:))
      .skipRepeats()

    let inError = Signal.merge(
      projectError.ignoreValues().mapConst(true),
      project.ignoreValues().mapConst(false)
    )

    let updateButtonStates = Signal.merge(
      projectOrError.ignoreValues(),
      isLoading.filter(isFalse).ignoreValues()
    )

    self.notifyDelegateCTATapped = self.pledgeState.signal.skipNil()
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

    self.prelaunchState <~ self.pledgeState.signal.skipNil().map { state -> PledgeCTAPrelaunchState in
      switch state {
      case let .prelaunch(saved, watchCount):
        return PledgeCTAPrelaunchState(
          prelaunch: true,
          saved: saved,
          watchesCount: watchCount
        )
      default:
        return PledgeCTAPrelaunchState(prelaunch: false, saved: false, watchesCount: 0)
      }
    }

    self.prelaunchCTASaved = self.prelaunchState.signal.skipNil()

    self.watchesLabelIsHidden = self.prelaunchState.signal.skipNil()
      .map { !$0.prelaunch }

    let updatedWatchCountProject = project
      .takePairWhen(self.prelaunchState.signal.skipNil())
      .map { project, prelaunchStateValue -> Project in
        let updatedProjectWithWatchesCount = project |> \.watchesCount .~ prelaunchStateValue.watchesCount

        return updatedProjectWithWatchesCount
      }

    self.buttonStyleType = self.pledgeState.signal.skipNil().map { $0.buttonStyle }
    self.buttonTitleText = self.pledgeState.signal.skipNil().map { $0.buttonTitle }
    let stackViewAndSpacerAreHidden = self.pledgeState.signal.skipNil().map { $0.stackViewAndSpacerAreHidden }
    self.spacerIsHidden = stackViewAndSpacerAreHidden
    self.stackViewIsHidden = stackViewAndSpacerAreHidden
    self.titleText = self.pledgeState.signal.skipNil().map { $0.titleLabel }.skipNil()
    self.watchesCountText = Signal.merge(project, updatedWatchCountProject)
      .map { project in
        let watchesCountText = project.watchesCount ?? 0

        return Strings.activity_followers(number_of_followers: "\(watchesCountText)")
      }

    self.subtitleText = Signal.combineLatest(project, self.pledgeState.signal.skipNil())
      .map(subtitle(project:pledgeState:))

    let pledgeTypeAndProject = Signal.combineLatest(self.pledgeState.signal.skipNil(), project)

    // Tracking
    pledgeTypeAndProject
      .takeWhen(self.pledgeCTAButtonTappedProperty.signal)
      .observeValues { state, project in

        AppEnvironment.current.ksrAnalytics.trackPledgeCTAButtonClicked(
          stateType: state,
          project: project
        )
      }
  }

  private var pledgeState = MutableProperty<PledgeStateCTAType?>(nil)
  private var prelaunchState = MutableProperty<PledgeCTAPrelaunchState?>(nil)

  fileprivate let configData = MutableProperty<PledgeCTAContainerViewData?>(nil)
  public func configureWith(value: PledgeCTAContainerViewData) {
    self.configData.value = value
  }

  fileprivate let pledgeCTAButtonTappedProperty = MutableProperty(())
  public func pledgeCTAButtonTapped() {
    self.pledgeCTAButtonTappedProperty.value = ()
  }

  fileprivate let savedProjectFromNotificationProperty = MutableProperty<(Project, Backing?)?>(nil)
  public func savedProjectFromNotification(project: Project?) {
    guard let projectValue = project else { return }
    self.savedProjectFromNotificationProperty.value = (projectValue, projectValue.personalization.backing)
  }

  public var inputs: PledgeCTAContainerViewViewModelInputs { return self }
  public var outputs: PledgeCTAContainerViewViewModelOutputs { return self }

  public let activityIndicatorIsHidden: Signal<Bool, Never>
  public let buttonStyleType: Signal<ButtonStyleType, Never>
  public let buttonTitleText: Signal<String, Never>
  public let prelaunchCTASaved: Signal<PledgeCTAPrelaunchState, Never>
  public let notifyDelegateCTATapped: Signal<PledgeStateCTAType, Never>
  public let pledgeCTAButtonIsHidden: Signal<Bool, Never>
  public let watchesLabelIsHidden: Signal<Bool, Never>
  public let retryStackViewIsHidden: Signal<Bool, Never>
  public let spacerIsHidden: Signal<Bool, Never>
  public let stackViewIsHidden: Signal<Bool, Never>
  public let subtitleText: Signal<String, Never>
  public let titleText: Signal<String, Never>
  public let watchesCountText: Signal<String, Never>
}

// MARK: - Functions

private func pledgeCTA(project: Project, backing: Backing?) -> PledgeStateCTAType {
  guard project.displayPrelaunch != .some(true) else {
    let projectIsSaved = project.personalization.isStarred ?? false

    return .prelaunch(saved: projectIsSaved, watchCount: project.watchesCount ?? 0)
  }

  guard let projectBacking = backing, project.personalization.isBacking == .some(true) else {
    if currentUserIsCreator(of: project) {
      return PledgeStateCTAType.viewYourRewards
    }

    if featurePostCampaignPledgeEnabled(), project.postCampaignPledgingEnabled,
      project.isInPostCampaignPledgingPhase {
      return PledgeStateCTAType.pledge
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

  switch pledgeState {
  case .fix:
    return pledgeState.subtitleLabel ?? ""
  default:
    break
  }

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
  let projectCurrencyCountry = projectCountry(forCurrency: project.stats.currency) ?? project.country

  return Format.formattedCurrency(
    formattedAmount,
    country: projectCurrencyCountry,
    omitCurrencyCode: project.stats.omitUSCurrencyCode
  )
}
