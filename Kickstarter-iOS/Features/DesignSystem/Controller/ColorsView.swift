import Library
import SwiftUI

struct ColorsView: View {
  let semanticColors = [
    Colors.Background.action,
    Colors.Background.selected,
    Colors.Background.Accent.Green.bold,
    Colors.Background.Accent.Green.Bold.pressed,
    Colors.Background.Accent.Green.disabled,
    Colors.Background.Accent.Gray.disabled,
    Colors.Background.Accent.Gray.subtle,
    Colors.Background.Accent.Red.subtle,
    Colors.Background.Action.disabled,
    Colors.Background.Action.pressed,
    Colors.Background.Danger.bold,
    Colors.Background.Danger.Bold.pressed,
    Colors.Background.Danger.disabled,
    Colors.Background.Inverse.pressed,
    Colors.Background.Inverse.disabled,
    Colors.Background.Surface.primary,
    Colors.Border.active,
    Colors.Border.bold,
    Colors.Border.subtle,
    Colors.Border.Danger.bold,
    Colors.Border.Danger.subtle,
    Colors.Icon.green,
    Colors.Icon.primary,
    Colors.Text.primary,
    Colors.Text.secondary,
    Colors.Text.disabled,
    Colors.Text.Inverse.primary,
    Colors.Text.Inverse.disabled,
    Colors.Text.Accent.red,
    Colors.Text.Accent.Red.bolder,
    Colors.Text.Accent.Red.disabled,
    Colors.Text.Accent.Red.Inverse.disabled
  ]

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 4) {
        Text("Semantic Colors")
          .font(InterFont.heading2XL.swiftUIFont())
          .foregroundStyle(Colors.Text.primary.swiftUIColor())
        Text("Dark mode feature flag enabled: \(featureDarkModeEnabled() ? "true" : "false")")
          .font(InterFont.bodyLG.swiftUIFont())
          .foregroundStyle(Colors.Text.primary.swiftUIColor())

        Divider()

        HStack {
          Group {
            VStack(alignment: .leading, spacing: 4) {
              Text("Light mode")
                .font(InterFont.headingLG.swiftUIFont())
                .foregroundStyle(Colors.Text.primary.swiftUIColor())
              ForEach(self.semanticColors) { color in
                ColorCard(title: color.name, color: color.swiftUIColor())
              }
            }
            .padding(.all, 4)
          }
          .environment(\.colorScheme, .light)
          .background(Colors.Background.Surface.primary.swiftUIColor())
          Group {
            VStack(alignment: .leading, spacing: 4) {
              Text("Dark mode")
                .font(InterFont.headingLG.swiftUIFont())
                .foregroundStyle(Colors.Text.primary.swiftUIColor())
              ForEach(self.semanticColors) { color in
                ColorCard(title: color.name, color: color.swiftUIColor())
              }
            }
            .padding(.all, 4)
          }
          .background(Colors.Background.Surface.primary.swiftUIColor())
          .environment(\.colorScheme, .dark)
        }
      }
      .padding(.all, 4)
      .frame(maxWidth: CGFloat.infinity, maxHeight: CGFloat.infinity)
    }
  }
}

extension SemanticColor: @retroactive Identifiable {
  public var id: String {
    return self.name
  }
}

struct ColorCard: View {
  let title: String
  let color: Color
  var body: some View {
    ZStack {
      self.color
      Text(self.title)
        .font(InterFont.bodyMD.swiftUIFont())
        .padding(.all, 4)
        .background(.white)
        .foregroundStyle(.black)
        .frame(alignment: .bottom)
    }
    .frame(minHeight: 100)
    .clipShape(RoundedRectangle(cornerRadius: 8))
  }
}

#Preview {
  ColorsView()
}
