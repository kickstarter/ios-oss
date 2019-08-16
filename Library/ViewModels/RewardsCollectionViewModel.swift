import Foundation
import KsApi
import Prelude
import ReactiveSwift

public typealias PledgeData = (project: Project, reward: Reward, refTag: RefTag?)

public protocol RewardsCollectionViewModelInputs {
  func configure(with project: Project, refTag: RefTag?)
  func rewardCellShouldShowDividerLine(_ show: Bool)
  func rewardSelected(with rewardId: Int)
  func traitCollectionDidChange(_ traitCollection: UITraitCollection)
  func viewDidAppear()
  func viewDidLoad()
  func viewWillAppear()
}

public protocol RewardsCollectionViewModelOutputs {
  var configureRewardsCollectionViewFooterWithCount: Signal<Int, Never> { get }
  var flashScrollIndicators: Signal<Void, Never> { get }
  var goToDeprecatedPledge: Signal<PledgeData, Never> { get }
  var goToPledge: Signal<PledgeData, Never> { get }
  var goToViewBacking: Signal<(Project, User?), Never> { get }
  var navigationBarShadowImageHidden: Signal<Bool, Never> { get }
  var reloadDataWithValues: Signal<[(Project, Either<Reward, Backing>)], Never> { get }
  var rewardsCollectionViewFooterIsHidden: Signal<Bool, Never> { get }
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
    .filter { arg in
      let (project, _, _) = arg

      return project.state == .live
    }
    .map { project, reward, refTag in
      PledgeData(project: project, reward: reward, refTag: refTag)
    }

    let selectedBacking = project
      .takePairWhen(selectedRewardFromId)
      .filter { project, reward -> Bool in
        project.state != .live && project.personalization.backing?.rewardId == reward.id
      }
      .map(first)

    self.goToViewBacking = selectedBacking
      .map { project in
        (project, AppEnvironment.current.currentUser)
      }

    self.goToPledge = goToPledge
      .filter { _ in featureNativeCheckoutPledgeViewEnabled() }

    self.goToDeprecatedPledge = goToPledge
      .filter { _ in !featureNativeCheckoutPledgeViewEnabled() }

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

  private let configDataProperty = MutableProperty<(Project, RefTag?)?>(nil)
  public func configure(with project: Project, refTag: RefTag?) {
    self.configDataProperty.value = (project, refTag)
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

  public let configureRewardsCollectionViewFooterWithCount: Signal<Int, Never>
  public let flashScrollIndicators: Signal<Void, Never>
  public let goToDeprecatedPledge: Signal<PledgeData, Never>
  public let goToPledge: Signal<PledgeData, Never>
  public let goToViewBacking: Signal<(Project, User?), Never>
  public let navigationBarShadowImageHidden: Signal<Bool, Never>
  public let reloadDataWithValues: Signal<[(Project, Either<Reward, Backing>)], Never>
  public let rewardsCollectionViewFooterIsHidden: Signal<Bool, Never>

  private let selectedRewardProperty = MutableProperty<Reward?>(nil)
  public func selectedReward() -> Reward? {
    return self.selectedRewardProperty.value
  }

  public var inputs: RewardsCollectionViewModelInputs { return self }
  public var outputs: RewardsCollectionViewModelOutputs { return self }
}
