import Foundation
import Library
import SwiftUI

class PPOCardStyles: ObservableObject {
  let alert = Alert()
  let projectDetails = ProjectDetails()
  let projectCreator = ProjectCreator()

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

  class ProjectDetails: ObservableObject {
    let spacing: CGFloat = Styles.grid(1)

    let imageShape = RoundedRectangle(cornerRadius: Styles.cornerRadius)
    let imageAspectRatio: CGFloat = 16 / 9
    let imageContentMode = ContentMode.fit

    let titleFont = UIFont.ksr_caption1().bolded
    let titleTextColor = UIColor.ksr_black
    let titleLineLimit = 2

    let subtitleFont = UIFont.ksr_footnote()
    let subtitleTextColor = UIColor.ksr_support_400
    let subtitleLineLimit = 1

    let textMaxWidth = CGFloat.infinity
    let textAlignment = Alignment.leading
  }

  class ProjectCreator: ObservableObject {
    let createdByFont = UIFont.ksr_caption2()
    let createdByColor = UIColor.ksr_support_400
    let sendMessageFont = UIFont.ksr_caption2()
    let sendMessageColor = UIColor.ksr_create_700
    let chevronSize: CGFloat = 10
    let chevronOffset = CGSize(width: 0, height: 2)
    let spacerWidth = Styles.grid(1)
    let textLineLimit = 1
    let labelMaxWidth = CGFloat.infinity
    let labelAlignment = Alignment.leading
    let buttonAlignment = Alignment.trailing
  }
}
