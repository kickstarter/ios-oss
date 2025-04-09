import Library
import SwiftUI

private let tintColor = Colors.Text.primary.swiftUIColor()
private let selectedColor = Colors.Border.subtle.swiftUIColor()
private let buttonFont = InterFont.headingMD

private struct SearchFiltersPillStyle<S: Shape>: SwiftUI.ButtonStyle {
  let isHighlighted: Bool
  let shape: S

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .buttonStyle(.borderless)
      .font(buttonFont.swiftUIFont(size: nil))
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

internal struct ImagePillButton: View {
  let action: () -> Void
  let image: UIImage
  let isHighlighted: Bool

  @ScaledMetric var scale: CGFloat = 1

  var body: some View {
    Button(action: self.action) {
      Image(uiImage: self.image)
        .renderingMode(.template)
        .aspectRatio(1.0, contentMode: .fill)
        .frame(width: self.scale * buttonFont.defaultSize, height: self.scale * buttonFont.defaultSize)
        .padding(
          EdgeInsets(
            top: Styles.gridHalf(1),
            leading: Styles.gridHalf(1),
            bottom: Styles.gridHalf(1),
            trailing: Styles.gridHalf(1)
          )
        )
    }
    .buttonStyle(SearchFiltersPillStyle(
      isHighlighted: self.isHighlighted,
      shape: Circle()
    ))
  }
}

internal struct DropdownPillButton: View {
  let action: () -> Void
  let title: String
  let isHighlighted: Bool

  var body: some View {
    Button(action: self.action) {
      HStack {
        Text(self.title)
        if let carat = Library.image(named: "arrow-down") {
          Spacer()
          Image(uiImage: carat)
            .renderingMode(.template)
            .aspectRatio(contentMode: .fill)
        }
      }
      .padding(EdgeInsets(
        top: Styles.gridHalf(1),
        leading: Styles.grid(1),
        bottom: Styles.gridHalf(1),
        trailing: Styles.grid(1)
      ))
    }
    .buttonStyle(SearchFiltersPillStyle(
      isHighlighted: self.isHighlighted,
      shape: Capsule()
    ))
  }
}
