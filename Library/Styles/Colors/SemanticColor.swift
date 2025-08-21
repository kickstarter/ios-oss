import SwiftUICore
import UIKit

public protocol AdaptiveColor {
  /// Returns a dynamically-provided `UIColor`, which responds to light/dark mode.
  var dynamicColor: UIColor { get }
}

public extension AdaptiveColor {
  func uiColor(opacity alpha: CGFloat = 1.0) -> UIColor {
    return self.dynamicColor.withAlphaComponent(alpha)
  }

  func swiftUIColor(opacity: CGFloat = 1.0) -> Color {
    Color(uiColor: self.uiColor(opacity: opacity))
  }
}

/// A semantic color from the Kickstarter design system, like "surface/primary".
/// Includes a light and dark mode color pair, as well as an identifying title.
public struct SemanticColor: AdaptiveColor {
  public let dynamicColor: UIColor

  public let name: String

  init(_ name: String, lightMode: CoreColor, darkMode: CoreColor) {
    self.name = name

    let lightModeColor = UIColor(coreColor: lightMode)
    let darkModeColor = UIColor(coreColor: darkMode)

    self.dynamicColor = UIColor { traits in
      if traits.userInterfaceStyle == .dark {
        return darkModeColor
      } else {
        return lightModeColor
      }
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
