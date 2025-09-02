import SwiftUI

public struct ColorsView: View {
  fileprivate let semanticColors = [
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
    Colors.Background.Action.primary,
    Colors.Background.Action.Primary.disabled,
    Colors.Background.Action.Primary.pressed,
    Colors.Background.Danger.bold,
    Colors.Background.Danger.Bold.pressed,
    Colors.Background.Danger.disabled,
    Colors.Background.Danger.subtle,
    Colors.Background.Inverse.pressed,
    Colors.Background.Inverse.disabled,
    Colors.Background.Surface.primary,
    Colors.Background.Surface.secondary,
    Colors.Brand.logo,
    Colors.Border.active,
    Colors.Border.bold,
    Colors.Border.disabled,
    Colors.Border.focus,
    Colors.Border.inverse,
    Colors.Border.subtle,
    Colors.Border.Accent.Blue.bold,
    Colors.Border.Accent.Blue.subtle,
    Colors.Border.Accent.Green.bold,
    Colors.Border.Accent.Green.subtle,
    Colors.Border.Danger.bold,
    Colors.Border.Danger.subtle,
    Colors.Border.Warning.bold,
    Colors.Border.Warning.subtle,
    Colors.Icon.danger,
    Colors.Icon.disabled,
    Colors.Icon.green,
    Colors.Icon.info,
    Colors.Icon.inverse,
    Colors.Icon.pressed,
    Colors.Icon.primary,
    Colors.Icon.subtle,
    Colors.Icon.warning,
    Colors.Icon.Danger.inverse,
    Colors.Icon.Green.inverse,
    Colors.Text.primary,
    Colors.Text.secondary,
    Colors.Text.disabled,
    Colors.Text.placeholder,
    Colors.Text.Inverse.primary,
    Colors.Text.Inverse.disabled,
    Colors.Text.Accent.red,
    Colors.Text.Accent.Red.bolder,
    Colors.Text.Accent.Red.disabled,
    Colors.Text.Accent.Red.Inverse.disabled,
    Colors.Text.Accent.gray,
    Colors.Text.Accent.green,
    Colors.Text.Accent.Blue.bolder,
    Colors.Text.Accent.Green.bolder,
    Colors.Text.Accent.Purple.bolder,
    Colors.Text.Accent.Yellow.bolder
  ]

  fileprivate let legacyColors = [
    LegacyColors.ksr_alert,
    LegacyColors.ksr_black,
    LegacyColors.ksr_white,
    LegacyColors.ksr_celebrate_500,
    LegacyColors.ksr_celebrate_700,
    LegacyColors.ksr_create_100,
    LegacyColors.ksr_create_300,
    LegacyColors.ksr_create_500,
    LegacyColors.ksr_create_700,
    LegacyColors.ksr_support_100,
    LegacyColors.ksr_support_200,
    LegacyColors.ksr_support_300,
    LegacyColors.ksr_support_400,
    LegacyColors.ksr_support_500,
    LegacyColors.ksr_support_700,
    LegacyColors.ksr_trust_100,
    LegacyColors.ksr_trust_500,
    LegacyColors.ksr_trust_700,
    LegacyColors.Background.Action.primary,
    LegacyColors.Background.Action.Primary.disabled,
    LegacyColors.Background.Action.Primary.pressed,
    LegacyColors.Facebook.primary,
    LegacyColors.Facebook.disabled,
    LegacyColors.Facebook.pressed,
    LegacyColors.Project.Navigation.selected,
    LegacyColors.Tags.Success.background,
    LegacyColors.Tags.Success.foreground,
    LegacyColors.Tags.Warn.background,
    LegacyColors.Tags.Warn.foreground,
    LegacyColors.Tags.Error.background,
    LegacyColors.Tags.Error.foreground,
    LegacyColors.Background.search,
    LegacyColors.Buttons.blue
  ]

  internal var snapshotTestHeight: CGFloat {
    150.0 + CGFloat(self.semanticColors.count + self.legacyColors.count) * 104.0
  }

  @ViewBuilder
  var colorList: some View {
    ForEach(self.semanticColors) { color in
      ColorCard(title: color.name, color: color.swiftUIColor())
    }
    ForEach(self.legacyColors) { color in
      ColorCard(title: color.name, color: color.swiftUIColor())
    }
  }

  public init() {}

  public var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 4) {
        Text("Semantic Colors")
          .font(InterFont.heading2XL.swiftUIFont())
          .foregroundStyle(Colors.Text.primary.swiftUIColor())

        Divider()

        HStack {
          Group {
            VStack(alignment: .leading, spacing: 4) {
              Text("Light mode")
                .font(InterFont.headingLG.swiftUIFont())
                .foregroundStyle(Colors.Text.primary.swiftUIColor())
              self.colorList
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
              self.colorList
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

extension LegacyColor: @retroactive Identifiable {
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
