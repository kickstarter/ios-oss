import Foundation
import Library
import SwiftUI

enum PPOStyles {
  static let header = (
    font: UIFont.ksr_title2(),
    foreground: LegacyColors.ksr_black.uiColor(),
    background: LegacyColors.ksr_white.uiColor(),
    padding: Edge.Set.top
  )

  static let loaderControlSize = ControlSize.large

  static let list = (
    separator: Visibility.hidden,
    rowInsets: EdgeInsets?.none
  )

  static let error = (
    font: UIFont.ksr_callout(),
    foreground: LegacyColors.ksr_black.uiColor(),
    background: LegacyColors.ksr_white.uiColor()
  )

  static let warningColor = (
    foreground: LegacyColors.ksr_support_400.uiColor(),
    background: LegacyColors.ksr_celebrate_100.uiColor()
  )

  static let alertColor = (
    foreground: Colors.Text.Accent.Red.bolder.uiColor(),
    background: Colors.Background.Danger.subtle.uiColor()
  )

  static let title = (
    font: UIFont.ksr_subhead().bolded,
    color: LegacyColors.ksr_black.uiColor()
  )

  static let subtitle = (
    font: UIFont.ksr_footnote(),
    color: LegacyColors.ksr_support_400.uiColor()
  )

  static let body = (
    font: UIFont.ksr_caption1(),
    color: LegacyColors.ksr_black.uiColor()
  )

  static let flagFont = UIFont.ksr_caption1().bolded
  static let flagSpacing: CGFloat = 8

  static let bannerPadding = 7

  static let background = LegacyColors.ksr_white.uiColor()

  static let timeImage = ImageResource.iconLimitedTime
  static let alertImage = ImageResource.iconNotice
  static let sendMessageImage = ImageResource.iconSendMessage

  static let badgeColor = UIColor.hex(0xFF3B30)
}
