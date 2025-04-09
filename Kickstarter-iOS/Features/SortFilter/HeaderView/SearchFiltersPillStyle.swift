import Library
import SwiftUI

private let tintColor = Colors.Text.primary.swiftUIColor()
private let selectedColor = Colors.Border.subtle.swiftUIColor()

struct SearchFiltersPillStyle<S: Shape>: SwiftUI.ButtonStyle {
  let isHighlighted: Bool
  let shape: S

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
      .compositingGroup()
      .tint(
        tintColor
      )
      .clipShape(self.shape)
      .overlay(
        self.shape
          .stroke(
            configuration.isPressed ? selectedColor : tintColor,
            lineWidth: self.isHighlighted ? 2.0 : 1.0
          )
      )
  }
}
