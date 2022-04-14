import Library
import Prelude
import UIKit

final class SettingsTableViewHeader: UIView, NibLoading {
  @IBOutlet fileprivate var titleLabel: UILabel!

  func configure(with title: String) {
    _ = self.titleLabel
      |> \.text .~ title
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> \.backgroundColor .~ .ksr_support_100
      |> \.layoutMargins .~ .init(
        top: Styles.grid(5),
        left: Styles.grid(2),
        bottom: Styles.grid(3),
        right: Styles.grid(2)
      )

    _ = self.titleLabel
      |> settingsDescriptionLabelStyle
  }
}
