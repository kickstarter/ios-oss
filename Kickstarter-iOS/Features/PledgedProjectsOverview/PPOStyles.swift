import Foundation
import Library
import SwiftUI

enum PPOStyles {
  static let header = (
    font: UIFont.ksr_title2(),
    foreground: Colors.Text.primary.uiColor(),
    background: Colors.Background.Surface.primary.uiColor(),
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
    foreground: LegacyColors.Tags.Warn.foreground.uiColor(),
    background: LegacyColors.Tags.Warn.background.uiColor()
  )

  static let alertColor = (
    foreground: LegacyColors.Tags.Error.foreground.uiColor(),
    background: LegacyColors.Tags.Error.background.uiColor()
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

  static let background = Colors.Background.Surface.primary.uiColor()

  static let timeImage = ImageResource.iconLimitedTime
  static let alertImage = ImageResource.iconNotice
  static let sendMessageImage = ImageResource.iconSendMessage

  static let badgeColor = UIColor.hex(0xFF3B30)
}
