import UIKit

/// A protocol for handling adaptive colors using a `RawRepresentable` enum.
/// It dynamically constructs the color name based on its namespace and retrieves it from the asset catalog.
protocol AdaptativeColors: RawRepresentable where RawValue == String {
  /// Retrieves the adaptive color from the asset catalog.
  /// - Returns: A `UIColor` object from the asset catalog, or default white if not found.
  func adaptative() -> UIColor
}

extension AdaptativeColors {
  public func adaptative() -> UIColor {
    // Determines the appropriate namespace based on the enum type.
    let namespace: String

    switch Self.self {
    case is Colors.Background.Type:
      namespace = "background/"
    case is Colors.Border.Type:
      namespace = "border/"
    case is Colors.Text.Type:
      namespace = "text/"
    default:
      namespace = ""
    }

    // Constructs the full color name for asset lookup.
    let colorName = "\(namespace)\(self.rawValue)"

    // Retrieves the color from the asset catalog, defaulting to white if unavailable.
    return UIColor(named: colorName) ?? .white
  }
}
