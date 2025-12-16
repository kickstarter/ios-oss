import SwiftUI
import UIKit

public protocol AdaptiveColor {
  /// Returns a dynamically-provided `UIColor`, which responds to light/dark mode.
  var dynamicColor: UIColor { get }
}

public extension AdaptiveColor {
  // UIColor with default opacity.
  func uiColor() -> UIColor {
    return self.dynamicColor
  }

  // Color with default opacity.
  func swiftUIColor() -> Color {
    Color(uiColor: self.uiColor())
  }

  // UIColor with custom opacity.
  func uiColor(opacity alpha: CGFloat) -> UIColor {
    return self.dynamicColor.withAlphaComponent(alpha)
  }

  // Color with custom opacity.
  func swiftUIColor(opacity: CGFloat) -> Color {
    Color(uiColor: self.uiColor(opacity: opacity))
  }
}

/// A semantic color from the Kickstarter design system, like "surface/primary".
/// Includes a light and dark mode color pair, as well as an identifying title.
public struct SemanticColor: AdaptiveColor {
  public let dynamicColor: UIColor

  public let name: String

  public init(_ name: String, lightMode: CoreColor, darkMode: CoreColor) {
    self.init(name, lightMode: lightMode, lightModeAlpha: 1.0, darkMode: darkMode, darkModeAlpha: 1.0)
  }

  public init(
    _ name: String,
    lightMode: CoreColor,
    lightModeAlpha: Double,
    darkMode: CoreColor,
    darkModeAlpha: Double
  ) {
    self.name = name

    let lightModeColor = UIColor(coreColor: lightMode, alpha: lightModeAlpha)
    let darkModeColor = UIColor(coreColor: darkMode, alpha: darkModeAlpha)

    self.dynamicColor = UIColor { traits in
      if traits.userInterfaceStyle == .dark {
        return darkModeColor
      } else {
        return lightModeColor
      }
    }
  }

  /// For CoreColorV2 Semantic Colors
  public init(_ name: String, lightMode: CoreColorV2, darkMode: CoreColorV2) {
    self.name = name

    let lightModeColor = UIColor(coreColorV2: lightMode)
    let darkModeColor = UIColor(coreColorV2: darkMode)

    self.dynamicColor = UIColor { traits in
      traits.userInterfaceStyle == .dark ? darkModeColor : lightModeColor
    }
  }
}

/// Used for old design system colors which can't be mapped directly to the Kickstarter color palette.
public struct LegacyColor: AdaptiveColor {
  public let name: String
  public let dynamicColor: UIColor

  init(_ name: String, lightMode: UIColor, darkMode: UIColor) {
    self.name = name
    self.dynamicColor = UIColor { traits in
      if traits.userInterfaceStyle == .dark {
        return darkMode
      } else {
        return lightMode
      }
    }
  }
}
