import UIKit

public enum CoreColor: Int {
  case white = 0xFFFFFF
  case grey_100 = 0xFAFAFA
  case grey_400 = 0xC9C9C9
  case grey_700 = 0x4D4D4D
  case grey_1000 = 0x171717
  case red_400 = 0xF7BBB7
  case red_700 = 0x931910
  // etc
}

extension UIColor {
  convenience init(coreColor: CoreColor) {
    let rgbValue = coreColor.rawValue
    self.init(
      red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
      green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
      blue: Double(rgbValue & 0x0000FF) / 255.0,
      alpha: 1.0
    )
  }
}
