import KDS
import SwiftUI
import UIKit

/// Use as the default environment style so block views adapt to light/dark automatically.
public struct AutomaticRichTextStyle: RichTextStyle, Sendable {
  public init() {}

  // MARK: RichTextStyle

  public var bodyFont: CustomFont {
    InterFont.bodyLG
  }

  public var bodyColor: AdaptiveColor {
    Colors.Text.primary
  }

  public var heading1Font: CustomFont {
    InterFont.heading2XL
  }

  public var heading2Font: CustomFont {
    InterFont.headingXL
  }

  public var heading3Font: CustomFont {
    InterFont.headingLG
  }

  public var heading4Font: CustomFont {
    InterFont.headingMD
  }

  public var headingColor: AdaptiveColor {
    Colors.Text.primary
  }

  public var photoCaptionFont: CustomFont {
    InterFont.caption1
  }

  public var photoCaptionColor: AdaptiveColor {
    Colors.Text.secondary
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
    Spacing.unit_06
  }

  public var contentHorizontalPadding: CGFloat {
    Spacing.unit_04
  }

  public var mediaCornerRadius: CGFloat {
    Dimension.CornerRadius.medium
  }
}
