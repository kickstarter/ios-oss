import Library
import Prelude
import UIKit

final class SettingsTableViewHeader: UIView, NibLoading {
  @IBOutlet fileprivate var titleLabel: UILabel!

  func configure(with title: String) {
    _ = self.titleLabel
      |> \.text .~ title
  }

  override func bindStyles() { super.bindStyles() }
}
