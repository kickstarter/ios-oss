import Foundation
import KsApi
import Prelude
import ReactiveSwift

public typealias ProjectSummaryItem = Int

public protocol ProjectSummaryCarouselViewModelInputs {
  func configure(with items: [ProjectSummaryItem])
}

public protocol ProjectSummaryCarouselViewModelOutputs {
  var loadProjectSummaryItemsIntoDataSource: Signal<[ProjectSummaryItem], Never> { get }
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

  private let itemsProperty = MutableProperty<[ProjectSummaryItem]?>(nil)
  public func configure(with items: [ProjectSummaryItem]) {
    self.itemsProperty.value = items
  }

  public let loadProjectSummaryItemsIntoDataSource: Signal<[ProjectSummaryItem], Never>

  public var inputs: ProjectSummaryCarouselViewModelInputs { return self }
  public var outputs: ProjectSummaryCarouselViewModelOutputs { return self }
}
