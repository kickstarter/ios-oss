import KDS
import SwiftUI

/// Reactive container for all style information needed to render rich text content blocks.
/// Exposed via `@Environment` so views adopt styles automatically. Implementations derive
/// from KDS.
public protocol RichTextStyle: Sendable {
  // MARK: - Typography

  /// Font and color for body/paragraph text
  var bodyFont: CustomFont { get }
  var bodyColor: AdaptiveColor { get }

  /// Fonts and color for headings
  var heading1Font: CustomFont { get }
  var heading2Font: CustomFont { get }
  var heading3Font: CustomFont { get }
  var heading4Font: CustomFont { get }
  var headingColor: AdaptiveColor { get }

  /// Link appearance
  var linkColor: AdaptiveColor { get }
  var linkUnderlined: Bool { get }

  // MARK: - Colors

  /// Background for container or blocks
  var backgroundColor: AdaptiveColor { get }

  // MARK: - Spacing

  /// Vertical gap between content blocks
  var blockSpacing: CGFloat { get }

  /// Indentation or spacing for list items and nesting
  var listIndentation: CGFloat { get }

  /// Horizontal padding for content
  var contentHorizontalPadding: CGFloat { get }

  // MARK: - Media blocks

  /// Corner radius for image, audio/video, and oEmbed blocks
  var mediaCornerRadius: CGFloat { get }
}
