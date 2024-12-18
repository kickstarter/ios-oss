import UIKit

extension UIView {
  public func rounded(with cornerRadius: CGFloat = Styles.cornerRadius) {
    self.clipsToBounds = true
    self.layer.masksToBounds = true
    self.layer.cornerRadius = cornerRadius
  }
}
