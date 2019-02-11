import Library
import Prelude

final class SettingsTableViewHeader: UIView, NibLoading {
  @IBOutlet fileprivate weak var titleLabel: UILabel!

  func configure(with title: String) {
    _ = self.titleLabel
      |> \.text .~ title
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> \.backgroundColor .~ .ksr_grey_200
      |> \.layoutMargins .~ .init(topBottom: Styles.grid(3), leftRight: Styles.grid(2))

    _ = self.titleLabel
      |> settingsDescriptionLabelStyle
      |> \.preferredMaxLayoutWidth .~ self.titleLabel.bounds.width
  }
}
