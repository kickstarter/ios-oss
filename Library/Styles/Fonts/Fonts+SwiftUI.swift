import SwiftUI

extension Font {
  /// medium, 24pt size, TextStyle.largeTitle
  public static func ksr_heading2XL(size: CGFloat? = nil) -> Font {
    return InterFont.heading2XL.swiftUIFont(size: size)
  }

  /// medium, 20pt size, TextStyle.title1
  public static func ksr_headingXL(size: CGFloat? = nil) -> Font {
    return InterFont.headingXL.swiftUIFont(size: size)
  }

  /// medium, 16pt size, TextStyle.title2
  public static func ksr_headingLG(size: CGFloat? = nil) -> Font {
    return InterFont.headingLG.swiftUIFont(size: size)
  }

  /// medium, 14pt size, TextStyle.title3
  public static func ksr_headingMD(size: CGFloat? = nil) -> Font {
    return InterFont.headingMD.swiftUIFont(size: size)
  }

  /// medium, 12pt size, TextStyle.headline
  public static func ksr_headingSM(size: CGFloat? = nil) -> Font {
    return InterFont.headingSM.swiftUIFont(size: size)
  }

  /// medium, 11pt size, TextStyle.subheadline
  public static func ksr_headingXS(size: CGFloat? = nil) -> Font {
    return InterFont.headingXS.swiftUIFont(size: size)
  }

  /// regular, 20pt size, TextStyle.body
  public static func ksr_bodyXL(size: CGFloat? = nil) -> Font {
    return InterFont.bodyXL.swiftUIFont(size: size)
  }

  /// regular, 16pt size, TextStyle.callout
  public static func ksr_bodyLG(size: CGFloat? = nil) -> Font {
    return InterFont.bodyLG.swiftUIFont(size: size)
  }

  /// regular, 14pt size, TextStyle.footnote
  public static func ksr_bodyMD(size: CGFloat? = nil) -> Font {
    return InterFont.bodyMD.swiftUIFont(size: size)
  }

  /// regular, 12pt size, TextStyle.caption1
  public static func ksr_bodySM(size: CGFloat? = nil) -> Font {
    return InterFont.bodySM.swiftUIFont(size: size)
  }

  /// regular, 11pt size, TextStyle.caption1
  public static func ksr_bodyXS(size: CGFloat? = nil) -> Font {
    return InterFont.bodyXS.swiftUIFont(size: size)
  }

  /// regular, 10pt size, TextStyle.caption1**
  public static func ksr_bodyXXS(size: CGFloat? = nil) -> Font {
    return InterFont.bodyXXS.swiftUIFont(size: size)
  }
}
