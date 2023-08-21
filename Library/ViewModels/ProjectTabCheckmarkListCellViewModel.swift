import KsApi
import Prelude
import ReactiveSwift

public protocol ProjectTabCheckmarkListCellViewModelInputs {
  /// Call to configure with a `ProjectTabFundingOptions`.
  func configureWith(value: ProjectTabFundingOptions)
}

public protocol ProjectTabCheckmarkListCellViewModelOutputs {
  /// Emits a `String` of the category
  var categoryLabelText: Signal<String, Never> { get }

  /// Emits an array of `String` descriptions of the funding options
  var descriptionOptionsText: Signal<[String], Never> { get }
}

public protocol ProjectTabCheckmarkListCellViewModelType {
  var inputs: ProjectTabCheckmarkListCellViewModelInputs { get }
  var outputs: ProjectTabCheckmarkListCellViewModelOutputs { get }
}

public final class ProjectTabCheckmarkListCellViewModel:
  ProjectTabCheckmarkListCellViewModelType, ProjectTabCheckmarkListCellViewModelInputs,
  ProjectTabCheckmarkListCellViewModelOutputs {
  public init() {
    let fundingOptions = self.configureWithProperty.signal
      .skipNil()

    self.categoryLabelText = fundingOptions
      .map { _ in Strings.My_project_seeks_funding_for_AI_technology() }

    self.descriptionOptionsText = fundingOptions
      .map { options in
        var optionsTextValues = [String]()

        if options.fundingForAiConsent {
          let consentText = internationalizedString(for: .consent)
          optionsTextValues.append(consentText)
        }

        if options.fundingForAiAttribution {
          let attributionText = internationalizedString(for: .attribution)
          optionsTextValues.append(attributionText)
        }

        if options.fundingForAiOption {
          let ownerText = internationalizedString(for: .option)
          optionsTextValues.append(ownerText)
        }

        return optionsTextValues
      }
  }

  fileprivate let configureWithProperty = MutableProperty<ProjectTabFundingOptions?>(nil)
  public func configureWith(value: ProjectTabFundingOptions) {
    self.configureWithProperty.value = value
  }

  public let categoryLabelText: Signal<String, Never>
  public let descriptionOptionsText: Signal<[String], Never>

  public var inputs: ProjectTabCheckmarkListCellViewModelInputs { self }
  public var outputs: ProjectTabCheckmarkListCellViewModelOutputs { self }
}

private func internationalizedString(for category: ProjectTabAIFundingCategory) -> String {
  switch category {
  case .attribution:
    return Strings.The_owners_of_those_works()
  case .consent:
    return Strings.For_the_database_or_source_I_will_use()
  case .option:
    return Strings.There_is_or_will_be_an_opt()
  }
}
