import UIKit

extension UIFont {
  // MARK: - Old Design System fonts

  /// regular, 17pt font, 22pt leading, -24pt tracking
  public static func ksr_body(size: CGFloat? = nil) -> UIFont {
    let fontType: CustomFont = featureNewDesignSystemEnabled() ? InterFont.body : SystemFont.body

    return fontType.font(size: size)
  }

  /// regular, 16pt font, 21pt leading, -20pt tracking
  public static func ksr_callout(size: CGFloat? = nil) -> UIFont {
    let fontType: CustomFont = featureNewDesignSystemEnabled() ? InterFont.callout : SystemFont.callout

    return fontType.font(size: size)
  }

  /// regular, 12pt font, 16pt leading, 0pt tracking
  public static func ksr_caption1(size: CGFloat? = nil) -> UIFont {
    let fontType: CustomFont = featureNewDesignSystemEnabled() ? InterFont.caption1 : SystemFont.caption1

    return fontType.font(size: size)
  }

  /// regular, 11pt font, 13pt leading, 6pt tracking
  public static func ksr_caption2(size: CGFloat? = nil) -> UIFont {
    let fontType: CustomFont = featureNewDesignSystemEnabled() ? InterFont.caption2 : SystemFont.caption2

    return fontType.font(size: size)
  }

  /// regular, 13pt font, 18pt leading, -6pt tracking
  public static func ksr_footnote(size: CGFloat? = nil) -> UIFont {
    let fontType: CustomFont = featureNewDesignSystemEnabled() ? InterFont.footnote : SystemFont.footnote

    return fontType.font(size: size)
  }

  /// semi-bold, 17pt font, 22pt leading, -24pt tracking
  public static func ksr_headline(size: CGFloat? = nil) -> UIFont {
    let fontType: CustomFont = featureNewDesignSystemEnabled() ? InterFont.headline : SystemFont.headline

    return fontType.font(size: size)
  }

  /// regular, 15pt font, 20pt leading, -16pt tracking
  public static func ksr_subhead(size: CGFloat? = nil) -> UIFont {
    let fontType: CustomFont = featureNewDesignSystemEnabled() ? InterFont.subhead : SystemFont.subhead

    return fontType.font(size: size)
  }

  /// regular, 28pt font, 34pt leading, 13pt tracking
  public static func ksr_title1(size: CGFloat? = nil) -> UIFont {
    let fontType: CustomFont = featureNewDesignSystemEnabled() ? InterFont.title1 : SystemFont.title1

    return fontType.font(size: size)
  }

  /// regular, 22pt font, 28pt leading, 16pt tracking
  public static func ksr_title2(size: CGFloat? = nil) -> UIFont {
    let fontType: CustomFont = featureNewDesignSystemEnabled() ? InterFont.title2 : SystemFont.title2

    return fontType.font(size: size)
  }

  /// regular, 20pt font, 24pt leading, 19pt tracking
  public static func ksr_title3(size: CGFloat? = nil) -> UIFont {
    let fontType: CustomFont = featureNewDesignSystemEnabled() ? InterFont.title3 : SystemFont.title3

    return fontType.font(size: size)
  }

  // MARK: - New Design System fonts

  /// medium, 24pt size, TextStyle.largeTitle
  public static func ksr_heading2XL(size: CGFloat? = nil) -> UIFont {
    return InterFont.heading2XL.font(size: size)
  }

  /// medium, 20pt size, TextStyle.title1
  public static func ksr_headingXL(size: CGFloat? = nil) -> UIFont {
    return InterFont.headingXL.font(size: size)
  }

  /// medium, 16pt size, TextStyle.title2
  public static func ksr_headingLG(size: CGFloat? = nil) -> UIFont {
    return InterFont.headingLG.font(size: size)
  }

  /// medium, 14pt size, TextStyle.title3
  public static func ksr_headingMD(size: CGFloat? = nil) -> UIFont {
    return InterFont.headingMD.font(size: size)
  }

  /// medium, 12pt size, TextStyle.headline
  public static func ksr_headingSM(size: CGFloat? = nil) -> UIFont {
    return InterFont.headingSM.font(size: size)
  }

  /// medium, 11pt size, TextStyle.subheadline
  public static func ksr_headingXS(size: CGFloat? = nil) -> UIFont {
    return InterFont.headingXS.font(size: size)
  }

  /// regular, 20pt size, TextStyle.body
  public static func ksr_bodyXL(size: CGFloat? = nil) -> UIFont {
    return InterFont.bodyXL.font(size: size)
  }

  /// regular, 16pt size, TextStyle.callout
  public static func ksr_bodyLG(size: CGFloat? = nil) -> UIFont {
    return InterFont.bodyLG.font(size: size)
  }

  /// regular, 14pt size, TextStyle.footnote
  public static func ksr_bodyMD(size: CGFloat? = nil) -> UIFont {
    return InterFont.bodyMD.font(size: size)
  }

  /// regular, 12pt size, TextStyle.caption1
  public static func ksr_bodySM(size: CGFloat? = nil) -> UIFont {
    return InterFont.bodySM.font(size: size)
  }

  /// regular, 11pt size, TextStyle.caption1
  public static func ksr_bodyXS(size: CGFloat? = nil) -> UIFont {
    return InterFont.bodyXS.font(size: size)
  }

  /// regular, 10pt size, TextStyle.caption1**
  public static func ksr_bodyXXS(size: CGFloat? = nil) -> UIFont {
    return InterFont.bodyXXS.font(size: size)
  }
}

extension UIFont {
  /// Returns a bolded version of `self`.
  public var bolded: UIFont {
    return self.fontDescriptor.withSymbolicTraits(.traitBold)
      .map { UIFont(descriptor: $0, size: 0.0) } ?? self
  }

  /// Returns a version of `self` with the desired weight.
  public func weighted(_ weight: UIFont.Weight) -> UIFont {
    let descriptor = self.fontDescriptor.addingAttributes([
      .traits: [UIFontDescriptor.TraitKey.weight: weight]
    ])
    return UIFont(descriptor: descriptor, size: 0.0)
  }

  /// Returns a italicized version of `self`.
  public var italicized: UIFont {
    return self.fontDescriptor.withSymbolicTraits(.traitItalic)
      .map { UIFont(descriptor: $0, size: 0.0) } ?? self
  }

  /// Returns a bold and italized version of `self`
  public var boldItalic: UIFont {
    return self.fontDescriptor.withSymbolicTraits([.traitBold, .traitItalic])
      .map { UIFont(descriptor: $0, size: 0.0) } ?? self
  }

  /// Returns a fancy monospaced font for the countdown.
  public var countdownMonospaced: UIFont {
    let monospacedDescriptor = self.fontDescriptor
      .addingAttributes(
        [
          UIFontDescriptor.AttributeName.featureSettings: [
            [
              UIFontDescriptor.FeatureKey.type: kNumberSpacingType,
              UIFontDescriptor.FeatureKey.selector: kMonospacedNumbersSelector
            ],
            [
              UIFontDescriptor.FeatureKey.type: kStylisticAlternativesType,
              UIFontDescriptor.FeatureKey.selector: kStylisticAltTwoOnSelector
            ],
            [
              UIFontDescriptor.FeatureKey.type: kStylisticAlternativesType,
              UIFontDescriptor.FeatureKey.selector: kStylisticAltOneOnSelector
            ]
          ]
        ]
      )

    return UIFont(descriptor: monospacedDescriptor, size: 0.0)
  }

  /// Returns a monospaced font for numeric use.
  public var monospaced: UIFont {
    let monospacedDescriptor = self.fontDescriptor
      .addingAttributes(
        [
          UIFontDescriptor.AttributeName.featureSettings: [
            [
              UIFontDescriptor.FeatureKey.type: kNumberSpacingType,
              UIFontDescriptor.FeatureKey.selector: kMonospacedNumbersSelector
            ]
          ]
        ]
      )

    return UIFont(descriptor: monospacedDescriptor, size: 0.0)
  }
}
