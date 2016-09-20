import UIKit

// swiftlint:disable valid_docs
extension UIFont {
  /// Returns a bolded version of `self`.
  public var bolded: UIFont {
    #if swift(>=2.3)
      return self.fontDescriptor().fontDescriptorWithSymbolicTraits(.TraitBold)
        .map { UIFont(descriptor: $0, size: 0.0) } ?? self
    #else
      return UIFont(descriptor: self.fontDescriptor().fontDescriptorWithSymbolicTraits(.TraitBold),
                    size: 0.0)
    #endif

  }

  /// Returns a italicized version of `self`.
  public var italicized: UIFont {
    #if swift(>=2.3)
      return self.fontDescriptor().fontDescriptorWithSymbolicTraits(.TraitItalic)
        .map { UIFont(descriptor: $0, size: 0.0) } ?? self
    #else
      return UIFont(descriptor: self.fontDescriptor().fontDescriptorWithSymbolicTraits(.TraitItalic),
                    size: 0.0)
    #endif
  }

  /// regular, 17pt font, 22pt leading, -24pt tracking
  public static func ksr_body(size size: CGFloat? = nil) -> UIFont {
    return .preferredFont(style: UIFontTextStyleBody, size: size)
  }

  /// regular, 16pt font, 21pt leading, -20pt tracking
  public static func ksr_callout(size size: CGFloat? = nil) -> UIFont {
    return .preferredFont(style: UIFontTextStyleCallout, size: size)
  }

  /// regular, 12pt font, 16pt leading, 0pt tracking
  public static func ksr_caption1(size size: CGFloat? = nil) -> UIFont {
    return .preferredFont(style: UIFontTextStyleCaption1, size: size)
  }

  /// regular, 11pt font, 13pt leading, 6pt tracking
  public static func ksr_caption2(size size: CGFloat? = nil) -> UIFont {
    return .preferredFont(style: UIFontTextStyleCaption2, size: size)
  }

  /// regular, 13pt font, 18pt leading, -6pt tracking
  public static func ksr_footnote(size size: CGFloat? = nil) -> UIFont {
    return .preferredFont(style: UIFontTextStyleFootnote, size: size)
  }

  /// semi-bold, 17pt font, 22pt leading, -24pt tracking
  public static func ksr_headline(size size: CGFloat? = nil) -> UIFont {
    return .preferredFont(style: UIFontTextStyleHeadline, size: size)
  }

  /// regular, 15pt font, 20pt leading, -16pt tracking
  public static func ksr_subhead(size size: CGFloat? = nil) -> UIFont {
    return .preferredFont(style: UIFontTextStyleSubheadline, size: size)
  }

  /// light, 28pt font, 34pt leading, 13pt tracking
  public static func ksr_title1(size size: CGFloat? = nil) -> UIFont {
    return .preferredFont(style: UIFontTextStyleTitle1, size: size)
  }

  /// regular, 22pt font, 28pt leading, 16pt tracking
  public static func ksr_title2(size size: CGFloat? = nil) -> UIFont {
    return .preferredFont(style: UIFontTextStyleTitle2, size: size)
  }

  /// regular, 20pt font, 24pt leading, 19pt tracking
  public static func ksr_title3(size size: CGFloat? = nil) -> UIFont {
    return .preferredFont(style: UIFontTextStyleTitle3, size: size)
  }

  // swiftlint:disable cyclomatic_complexity
  private static func preferredFont(style style: String, size: CGFloat? = nil) -> UIFont {

    let defaultSize: CGFloat
    switch style {
    case UIFontTextStyleBody:         defaultSize = 17
    case UIFontTextStyleCallout:      defaultSize = 16
    case UIFontTextStyleCaption1:     defaultSize = 12
    case UIFontTextStyleCaption2:     defaultSize = 11
    case UIFontTextStyleFootnote:     defaultSize = 13
    case UIFontTextStyleHeadline:     defaultSize = 17
    case UIFontTextStyleSubheadline:  defaultSize = 15
    case UIFontTextStyleTitle1:       defaultSize = 28
    case UIFontTextStyleTitle2:       defaultSize = 22
    case UIFontTextStyleTitle3:       defaultSize = 20
    default:                          defaultSize = 17
    }

    let font = UIFont.preferredFontForTextStyle(style)
    let descriptor = font.fontDescriptor()
    return UIFont(descriptor: descriptor,
                  size: ceil(font.pointSize / defaultSize * (size ?? defaultSize)))
  }
  // swiftlint:enable cyclomatic_complexity
}
