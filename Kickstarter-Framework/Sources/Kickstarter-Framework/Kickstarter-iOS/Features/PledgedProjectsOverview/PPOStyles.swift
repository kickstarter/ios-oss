import Foundation
import KDS
import Library
import SwiftUI

enum PPOStyles {
  static let header = (
    font: { UIFont.ksr_title2() },
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
    font: { UIFont.ksr_callout() },
    foreground: LegacyColors.ksr_black.uiColor(),
    background: LegacyColors.ksr_white.uiColor()
  )

  static let infoColor = (
    foreground: Colors.Text.Accent.Green.bolder.uiColor(),
    background: Colors.Background.Accent.Green.subtle.uiColor()
  )

  static let warningColor = (
    foreground: Colors.Text.secondary.uiColor(),
    background: Colors.Background.Warning.subtle.uiColor()
  )

  static let alertColor = (
    foreground: Colors.Text.Accent.Red.bolder.uiColor(),
    background: Colors.Background.Accent.Red.subtle.uiColor()
  )

  static let title = (
    font: { UIFont.ksr_subhead().bolded },
    color: LegacyColors.ksr_black.uiColor()
  )

  static let subtitle = (
    font: { UIFont.ksr_footnote() },
    color: LegacyColors.ksr_support_400.uiColor()
  )

  static let body = (
    font: { UIFont.ksr_caption1() },
    color: LegacyColors.ksr_black.uiColor()
  )

  static let flagFont = { UIFont.ksr_caption1().bolded }
  static let flagSpacing: CGFloat = Spacing.unit_02

  static let bannerPadding = 7

  static let background = Colors.Background.Surface.primary.uiColor()

  static let timeImage = ImageResource.iconLimitedTime
  static let alertImage = ImageResource.iconNotice
  static let sendMessageImage = ImageResource.iconSendMessage
  static let chevronRight = ImageResource.chevronRight
  static let editAddressImage = ImageResource.edit

  static let badgeColor = LegacyColors.Badge.Notification.background.uiColor()
}
