import KsApi
import Prelude
import ReactiveSwift

public protocol ProjectEnvironmentalCommitmentsViewModelInputs {
  /// Call with the `[ProjectEnvironmentalCommitment]` given to the view.
  func configureWith(environmentalCommitments: [ProjectEnvironmentalCommitment])

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol ProjectEnvironmentalCommitmentsViewModelOutputs {
  /// Emits a `[ProjectEnvironmentalCommitment]` so the data source can use the environmental commitments to render cells
  var loadEnvironmentalCommitments: Signal<[ProjectEnvironmentalCommitment], Never> { get }
}

public protocol ProjectEnvironmentalCommitmentsViewModelType {
  var inputs: ProjectEnvironmentalCommitmentsViewModelInputs { get }
  var outputs: ProjectEnvironmentalCommitmentsViewModelOutputs { get }
}

public final class ProjectEnvironmentalCommitmentsViewModel: ProjectEnvironmentalCommitmentsViewModelType,
  ProjectEnvironmentalCommitmentsViewModelInputs, ProjectEnvironmentalCommitmentsViewModelOutputs {
  public init() {
    self.loadEnvironmentalCommitments = self.configureDataProperty.signal
      .skipNil()
      .combineLatest(with: self.viewDidLoadProperty.signal)
      .map(first)
  }

  fileprivate let configureDataProperty = MutableProperty<[ProjectEnvironmentalCommitment]?>(nil)
  public func configureWith(environmentalCommitments: [ProjectEnvironmentalCommitment]) {
    self.configureDataProperty.value = environmentalCommitments
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let loadEnvironmentalCommitments: Signal<[ProjectEnvironmentalCommitment], Never>

  public var inputs: ProjectEnvironmentalCommitmentsViewModelInputs { return self }
  public var outputs: ProjectEnvironmentalCommitmentsViewModelOutputs { return self }
}
