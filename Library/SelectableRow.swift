import KsApi
import Prelude

public struct SelectableRow {
  public fileprivate(set) var isSelected: Bool
  public fileprivate(set) var params: DiscoveryParams

    public enum lens {
    public static let isSelected = Lens<SelectableRow, Bool>(
      view: { $0.isSelected },
      set: { SelectableRow(isSelected: $0, params: $1.params) }
    )

    public static let params = Lens<SelectableRow, DiscoveryParams>(
      view: { $0.params },
      set: { SelectableRow(isSelected: $1.isSelected, params: $0) }
    )
  }
}

public extension Lens where Whole == SelectableRow, Part == DiscoveryParams {
  public var social: Lens<SelectableRow, Bool?> {
    return SelectableRow.lens.params..DiscoveryParams.lens.social
  }
  public var staffPicks: Lens<SelectableRow, Bool?> {
    return SelectableRow.lens.params..DiscoveryParams.lens.staffPicks
  }
  public var starred: Lens<SelectableRow, Bool?> {
    return SelectableRow.lens.params..DiscoveryParams.lens.starred
  }
  public var category: Lens<SelectableRow, KsApi.RootCategoriesEnvelope.Category?> {
    return SelectableRow.lens.params..DiscoveryParams.lens.category
  }
  public var hasLiveStreams: Lens<SelectableRow, Bool?> {
    return SelectableRow.lens.params..DiscoveryParams.lens.hasLiveStreams
  }
  public var includePOTD: Lens<SelectableRow, Bool?> {
    return SelectableRow.lens.params..DiscoveryParams.lens.includePOTD
  }
  public var recommended: Lens<SelectableRow, Bool?> {
    return SelectableRow.lens.params..DiscoveryParams.lens.recommended
  }
  public var backed: Lens<SelectableRow, Bool?> {
    return SelectableRow.lens.params..DiscoveryParams.lens.backed
  }
}

extension SelectableRow: Equatable {}
public func == (lhs: SelectableRow, rhs: SelectableRow) -> Bool {
  return lhs.isSelected == rhs.isSelected && lhs.params == rhs.params
}
