import UIKit

/// Represents colors in our design system New Core Colors palette initially created for mobile visioning work.
/// First applied to the new Floating Tab Bar UI.
public enum CoreColorV2: Int {
  case white = 0xFFFFFF

  case gray_1050 = 0x272727

  case green_200 = 0xA3FF55
}

public extension UIColor {
  convenience init(coreColorV2: CoreColorV2, alpha: Double = 1) {
    let rgbValue = coreColorV2.rawValue
    self.init(
      red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
      green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
      blue: Double(rgbValue & 0x0000FF) / 255.0,
      alpha: alpha
    )
  }
}
