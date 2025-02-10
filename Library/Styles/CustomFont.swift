import UIKit

public protocol CustomFont {
  var fontName: String { get }
  var defaultSize: CGFloat { get }
  var textStyle: UIFont.TextStyle { get }
}

extension UIFont {
  public static func customFont(with customFont: CustomFont, size: CGFloat? = nil) -> UIFont {
    var fontDescriptor = UIFontDescriptor(name: customFont.fontName, size: size ?? customFont.defaultSize)
    
    if UIAccessibility.isBoldTextEnabled {
      fontDescriptor = fontDescriptor.withSymbolicTraits(.traitBold)!
    }
    
    let font = UIFont(descriptor: fontDescriptor, size: ceil(fontDescriptor.pointSize / customFont.defaultSize * (size ?? customFont.defaultSize)))
    
    let metrics = UIFontMetrics(forTextStyle: customFont.textStyle)
    return metrics.scaledFont(for: font)
  }
  
  // TODO: remove, not necessary so far
  private static func defaultSystemFont(with customFont: CustomFont, size: CGFloat? = nil) -> UIFont {
    let font = UIFont.preferredFont(
      forTextStyle: customFont.textStyle,
      compatibleWith: .current
    )
    var descriptor = font.fontDescriptor
    
    return UIFont(
      descriptor: descriptor,
      size: ceil(font.pointSize / customFont.defaultSize * (size ?? customFont.defaultSize))
    )
  }
}
