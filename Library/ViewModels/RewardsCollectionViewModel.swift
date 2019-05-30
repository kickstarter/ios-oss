import Foundation
import KsApi
import Prelude
import ReactiveSwift
public typealias PledgeData = (project: Project, reward: Reward, refTag: RefTag?)

public protocol RewardsCollectionViewModelOutputs {
  var goToPledge: Signal<PledgeData, Never> { get }
  var reloadDataWithRewards: Signal<[Reward], Never> { get }
}

public protocol RewardsCollectionViewModelInputs {
  func configure(with project: Project, refTag: RefTag?)
  func rewardSelected(at index: Int)
  func viewDidLoad()
}

protocol RewardsCollectionViewModelType {
  var inputs: RewardsCollectionViewModelInputs { get }
  var outputs: RewardsCollectionViewModelOutputs { get }
}

public final class RewardsCollectionViewModel: RewardsCollectionViewModelType,
  RewardsCollectionViewModelInputs, RewardsCollectionViewModelOutputs {
  public init() {
    self.reloadDataWithRewards = Signal.combineLatest(
      self.configureWithProjectProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    )
    .map(first)
    .map { $0.rewards }

    let selectedReward = self.reloadDataWithRewards
      .takePairWhen(self.rewardSelectedIndexProperty.signal.skipNil())
      .map { rewards, index in rewards[index] }

    self.goToPledge = Signal.combineLatest(
      self.configureWithProjectProperty.signal.skipNil(),
      selectedReward,
      self.configureWithRefTagProperty.signal
    )
    .map { project, reward, refTag in
      PledgeData(project: project, reward: reward, refTag: refTag)
    }
  }

  private let configureWithProjectProperty = MutableProperty<Project?>(nil)
  private let configureWithRefTagProperty = MutableProperty<RefTag?>(nil)
  public func configure(with project: Project, refTag: RefTag?) {
    self.configureWithProjectProperty.value = project
    self.configureWithRefTagProperty.value = refTag
  }

  private let rewardSelectedIndexProperty = MutableProperty<Int?>(nil)
  public func rewardSelected(at index: Int) {
    self.rewardSelectedIndexProperty.value = index
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let goToPledge: Signal<PledgeData, Never>
  public let reloadDataWithRewards: Signal<[Reward], Never>

  public var inputs: RewardsCollectionViewModelInputs { return self }
  public var outputs: RewardsCollectionViewModelOutputs { return self }
}
