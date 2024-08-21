import Foundation
import Library
import SwiftUI

enum PPOCardStyles {
  static let warningColor = (
    foreground: UIColor.ksr_support_400,
    background: UIColor.ksr_celebrate_100
  )

  static let alertColor = (
    foreground: UIColor.hex(0x73140D),
    background: UIColor.hex(0xFEF2F1)
  )

  static let title = (
    font: UIFont.ksr_caption1().bolded,
    color: UIColor.ksr_black
  )

  static let subtitle = (
    font: UIFont.ksr_footnote(),
    color: UIColor.ksr_support_400
  )

  static let timeImage = ImageResource.iconLimitedTime
  static let alertImage = ImageResource.iconNotice
}
