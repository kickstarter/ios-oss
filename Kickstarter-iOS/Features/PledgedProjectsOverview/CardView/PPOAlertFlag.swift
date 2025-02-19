import KsApi
import Library
import SwiftUI

struct PPOAlertFlag: View {
  let alert: PPOProjectCardModel.Alert

  var body: some View {
    HStack {
      self.image
        .renderingMode(.template)
        .aspectRatio(contentMode: .fit)
        .foregroundStyle(self.foregroundColor)
        .frame(width: Constants.imageSize, height: Constants.imageSize)
      Spacer()
        .frame(width: Constants.spacerWidth)
      Text(self.alert.message)
        .font(Font(PPOStyles.flagFont))
        .foregroundStyle(self.foregroundColor)
    }
    .padding(Constants.padding)
    .background(self.backgroundColor)
    .clipShape(RoundedRectangle(cornerSize: CGSize(
      width: Constants.cornerRadius,
      height: Constants.cornerRadius
    )))
    .accessibilityElement(children: .combine)
    .accessibilityAddTraits(.isStaticText)
  }

  var image: Image {
    switch self.alert.icon {
    case .time:
      Image(PPOStyles.timeImage)
    case .alert:
      Image(PPOStyles.alertImage)
    }
  }

  var foregroundColor: Color {
    switch self.alert.type {
    case .warning:
      Color(uiColor: PPOStyles.warningColor.foreground)
    case .alert:
      Color(uiColor: PPOStyles.alertColor.foreground)
    }
  }

  var backgroundColor: Color {
    switch self.alert.type {
    case .warning:
      Color(uiColor: PPOStyles.warningColor.background)
    case .alert:
      Color(uiColor: PPOStyles.alertColor.background)
    }
  }

  private enum Constants {
    static let imageSize: CGFloat = 18
    static let spacerWidth: CGFloat = 4
    static let cornerRadius: CGFloat = 6
    static let font = UIFont.ksr_caption1().bolded
    static let padding = EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 8)
  }
}

#Preview("Stack of flags") {
  VStack(alignment: .leading, spacing: 8) {
    PPOAlertFlag(alert: .init(type: .warning, icon: .time, message: "Address locks in 8 hours"))
    PPOAlertFlag(alert: .init(type: .warning, icon: .alert, message: "Survey available"))
    PPOAlertFlag(alert: .init(type: .alert, icon: .alert, message: "Payment failed"))
    PPOAlertFlag(alert: .init(type: .alert, icon: .time, message: "Pledge will be dropped in 6 days"))
    PPOAlertFlag(alert: .init(type: .alert, icon: .alert, message: "Card needs authentication"))
  }
}
