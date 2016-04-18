import UIKit

extension UIViewController {
  public override func awakeFromNib() {
    bindViewModel()
  }

  public func bindViewModel() {
  }

  public static var defaultNib: String {
    return self.description().componentsSeparatedByString(".").dropFirst().joinWithSeparator(".")
  }
}
