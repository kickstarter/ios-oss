import Foundation
import KsApi
import Prelude
import ReactiveSwift

public typealias PledgeData = (project: Project, reward: Reward, refTag: RefTag?)

public enum RewardsCollectionViewContext {
  case createPledge
  case managePledge
}

public protocol RewardsCollectionViewModelInputs {
  func configure(with project: Project, refTag: RefTag?, context: RewardsCollectionViewContext)
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
  var goToDeprecatedPledge: Signal<PledgeData, Never> { get }
  var goToPledge: Signal<(PledgeData, PledgeViewContext), Never> { get }
  var navigationBarShadowImageHidden: Signal<Bool, Never> { get }
  var reloadDataWithValues: Signal<[(Project, Either<Reward, Backing>)], Never> { get }
  var rewardsCollectionViewFooterIsHidden: Signal<Bool, Never> { get }
  var scrollToBackedRewardIndexPath: Signal<IndexPath, Never> { get }
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
      .map { $0.rewards }

    let context = configData.map(third)

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
        rewards.map { (project, Either<Reward, Backing>.left($0)) }
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
    .filter { project, _, _ in project.state == .live }
    .map { project, reward, refTag in
      PledgeData(project: project, reward: reward, refTag: refTag)
    }

    self.goToPledge = goToPledge
      .filter { project, reward, _ in
        featureNativeCheckoutPledgeViewIsEnabled() && !userIsBacking(reward: reward, inProject: project)
      }
      .map { data in
        (data, data.project.personalization.backing == nil ? .pledge : .updateReward)
      }

    self.goToDeprecatedPledge = goToPledge
      .filter { _ in
        !featureNativeCheckoutPledgeViewIsEnabled()
      }

    self.rewardsCollectionViewFooterIsHidden = self.traitCollectionChangedProperty.signal
      .skipNil()
      .map { isFalse($0.verticalSizeClass == .regular) }

    let hideDividerLine = self.rewardCellShouldShowDividerLineProperty.signal
      .negate()

    self.navigationBarShadowImageHidden = Signal.merge(
      hideDividerLine,
      hideDividerLine.takeWhen(self.viewWillAppearProperty.signal)
    )

    let pledgeContext = context
      .map(trackingPledgeContext(for:))

    // Tracking
    Signal.combineLatest(project, selectedRewardFromId, pledgeContext, refTag)
      .observeValues { project, reward, context, refTag in
        AppEnvironment.current.koala.trackRewardClicked(
          project: project,
          reward: reward,
          context: context,
          refTag: refTag
        )
      }
  }

  private let configDataProperty = MutableProperty<(Project, RefTag?, RewardsCollectionViewContext)?>(nil)
  public func configure(with project: Project, refTag: RefTag?, context: RewardsCollectionViewContext) {
    self.configDataProperty.value = (project, refTag, context)
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
  public let goToDeprecatedPledge: Signal<PledgeData, Never>
  public let goToPledge: Signal<(PledgeData, PledgeViewContext), Never>
  public let navigationBarShadowImageHidden: Signal<Bool, Never>
  public let reloadDataWithValues: Signal<[(Project, Either<Reward, Backing>)], Never>
  public let rewardsCollectionViewFooterIsHidden: Signal<Bool, Never>
  public let scrollToBackedRewardIndexPath: Signal<IndexPath, Never>
  public let title: Signal<String, Never>

  private let selectedRewardProperty = MutableProperty<Reward?>(nil)
  public func selectedReward() -> Reward? {
    return self.selectedRewardProperty.value
  }

  public var inputs: RewardsCollectionViewModelInputs { return self }
  public var outputs: RewardsCollectionViewModelOutputs { return self }
}

private func titleForContext(_ context: RewardsCollectionViewContext, project: Project) -> String {
  if currentUserIsCreator(of: project) {
    return Strings.View_your_rewards()
  }

  guard project.state == .live else {
    return Strings.View_rewards()
  }

  return context == .createPledge ? Strings.Back_this_project() : Strings.Choose_another_reward()
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

private func trackingPledgeContext(for rewardsContext: RewardsCollectionViewContext) -> Koala.PledgeContext {
  switch rewardsContext {
  case .createPledge:
    return Koala.PledgeContext.newPledge
  case .managePledge:
    return Koala.PledgeContext.changeReward
  }
}
