import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol DiscoveryExpandableRowCellInputs {
  func configureWith(row: ExpandableRow, categoryId: Int?)
  func willDisplay()
}

public protocol DiscoveryExpandableRowCellOutputs {
  var cellAccessibilityHint: Signal<String, NoError> { get }
  var cellAccessibilityLabel: Signal<String, NoError> { get }
  var expandCategoryStyle: Signal<(ExpandableRow, Int?), NoError> { get }
  var filterIsExpanded: Signal<Bool, NoError> { get }
  var filterTitleLabelText: Signal<String, NoError> { get }
  var projectsCountLabelAlpha: Signal<CGFloat, NoError> { get }
  var projectsCountLabelHidden: Signal<Bool, NoError> { get }
  var projectsCountLabelText: Signal<String, NoError> { get }
  var projectsCountLabelTextColor: Signal<UIColor, NoError> { get }
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
    let categoryId = expandableRowAndCategoryId.map(second)

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
          filter_name: ($0.params.category?.name ?? ""),
          project_count:($0.params.category?.projectsCount ?? 0))
      }

    self.projectsCountLabelText = expandableRow
      .map { Format.wholeNumber($0.params.category?.projectsCount ?? 0) }

    self.projectsCountLabelHidden = expandableRow
      .map { $0.params.category?.projectsCount == .Some(0) }

    self.projectsCountLabelTextColor = categoryId
      .map(discoverySecondaryColor(forCategoryId:))

    self.projectsCountLabelAlpha = expandableRowAndCategoryId
      .map { expandableRow, categoryId in categoryId == nil || expandableRow.isExpanded ? 1.0 : 0.4 }

  }

  fileprivate let expandableRowAndCategoryIdProperty = MutableProperty<(ExpandableRow, Int?)?>(nil)
  public func configureWith(row: ExpandableRow, categoryId: Int?) {
    self.expandableRowAndCategoryIdProperty.value = (row, categoryId)
  }

  fileprivate let willDisplayProperty = MutableProperty()
  public func willDisplay() {
    self.willDisplayProperty.value = ()
  }

  public let cellAccessibilityHint: Signal<String, NoError>
  public let cellAccessibilityLabel: Signal<String, NoError>
  public let expandCategoryStyle: Signal<(ExpandableRow, Int?), NoError>
  public let filterIsExpanded: Signal<Bool, NoError>
  public let filterTitleLabelText: Signal<String, NoError>
  public let projectsCountLabelAlpha: Signal<CGFloat, NoError>
  public let projectsCountLabelHidden: Signal<Bool, NoError>
  public let projectsCountLabelText: Signal<String, NoError>
  public let projectsCountLabelTextColor: Signal<UIColor, NoError>

  public var inputs: DiscoveryExpandableRowCellInputs { return self }
  public var outputs: DiscoveryExpandableRowCellOutputs { return self }
}
