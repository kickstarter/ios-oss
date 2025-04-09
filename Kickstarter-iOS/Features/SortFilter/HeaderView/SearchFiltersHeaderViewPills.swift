import Library
import SwiftUI

private let tintColor = Colors.Text.primary.swiftUIColor()
private let selectedColor = Colors.Border.subtle.swiftUIColor()
private let buttonFont = InterFont.headingMD

private struct SearchFiltersPillStyle: SwiftUI.ButtonStyle {
  let isHighlighted: Bool

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .buttonStyle(.borderless)
      .font(buttonFont.swiftUIFont(size: nil))
      .foregroundStyle(.tint)
      .tint(
        tintColor
      )
      .padding(
        EdgeInsets(
          top: Styles.grid(2),
          leading: Styles.grid(2),
          bottom: Styles.grid(2),
          trailing: Styles.grid(2)
        )
      )
      .clipShape(Capsule())
      .overlay(
        Capsule()
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

  // We want pills with icons to render at the same height
  // as pills with text, even with large font sizes.
  @ScaledMetric var scaledSize: CGFloat = buttonFont.defaultSize

  // This extra 3 px was determined via trial-and-error.
  // It makes this pill render *exactly* the same height as a text pill.
  let fontPadding = 3.0

  var body: some View {
    Button(action: self.action) {
      Image(uiImage: self.image)
        .renderingMode(.template)
        .aspectRatio(1.0, contentMode: .fill)
        .frame(
          // Always render image pills as square, so the capsule becomes a circle.
          width: self.scaledSize + self.fontPadding,
          height: self.scaledSize + self.fontPadding
        )
    }
    .buttonStyle(SearchFiltersPillStyle(
      isHighlighted: self.isHighlighted
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
    }
    .buttonStyle(SearchFiltersPillStyle(
      isHighlighted: self.isHighlighted
    ))
  }
}
