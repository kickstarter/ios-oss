import Foundation
import KsApi
import Prelude
import ReactiveSwift

public protocol ProjectSummaryCarouselCellViewModelInputs {
  func configure(with item: ProjectSummaryEnvelope.ProjectSummaryItem)
}

public protocol ProjectSummaryCarouselCellViewModelOutputs {
  var body: Signal<String, Never> { get }
  var title: Signal<String, Never> { get }
}

public protocol ProjectSummaryCarouselCellViewModelType {
  var inputs: ProjectSummaryCarouselCellViewModelInputs { get }
  var outputs: ProjectSummaryCarouselCellViewModelOutputs { get }
}

public final class ProjectSummaryCarouselCellViewModel: ProjectSummaryCarouselCellViewModelType,
  ProjectSummaryCarouselCellViewModelInputs, ProjectSummaryCarouselCellViewModelOutputs {
  public init() {
    let item = self.itemProperty.signal
      .skipNil()

    self.body = item
      .map(\.response)

    self.title = item
      .map(\.question)
      .map(ProjectSummaryCarouselCellViewModel.titleText(for:))
  }

  private let itemProperty = MutableProperty<ProjectSummaryEnvelope.ProjectSummaryItem?>(nil)
  public func configure(with item: ProjectSummaryEnvelope.ProjectSummaryItem) {
    self.itemProperty.value = item
  }

  public let body: Signal<String, Never>
  public let title: Signal<String, Never>

  public var inputs: ProjectSummaryCarouselCellViewModelInputs { return self }
  public var outputs: ProjectSummaryCarouselCellViewModelOutputs { return self }
}

extension ProjectSummaryCarouselCellViewModel {
  public static func titleText(
    for question: ProjectSummaryEnvelope.ProjectSummaryItem.ProjectSummaryQuestion
  ) -> String {
    switch question {
    case .whatIsTheProject:
      return localizedString(
        key: "What_is_this_project",
        defaultValue: "What is this project?"
      )
    case .whatWillYouDoWithTheMoney:
      return localizedString(
        key: "How_will_the_funds_bring_it_to_life",
        defaultValue: "How will the funds bring it to life?"
      )
    case .whoAreYou:
      return localizedString(
        key: "Who_is_the_creator",
        defaultValue: "Who is the creator?"
      )
    }
  }
}
