import Library
import SwiftUI

private let tintColor = Colors.Text.primary.swiftUIColor()
private let selectedColor = Colors.Border.subtle.swiftUIColor()

struct SearchFiltersPillStyle: SwiftUI.ButtonStyle {
  let isHighlighted: Bool
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .buttonStyle(.borderless)
      .font(Font.ksr_headingMD())
      .padding(EdgeInsets(
        top: Styles.grid(1),
        leading: Styles.grid(1),
        bottom: Styles.grid(1),
        trailing: Styles.grid(1)
      ))
      .foregroundStyle(.tint)
      .overlay(
        Capsule()
          .stroke(
            configuration.isPressed ? selectedColor : tintColor,
            lineWidth: self.isHighlighted ? 2.0 : 1.0
          )
      )
      .clipShape(Capsule())
      .tint(
        tintColor
      )
  }
}
