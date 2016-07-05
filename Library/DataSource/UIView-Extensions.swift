import UIKit

extension UIView {
  public override func awakeFromNib() {
    super.awakeFromNib()
    self.bindViewModel()
    self.bindStyles()
  }

  public func bindStyles() {
  }

  public func bindViewModel() {
  }

  public static var defaultReusableId: String {
    return self.description()
      .componentsSeparatedByString(".")
      .dropFirst()
      .joinWithSeparator(".")
  }
}
