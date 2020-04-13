import Foundation
import KsApi
import Prelude
import ReactiveSwift

public protocol ProjectSummaryCarouselViewModelInputs {
  func configure(with items: [ProjectSummaryEnvelope.ProjectSummaryItem])
}

public protocol ProjectSummaryCarouselViewModelOutputs {
  var loadProjectSummaryItemsIntoDataSource:
    Signal<[ProjectSummaryEnvelope.ProjectSummaryItem], Never> { get }
}

public protocol ProjectSummaryCarouselViewModelType {
  var inputs: ProjectSummaryCarouselViewModelInputs { get }
  var outputs: ProjectSummaryCarouselViewModelOutputs { get }
}

public final class ProjectSummaryCarouselViewModel: ProjectSummaryCarouselViewModelType,
  ProjectSummaryCarouselViewModelInputs, ProjectSummaryCarouselViewModelOutputs {
  public init() {
    self.loadProjectSummaryItemsIntoDataSource = self.itemsProperty.signal.skipNil()
  }

  private let itemsProperty = MutableProperty<[ProjectSummaryEnvelope.ProjectSummaryItem]?>(nil)
  public func configure(with items: [ProjectSummaryEnvelope.ProjectSummaryItem]) {
    self.itemsProperty.value = items
  }

  public let loadProjectSummaryItemsIntoDataSource: Signal<[ProjectSummaryEnvelope.ProjectSummaryItem], Never>

  public var inputs: ProjectSummaryCarouselViewModelInputs { return self }
  public var outputs: ProjectSummaryCarouselViewModelOutputs { return self }
}
