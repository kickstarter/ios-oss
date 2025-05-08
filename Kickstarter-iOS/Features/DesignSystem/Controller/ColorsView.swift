import Library
import SwiftUI

struct ColorsView: View {
  let semanticColors = [
    Colors2.surface.primary,
    Colors2.text.primary,
    Colors2.text.secondary,
    Colors2.text.accent.red.disabled
  ]

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 4) {
        Text("Semantic Colors")
          .font(InterFont.heading2XL.swiftUIFont())
          .foregroundStyle(Colors2.text.primary.swiftUIColor())
        Text("Dark mode feature flag enabled: \(featureDarkModeEnabled() ? "true" : "false")")
          .font(InterFont.bodyLG.swiftUIFont())
          .foregroundStyle(Colors2.text.primary.swiftUIColor())

        Divider()

        HStack {
          Group {
            VStack(alignment: .leading, spacing: 4) {
              Text("Light mode")
                .font(InterFont.headingLG.swiftUIFont())
                .foregroundStyle(Colors2.text.primary.swiftUIColor())
              ForEach(self.semanticColors) { color in
                ColorCard(title: color.name, color: color.swiftUIColor())
              }
            }
            .padding(.all, 4)
          }
          .environment(\.colorScheme, .light)
          .background(Colors2.surface.primary.swiftUIColor())
          Group {
            VStack(alignment: .leading, spacing: 4) {
              Text("Dark mode")
                .font(InterFont.headingLG.swiftUIFont())
                .foregroundStyle(Colors2.text.primary.swiftUIColor())
              ForEach(self.semanticColors) { color in
                ColorCard(title: color.name, color: color.swiftUIColor())
              }
            }
            .padding(.all, 4)
          }
          .background(Colors2.surface.primary.swiftUIColor())
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
