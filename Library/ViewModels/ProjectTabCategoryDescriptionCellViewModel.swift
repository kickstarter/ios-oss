import KsApi
import Prelude
import ReactiveSwift

public protocol ProjectTabCategoryDescriptionCellViewModelInputs {
  /// Call to configure with a `ProjectTabCategoryDescription`.
  func configureWith(value: ProjectTabCategoryDescription)
}

public protocol ProjectTabCategoryDescriptionCellViewModelOutputs {
  /// Emits a `String` of the category from the `ProjectTabCategoryDescription` object
  var categoryLabelText: Signal<String, Never> { get }

  /// Emits a `String` of the description from the `ProjectTabCategoryDescription` object
  var descriptionLabelText: Signal<String, Never> { get }
}

public protocol ProjectTabCategoryDescriptionCellViewModelType {
  var inputs: ProjectTabCategoryDescriptionCellViewModelInputs { get }
  var outputs: ProjectTabCategoryDescriptionCellViewModelOutputs { get }
}

public final class ProjectTabCategoryDescriptionCellViewModel:
  ProjectTabCategoryDescriptionCellViewModelType, ProjectTabCategoryDescriptionCellViewModelInputs,
  ProjectTabCategoryDescriptionCellViewModelOutputs {
  public init() {
    let categoryDescription = self.configureWithProperty.signal
      .skipNil()

    self.categoryLabelText = categoryDescription
      .map(\.category)
      .map(internationalizedString)

    self.descriptionLabelText = categoryDescription.map(\.description)
  }

  fileprivate let configureWithProperty = MutableProperty<ProjectTabCategoryDescription?>(nil)
  public func configureWith(value: ProjectTabCategoryDescription) {
    self.configureWithProperty.value = value
  }

  public let categoryLabelText: Signal<String, Never>
  public let descriptionLabelText: Signal<String, Never>

  public var inputs: ProjectTabCategoryDescriptionCellViewModelInputs { self }
  public var outputs: ProjectTabCategoryDescriptionCellViewModelOutputs { self }
}

private func internationalizedString(for category: ProjectTabCategory) -> String {
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
  case .aiDisclosureDetailsAndConsent:
    return category.rawValue
  case .aiDisclosureOtherDetails:
    return category.rawValue
  case .somethingElse:
    return Strings.Something_else()
  }
}
