import UIKit

// swiftlint:disable valid_docs
extension UIFont {
  /// Returns a bolded version of `self`.
  public var bolded: UIFont {
    return self.fontDescriptor.withSymbolicTraits(.traitBold)
      .map { UIFont(descriptor: $0, size: 0.0) } ?? self
  }

  /// Returns a italicized version of `self`.
  public var italicized: UIFont {
    return self.fontDescriptor.withSymbolicTraits(.traitItalic)
      .map { UIFont(descriptor: $0, size: 0.0) } ?? self
  }

  /// Returns a fancy monospaced font for the countdown.
  public var countdownMonospaced: UIFont {
    let monospacedDescriptor = self.fontDescriptor
      .addingAttributes(
        [
          UIFontDescriptor.AttributeName.featureSettings: [
            [
              UIFontDescriptor.FeatureKey.featureIdentifier: kNumberSpacingType,
              UIFontDescriptor.FeatureKey.typeIdentifier: kMonospacedNumbersSelector
            ],
            [
              UIFontDescriptor.FeatureKey.featureIdentifier: kStylisticAlternativesType,
              UIFontDescriptor.FeatureKey.typeIdentifier: kStylisticAltTwoOnSelector
            ],
            [
              UIFontDescriptor.FeatureKey.featureIdentifier: kStylisticAlternativesType,
              UIFontDescriptor.FeatureKey.typeIdentifier: kStylisticAltOneOnSelector
            ]
          ]
        ]
      )

    return UIFont(descriptor: monospacedDescriptor, size: 0.0)
  }

  /// regular, 17pt font, 22pt leading, -24pt tracking
  public static func ksr_body(size: CGFloat? = nil) -> UIFont {
    return .preferredFont(style: .body, size: size)
  }

  /// regular, 16pt font, 21pt leading, -20pt tracking
  public static func ksr_callout(size: CGFloat? = nil) -> UIFont {
    return .preferredFont(style: .callout, size: size)
  }

  /// regular, 12pt font, 16pt leading, 0pt tracking
  public static func ksr_caption1(size: CGFloat? = nil) -> UIFont {
    return .preferredFont(style: .caption1, size: size)
  }

  /// regular, 11pt font, 13pt leading, 6pt tracking
  public static func ksr_caption2(size: CGFloat? = nil) -> UIFont {
    return .preferredFont(style: .caption2, size: size)
  }

  /// regular, 13pt font, 18pt leading, -6pt tracking
  public static func ksr_footnote(size: CGFloat? = nil) -> UIFont {
    return .preferredFont(style: .footnote, size: size)
  }

  /// semi-bold, 17pt font, 22pt leading, -24pt tracking
  public static func ksr_headline(size: CGFloat? = nil) -> UIFont {
    return .preferredFont(style: .headline, size: size)
  }

  /// regular, 15pt font, 20pt leading, -16pt tracking
  public static func ksr_subhead(size: CGFloat? = nil) -> UIFont {
    return .preferredFont(style: .subheadline, size: size)
  }

  /// light, 28pt font, 34pt leading, 13pt tracking
  public static func ksr_title1(size: CGFloat? = nil) -> UIFont {
    return .preferredFont(style: .title1, size: size)
  }

  /// regular, 22pt font, 28pt leading, 16pt tracking
  public static func ksr_title2(size: CGFloat? = nil) -> UIFont {
    return .preferredFont(style: .title2, size: size)
  }

  /// regular, 20pt font, 24pt leading, 19pt tracking
  public static func ksr_title3(size: CGFloat? = nil) -> UIFont {
    return .preferredFont(style: .title3, size: size)
  }

  /// Returns a monospaced font for numeric use.
  public var monospaced: UIFont {
    let monospacedDescriptor = self.fontDescriptor
      .addingAttributes(
        [
          UIFontDescriptor.AttributeName.featureSettings: [
            [
              UIFontDescriptor.FeatureKey.featureIdentifier: kNumberSpacingType,
              UIFontDescriptor.FeatureKey.typeIdentifier: kMonospacedNumbersSelector
            ]
          ]
        ]
      )

    return UIFont(descriptor: monospacedDescriptor, size: 0.0)
  }

  // swiftlint:disable:next cyclomatic_complexity
  fileprivate static func preferredFont(style: UIFont.TextStyle, size: CGFloat? = nil) -> UIFont {
    let defaultSize: CGFloat
    switch style {
    case UIFont.TextStyle.body: defaultSize = 17
    case UIFont.TextStyle.callout: defaultSize = 16
    case UIFont.TextStyle.caption1: defaultSize = 12
    case UIFont.TextStyle.caption2: defaultSize = 11
    case UIFont.TextStyle.footnote: defaultSize = 13
    case UIFont.TextStyle.headline: defaultSize = 17
    case UIFont.TextStyle.subheadline: defaultSize = 15
    case UIFont.TextStyle.title1: defaultSize = 28
    case UIFont.TextStyle.title2: defaultSize = 22
    case UIFont.TextStyle.title3: defaultSize = 20
    default: defaultSize = 17
    }

    let font: UIFont
    if #available(iOS 13.0, *) {
      font = UIFont.preferredFont(
        forTextStyle: style,
        compatibleWith: .current
      )
    } else {
      font = UIFont.preferredFont(forTextStyle: style)
    }
    let descriptor = font.fontDescriptor
    return UIFont(
      descriptor: descriptor,
      size: ceil(font.pointSize / defaultSize * (size ?? defaultSize))
    )
  }
}
