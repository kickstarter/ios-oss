import Foundation
import UIKit

/// The search view controller displays selected search options as a series of "pill"-style buttons,
/// using `SearchFiltersHeaderView`.
/// This is a model object that represents one of those pills.
public struct SearchFilterPill: Identifiable {
  public var id: Int {
    return self.filterType.rawValue
  }

  public let isHighlighted: Bool
  public let filterType: FilterType
  public let buttonType: ButtonType
  public let count: Int

  /// Which filter the pill represents.
  /// Only one pill of each type will be shown, since this powers the id of the pill.
  public enum FilterType: Int {
    case allFilters
    case category
    case sort
    case projectState
    case percentRaised
    case location
    case amountRaised
    case goal
    case projectsWeLove
    case saved
    case following
    case recommended

    /// If `true`, this pill is a boolean value that can be toggled directly from the search header.
    /// Tapping on this pill doesn't open a modal.
    var isToggle: Bool {
      switch self {
      case .projectsWeLove:
        true
      case .saved:
        true
      case .following:
        true
      case .recommended:
        true
      default:
        false
      }
    }
  }

  /// How the pill should be rendered.
  public enum ButtonType {
    case image(UIImage)
    case dropdown(String)
    case toggle(String)
    case toggleWithImage(String, UIImage)
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
