import KsApi
import Prelude
import ReactiveSwift
import UIKit

public enum RewardsCollectionViewContext {
  case createPledge
  case managePledge
}

public protocol RewardsCollectionViewModelInputs {
  func configure(
    with project: Project,
    refTag: RefTag?,
    context: RewardsCollectionViewContext,
    secretRewardToken: String?
  )
  func confirmedEditReward()
  func rewardCellShouldShowDividerLine(_ show: Bool)
  func rewardSelected(with rewardId: Int)
  func shippingLocationViewDidFailToLoad()
  func shippingLocationSelected(_ location: Location?)
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
  var goToCustomizeYourReward: Signal<PledgeViewData, Never> { get }
  var navigationBarShadowImageHidden: Signal<Bool, Never> { get }
  var reloadDataWithValues: Signal<[RewardCardViewData], Never> { get }
  var showPlaceholderRewardCards: Signal<Int, Never> { get }
  var rewardsCollectionViewFooterIsHidden: Signal<Bool, Never> { get }
  var scrollToRewardIndexPath: Signal<IndexPath, Never> { get }
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
    let configData = self.configDataProperty.signal
      .skipNil()
      .takeWhen(self.viewDidLoadProperty.signal)

    let project = configData
      .map { $0.0 }

    let secretRewardToken = configData
      .map { _, _, _, secretRewardToken in
        secretRewardToken
      }

    self.title = configData
      .map { project, _, context, _ in (context, project) }
      .takeWhen(self.viewDidLoadProperty.signal)
      .map(titleForContext)

    // The actual selected shipping location.
    // Can be nil if the project has no shippable rewards.
    let selectedShippingLocation: Signal<Location?, Never> = self.shippingLocationSelectedSignal

    // The country to which we should filter the rewards.
    // TODO: If we passed in ShippableCountries to the location selector, we could call this faster.
    let filterCountry: Signal<String?, Never> = self.shippingLocationSelectedSignal
      .signal
      .map { $0?.country }
      .skipRepeats()

    let isLoadingProperty = MutableProperty(true)

    // Fetch the sorted rewards when a shipping country code is selected
    let fetchedRewards = project
      .combineLatest(with: filterCountry)
      .on(value: { _ in
        isLoadingProperty.value = true
      })
      .flatMap { project, location in
        AppEnvironment.current.apiService
          .fetchProjectRewardsWithNoReward(
            projectId: project.id,
            sortedForShippingCountryCode: location
          )
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
          .values()
          .on(completed: {
            isLoadingProperty.value = false
          })
      }
      .map(filteredRewards)

    self.scrollToRewardIndexPath = Signal.combineLatest(
      project,
      fetchedRewards,
      secretRewardToken,
      self.viewDidLayoutSubviewsProperty.signal
    )
    .map { project, rewards, secretRewardToken, _ in
      rewardToScrollIndexPath(
        project,
        rewards: rewards,
        secretRewardToken: secretRewardToken
      )
    }
    .skipNil()
    .take(first: 1)

    let isLoading = isLoadingProperty
      .signal(takeInitialValueWhen: configData.ignoreValues())
      .skipRepeats()

    self.showPlaceholderRewardCards = project
      .combineLatestAndFilterOn(isLoading)
      .map { $0.rewards.count }

    self.reloadDataWithValues = Signal.combineLatest(
      project,
      fetchedRewards,
      selectedShippingLocation
    )
    .combineLatestAndFilterOn(isLoading.signal.negate())
    .map { project, rewards, location in
      rewards.map { reward in
        RewardCardViewData(
          project: project,
          reward: reward,
          context: .pledge,
          currentShippingLocation: location
        )
      }
    }

    self.configureRewardsCollectionViewFooterWithCount = self.reloadDataWithValues
      .map { $0.count }

    self.flashScrollIndicators = self.viewDidAppearProperty.signal

    // MARK: Shipping Location

    let selectedShippingRule: Signal<ShippingRule?, Never> = selectedShippingLocation
      .takePairWhen(self.selectedRewardProperty.signal.skipNil())
      .map { location, reward in
        shippingRule(forReward: reward, selectedLocation: location)
      }

    let selectedRewardFromId = fetchedRewards
      .takePairWhen(self.rewardSelectedWithRewardIdProperty.signal.skipNil())
      .map { rewards, rewardId in
        rewards.first(where: { $0.id == rewardId })
      }
      .skipNil()

    self.selectedRewardProperty <~ selectedRewardFromId

    let refTag = configData
      .map { $0.1 }

    let goToPledge: Signal<(PledgeViewData, Bool), Never> = Signal.combineLatest(
      project,
      selectedRewardFromId,
      refTag,
      selectedShippingRule
    )
    .takeWhen(self.rewardSelectedWithRewardIdProperty.signal)
    .filter { project, reward, _, shippingRule in
      rewardsCarouselCanNavigateToReward(
        reward,
        in: project,
        selectedShippingLocation: shippingRule?.location
      )
    }
    .map { project, reward, refTag, selectedShippingRule -> (PledgeViewData, Bool) in
      let pledgeContext =
        project.isInPostCampaignPledgingPhase
          ? PledgeViewContext.latePledge
          : PledgeViewContext.pledge

      /// Differentiating between updating a reward for a regular pledge and updating a Pledge Over Time pledge.
      let isPledgeOverTime = project.isPledgeOverTimeAllowed == true
      let updatePledgeContext = isPledgeOverTime
        ? PledgeViewContext.editPledgeOverTime
        : PledgeViewContext.updateReward

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        bonusSupport: nil,
        selectedShippingRule: selectedShippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil, // Set during add-ons selection.
        refTag: refTag,
        context: project.personalization.backing == nil ? pledgeContext : updatePledgeContext
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

    self.goToCustomizeYourReward = Signal.merge(
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
    )
    .takeWhen(self.viewDidLoadProperty.signal)
    .observeValues { project, refTag in
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

    // Facebook CAPI + Google Analytics
    _ = Signal.combineLatest(project, self.viewDidAppearProperty.signal.ignoreValues())
      .observeValues { projectAndRefTag in
        let (project, _) = projectAndRefTag

        AppEnvironment.current.appTrackingTransparency.updateAdvertisingIdentifier()

        guard let externalId = AppEnvironment.current.appTrackingTransparency.advertisingIdentifier
        else { return }

        var userId = ""

        if let userValue = AppEnvironment.current.currentUser {
          userId = "\(userValue.id)"
        }

        let projectId = "\(project.id)"

        var extInfo = Array(repeating: "", count: 16)
        extInfo[0] = "i2"
        extInfo[4] = AppEnvironment.current.mainBundle.platformVersion

        _ = AppEnvironment
          .current
          .apiService
          .triggerThirdPartyEventInput(
            input: .init(
              deviceId: externalId,
              eventName: ThirdPartyEventInputName.RewardSelectionViewed.rawValue,
              projectId: projectId,
              pledgeAmount: nil,
              shipping: nil,
              transactionId: nil,
              userId: userId,
              appData: .init(
                advertiserTrackingEnabled: true,
                applicationTrackingEnabled: true,
                extinfo: extInfo
              ),
              clientMutationId: ""
            )
          )
      }
  }

  private let configDataProperty = MutableProperty<(
    Project,
    RefTag?,
    RewardsCollectionViewContext,
    String?
  )?>(nil)
  public func configure(
    with project: Project,
    refTag: RefTag?,
    context: RewardsCollectionViewContext,
    secretRewardToken: String?
  ) {
    self.configDataProperty.value = (project, refTag, context, secretRewardToken)
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

  private let shippingLocationViewDidFailToLoadProperty = MutableProperty(())
  public func shippingLocationViewDidFailToLoad() {
    self.shippingLocationViewDidFailToLoadProperty.value = ()
  }

  private let (shippingLocationSelectedSignal, shippingLocationSelectedObserver) = Signal<Location?, Never>
    .pipe()
  public func shippingLocationSelected(_ location: Location?) {
    self.shippingLocationSelectedObserver.send(value: location)
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
  public let goToCustomizeYourReward: Signal<PledgeViewData, Never>
  public let navigationBarShadowImageHidden: Signal<Bool, Never>
  public let reloadDataWithValues: Signal<[RewardCardViewData], Never>
  public let showPlaceholderRewardCards: Signal<Int, Never>
  public let rewardsCollectionViewFooterIsHidden: Signal<Bool, Never>
  public let scrollToRewardIndexPath: Signal<IndexPath, Never>
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

/// Returns the `IndexPath` of the reward to auto-scroll to in the collection view.
/// If a `secretRewardToken` is provided, it returns the first secret reward's index.
/// Otherwise, it returns the index of the backed reward (if the project is backed).
private func rewardToScrollIndexPath(
  _ project: Project,
  rewards: [Reward],
  secretRewardToken: String?
) -> IndexPath? {
  if let secretRewardToken = secretRewardToken, !secretRewardToken.isEmpty {
    return firstSecretRewardIndexPath(rewards: rewards)
  }

  return backedRewardIndexPath(project, rewards: rewards)
}

private func firstSecretRewardIndexPath(rewards: [Reward]) -> IndexPath? {
  return rewards.firstIndex(where: { $0.isSecretReward && $0.isAvailable == true })
    .flatMap { IndexPath(row: $0, section: 0) }
}

private func backedRewardIndexPath(_ project: Project, rewards: [Reward]) -> IndexPath? {
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

private func filteredRewards(
  _ rewards: [Reward]
) -> [Reward] {
  return rewards.filter { shouldShowReward($0) }
}

private func shouldShowReward(
  _ reward: Reward
) -> Bool {
  // Check if the reward isn't available yet.
  // These are usually filtered out by the backend, but may be visible if you're the project creator.
  // We filter these out so that creators aren't concerned that backers may see them.
  if !isStartDateBeforeToday(for: reward) {
    return false
  }

  return true
}

private func shippingRule(forReward reward: Reward, selectedLocation location: Location?) -> ShippingRule? {
  guard let selectedLocation = location else {
    return nil
  }

  // Whether or not this is a "shippable" reward.
  // "No Reward", digital rewards and local pickup rewards are not shippable.
  let hasShipping = reward.isRestrictedShippingPreference || reward.isUnRestrictedShippingPreference

  guard let rules = reward.shippingRulesExpanded else {
    assert(
      !hasShipping,
      "This reward is shippable, but no shipping rules were included on the reward. The backer may not be able to complete this pledge."
    )

    return nil
  }

  guard var rule = rules.first(where: { $0.location.id == selectedLocation.id }) else {
    assert(
      !hasShipping,
      "This reward is shippable, but no shipping rule matched the selected location. The backer may not be able to complete this pledge."
    )

    return nil
  }

  return rule
}

// Combines a value signal with a boolean signal, returning filtered results.
//
// This will fire when _either_ the value signal, or the boolean signal, fires -
// unlike filterWhenLatestFrom(someSignal, satisfies: isTrue), which will only fire
// when the value signal changes.
private extension Signal where Error == Never {
  func combineLatestAndFilterOn(_ signal: Signal<Bool, Never>) -> Signal<Value, Never> {
    return self.combineLatest(with: signal)
      .filter { _, test in test == true }
      .map { value, _ in value }
  }
}
