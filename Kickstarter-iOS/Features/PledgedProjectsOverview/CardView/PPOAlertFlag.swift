import Library
import SwiftUI

struct PPOAlertFlag: View {
  let alert: PPOProjectCardViewModel.Alert
  
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
        .font(Font(Constants.font))
        .foregroundStyle(self.foregroundColor)
    }
    .padding(Constants.padding)
    .background(self.backgroundColor)
    .clipShape(RoundedRectangle(cornerSize: CGSize(width: Constants.cornerRadius, height: Constants.cornerRadius)))
  }
  
  var image: Image {
    switch self.alert.type {
    case .time:
      Image(Constants.timeImage)
    case .alert:
      Image(Constants.alertImage)
    }
  }
  
  var foregroundColor: Color {
    switch self.alert.icon {
    case .warning:
      Color(uiColor: Constants.warningForegroundColor)
    case .alert:
      Color(uiColor: Constants.alertForegroundColor)
    }
  }
  
  var backgroundColor: Color {
    switch self.alert.icon {
    case .warning:
      Color(uiColor: Constants.warningBackgroundColor)
    case .alert:
      Color(uiColor: Constants.alertBackgroundColor)
    }
  }
  
  private enum Constants {
    static let warningForegroundColor = UIColor.ksr_support_400
    static let warningBackgroundColor = UIColor.ksr_celebrate_100
    
    static let alertForegroundColor = UIColor.hex(0x73140D)
    static let alertBackgroundColor = UIColor.hex(0xFEF2F1)
    
    static let timeImage = ImageResource.iconLimitedTime
    static let alertImage = ImageResource.iconNotice
    
    static let imageSize: CGFloat = 18
    static let spacerWidth: CGFloat = 4
    static let cornerRadius: CGFloat = 6
    static let font = UIFont.ksr_caption1().bolded
    static let padding = EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 8)
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
}
