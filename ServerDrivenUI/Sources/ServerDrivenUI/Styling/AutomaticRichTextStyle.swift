import KDS
import SwiftUI
import UIKit

/// Compositional style that holds `LightRichTextStyle` and `DarkRichTextStyle` and delegates
/// all `RichTextStyle` properties to the appropriate one based on the current trait collection.
/// Use as the default environment style so block views adapt to light/dark automatically.
/// When the app’s color scheme changes, SwiftUI re-renders views that read this style.
public struct AutomaticRichTextStyle: RichTextStyle, Sendable {
  private let lightStyle: LightRichTextStyle
  private let darkStyle: DarkRichTextStyle

  public init() {
    self.lightStyle = LightRichTextStyle()
    self.darkStyle = DarkRichTextStyle()
  }

  private var current: any RichTextStyle {
    if UITraitCollection.current.userInterfaceStyle == .dark {
      return self.darkStyle
    }
    return self.lightStyle
  }

  // MARK: RichTextStyle

  public var bodyFont: Font { self.current.bodyFont }
  public var bodyColor: Color { self.current.bodyColor }
  public var heading1Font: Font { self.current.heading1Font }
  public var heading2Font: Font { self.current.heading2Font }
  public var heading3Font: Font { self.current.heading3Font }
  public var heading4Font: Font { self.current.heading4Font }
  public var headingColor: Color { self.current.headingColor }
  public var linkColor: Color { self.current.linkColor }
  public var linkUnderlined: Bool { self.current.linkUnderlined }
  public var backgroundColor: Color { self.current.backgroundColor }
  public var blockSpacing: CGFloat { self.current.blockSpacing }
  public var listIndentation: CGFloat { self.current.listIndentation }
  public var contentHorizontalPadding: CGFloat { self.current.contentHorizontalPadding }
  public var mediaCornerRadius: CGFloat { self.current.mediaCornerRadius }
}
