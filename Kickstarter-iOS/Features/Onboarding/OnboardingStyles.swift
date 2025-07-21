import Foundation
import Library
import SwiftUI

enum OnboardingStyles {
  static let title = UIFont.ksr_title2().bolded
  static let subtitle = UIFont.ksr_bodyLG()

  static let ctaFont = UIFont.ksr_bodyLG().bolded

  static let backgroundColor = Color(.hex(0x06E584))
  static let progressBarTintColor = Color(.hex(0x00743D))

  static let closeImage = ImageResource.closeIconNoBackground
  static let backgroundImage = ImageResource.onboardingSquiggleBackground

  static let primaryButtonBackgroundColor = Color(.black)
  static let primaryButtonForegroundColor = Color(.white)
  static let secondaryButtonForegroundColor = Color(.black)
}
