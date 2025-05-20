import SwiftUICore
import UIKit

public protocol AdaptiveColor {
  var lightModeColor: UIColor { get }
  var darkModeColor: UIColor { get }
}

public extension AdaptiveColor {
  func uiColor(opacity alpha: CGFloat = 1.0) -> UIColor {
    return AppEnvironment.current.colorResolver.color(
      withLightModeColor: self.lightModeColor,
      darkModeColor: self.darkModeColor,
      alpha: alpha
    )
  }

  func swiftUIColor(opacity: CGFloat = 1.0) -> Color {
    Color(uiColor: self.uiColor(opacity: opacity))
  }
}

/// A semantic color from the Kickstarter design system, like "surface/primary".
/// Includes a light and dark mode color pair, as well as an identifying title.
public struct SemanticColor: AdaptiveColor {
  private let lightMode: CoreColor
  private let darkMode: CoreColor

  public let name: String

  init(_ name: String, lightMode: CoreColor, darkMode: CoreColor) {
    self.name = name
    self.lightMode = lightMode
    self.darkMode = darkMode
  }

  public var lightModeColor: UIColor {
    return UIColor(coreColor: self.lightMode)
  }

  public var darkModeColor: UIColor {
    return UIColor(coreColor: self.darkMode)
  }
}

/// Used for old design system colors which can't be mapped directly to the Kickstarter color palette.
public struct LegacyColor: AdaptiveColor {
  public let name: String

  public let lightModeColor: UIColor
  public let darkModeColor: UIColor

  init(_ name: String, lightMode: UIColor, darkMode: UIColor) {
    self.name = name
    self.lightModeColor = lightMode
    self.darkModeColor = darkMode
  }
}
