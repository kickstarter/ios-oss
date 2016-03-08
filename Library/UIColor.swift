import class UIKit.UIColor
import struct CoreGraphics.CGFloat
import func CoreGraphics./

extension UIColor {
  @nonobjc static func hexa(value: UInt32) -> UIColor {
    let a = CGFloat((value & 0xFF000000) >> 24) / 255.0
    let r = CGFloat((value & 0xFF0000) >> 16) / 255.0
    let g = CGFloat((value & 0xFF00) >> 8) / 255.0
    let b = CGFloat((value & 0xFF)) / 255.0

    return UIColor(red: r, green: g, blue: b, alpha: a)
  }

  @nonobjc static func hex(value: UInt32) -> UIColor {
    let r = CGFloat((value & 0xFF0000) >> 16) / 255.0
    let g = CGFloat((value & 0xFF00) >> 8) / 255.0
    let b = CGFloat((value & 0xFF)) / 255.0

    return UIColor(red: r, green: g, blue: b, alpha: 1.0)
  }
}
