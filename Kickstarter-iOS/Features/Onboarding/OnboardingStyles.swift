import Foundation
import Library
import SwiftUI

enum OnboardingStyles {
  /// Colors are static because we want the same appearance regardless of the user's Light/Dark Mode settings.

  static let black = Color(.hex(0x000000))
  static let white = Color(.hex(0xFFFFFF))

  static let title = UIFont.ksr_title2().bolded
  static let titleColor = black
  static let subtitle = UIFont.ksr_bodyLG()
  static let subtitleColor = black

  static let ctaFont = UIFont.ksr_bodyLG().bolded
  static let ctaFontColor = black

  static let backgroundColor = Color(.hex(0x06E584))
  static let progressBarTintColor = Color(.hex(0x00743D))
  static let progressBarBackgroundColor = white

  static let closeImage = ImageResource.closeIconNoBackground
  static let backgroundImage = ImageResource.onboardingSquiggleBackground

  static let primaryButtonBackgroundColor = black
  static let primaryButtonForegroundColor = white
  static let secondaryButtonForegroundColor = black
}
