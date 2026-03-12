import KsApi
import Prelude
import ReactiveSwift

public protocol RewardCardContainerViewModelInputs {
  func configureWith(data: RewardCardViewData)
  func pledgeButtonTapped()
}

public protocol RewardCardContainerViewModelOutputs {
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
    let data = self.configDataProperty
      .signal
      .skipNil()

    let reward: Signal<Reward, Never> =
      data
        .map { $0.reward }

    self.currentRewardProperty <~ reward

    let pledgeButtonTitleText = data
      .map { data in
        pledgeButtonTitle(data: data)
      }

    self.pledgeButtonTitleText = pledgeButtonTitleText

    self.pledgeButtonStyleType = data
      .map { data in
        buttonStyleType(data: data)
      }

    self.pledgeButtonEnabled = data
      .map { data in
        rewardsCarouselCanNavigateToReward(
          data.reward,
          in: data.project,
          selectedShippingLocation: data.currentShippingLocation
        )
      }

    self.pledgeButtonHidden = pledgeButtonTitleText.map(isNil)

    self.rewardSelected = reward
      .takeWhen(self.pledgeButtonTappedProperty.signal)
      .map { $0.id }
  }

  private let configDataProperty = MutableProperty<RewardCardViewData?>(nil)
  public func configureWith(data: RewardCardViewData) {
    self.configDataProperty.value = data
  }

  private let pledgeButtonTappedProperty = MutableProperty(())
  public func pledgeButtonTapped() {
    self.pledgeButtonTappedProperty.value = ()
  }

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

private func pledgeButtonTitle(data: RewardCardViewData) -> String? {
  if currentUserIsCreator(of: data.project) { return nil }

  let projectBackingState = RewardCellProjectBackingStateType.state(with: data.project)
  let isBackingThisReward = userIsBacking(reward: data.reward, inProject: data.project)
  let isRewardAvailable = rewardIsAvailable(data.reward)
  let rewardShipsToLocation = rewardCanShip(data.reward, toLocation: data.currentShippingLocation)

  switch (projectBackingState, isBackingThisReward, isRewardAvailable, rewardShipsToLocation) {
  case (.backed(.live), false, true, _):
    return Strings.Select()
  case (.backed(.live), true, _, _):
    return Strings.Continue()
  case (.backed(.nonLive), true, _, _):
    return Strings.Selected()
  case (.nonBacked(.live), _, true, true):
    return Strings.Select()
  case (.nonBacked(.live), _, true, false):
    return Strings.Not_available_in_selected_country()
  case (.backed(.nonLive), false, _, _),
       (.backed(.inPostCampaignPledgingPhase), _, _, _),
       (.nonBacked(.nonLive), _, _, _):
    return nil
  case (_, _, false, _):
    return Strings.No_longer_available()
  case (.nonBacked(.inPostCampaignPledgingPhase), _, true, _):
    return Strings.Select()
  }
}

private func buttonStyleType(data: RewardCardViewData) -> ButtonStyleType {
  if currentUserIsCreator(of: data.project) { return .none }

  let projectBackingState = RewardCellProjectBackingStateType.state(with: data.project)
  let isBackingThisReward = userIsBacking(reward: data.reward, inProject: data.project)

  switch projectBackingState {
  case .backed(.live):
    if isBackingThisReward {
      return .green
    }
  case .nonBacked(.live):
    return .green
  case .backed(.nonLive):
    if isBackingThisReward {
      return .black
    }
    return .none
  case .nonBacked(.nonLive),
       .backed(.inPostCampaignPledgingPhase):
    return .none
  case .nonBacked(.inPostCampaignPledgingPhase):
    return .green
  }

  return .green
}
