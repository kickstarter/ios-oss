import SwiftUI
import UIKit

/// A protocol for handling adaptive colors using a `RawRepresentable` enum.
/// It dynamically constructs the color name based on its namespace and retrieves it from the asset catalog.
/// This allows consistent color definitions across both UIKit and SwiftUI.
public protocol AdaptiveColors: RawRepresentable where RawValue == String {
  /// Retrieves the adaptive color for UIKit.
  /// - Returns: A `UIColor` object from the asset catalog, or a default fallback color (`ksr_create_700`) if not found.
  func adaptive() -> UIColor
  /// Retrieves the adaptive color for SwiftUI.
  /// - Returns: A `Color` object from the asset catalog, or a default fallback color (`ksr_create_700`) if not found.
  func swiftUIColor() -> Color
}

extension AdaptiveColors {
  /// Defines the namespace for each color type to prevent conflicts and improve organization.
  /// - Returns: A string representing the namespace prefix.
  private var namespace: String {
    switch Self.self {
    case is Colors.Background.Type:
      return "background/"
    case is Colors.Border.Type:
      return "border/"
    case is Colors.Icon.Type:
      return "icon/"
    case is Colors.Text.Type:
      return "text/"
    default:
      // Adding an assertion failure to catch any new color categories that aren't defined within a namespace.
      assertionFailure("⚠️ Unexpected enum type for AdaptiveColors: \(Self.self)")
      return ""
    }
  }

  /// Retrieves the adaptive color for UIKit.
  /// - Returns: A `UIColor` object from the asset catalog, or a default fallback color (`ksr_create_700`) if not found.
  public func adaptive() -> UIColor {
    // Constructs the full color name for asset lookup.
    let colorName = "\(self.namespace)\(self.rawValue)"

    // Retrieves the color from the asset catalog, defaulting to KSR green (ksr_create_700) if unavailable.
    guard let color = UIColor(named: colorName) else {
      assertionFailure("⚠️ Color not found in asset catalog: \(colorName)")
      return .ksr_create_700
    }

    return color
  }

  /// Retrieves the adaptive color for SwiftUI.
  /// - Returns: A `Color` object from the asset catalog, or a default fallback color (`ksr_create_700`) if not found.
  public func swiftUIColor() -> Color {
    Color(uiColor: self.adaptive())
  }
}
