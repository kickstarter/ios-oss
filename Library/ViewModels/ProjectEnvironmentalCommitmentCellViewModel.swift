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

    self.categoryLabelText = environmentalCommitment
      .map(\.category)
      .map(internationalizedString)

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

private func internationalizedString(for category: ProjectCommitmentCategory) -> String {
  switch category {
  case .longLastingDesign:
    return Strings.Long_lasting_design()
  case .sustainableMaterials:
    return Strings.Sustainable_materials()
  case .environmentallyFriendlyFactories:
    return Strings.Environmentally_friendly_factories()
  case .sustainableDistribution:
    return Strings.Sustainable_distribution()
  case .reusabilityAndRecyclability:
    return Strings.Reusability_and_recyclability()
  case .somethingElse:
    return Strings.Something_else()
  }
}
