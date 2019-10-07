import KsApi
import Prelude
import ReactiveSwift

public protocol RewardCardContainerViewModelInputs {
  func configureWith(project: Project, rewardOrBacking: Either<Reward, Backing>)
  func pledgeButtonTapped()
}

public protocol RewardCardContainerViewModelOutputs {
  var gradientViewHidden: Signal<Bool, Never> { get }
  var pledgeButtonStyleType: Signal<ButtonStyleType, Never> { get }
  var pledgeButtonEnabled: Signal<Bool, Never> { get }
  var pledgeButtonHidden: Signal<Bool, Never> { get }
  var pledgeButtonTitleText: Signal<String?, Never> { get }
  var rewardSelected: Signal<Int, Never> { get }
  func currentReward(is reward: Reward) -> Bool
}

public protocol RewardCardContainerViewModelType {
  var inputs: RewardCardContainerViewModelInputs { get }
  var outputs: RewardCardContainerViewModelOutputs { get }
}

public final class RewardCardContainerViewModel: RewardCardContainerViewModelType,
  RewardCardContainerViewModelInputs, RewardCardContainerViewModelOutputs {
  public init() {
    let projectAndRewardOrBacking: Signal<(Project, Either<Reward, Backing>), Never> =
      self.projectAndRewardOrBackingProperty.signal.skipNil()

    let project: Signal<Project, Never> = projectAndRewardOrBacking.map(first)

    let reward: Signal<Reward, Never> = projectAndRewardOrBacking
      .map { project, rewardOrBacking -> Reward in
        rewardOrBacking.left
          ?? rewardOrBacking.right?.reward
          ?? backingReward(fromProject: project)
          ?? Reward.noReward
      }

    let projectAndReward = Signal.zip(project, reward)

    self.currentRewardProperty <~ reward

    let pledgeButtonTitleText = projectAndReward
      .map(pledgeButtonTitle(project:reward:))

    self.pledgeButtonTitleText = pledgeButtonTitleText

    self.pledgeButtonStyleType = projectAndReward
      .map(buttonStyleType(project:reward:))

    self.pledgeButtonEnabled = projectAndReward
      .map(pledgeButtonIsEnabled(project:reward:))

    self.pledgeButtonHidden = pledgeButtonTitleText.map(isNil)

    self.gradientViewHidden = self.pledgeButtonHidden

    self.rewardSelected = reward
      .takeWhen(self.pledgeButtonTappedProperty.signal)
      .map { $0.id }

    // Tracking
    projectAndRewardOrBacking
      .takeWhen(self.pledgeButtonTappedProperty.signal)
      .observeValues { projectAndRewardOrBacking in
        let (project, rewardOrBacking) = projectAndRewardOrBacking
        AppEnvironment.current.koala.trackSelectRewardButtonClicked(
          project: project,
          reward: rewardOrBacking.left,
          backing: rewardOrBacking.right,
          screen: .backThisPage
        )
      }
  }

  private let projectAndRewardOrBackingProperty = MutableProperty<(Project, Either<Reward, Backing>)?>(nil)
  public func configureWith(project: Project, rewardOrBacking: Either<Reward, Backing>) {
    self.projectAndRewardOrBackingProperty.value = (project, rewardOrBacking)
  }

  private let pledgeButtonTappedProperty = MutableProperty(())
  public func pledgeButtonTapped() {
    self.pledgeButtonTappedProperty.value = ()
  }

  public let gradientViewHidden: Signal<Bool, Never>
  public let pledgeButtonStyleType: Signal<ButtonStyleType, Never>
  public let pledgeButtonEnabled: Signal<Bool, Never>
  public let pledgeButtonHidden: Signal<Bool, Never>
  public let pledgeButtonTitleText: Signal<String?, Never>
  public let rewardSelected: Signal<Int, Never>

  private let currentRewardProperty = MutableProperty<Reward?>(nil)
  public func currentReward(is reward: Reward) -> Bool {
    return self.currentRewardProperty.value == reward
  }

  public var inputs: RewardCardContainerViewModelInputs { return self }
  public var outputs: RewardCardContainerViewModelOutputs { return self }
}

// MARK: - Functions

private func backingReward(fromProject project: Project) -> Reward? {
  guard let backing = project.personalization.backing else {
    return nil
  }

  return project.rewards
    .filter { $0.id == backing.rewardId || $0.id == backing.reward?.id }
    .first
    .coalesceWith(.noReward)
}

private func pledgeButtonTitle(project: Project, reward: Reward) -> String? {
  let projectBackingState = RewardCellProjectBackingStateType.state(with: project)
  let isBackingThisReward = userIsBacking(reward: reward, inProject: project)
  let isRewardAvailable = rewardIsAvailable(reward: reward)

  switch (projectBackingState, isBackingThisReward, isRewardAvailable) {
  case (.backedError, false, true):
    return Strings.Select()
  case (.backedError, true, _):
    return Strings.Fix_your_payment_method()
  case (.backed(.live), false, true):
    return Strings.Select()
  case (.backed(.live), true, _):
    return Strings.Selected()
  case (.nonBacked(.live), _, true):
    return Strings.Select()
  case (.backed(.nonLive), true, _):
    return Strings.View_your_pledge()
  case (.backed(.nonLive), false, _),
       (.nonBacked(.nonLive), _, _):
    return nil
  case (_, _, false):
    return Strings.No_longer_available()
  }
}

private func buttonStyleType(project: Project, reward: Reward) -> ButtonStyleType {
  let projectBackingState = RewardCellProjectBackingStateType.state(with: project)
  let isBackingThisReward = userIsBacking(reward: reward, inProject: project)

  switch projectBackingState {
  case .backedError:
    if isBackingThisReward {
      return .apricot
    }
  case .backed(.live):
    if isBackingThisReward {
      return .blue
    }
  case .nonBacked(.live):
    return .green
  case .backed(.nonLive):
    if isBackingThisReward {
      return .black
    }
    return .none
  case .nonBacked(.nonLive):
    return .none
  }

  return .green
}

private func pledgeButtonIsEnabled(project: Project, reward: Reward) -> Bool {
  let isAvailable = rewardIsAvailable(reward: reward)
  let isBacking = userIsBacking(reward: reward, inProject: project)

  return (project.state == .live && isAvailable) || isBacking
}

private func rewardIsAvailable(reward: Reward) -> Bool {
  let isLimited = reward.remaining != nil || reward.endsAt != nil

  guard isLimited else { return true }

  let remaining = reward.remaining.coalesceWith(0) > 0
  let endsAt = reward.endsAt.coalesceWith(0)
  let now = AppEnvironment.current.dateType.init().timeIntervalSince1970
  let timeLimitNotReached = endsAt > now

  return remaining || timeLimitNotReached
}
