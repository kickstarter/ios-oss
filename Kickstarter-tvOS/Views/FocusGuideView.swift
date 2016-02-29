import UIKit

class FocusGuideView: UIView {

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    backgroundColor = .clearColor()
  }

  override func canBecomeFocused() -> Bool {
    return true
  }
}
