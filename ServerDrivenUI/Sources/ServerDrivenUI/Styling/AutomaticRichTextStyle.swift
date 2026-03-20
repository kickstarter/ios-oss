import KDS
import SwiftUI
import UIKit

/// Use as the default environment style so block views adapt to light/dark automatically.
public struct AutomaticRichTextStyle: RichTextStyle, Sendable {
  public init() {}

  // MARK: RichTextStyle

  public var bodyFont: Font {
    InterFont.bodyLG.swiftUIFont(size: nil)
  }

  public var bodyColor: AdaptiveColor {
    Colors.Text.primary
  }

  public var heading1Font: Font {
    InterFont.heading2XL.swiftUIFont(size: nil)
  }

  public var heading2Font: Font {
    InterFont.headingXL.swiftUIFont(size: nil)
  }

  public var heading3Font: Font {
    InterFont.headingLG.swiftUIFont(size: nil)
  }

  public var heading4Font: Font {
    InterFont.headingMD.swiftUIFont(size: nil)
  }

  public var headingColor: AdaptiveColor {
    Colors.Text.primary
  }

  public var linkColor: AdaptiveColor {
    Colors.Text.Accent.Blue.bolder
  }

  public var linkUnderlined: Bool {
    true
  }

  public var backgroundColor: AdaptiveColor {
    Colors.Background.Surface.primary
  }

  public var blockSpacing: CGFloat {
    Spacing.unit_04
  }

  public var listIndentation: CGFloat {
    Spacing.unit_04
  }

  public var contentHorizontalPadding: CGFloat {
    Spacing.unit_04
  }

  public var mediaCornerRadius: CGFloat {
    Dimension.CornerRadius.medium
  }
}
