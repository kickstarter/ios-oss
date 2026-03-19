import SwiftUI

private struct RichTextStyleKey: EnvironmentKey {
  static let defaultValue: any RichTextStyle = AutomaticRichTextStyle()
}

public extension EnvironmentValues {
  /// Current rich text style for content blocks. Defaults to `AutomaticRichTextStyle`, which
  /// switches between light and dark based on the current color scheme.
  var richTextStyle: any RichTextStyle {
    get { self[RichTextStyleKey.self] }
    set { self[RichTextStyleKey.self] = newValue }
  }
}

// MARK: - View modifier

public extension View {
  /// Injects the given rich text style into the environment for content blocks.
  func richTextStyle(_ style: any RichTextStyle) -> some View {
    environment(\.richTextStyle, style)
  }
}
