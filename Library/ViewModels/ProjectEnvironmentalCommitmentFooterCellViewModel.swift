import KsApi
import Prelude
import ReactiveSwift

public protocol ProjectEnvironmentalCommitmentFooterCellViewModelInputs {
  /// Call to configure the cell.
  func configure()
}

public protocol ProjectEnvironmentalCommitmentFooterCellViewModelOutputs {
  /// Emits a `String` of the description from the `ProjectEnvironmentalCommitment` object
  var descriptionText: Signal<String, Never> { get }
}

public protocol ProjectEnvironmentalCommitmentFooterCellViewModelType {
  var inputs: ProjectEnvironmentalCommitmentFooterCellViewModelInputs { get }
  var outputs: ProjectEnvironmentalCommitmentFooterCellViewModelOutputs { get }
}

public final class ProjectEnvironmentalCommitmentFooterCellViewModel:
  ProjectEnvironmentalCommitmentFooterCellViewModelType,
  ProjectEnvironmentalCommitmentFooterCellViewModelInputs,
  ProjectEnvironmentalCommitmentFooterCellViewModelOutputs {
  public init() {
    self.descriptionText = self.configureProperty.signal.map { _ in
      "Visit our Environmental Resources Center to learn how Kickstarter encourages sustainable practices."
    }
  }

  fileprivate let configureProperty = MutableProperty(())
  public func configure() {
    self.configureProperty.value = ()
  }

  public let descriptionText: Signal<String, Never>

  public var inputs: ProjectEnvironmentalCommitmentFooterCellViewModelInputs { self }
  public var outputs: ProjectEnvironmentalCommitmentFooterCellViewModelOutputs { self }
}
