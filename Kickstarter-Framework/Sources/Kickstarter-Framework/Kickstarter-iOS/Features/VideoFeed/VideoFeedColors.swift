import UIKit

/// Shared color helpers for the Video Feed feature.
/// Uses hex values from design specs.
public enum VideoFeedColors {
  static let white = UIColor(hex: "#FFFFFF")
  static let white25 = UIColor(hex: "#FFFFFF", alpha: 0.25)
  static let white24 = UIColor(hex: "#FFFFFF", alpha: 0.24)

  static let grayD4 = UIColor(hex: "#D4D4D4")
  static let gray656969 = UIColor(hex: "#656969")
  static let gray666666 = UIColor(hex: "#666666")

  static let black = UIColor(hex: "#000000")
  static let black32 = UIColor(hex: "#000000", alpha: 0.32)
  static let black40 = UIColor(hex: "#000000", alpha: 0.40)
  static let black75 = UIColor(hex: "#000000", alpha: 0.75)

  static let surface202020 = UIColor(hex: "#202020", alpha: 0.90)
  static let surface2B2B2D25 = UIColor(hex: "#2B2B2D", alpha: 0.25)

  static let redFF6969 = UIColor(hex: "#FF6969")

  static let blue0866FF = UIColor(hex: "#0866FF")
  static let green05CE78 = UIColor(hex: "#05CE78")
  static let green25D366 = UIColor(hex: "#25D366")

  static let lime9BFF1D = UIColor(hex: "#9BFF1D")
}

extension UIColor {
  /// Creates a UIColor from a hex string like "#RRGGBB".
  convenience init(hex: String, alpha: CGFloat = 1.0) {
    let cleaned = hex
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .replacingOccurrences(of: "#", with: "")

    var value: UInt64 = 0
    Scanner(string: cleaned).scanHexInt64(&value)

    let r = CGFloat((value & 0xFF0000) >> 16) / 255.0
    let g = CGFloat((value & 0x00FF00) >> 8) / 255.0
    let b = CGFloat(value & 0x0000FF) / 255.0

    self.init(red: r, green: g, blue: b, alpha: alpha)
  }
}
