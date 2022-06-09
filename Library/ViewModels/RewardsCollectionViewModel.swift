import KsApi
import Prelude
import ReactiveSwift
import UIKit

public enum RewardsCollectionViewContext {
  case createPledge
  case managePledge
}

public protocol RewardsCollectionViewModelInputs {
  func configure(with project: Project, refTag: RefTag?, context: RewardsCollectionViewContext)
  func confirmedEditReward()
  func rewardCellShouldShowDividerLine(_ show: Bool)
  func rewardSelected(with rewardId: Int)
  func traitCollectionDidChange(_ traitCollection: UITraitCollection)
  func viewDidAppear()
  func viewDidLayoutSubviews()
  func viewDidLoad()
  func viewWillAppear()
}

public protocol RewardsCollectionViewModelOutputs {
  var configureRewardsCollectionViewFooterWithCount: Signal<Int, Never> { get }
  var flashScrollIndicators: Signal<Void, Never> { get }
  var goToAddOnSelection: Signal<PledgeViewData, Never> { get }
  var goToPledge: Signal<PledgeViewData, Never> { get }
  var navigationBarShadowImageHidden: Signal<Bool, Never> { get }
  var reloadDataWithValues: Signal<[RewardCardViewData], Never> { get }
  var rewardsCollectionViewFooterIsHidden: Signal<Bool, Never> { get }
  var scrollToBackedRewardIndexPath: Signal<IndexPath, Never> { get }
  var showEditRewardConfirmationPrompt: Signal<(String, String), Never> { get }
  var title: Signal<String, Never> { get }

  func selectedReward() -> Reward?
}

public protocol RewardsCollectionViewModelType {
  var inputs: RewardsCollectionViewModelInputs { get }
  var outputs: RewardsCollectionViewModelOutputs { get }
}

public final class RewardsCollectionViewModel: RewardsCollectionViewModelType,
  RewardsCollectionViewModelInputs, RewardsCollectionViewModelOutputs {
  public init() {
    let configData = Signal.combineLatest(
      self.configDataProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    )
    .map(first)

    let project = configData
      .map(first)

    let rewards = project
      .map(allowableProjectRewards)

    self.title = configData
      .map { project, _, context in (context, project) }
      .combineLatest(with: self.viewDidLoadProperty.signal.ignoreValues())
      .map(first)
      .map(titleForContext)

    self.scrollToBackedRewardIndexPath = Signal.combineLatest(project, rewards)
      .takeWhen(self.viewDidLayoutSubviewsProperty.signal.ignoreValues())
      .map(backedReward(_:rewards:))
      .skipNil()
      .take(first: 1)

    self.reloadDataWithValues = Signal.combineLatest(project, rewards)
      .map { project, rewards in
        rewards.filter { reward in isStartDateBeforeToday(for: reward) }
          .map { reward in (project, reward, .pledge) }
      }

    self.configureRewardsCollectionViewFooterWithCount = self.reloadDataWithValues
      .map { $0.count }

    self.flashScrollIndicators = self.viewDidAppearProperty.signal

    let selectedRewardFromId = rewards
      .takePairWhen(self.rewardSelectedWithRewardIdProperty.signal.skipNil())
      .map { rewards, rewardId in
        rewards.first(where: { $0.id == rewardId })
      }
      .skipNil()

    self.selectedRewardProperty <~ selectedRewardFromId

    let refTag = configData
      .map(second)

    let goToPledge = Signal.combineLatest(
      project,
      selectedRewardFromId,
      refTag
    )
    .filter { project, reward, _ in
      rewardsCarouselCanNavigateToReward(reward, in: project)
    }
    .map { project, reward, refTag -> (PledgeViewData, Bool) in
      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil, // Set during add-ons selection.
        refTag: refTag,
        context: project.personalization.backing == nil ? .pledge : .updateReward
      )

      return (data, reward.hasAddOns)
    }

    // Reward has add-ons, project is not backed, navigates to add-on selection without prompt.
    let goToAddOnSelectionNotBackedWithAddOns = goToPledge
      .filter(second >>> isTrue)
      .map(first)
      .filter(shouldTriggerEditRewardPrompt >>> isFalse)

    // Reward has add-ons, project is backed with add-ons, triggers prompt before add-on selection.
    let goToAddOnSelectionBackedWithAddOns = goToPledge
      .filter(second >>> isTrue)
      .map(first)
      .filter(shouldTriggerEditRewardPrompt >>> isTrue)

    // Reward does not have add-ons, project is not backed, navigates to pledge without prompt.
    let goToPledgeNotBackedWithAddOns = goToPledge
      .filter(second >>> isFalse)
      .map(first)
      .filter(shouldTriggerEditRewardPrompt >>> isFalse)

    // Reward does not have add-ons, project is backed with add-ons, triggers prompt before pledge.
    let goToPledgeBackedWithAddOns = goToPledge
      .filter(second >>> isFalse)
      .map(first)
      .filter(shouldTriggerEditRewardPrompt >>> isTrue)

    self.showEditRewardConfirmationPrompt = Signal.merge(
      goToAddOnSelectionBackedWithAddOns,
      goToPledgeBackedWithAddOns
    )
    .map { _ in
      (Strings.Continue_with_this_reward(), Strings.It_may_not_offer_some_or_all_of_your_add_ons())
    }

    let goToAddOnSelectionBackedConfirmed = goToPledge
      .takeWhen(self.confirmedEditRewardProperty.signal)
      .filter(second >>> isTrue)
      .map(first)

    let goToPledgeBackedConfirmed = goToPledge
      .takeWhen(self.confirmedEditRewardProperty.signal)
      .filter(second >>> isFalse)
      .map(first)

    self.goToAddOnSelection = Signal.merge(
      goToAddOnSelectionNotBackedWithAddOns,
      goToAddOnSelectionBackedConfirmed
    )
    self.goToPledge = Signal.merge(
      goToPledgeNotBackedWithAddOns,
      goToPledgeBackedConfirmed
    )

    self.rewardsCollectionViewFooterIsHidden = self.traitCollectionChangedProperty.signal
      .skipNil()
      .map { isFalse($0.verticalSizeClass == .regular) }

    let hideDividerLine = self.rewardCellShouldShowDividerLineProperty.signal
      .negate()

    self.navigationBarShadowImageHidden = Signal.merge(
      hideDividerLine,
      hideDividerLine.takeWhen(self.viewWillAppearProperty.signal)
    )

    // Tracking
    Signal.combineLatest(
      project,
      refTag,
      self.viewDidLoadProperty.signal.ignoreValues()
    )
    .observeValues { project, refTag, _ in
      // This event is fired before a base reward is selected
      let reward = Reward.noReward
      let (backing, shippingTotal) = backingAndShippingTotal(for: project, and: reward)
      let checkoutPropertiesData = checkoutProperties(
        from: project,
        baseReward: reward,
        addOnRewards: backing?.addOns ?? [],
        selectedQuantities: [:],
        additionalPledgeAmount: backing?.bonusAmount ?? 0,
        pledgeTotal: backing?.amount ?? reward.minimum,
        shippingTotal: shippingTotal ?? 0,
        isApplePay: nil
      )

      AppEnvironment.current.ksrAnalytics.trackRewardsViewed(
        project: project,
        checkoutPropertiesData: checkoutPropertiesData,
        refTag: refTag
      )
    }

    Signal.combineLatest(project, selectedRewardFromId, refTag)
      .observeValues { project, reward, refTag in

        // The `Backing` is nil for a new pledge.
        let (backing, shippingTotal) = backingAndShippingTotal(for: project, and: reward)

        // Regardless of whether this is the beginning of a new pledge or we are editing our reward,
        // we only have the base reward selected at this point
        let checkoutPropertiesData = checkoutProperties(
          from: project,
          baseReward: reward,
          addOnRewards: backing?.addOns ?? [],
          selectedQuantities: [reward.id: 1],
          additionalPledgeAmount: backing?.bonusAmount ?? 0,
          pledgeTotal: backing?.amount ?? reward.minimum, // The total is the value of the reward
          shippingTotal: shippingTotal ?? 0,
          isApplePay: nil
        )

        AppEnvironment.current.ksrAnalytics.trackRewardClicked(
          project: project,
          reward: reward,
          checkoutPropertiesData: checkoutPropertiesData,
          refTag: refTag
        )
      }
  }

  private let configDataProperty = MutableProperty<(Project, RefTag?, RewardsCollectionViewContext)?>(nil)
  public func configure(with project: Project, refTag: RefTag?, context: RewardsCollectionViewContext) {
    self.configDataProperty.value = (project, refTag, context)
  }

  private let confirmedEditRewardProperty = MutableProperty(())
  public func confirmedEditReward() {
    self.confirmedEditRewardProperty.value = ()
  }

  private let rewardCellShouldShowDividerLineProperty = MutableProperty<Bool>(false)
  public func rewardCellShouldShowDividerLine(_ show: Bool) {
    self.rewardCellShouldShowDividerLineProperty.value = show
  }

  private let rewardSelectedWithRewardIdProperty = MutableProperty<Int?>(nil)
  public func rewardSelected(with rewardId: Int) {
    self.rewardSelectedWithRewardIdProperty.value = rewardId
  }

  private let traitCollectionChangedProperty = MutableProperty<UITraitCollection?>(nil)
  public func traitCollectionDidChange(_ traitCollection: UITraitCollection) {
    self.traitCollectionChangedProperty.value = traitCollection
  }

  private let viewDidAppearProperty = MutableProperty(())
  public func viewDidAppear() {
    self.viewDidAppearProperty.value = ()
  }

  private let viewDidLayoutSubviewsProperty = MutableProperty(())
  public func viewDidLayoutSubviews() {
    self.viewDidLayoutSubviewsProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let viewWillAppearProperty = MutableProperty(())
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  public let configureRewardsCollectionViewFooterWithCount: Signal<Int, Never>
  public let flashScrollIndicators: Signal<Void, Never>
  public let goToAddOnSelection: Signal<PledgeViewData, Never>
  public let goToPledge: Signal<PledgeViewData, Never>
  public let navigationBarShadowImageHidden: Signal<Bool, Never>
  public let reloadDataWithValues: Signal<[RewardCardViewData], Never>
  public let rewardsCollectionViewFooterIsHidden: Signal<Bool, Never>
  public let scrollToBackedRewardIndexPath: Signal<IndexPath, Never>
  public let showEditRewardConfirmationPrompt: Signal<(String, String), Never>
  public let title: Signal<String, Never>

  private let selectedRewardProperty = MutableProperty<Reward?>(nil)
  public func selectedReward() -> Reward? {
    return self.selectedRewardProperty.value
  }

  public var inputs: RewardsCollectionViewModelInputs { return self }
  public var outputs: RewardsCollectionViewModelOutputs { return self }
}

// MARK: - Functions

private func titleForContext(_ context: RewardsCollectionViewContext, project: Project) -> String {
  if currentUserIsCreator(of: project) {
    return Strings.View_your_rewards()
  }

  guard project.state == .live else {
    return Strings.View_rewards()
  }

  return context == .createPledge ? Strings.Back_this_project() : Strings.Edit_reward()
}

private func shouldTriggerEditRewardPrompt(_ data: PledgeViewData) -> Bool {
  // If the user is not backing the project then there is no need to show the prompt.
  guard
    userIsBackingProject(data.project),
    let backing = data.project.personalization.backing
  else { return false }

  let rewardChanged = data.rewards.first?.id != backing.reward?.id

  // We show the prompt if they have previously backed with add-ons and they are selecting a new reward.
  return backing.addOns?.isEmpty == false && rewardChanged
}

private func backedReward(_ project: Project, rewards: [Reward]) -> IndexPath? {
  guard let backing = project.personalization.backing else {
    return nil
  }

  let backedReward = reward(from: backing, inProject: project)
  return rewards
    .firstIndex(where: { $0.id == backedReward.id })
    .flatMap { IndexPath(row: $0, section: 0) }
}

private func backingAndShippingTotal(for project: Project, and reward: Reward) -> (Backing?, Double?) {
  let backing = project.personalization.backing
  let shippingTotal = reward.shipping.enabled ? backing?.shippingAmount.flatMap(Double.init) : 0.0

  return (backing, shippingTotal)
}

private func allowableProjectRewards(from project: Project) -> [Reward] {
  let rewards = project.rewards
  var allowedDisplay = true
  var backedReward: Reward?

  if let backing = project.personalization.backing {
    backedReward = reward(from: backing, inProject: project)
  }

  let isRewardBeingBacked: (Reward) -> Bool = { reward in
    var rewardIsBacked = false

    if let backedRewardExists = backedReward,
      backedRewardExists.id == reward.id {
      rewardIsBacked = true
    }

    return rewardIsBacked
  }

  let allowedNonbackedRewardsFromFeatureFlagRules = rewards.filter { reward in
    allowedDisplay = true

    if !featureRewardLocalPickupEnabled(),
      isRewardLocalPickup(reward),
      !isRewardBeingBacked(reward) {
      allowedDisplay = false
    }

    return allowedDisplay
  }

  return allowedNonbackedRewardsFromFeatureFlagRules
}
