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
    let project = Signal.combineLatest(
      self.configureWithProjectProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    )
    .map(first)

    let rewards = Signal.combineLatest(
      self.configureWithRewardsProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    )
    .map(first)

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

    self.goToPledge = Signal.combineLatest(
      self.configureWithProjectProperty.signal.skipNil(),
      selectedRewardFromId,
      self.configureWithRefTagProperty.signal
    )
    .map { project, reward, refTag in
      PledgeData(project: project, reward: reward, refTag: refTag)
    }
  }

  private let configureWithProjectProperty = MutableProperty<Project?>(nil)
  private let configureWithRewardsProperty = MutableProperty<[Reward]?>(nil)
  private let configureWithRefTagProperty = MutableProperty<RefTag?>(nil)
  public func configure(with project: Project, refTag: RefTag?) {
    self.configureWithProjectProperty.value = project
    self.configureWithRewardsProperty.value = project.rewards
    self.configureWithRefTagProperty.value = refTag
  }

  private let rewardSelectedWithRewardIdProperty = MutableProperty<Int?>(nil)
  public func rewardSelected(with rewardId: Int) {
    self.rewardSelectedWithRewardIdProperty.value = rewardId
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let goToPledge: Signal<PledgeData, Never>
  public let reloadDataWithValues: Signal<[(Project, Either<Reward, Backing>)], Never>

  private let selectedRewardProperty = MutableProperty<Reward?>(nil)
  public func selectedReward() -> Reward? {
    return self.selectedRewardProperty.value
  }

  public var inputs: RewardsCollectionViewModelInputs { return self }
  public var outputs: RewardsCollectionViewModelOutputs { return self }
}
