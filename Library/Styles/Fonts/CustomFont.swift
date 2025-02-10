import UIKit

public protocol CustomFont {
  func font(size: CGFloat?) -> UIFont
}

protocol CustomFontConfigurable {
  var fontName: String { get }
  var boldFontName: String { get }
  var defaultSize: CGFloat { get }
  var textStyle: UIFont.TextStyle { get }
}

extension UIFont {
  static func customFont(with fontConfig: CustomFontConfigurable, size: CGFloat? = nil) -> UIFont {
    let fontName = UIAccessibility.isBoldTextEnabled ? fontConfig.boldFontName : fontConfig.fontName
    guard let font = UIFont(name: fontName, size: size ?? fontConfig.defaultSize) else {
      return self.defaultSystemFont(with: fontConfig, size: size)
    }

    let metrics = UIFontMetrics(forTextStyle: fontConfig.textStyle)
    let finalFont = metrics.scaledFont(for: font)
    return finalFont
  }

  private static func defaultSystemFont(
    with fontConfig: CustomFontConfigurable,
    size: CGFloat? = nil
  ) -> UIFont {
    let font = UIFont.preferredFont(
      forTextStyle: fontConfig.textStyle,
      compatibleWith: .current
    )

    return UIFont(
      descriptor: font.fontDescriptor,
      size: ceil(font.pointSize / fontConfig.defaultSize * (size ?? fontConfig.defaultSize))
    )
  }
}
