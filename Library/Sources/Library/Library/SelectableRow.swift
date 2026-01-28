import KsApi
import Prelude

public struct SelectableRow {
  public let isSelected: Bool
  public let params: DiscoveryParams

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
  var social: Lens<SelectableRow, Bool?> {
    return SelectableRow.lens.params .. DiscoveryParams.lens.social
  }

  var staffPicks: Lens<SelectableRow, Bool?> {
    return SelectableRow.lens.params .. DiscoveryParams.lens.staffPicks
  }

  var starred: Lens<SelectableRow, Bool?> {
    return SelectableRow.lens.params .. DiscoveryParams.lens.starred
  }

  var category: Lens<SelectableRow, KsApi.Category?> {
    return SelectableRow.lens.params .. DiscoveryParams.lens.category
  }

  var includePOTD: Lens<SelectableRow, Bool?> {
    return SelectableRow.lens.params .. DiscoveryParams.lens.includePOTD
  }

  var recommended: Lens<SelectableRow, Bool?> {
    return SelectableRow.lens.params .. DiscoveryParams.lens.recommended
  }

  var backed: Lens<SelectableRow, Bool?> {
    return SelectableRow.lens.params .. DiscoveryParams.lens.backed
  }
}

extension SelectableRow: Equatable {}
public func == (lhs: SelectableRow, rhs: SelectableRow) -> Bool {
  return lhs.isSelected == rhs.isSelected && lhs.params == rhs.params
}
