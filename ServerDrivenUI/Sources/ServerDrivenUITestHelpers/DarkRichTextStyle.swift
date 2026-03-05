import KDS
import ServerDrivenUI
import SwiftUI

/// Fixed dark theme for rich text with explicit dark-mode colors from KDS.
/// Use for screenshot tests and snapshots so colors are deterministic (no runtime trait resolution).
public struct DarkRichTextStyle: RichTextStyle, Sendable {
  private let parent = AutomaticRichTextStyle()
  public init() {}

  // MARK: - RichTextStyle
  public var bodyFont: Font { self.parent.bodyFont }
  public var bodyColor: AdaptiveColor { self.parent.bodyColor.resolvedForDarkMode() }
  public var heading1Font: Font { self.parent.heading1Font }
  public var heading2Font: Font { self.parent.heading2Font }
  public var heading3Font: Font { self.parent.heading3Font }
  public var heading4Font: Font { self.parent.heading4Font }
  public var headingColor: AdaptiveColor { self.parent.headingColor.resolvedForDarkMode() }
  public var linkColor: AdaptiveColor { self.parent.linkColor.resolvedForDarkMode() }
  public var linkUnderlined: Bool { self.parent.linkUnderlined }
  public var backgroundColor: AdaptiveColor { self.parent.backgroundColor.resolvedForDarkMode() }
  public var blockSpacing: CGFloat { self.parent.blockSpacing }
  public var listIndentation: CGFloat { self.parent.listIndentation }
  public var contentHorizontalPadding: CGFloat { self.parent.contentHorizontalPadding }
  public var mediaCornerRadius: CGFloat { self.parent.mediaCornerRadius }
}
