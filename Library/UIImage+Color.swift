import UIKit

public extension UIImage {
  convenience init?(in rect: CGRect, with color: UIColor) {
    UIGraphicsBeginImageContext(rect.size)

    guard let context = UIGraphicsGetCurrentContext() else { return nil }

    context.setFillColor(color.cgColor)
    context.fill(rect)

    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    guard let cgImage = image?.cgImage else { return nil }
    self.init(cgImage: cgImage)
  }
}
