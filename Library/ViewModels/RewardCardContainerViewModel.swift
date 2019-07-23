import KsApi
import Prelude
import ReactiveSwift

public protocol RewardCardContainerViewModelInputs {
  func configureWith(project: Project, rewardOrBacking: Either<Reward, Backing>)
  func pledgeButtonTapped()
}

public protocol RewardCardContainerViewModelOutputs {
  var pledgeButtonEnabled: Signal<Bool, Never> { get }
  var pledgeButtonTitleText: Signal<String, Never> { get }
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

    let reward: Signal<Reward, Never> = projectAndRewardOrBacking
      .map { project, rewardOrBacking -> Reward in
        rewardOrBacking.left
          ?? rewardOrBacking.right?.reward
          ?? backingReward(fromProject: project)
          ?? Reward.noReward
      }

    self.currentRewardProperty <~ reward

    let rewardAvailable = reward
      .map { $0.remaining == 0 }.negate()

    self.pledgeButtonTitleText = projectAndRewardOrBacking
      .map(pledgeButtonTitle(project:rewardOrBacking:))

    self.pledgeButtonEnabled = rewardAvailable

    self.rewardSelected = reward
      .takeWhen(self.pledgeButtonTappedProperty.signal)
      .map { $0.id }
  }

  private let projectAndRewardOrBackingProperty = MutableProperty<(Project, Either<Reward, Backing>)?>(nil)
  public func configureWith(project: Project, rewardOrBacking: Either<Reward, Backing>) {
    self.projectAndRewardOrBackingProperty.value = (project, rewardOrBacking)
  }

  private let pledgeButtonTappedProperty = MutableProperty(())
  public func pledgeButtonTapped() {
    self.pledgeButtonTappedProperty.value = ()
  }

  public let pledgeButtonEnabled: Signal<Bool, Never>
  public let pledgeButtonTitleText: Signal<String, Never>
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

private func pledgeButtonTitle(project: Project, rewardOrBacking: Either<Reward, Backing>) -> String {
  let minimumFormattedAmount = formattedAmountForRewardOrBacking(
    project: project,
    rewardOrBacking: rewardOrBacking
  )
  return project.personalization.isBacking == true
    ? Strings.Select_this_reward_instead()
    : Strings.rewards_title_pledge_reward_currency_or_more(reward_currency: minimumFormattedAmount)
}
