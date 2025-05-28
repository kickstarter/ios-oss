import Foundation
import UIKit

/// The search view controller displays selected search options as a series of "pill"-style buttons,
/// using `SearchFiltersHeaderView`.
/// This is a model object that represents one of those pills.
public struct SearchFilterPill: Identifiable {
  public var id: Int {
    return self.filterType.hashValue
  }

  public let isHighlighted: Bool
  public let filterType: FilterType
  public let buttonType: ButtonType
  public let count: Int

  /// Which filter the pill represents.
  /// Only one pill of each type will be shown, since this powers the id of the pill.
  public enum FilterType {
    case allFilters
    case category
    case sort
    case projectState
    case percentRaised
  }

  /// How the pill should be rendered.
  public enum ButtonType {
    case image(String)
    case dropdown(String)
  }

  public init(
    isHighlighted: Bool,
    filterType: SearchFilterPill.FilterType,
    buttonType: ButtonType,
    count: Int = 0
  ) {
    self.isHighlighted = isHighlighted
    self.filterType = filterType
    self.buttonType = buttonType
    self.count = count
  }
}
