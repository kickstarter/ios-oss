import KDS
import ServerDrivenUI
import SwiftUI

/// Fixed light theme for rich text with explicit light-mode colors from KDS.
/// Use for screenshot tests and snapshots so colors are deterministic (no runtime trait resolution).
public struct LightRichTextStyle: RichTextStyle, Sendable {
  private let parent = AutomaticRichTextStyle()
  public init() {}

  // MARK: - RichTextStyle

  public var bodyFont: CustomFont { self.parent.bodyFont }
  public var bodyColor: AdaptiveColor { self.parent.bodyColor.resolvedForLightMode() }
  public var heading1Font: CustomFont { self.parent.heading1Font }
  public var heading2Font: CustomFont { self.parent.heading2Font }
  public var heading3Font: CustomFont { self.parent.heading3Font }
  public var heading4Font: CustomFont { self.parent.heading4Font }
  public var headingColor: AdaptiveColor { self.parent.headingColor.resolvedForLightMode() }
  public var linkColor: AdaptiveColor { self.parent.linkColor.resolvedForLightMode() }
  public var linkUnderlined: Bool { self.parent.linkUnderlined }
  public var backgroundColor: AdaptiveColor { self.parent.backgroundColor.resolvedForLightMode() }
  public var blockSpacing: CGFloat { self.parent.blockSpacing }
  public var listIndentation: CGFloat { self.parent.listIndentation }
  public var contentHorizontalPadding: CGFloat { self.parent.contentHorizontalPadding }
  public var mediaCornerRadius: CGFloat { self.parent.mediaCornerRadius }
}
