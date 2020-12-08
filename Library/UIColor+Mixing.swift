import UIKit

extension UIColor {
  public func mixLighter(_ amount: CGFloat) -> UIColor {
    return self.mix(with: .ksr_white, amount: amount)
  }

  public func mixDarker(_ amount: CGFloat) -> UIColor {
    return self.mix(with: .ksr_black, amount: amount)
  }

  private func mix(with color: UIColor, amount: CGFloat) -> UIColor {
    var r1: CGFloat = 0
    var g1: CGFloat = 0
    var b1: CGFloat = 0
    var alpha1: CGFloat = 0
    var r2: CGFloat = 0
    var g2: CGFloat = 0
    var b2: CGFloat = 0
    var alpha2: CGFloat = 0

    self.getRed(&r1, green: &g1, blue: &b1, alpha: &alpha1)
    color.getRed(&r2, green: &g2, blue: &b2, alpha: &alpha2)

    return UIColor(
      red: r1 * (1.0 - amount) + r2 * amount,
      green: g1 * (1.0 - amount) + g2 * amount,
      blue: b1 * (1.0 - amount) + b2 * amount,
      alpha: alpha1
    )
  }
}
