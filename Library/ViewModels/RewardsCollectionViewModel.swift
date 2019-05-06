import Foundation
import ReactiveSwift
import Result
import KsApi
import Prelude

public protocol RewardsCollectionViewModelOutputs {
  var reloadDataWithRewards: Signal<[Reward], NoError> { get }
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
    self.reloadDataWithRewards = Signal.combineLatest(
      self.configureWithProjectProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    )
      .map(first)
      .map { $0.rewards }
  }

  private let configureWithProjectProperty = MutableProperty<Project?>(nil)
  private let configureWithRefTagProperty = MutableProperty<RefTag?>(nil)
  public func configure(with project: Project, refTag: RefTag?) {
    self.configureWithProjectProperty.value = project
    self.configureWithRefTagProperty.value = refTag
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let reloadDataWithRewards: Signal<[Reward], NoError>

  public var inputs: RewardsCollectionViewModelInputs { return self }
  public var outputs: RewardsCollectionViewModelOutputs { return self }
}
