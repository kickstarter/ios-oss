import UIKit

class ContentSizeTableView: UITableView {
  override var contentSize: CGSize {
    didSet {
      self.invalidateIntrinsicContentSize()
    }
  }

  override var intrinsicContentSize: CGSize {
    self.layoutIfNeeded()

    // height minus 1 px to hide last cell separator
    return CGSize(width: UIView.noIntrinsicMetric, height: self.contentSize.height - 1)
  }
}
