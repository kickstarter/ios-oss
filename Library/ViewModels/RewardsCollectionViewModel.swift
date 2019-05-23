import Foundation
import ReactiveSwift
import Result
import KsApi
import Prelude

public protocol RewardsCollectionViewModelOutputs {
  var reloadDataWithValues: Signal<[(Project, Either<Reward, Backing>)], NoError> { get }
}

public protocol RewardsCollectionViewModelInputs {
  func configure(with project: Project, refTag: RefTag?)
  func viewDidLoad()
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
      self.viewDidLoadProperty.signal)
      .map(first)

    self.reloadDataWithValues = Signal.combineLatest(project, rewards)
      .map { project, rewards in
        return rewards.map { (project, Either<Reward, Backing>.left($0)) }
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

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let reloadDataWithValues: Signal<[(Project, Either<Reward, Backing>)], NoError>

  public var inputs: RewardsCollectionViewModelInputs { return self }
  public var outputs: RewardsCollectionViewModelOutputs { return self }
}
