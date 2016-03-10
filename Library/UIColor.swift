import class UIKit.UIColor
import struct CoreGraphics.CGFloat
import func CoreGraphics./
import func Darwin.round

extension UIColor {
  @nonobjc static func hexa(value: UInt32) -> UIColor {
    let a = CGFloat((value & 0xFF000000) >> 24) / 255.0
    let r = CGFloat((value & 0xFF0000) >> 16) / 255.0
    let g = CGFloat((value & 0xFF00) >> 8) / 255.0
    let b = CGFloat((value & 0xFF)) / 255.0

    let aRounded = UIColor.toDecimalPlace(a, decimalNum: 1)
    let rRounded = UIColor.toDecimalPlace(r, decimalNum: 2)
    let gRounded = UIColor.toDecimalPlace(g, decimalNum: 2)
    let bRounded = UIColor.toDecimalPlace(b, decimalNum: 2)

    return UIColor(red: rRounded, green: gRounded, blue: bRounded, alpha: aRounded)
  }

  @nonobjc static func hex(value: UInt32) -> UIColor {
    let r = CGFloat((value & 0xFF0000) >> 16) / 255.0
    let g = CGFloat((value & 0xFF00) >> 8) / 255.0
    let b = CGFloat((value & 0xFF)) / 255.0

    let rRounded = UIColor.toDecimalPlace(r, decimalNum: 2)
    let gRounded = UIColor.toDecimalPlace(g, decimalNum: 2)
    let bRounded = UIColor.toDecimalPlace(b, decimalNum: 2)

    return UIColor(red: rRounded, green: gRounded, blue: bRounded, alpha: 1.0)
  }

  private static func toDecimalPlace(num: CGFloat, decimalNum: Int) -> CGFloat {
    switch decimalNum {
    case 1:
      return CGFloat(round(Double(num) * 10) / 10)
    case 2:
      return CGFloat(round(Double(num) * 100) / 100)
    default:
      return num
    }
  }
}
