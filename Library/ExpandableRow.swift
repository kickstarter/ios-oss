import KsApi
import Prelude

public struct ExpandableRow {
  public fileprivate(set) var isExpanded: Bool
  public fileprivate(set) var params: DiscoveryParams
  public fileprivate(set) var selectableRows: [SelectableRow]

    public enum lens {
    public static let isExpanded = Lens<ExpandableRow, Bool>(
      view: { $0.isExpanded },
      set: { ExpandableRow(isExpanded: $0, params: $1.params, selectableRows: $1.selectableRows) }
    )

    public static let params = Lens<ExpandableRow, DiscoveryParams>(
      view: { $0.params },
      set: { ExpandableRow(isExpanded: $1.isExpanded, params: $0, selectableRows: $1.selectableRows) }
    )

    public static let selectableRows = Lens<ExpandableRow, [SelectableRow]>(
      view: { $0.selectableRows },
      set: { ExpandableRow(isExpanded: $1.isExpanded, params: $1.params, selectableRows: $0) }
    )
  }
}

public extension Lens where Whole == ExpandableRow, Part == DiscoveryParams {
  public var social: Lens<ExpandableRow, Bool?> {
    return ExpandableRow.lens.params..DiscoveryParams.lens.social
  }
  public var staffPicks: Lens<ExpandableRow, Bool?> {
    return ExpandableRow.lens.params..DiscoveryParams.lens.staffPicks
  }
  public var starred: Lens<ExpandableRow, Bool?> {
    return ExpandableRow.lens.params..DiscoveryParams.lens.starred
  }
  public var category: Lens<ExpandableRow, KsApi.Category?> {
    return ExpandableRow.lens.params..DiscoveryParams.lens.category
  }
}

extension ExpandableRow: Equatable {}
public func == (lhs: ExpandableRow, rhs: ExpandableRow) -> Bool {
  return lhs.isExpanded == rhs.isExpanded &&
    lhs.params == rhs.params &&
    lhs.selectableRows == rhs.selectableRows
}
