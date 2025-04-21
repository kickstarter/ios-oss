import Library
import SwiftUI

private let buttonFont = InterFont.headingMD

private struct SearchFiltersPillStyle: SwiftUI.ButtonStyle {
  let isHighlighted: Bool

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .buttonStyle(.borderless)
      .font(buttonFont.swiftUIFont())
      .foregroundStyle(.tint)
      .tint(
        Colors.Text.primary.swiftUIColor()
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
            self.isHighlighted ? Colors.Border.active.swiftUIColor() : Colors.Border.bold.swiftUIColor(),
            lineWidth: self.isHighlighted ? 2.0 : 1.0
          )
      )
      .opacity(configuration.isPressed ? 0.5 : 1.0)
  }
}

private struct ScaledToFontSize: ViewModifier {
  let horizontal: Bool
  let vertical: Bool
  // We want pills to scale with the font size.
  @ScaledMetric var scaledSize: CGFloat = buttonFont.defaultSize

  func body(content: Content) -> some View {
    content.frame(
      width: self.horizontal ? self.scaledSize : nil,
      height: self.vertical ? self.scaledSize : nil
    )
  }
}

private extension View {
  /// Make sure all pills render at the same height, by clamping their content to a height scaled to the selected font size.
  func pillHeight() -> some View {
    modifier(ScaledToFontSize(horizontal: false, vertical: true))
  }
}

internal struct FilterBadgeView: View {
  let count: Int
  var body: some View {
    Text("\(self.count)")
      .font(InterFont.headingXS.swiftUIFont())
      .padding(EdgeInsets(
        top: Styles.gridHalf(1),
        leading: Styles.grid(1),
        bottom: Styles.gridHalf(1),
        trailing: Styles.grid(1)
      ))
      .foregroundStyle(Colors.Text.primary.swiftUIColor())
      .background(Colors.Background.accentGraySubtle.swiftUIColor())
      .clipShape(RoundedRectangle(cornerRadius: Styles.grid(1)))
  }
}

internal struct ImagePillButton: View {
  let action: () -> Void
  let image: UIImage
  let isHighlighted: Bool
  let count: Int

  var body: some View {
    Button(action: self.action) {
      HStack {
        Image(uiImage: self.image)
          .renderingMode(.template)
          .aspectRatio(1.0, contentMode: .fill)
          // Always render image pills as square, so the capsule becomes a circle.
          .modifier(ScaledToFontSize(horizontal: true, vertical: true))
        if self.count > 0 {
          FilterBadgeView(count: self.count)
        }
      }
      .pillHeight()
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
  let count: Int

  var body: some View {
    Button(action: self.action) {
      HStack {
        Text(self.title)
        if self.count > 0 {
          FilterBadgeView(count: self.count)
        }
        if let carat = Library.image(named: "arrow-down") {
          Spacer()
          Image(uiImage: carat)
            .renderingMode(.template)
            .aspectRatio(contentMode: .fill)
        }
      }
      .pillHeight()
    }
    .buttonStyle(SearchFiltersPillStyle(
      isHighlighted: self.isHighlighted
    ))
  }
}
