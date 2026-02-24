import KDS
import SwiftUI

/// Fixed light theme for rich text with explicit light-mode colors from KDS.
/// Use for screenshot tests and snapshots so colors are deterministic (no runtime trait resolution).
public struct LightRichTextStyle: RichTextStyle, Sendable {
  public init() {}

  public var bodyFont: Font {
    InterFont.bodyLG.swiftUIFont(size: nil)
  }

  public var bodyColor: Color {
    Colors.Text.primary.swiftUIColorResolvedForLightMode()
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
    Colors.Text.primary.swiftUIColorResolvedForLightMode()
  }

  public var linkColor: Color {
    Colors.Text.Accent.Blue.bolder.swiftUIColorResolvedForLightMode()
  }

  public var linkUnderlined: Bool {
    true
  }

  public var backgroundColor: Color {
    Colors.Background.Surface.primary.swiftUIColorResolvedForLightMode()
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
