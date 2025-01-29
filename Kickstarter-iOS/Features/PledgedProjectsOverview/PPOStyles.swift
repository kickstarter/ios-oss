import Foundation
import Library
import SwiftUI

enum PPOStyles {
  static let header = (
    font: UIFont.ksr_title2(),
    foreground: UIColor.ksr_black,
    background: UIColor.ksr_white,
    padding: Edge.Set.top
  )

  static let loaderControlSize = ControlSize.large

  static let list = (
    separator: Visibility.hidden,
    rowInsets: EdgeInsets?.none
  )

  static let error = (
    font: UIFont.ksr_callout(),
    foreground: UIColor.ksr_black,
    background: UIColor.ksr_white
  )

  static let warningColor = (
    foreground: UIColor.ksr_support_400,
    background: UIColor.ksr_celebrate_100
  )

  static let alertColor = (
    foreground: UIColor.hex(0x73140D),
    background: UIColor.hex(0xFEF2F1)
  )

  static let title = (
    font: UIFont.ksr_subhead().bolded,
    color: UIColor.ksr_black
  )

  static let subtitle = (
    font: UIFont.ksr_footnote(),
    color: UIColor.ksr_support_400
  )

  static let body = (
    font: UIFont.ksr_caption1(),
    color: UIColor.ksr_black
  )

  static let flagFont = UIFont.ksr_caption1().bolded

  static let bannerPadding = 7

  static let background = UIColor.ksr_white

  static let timeImage = ImageResource.iconLimitedTime
  static let alertImage = ImageResource.iconNotice

  static let badgeColor = UIColor.hex(0xFF3B30)
}
