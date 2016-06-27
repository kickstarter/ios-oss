import UIKit

extension UIFont {
  /// Returns a bolded version of `self`.
  public var bolded: UIFont {
    let descriptor = self.fontDescriptor()
    let mediumDescriptor = descriptor.fontDescriptorWithSymbolicTraits(.TraitBold)
    return UIFont(descriptor: mediumDescriptor, size: 0.0)
  }

  /// Returns a italicized version of `self`.
  public var italicized: UIFont {
    let descriptor = self.fontDescriptor()
    let mediumDescriptor = descriptor.fontDescriptorWithSymbolicTraits(.TraitItalic)
    return UIFont(descriptor: mediumDescriptor, size: 0.0)
  }

  /// 17pt font
  public static var ksr_body: UIFont {
    return .preferredFontForTextStyle(UIFontTextStyleBody)
  }

  /// 16pt font
  public static var ksr_callout: UIFont {
    return .preferredFontForTextStyle(UIFontTextStyleCallout)
  }

  /// 12pt font
  public static var ksr_caption1: UIFont {
    return .preferredFontForTextStyle(UIFontTextStyleCaption1)
  }

  /// 11pt font
  public static var ksr_caption2: UIFont {
    return .preferredFontForTextStyle(UIFontTextStyleCaption2)
  }

  /// 13pt font
  public static var ksr_footnote: UIFont {
    return .preferredFontForTextStyle(UIFontTextStyleFootnote)
  }

  /// 17pt font
  public static var ksr_headline: UIFont {
    return .preferredFontForTextStyle(UIFontTextStyleHeadline)
  }

  /// 15pt font
  public static var ksr_subhead: UIFont {
    return .preferredFontForTextStyle(UIFontTextStyleSubheadline)
  }

  /// 28pt font
  public static var ksr_title1: UIFont {
    return .preferredFontForTextStyle(UIFontTextStyleTitle1)
  }

  /// 22pt font
  public static var ksr_title2: UIFont {
    return .preferredFontForTextStyle(UIFontTextStyleTitle2)
  }

  /// 20pt font
  public static var ksr_title3: UIFont {
    return .preferredFontForTextStyle(UIFontTextStyleTitle3)
  }
}
