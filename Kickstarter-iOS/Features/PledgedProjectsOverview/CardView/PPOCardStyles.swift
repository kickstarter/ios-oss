import Foundation
import Library
import SwiftUI

class PPOCardStyles: ObservableObject {
  let alert = Alert()

  class Alert: ObservableObject {
    let warningForegroundColor = UIColor.ksr_support_400
    let warningBackgroundColor = UIColor.ksr_celebrate_100

    let alertForegroundColor = UIColor.hex(0x73140D)
    let alertBackgroundColor = UIColor.hex(0xFEF2F1)

    let timeImage = ImageResource.iconLimitedTime
    let alertImage = ImageResource.iconNotice

    let imageSize: CGFloat = 18
    let spacerWidth: CGFloat = 4
    let cornerRadius: CGFloat = 6
    let font = UIFont.ksr_caption1().bolded
    let padding = EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 8)
  }
}
