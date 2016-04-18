import UIKit

extension UIView {
  public override func awakeFromNib() {
    super.awakeFromNib()
    bindViewModel()
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
