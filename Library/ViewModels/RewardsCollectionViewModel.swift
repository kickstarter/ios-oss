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
  func viewDidLoad()
  func viewWillAppear()
}

public protocol RewardsCollectionViewModelOutputs {
  var backedRewardIndexPath: Signal<IndexPath, Never> { get }
  var configureRewardsCollectionViewFooterWithCount: Signal<Int, Never> { get }
  var flashScrollIndicators: Signal<Void, Never> { get }
  var goToDeprecatedPledge: Signal<PledgeData, Never> { get }
  var goToPledge: Signal<(PledgeData, PledgeViewContext), Never> { get }
  var navigationBarShadowImageHidden: Signal<Bool, Never> { get }
  var reloadDataWithValues: Signal<[(Project, Either<Reward, Backing>)], Never> { get }
  var rewardsCollectionViewFooterIsHidden: Signal<Bool, Never> { get }
  var title: Signal<String, Never> { get }
  func selectedReward() -> Reward?
}

protocol RewardsCollectionViewModelType {
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

    self.title = configData
      .map(third)
      .takeWhen(self.viewDidLoadProperty.signal.ignoreValues())
      .map(title(for:))

    self.reloadDataWithValues = Signal.combineLatest(project, rewards)
      .map { project, rewards in
        rewards.map { (project, Either<Reward, Backing>.left($0)) }
      }

    self.backedRewardIndexPath = Signal.combineLatest(project, rewards)
      .takeWhen(self.viewDidAppearProperty.signal.ignoreValues())
      .map(backedReward(_:rewards:))
      .skipNil()

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
    .filter { arg in
      let (project, _, _) = arg

      return project.state == .live
    }
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

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let viewWillAppearProperty = MutableProperty(())
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  public let backedRewardIndexPath: Signal<IndexPath, Never>
  public let configureRewardsCollectionViewFooterWithCount: Signal<Int, Never>
  public let flashScrollIndicators: Signal<Void, Never>
  public let goToDeprecatedPledge: Signal<PledgeData, Never>
  public let goToPledge: Signal<(PledgeData, PledgeViewContext), Never>
  public let navigationBarShadowImageHidden: Signal<Bool, Never>
  public let reloadDataWithValues: Signal<[(Project, Either<Reward, Backing>)], Never>
  public let rewardsCollectionViewFooterIsHidden: Signal<Bool, Never>
  public let title: Signal<String, Never>

  private let selectedRewardProperty = MutableProperty<Reward?>(nil)
  public func selectedReward() -> Reward? {
    return self.selectedRewardProperty.value
  }

  public var inputs: RewardsCollectionViewModelInputs { return self }
  public var outputs: RewardsCollectionViewModelOutputs { return self }
}

private func title(for context: RewardsCollectionViewContext) -> String {
  return context == .createPledge ? Strings.Back_this_project() : Strings.Choose_another_reward()
}

private func backedReward(_ project: Project, rewards: [Reward]) -> IndexPath? {
  if let reward = rewards.first(where: { userIsBacking(reward: $0, inProject: project) }) {
    return rewards
      .firstIndex(where: { $0.id == reward.id })
      .flatMap { IndexPath(row: $0, section: 0) }
  }
  return nil
}
