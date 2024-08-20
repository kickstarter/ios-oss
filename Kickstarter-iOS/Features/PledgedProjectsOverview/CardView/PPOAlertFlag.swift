import SwiftUI

struct PPOAlertFlag: View {
  let alert: Alert
  @EnvironmentObject var style: PPOCardStyles

  var body: some View {
    HStack {
      self.image
        .renderingMode(.template)
        .aspectRatio(contentMode: .fit)
        .foregroundStyle(self.foregroundColor)
        .frame(width: self.style.alert.imageSize, height: self.style.alert.imageSize)
      Spacer()
        .frame(width: self.style.alert.spacerWidth)
      Text(self.alert.message)
        .font(Font(self.style.alert.font))
        .foregroundStyle(self.foregroundColor)
    }
    .padding(self.style.alert.padding)
    .background(self.backgroundColor)
    .clipShape(RoundedRectangle(cornerSize: CGSize(
      width: self.style.alert.cornerRadius,
      height: self.style.alert.cornerRadius
    )))
  }

  var image: Image {
    switch self.alert.type {
    case .time:
      Image(self.style.alert.timeImage)
    case .alert:
      Image(self.style.alert.alertImage)
    }
  }

  var foregroundColor: Color {
    switch self.alert.icon {
    case .warning:
      Color(uiColor: self.style.alert.warningForegroundColor)
    case .alert:
      Color(uiColor: self.style.alert.alertForegroundColor)
    }
  }

  var backgroundColor: Color {
    switch self.alert.icon {
    case .warning:
      Color(uiColor: self.style.alert.warningBackgroundColor)
    case .alert:
      Color(uiColor: self.style.alert.alertBackgroundColor)
    }
  }

  struct Alert: Identifiable {
    let type: AlertType
    let icon: AlertIcon
    let message: String

    var id: String {
      "\(self.type)-\(self.icon)-\(self.message)"
    }

    enum AlertType: Identifiable {
      case time
      case alert

      var id: String {
        switch self {
        case .time:
          "time"
        case .alert:
          "alert"
        }
      }
    }

    enum AlertIcon: Identifiable {
      case warning
      case alert

      var id: String {
        switch self {
        case .warning:
          "warning"
        case .alert:
          "alert"
        }
      }
    }
  }
}

#Preview("Stack of flags") {
  VStack(alignment: .leading, spacing: 8) {
    PPOAlertFlag(alert: .init(type: .time, icon: .warning, message: "Address locks in 8 hours"))
    PPOAlertFlag(alert: .init(type: .alert, icon: .warning, message: "Survey available"))
    PPOAlertFlag(alert: .init(type: .alert, icon: .alert, message: "Payment failed"))
    PPOAlertFlag(alert: .init(type: .time, icon: .alert, message: "Pledge will be dropped in 6 days"))
    PPOAlertFlag(alert: .init(type: .alert, icon: .alert, message: "Card needs authentication"))
  }
  .environmentObject(PPOCardStyles())
}
