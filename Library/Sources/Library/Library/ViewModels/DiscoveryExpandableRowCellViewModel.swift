import KsApi
import Prelude
import ReactiveSwift
import UIKit

public protocol DiscoveryExpandableRowCellInputs {
  func configureWith(row: ExpandableRow, categoryId: Int?)
  func willDisplay()
}

public protocol DiscoveryExpandableRowCellOutputs {
  var cellAccessibilityHint: Signal<String, Never> { get }
  var cellAccessibilityLabel: Signal<String, Never> { get }
  var expandCategoryStyle: Signal<(ExpandableRow, Int?), Never> { get }
  var filterIsExpanded: Signal<Bool, Never> { get }
  var filterTitleLabelText: Signal<String, Never> { get }
  var projectsCountLabelAlpha: Signal<CGFloat, Never> { get }
  var projectsCountLabelHidden: Signal<Bool, Never> { get }
  var projectsCountLabelText: Signal<String, Never> { get }
}

public protocol DiscoveryExpandableRowCellViewModelType {
  var inputs: DiscoveryExpandableRowCellInputs { get }
  var outputs: DiscoveryExpandableRowCellOutputs { get }
}

public final class DiscoveryExpandableRowCellViewModel: DiscoveryExpandableRowCellViewModelType,
  DiscoveryExpandableRowCellInputs, DiscoveryExpandableRowCellOutputs {
  public init() {
    let expandableRowAndCategoryId = self.expandableRowAndCategoryIdProperty.signal.skipNil()
      .takeWhen(self.willDisplayProperty.signal)

    let expandableRow = expandableRowAndCategoryId.map(first)

    self.expandCategoryStyle = expandableRowAndCategoryId

    self.filterTitleLabelText = expandableRow
      .map { $0.params.category?.name ?? "" }

    self.filterIsExpanded = expandableRow
      .map { $0.isExpanded }

    self.cellAccessibilityHint = expandableRow
      .map { $0.isExpanded ? Strings.Collapses_subcategories() : Strings.Expands_subcategories() }

    self.cellAccessibilityLabel = expandableRow
      .map {
        Strings.Filter_name_project_count_live_projects(
          filter_name: $0.params.category?.name ?? "",
          project_count: $0.params.category?.totalProjectCount ?? 0
        )
      }

    self.projectsCountLabelText = expandableRow
      .map { Format.wholeNumber($0.params.category?.totalProjectCount ?? 0) }

    self.projectsCountLabelHidden = expandableRow
      .map { $0.params.category?.totalProjectCount == .some(0) }

    self.projectsCountLabelAlpha = expandableRowAndCategoryId
      .map { expandableRow, categoryId in categoryId == nil || expandableRow.isExpanded ? 1.0 : 0.4 }
  }

  fileprivate let expandableRowAndCategoryIdProperty = MutableProperty<(ExpandableRow, Int?)?>(nil)
  public func configureWith(row: ExpandableRow, categoryId: Int?) {
    self.expandableRowAndCategoryIdProperty.value = (row, categoryId)
  }

  fileprivate let willDisplayProperty = MutableProperty(())
  public func willDisplay() {
    self.willDisplayProperty.value = ()
  }

  public let cellAccessibilityHint: Signal<String, Never>
  public let cellAccessibilityLabel: Signal<String, Never>
  public let expandCategoryStyle: Signal<(ExpandableRow, Int?), Never>
  public let filterIsExpanded: Signal<Bool, Never>
  public let filterTitleLabelText: Signal<String, Never>
  public let projectsCountLabelAlpha: Signal<CGFloat, Never>
  public let projectsCountLabelHidden: Signal<Bool, Never>
  public let projectsCountLabelText: Signal<String, Never>

  public var inputs: DiscoveryExpandableRowCellInputs { return self }
  public var outputs: DiscoveryExpandableRowCellOutputs { return self }
}
