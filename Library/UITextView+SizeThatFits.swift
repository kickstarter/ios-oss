import Foundation
import UIKit

public extension UITextView {
  func sizeThatFitsCurrentWidth() -> CGSize {
    return self.sizeThatFits(
      CGSize(width: self.bounds.size.width, height: .greatestFiniteMagnitude)
    )
  }
}
