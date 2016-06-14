import KsApi
import Prelude

public struct SelectableRow {
  public let isSelected: Bool
  public let params: DiscoveryParams

  // swiftlint:disable type_name
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
  // swiftlint:enable type_name
}

public extension LensType where Whole == SelectableRow, Part == DiscoveryParams {
  public var social: Lens<SelectableRow, Bool?> {
    return SelectableRow.lens.params • DiscoveryParams.lens.social
  }
  public var staffPicks: Lens<SelectableRow, Bool?> {
    return SelectableRow.lens.params • DiscoveryParams.lens.staffPicks
  }
  public var starred: Lens<SelectableRow, Bool?> {
    return SelectableRow.lens.params • DiscoveryParams.lens.starred
  }
  public var category: Lens<SelectableRow, KsApi.Category?> {
    return SelectableRow.lens.params • DiscoveryParams.lens.category
  }
  public var includePOTD: Lens<SelectableRow, Bool?> {
    return SelectableRow.lens.params • DiscoveryParams.lens.includePOTD
  }
}

extension SelectableRow: Equatable {}
public func == (lhs: SelectableRow, rhs: SelectableRow) -> Bool {
  return lhs.isSelected == rhs.isSelected && lhs.params == rhs.params
}
