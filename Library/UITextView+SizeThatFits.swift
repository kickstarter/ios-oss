import Foundation
import UIKit

public extension UITextView {
  func ksr_sizeThatFitsCurrentWidth() -> CGSize {
    return self.sizeThatFits(
      CGSize(width: self.bounds.size.width, height: .greatestFiniteMagnitude)
    )
  }
}
