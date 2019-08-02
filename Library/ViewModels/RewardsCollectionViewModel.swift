import Foundation
import KsApi
import Prelude
import ReactiveSwift

public typealias PledgeData = (project: Project, reward: Reward, refTag: RefTag?)

public protocol RewardsCollectionViewModelInputs {
  func configure(with project: Project, refTag: RefTag?)
  func rewardSelected(with rewardId: Int)
  func viewDidLoad()
}

public protocol RewardsCollectionViewModelOutputs {
  var goToDeprecatedPledge: Signal<PledgeData, Never> { get }
  var goToPledge: Signal<PledgeData, Never> { get }
  var reloadDataWithValues: Signal<[(Project, Either<Reward, Backing>)], Never> { get }
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
    .map { project, reward, refTag in
      PledgeData(project: project, reward: reward, refTag: refTag)
    }

    self.goToPledge = goToPledge
      .filter { _ in featureNativeCheckoutPledgeViewEnabled() }

    self.goToDeprecatedPledge = goToPledge
      .filter { _ in !featureNativeCheckoutPledgeViewEnabled() }
  }

  private let configDataProperty = MutableProperty<(Project, RefTag?)?>(nil)
  public func configure(with project: Project, refTag: RefTag?) {
    self.configDataProperty.value = (project, refTag)
  }

  private let rewardSelectedWithRewardIdProperty = MutableProperty<Int?>(nil)
  public func rewardSelected(with rewardId: Int) {
    self.rewardSelectedWithRewardIdProperty.value = rewardId
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let goToDeprecatedPledge: Signal<PledgeData, Never>
  public let goToPledge: Signal<PledgeData, Never>
  public let reloadDataWithValues: Signal<[(Project, Either<Reward, Backing>)], Never>

  private let selectedRewardProperty = MutableProperty<Reward?>(nil)
  public func selectedReward() -> Reward? {
    return self.selectedRewardProperty.value
  }

  public var inputs: RewardsCollectionViewModelInputs { return self }
  public var outputs: RewardsCollectionViewModelOutputs { return self }
}
