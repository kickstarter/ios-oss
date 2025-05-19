import SwiftUICore
import UIKit

/// A semantic color from the Kickstarter design system, like "surface/primary".
/// Includes a light and dark mode color pair, as well as an identifying title.
public struct SemanticColor {
  private let lightModeColor: CoreColor
  private let darkModeColor: CoreColor
  public let name: String

  init(_ name: String, lightMode: CoreColor, darkMode: CoreColor) {
    self.name = name
    self.lightModeColor = lightMode
    self.darkModeColor = darkMode
  }

  public func uiColor(opacity: CGFloat = 1.0) -> UIColor {
    return UIColor { traits in
      if traits.userInterfaceStyle == .dark && featureDarkModeEnabled() {
        return UIColor(coreColor: self.darkModeColor).withAlphaComponent(opacity)
      } else {
        return UIColor(coreColor: self.lightModeColor).withAlphaComponent(opacity)
      }
    }
  }

  public func swiftUIColor() -> Color {
    Color(uiColor: self.uiColor())
  }
}
