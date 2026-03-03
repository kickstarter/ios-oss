import SwiftUI

/// Reactive container for all style information needed to render rich text content blocks.
/// Exposed via `@Environment` so views adopt styles automatically. Implementations derive
/// from KDS.
public protocol RichTextStyle: Sendable {
  // MARK: - Typography

  /// Font and color for body/paragraph text
  var bodyFont: Font { get }
  var bodyColor: Color { get }

  /// Fonts and color for headings
  var heading1Font: Font { get }
  var heading2Font: Font { get }
  var heading3Font: Font { get }
  var heading4Font: Font { get }
  var headingColor: Color { get }

  /// Link appearance
  var linkColor: Color { get }
  var linkUnderlined: Bool { get }

  // MARK: - Colors

  /// Background for container or blocks
  var backgroundColor: Color { get }

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
