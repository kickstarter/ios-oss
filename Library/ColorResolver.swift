import UIKit

/// Turns a light and dark color pair into a dynamically-provided `UIColor` object.
///
/// A `UIColor` created with a `UIColor(dynamicColorProvider:)` can't be compared with `==`. That breaks any unit tests that compare colors returned from view models.
/// `ColorResolverType` allows us to inject code in our test environment which
/// will return statically assigned colors, instead of dynamically provided colors.
public protocol ColorResolverType {
  func color(
    withLightModeColor: UIColor,
    darkModeColor: UIColor,
    alpha: CGFloat
  ) -> UIColor
}

public struct AppColorResolver: ColorResolverType {
  public func color(
    withLightModeColor lightModeColor: UIColor,
    darkModeColor: UIColor,
    alpha: CGFloat
  ) -> UIColor {
    let dynamicColor = UIColor { traits in
      if traits.userInterfaceStyle == .dark && featureDarkModeEnabled() {
        return darkModeColor
      } else {
        return lightModeColor
      }
    }

    return dynamicColor.withAlphaComponent(alpha)
  }

  public init() {}
}

public struct MockColorResolver: ColorResolverType {
  public func color(
    withLightModeColor lightModeColor: UIColor,
    darkModeColor _: UIColor,
    alpha: CGFloat
  ) -> UIColor {
    return lightModeColor.withAlphaComponent(alpha)
  }
}
