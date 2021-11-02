import KsApi
import Prelude
import ReactiveSwift

public protocol ProjectEnvironmentalCommitmentCellViewModelInputs {
  /// Call to configure with a `ProjectEnvironmentalCommitment`.
  func configureWith(value: ProjectEnvironmentalCommitment)
}

public protocol ProjectEnvironmentalCommitmentCellViewModelOutputs {
  /// Emits a `String` of the category from the `ProjectEnvironmentalCommitment` object
  var categoryLabelText: Signal<String, Never> { get }

  /// Emits a `String` of the description from the `ProjectEnvironmentalCommitment` object
  var descriptionLabelText: Signal<String, Never> { get }
}

public protocol ProjectEnvironmentalCommitmentCellViewModelType {
  var inputs: ProjectEnvironmentalCommitmentCellViewModelInputs { get }
  var outputs: ProjectEnvironmentalCommitmentCellViewModelOutputs { get }
}

public final class ProjectEnvironmentalCommitmentCellViewModel:
  ProjectEnvironmentalCommitmentCellViewModelType, ProjectEnvironmentalCommitmentCellViewModelInputs,
  ProjectEnvironmentalCommitmentCellViewModelOutputs {
  public init() {
    let environmentalCommitment = self.configureWithProperty.signal
      .skipNil()

    self.categoryLabelText = environmentalCommitment.map(\.category.rawValue)
    self.descriptionLabelText = environmentalCommitment.map(\.description)
  }

  fileprivate let configureWithProperty = MutableProperty<ProjectEnvironmentalCommitment?>(nil)
  public func configureWith(value: ProjectEnvironmentalCommitment) {
    self.configureWithProperty.value = value
  }

  public let categoryLabelText: Signal<String, Never>
  public let descriptionLabelText: Signal<String, Never>

  public var inputs: ProjectEnvironmentalCommitmentCellViewModelInputs { self }
  public var outputs: ProjectEnvironmentalCommitmentCellViewModelOutputs { self }
}
