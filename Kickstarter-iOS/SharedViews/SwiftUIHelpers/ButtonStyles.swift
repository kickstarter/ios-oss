import Library
import SwiftUI

// See `Library/Styles/ButtonStyles.swift` for the Prelude version of these styles.
// These files should be kept in sync.

struct GreenButtonStyle: SwiftUI.ButtonStyle {
  @SwiftUI.Environment(\.isEnabled) private var isEnabled

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .frame(maxWidth: .infinity)
      .font(Font(UIFont.ksr_headline(size: 16)))
      .foregroundColor(Color(.ksr_white))
      .padding(Styles.grid(2))
      .background(self.backgroundColor(configuration))
      .cornerRadius(Styles.grid(2))
  }

  private func backgroundColor(_ configuration: Configuration) -> Color {
    if !self.isEnabled {
      return Color(.ksr_create_700.mixLighter(0.36))
    } else if configuration.isPressed {
      return Color(.ksr_create_700.mixDarker(0.36))
    }
    return Color(.ksr_create_700)
  }
}

struct RedButtonStyle: SwiftUI.ButtonStyle {
  @SwiftUI.Environment(\.isEnabled) private var isEnabled

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .frame(maxWidth: .infinity)
      .font(Font(UIFont.ksr_headline(size: 16)))
      .foregroundColor(Color(.ksr_white))
      .padding(Styles.grid(2))
      .background(self.backgroundColor(configuration))
      .cornerRadius(Styles.grid(2))
  }

  private func backgroundColor(_ configuration: Configuration) -> Color {
    if !self.isEnabled {
      return Color(.ksr_alert.mixLighter(0.36))
    } else if configuration.isPressed {
      return Color(.ksr_alert.mixDarker(0.12))
    }
    return Color(.ksr_alert)
  }
}

struct BlackButtonStyle: SwiftUI.ButtonStyle {
  @SwiftUI.Environment(\.isEnabled) private var isEnabled

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .frame(maxWidth: .infinity)
      .font(Font(UIFont.ksr_headline(size: 16)))
      .foregroundColor(self.isEnabled ? Color(.ksr_white) : Color(.ksr_support_100))
      .padding(Styles.grid(2))
      .background(self.backgroundColor(configuration))
      .cornerRadius(Styles.grid(2))
  }

  private func backgroundColor(_ configuration: Configuration) -> Color {
    if !self.isEnabled {
      return Color(.ksr_support_700.mixLighter(0.36))
    } else if configuration.isPressed {
      return Color(.ksr_support_700.mixDarker(0.66))
    }
    return Color(.ksr_support_700)
  }
}
