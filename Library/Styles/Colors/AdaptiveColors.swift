import UIKit

/// A protocol for handling adaptive colors using a `RawRepresentable` enum.
/// It dynamically constructs the color name based on its namespace and retrieves it from the asset catalog.
protocol AdaptiveColors: RawRepresentable where RawValue == String {
  /// Retrieves the adaptive color from the asset catalog.
  /// - Returns: A `UIColor` object from the asset catalog, or default white if not found.
  func adaptive() -> UIColor
}

extension AdaptiveColors {
  public func adaptive() -> UIColor {
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
      // Adding an assertion failure to catch any new color categories that aren't defined within a namespace.
      assertionFailure("⚠️ Unexpected enum type for AdaptiveColors: \(Self.self)")
      namespace = ""
    }

    // Constructs the full color name for asset lookup.
    let colorName = "\(namespace)\(self.rawValue)"

    // Retrieves the color from the asset catalog, defaulting to white if unavailable.
    if let color = UIColor(named: colorName) {
      return color
    }

    assertionFailure("⚠️ Color not found in asset catalog: \(colorName)")
    return .white
  }
}
