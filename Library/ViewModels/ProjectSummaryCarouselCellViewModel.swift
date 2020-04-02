import Foundation
import KsApi
import Prelude
import ReactiveSwift

public protocol ProjectSummaryCarouselCellViewModelInputs {
  func configure(with item: ProjectSummaryEnvelope.ProjectSummaryItem)
}

public protocol ProjectSummaryCarouselCellViewModelOutputs {
  var title: Signal<String, Never> { get }
  var body: Signal<String, Never> { get }
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

    self.title = item
      .map(\.question.rawValue)

    self.body = item
      .map(\.response)
  }

  private let itemProperty = MutableProperty<ProjectSummaryEnvelope.ProjectSummaryItem?>(nil)
  public func configure(with item: ProjectSummaryEnvelope.ProjectSummaryItem) {
    self.itemProperty.value = item
  }

  public let title: Signal<String, Never>
  public let body: Signal<String, Never>

  public var inputs: ProjectSummaryCarouselCellViewModelInputs { return self }
  public var outputs: ProjectSummaryCarouselCellViewModelOutputs { return self }
}
