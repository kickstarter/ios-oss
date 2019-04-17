import UIKit
import Foundation
import Prelude

final class MultiLineButton: UIButton {
  override var intrinsicContentSize: CGSize {
    let size = self.titleLabel?.intrinsicContentSize ?? .zero
    let titleInsets = self.titleEdgeInsets

    return CGSize(
      width: titleInsets.left + size.width  + titleInsets.right,
      height: titleInsets.top + size.height + titleInsets.bottom
    )
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let width = self.titleLabel?.frame.width ?? 0

    _ = self.titleLabel
      ?|> \.preferredMaxLayoutWidth .~ width
  }
}
