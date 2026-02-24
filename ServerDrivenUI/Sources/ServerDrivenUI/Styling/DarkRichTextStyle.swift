import KDS
import SwiftUI

/// Fixed dark theme for rich text with explicit dark-mode colors from KDS.
/// Use for screenshot tests and snapshots so colors are deterministic (no runtime trait resolution).
public struct DarkRichTextStyle: RichTextStyle, Sendable {
  public init() {}

  public var bodyFont: Font {
    InterFont.bodyLG.swiftUIFont(size: nil)
  }

  public var bodyColor: Color {
    Colors.Text.primary.swiftUIColorResolvedForDarkMode()
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

  public var headingColor: Color {
    Colors.Text.primary.swiftUIColorResolvedForDarkMode()
  }

  public var linkColor: Color {
    Colors.Text.Accent.Blue.bolder.swiftUIColorResolvedForDarkMode()
  }

  public var linkUnderlined: Bool {
    true
  }

  public var backgroundColor: Color {
    Colors.Background.Surface.primary.swiftUIColorResolvedForDarkMode()
  }

  public var blockSpacing: CGFloat {
    Spacing.unit_04
  }

  public var listIndentation: CGFloat {
    Spacing.unit_06
  }

  public var contentHorizontalPadding: CGFloat {
    Spacing.unit_04
  }

  public var mediaCornerRadius: CGFloat {
    Dimension.CornerRadius.medium
  }
}
