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

    // FIXME: For translations.
    self.categoryLabelText = fundingOptions
      .map { _ in "My project seeks funding for AI technology." }

    // FIXME: For translations.
    self.descriptionOptionsText = fundingOptions
      .map { options in
        var optionsTextValues = [String]()

        if options.fundingForAiConsent {
          let consentText =
            "For the database or source that I will use or will create, the consent of the persons whose works or information incorporated have been obtained."

          optionsTextValues.append(consentText)
        }

        if options.fundingForAiAttribution {
          let attributionText = "The owners of those works is or will be attributed."

          optionsTextValues.append(attributionText)
        }

        if options.fundingForAiOption {
          let ownerText = "There is or will be an opt-in or opt-out for those owners."

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
  case .attribution, .consent, .option:
    return category.rawValue
  }
}
