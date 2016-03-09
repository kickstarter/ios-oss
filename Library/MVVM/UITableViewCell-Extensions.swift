import class UIKit.UITableViewCell

extension UITableViewCell {
  public override func awakeFromNib() {
    super.awakeFromNib()
    bindViewModel()
  }

  /// All signal observations should happen in here.
  public func bindViewModel() {
  }
}
