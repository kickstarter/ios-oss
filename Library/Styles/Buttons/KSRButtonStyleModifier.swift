import SwiftUI

/// `KSRButtonStyleModifier` applies the new Design System `KSRButtonStyle` to SwiftUI buttons.
/// It configures the button's font, background color, foreground color, border, and state (enabled, pressed, disabled).
public struct KSRButtonStyleModifier: SwiftUI.ButtonStyle {
  let style: KSRButtonStyle

  @SwiftUI.Environment(\.isEnabled) private var isEnabled

  public init(style: KSRButtonStyle) {
    self.style = style
  }

  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .frame(maxWidth: .infinity)
      .font(Font(self.style.font))
      .foregroundColor(self.foregroundColor(configuration))
      .padding(Styles.grid(2))
      .background(self.backgroundColor(configuration))
      .cornerRadius(self.style.cornerRadius)
      .overlay(
        RoundedRectangle(cornerRadius: self.style.cornerRadius)
          .stroke(self.borderColor(configuration), lineWidth: self.style.borderWidth)
      )
  }

  /// Selects the correct background color based on the button state.
  private func backgroundColor(_ configuration: Configuration) -> Color {
    guard self.isEnabled else {
      return Color(self.style.disabledBackgroundColor)
    }

    if configuration.isPressed {
      return Color(self.style.highlightedBackgroundColor)
    }

    return Color(self.style.backgroundColor)
  }

  /// Selects the correct foreground color based on the button state.
  private func foregroundColor(_ configuration: Configuration) -> Color {
    guard self.isEnabled else {
      return Color(self.style.disabledTitleColor)
    }

    if configuration.isPressed {
      return Color(self.style.highlightedTitleColor)
    }

    return Color(self.style.titleColor)
  }

  /// Selects the correct border color based on the button state.
  private func borderColor(_ configuration: Configuration) -> Color {
    guard self.isEnabled else {
      return Color(self.style.disabledBorderColor)
    }

    if configuration.isPressed {
      return Color(self.style.highlightedBorderColor)
    }

    return Color(self.style.borderColor)
  }
}
