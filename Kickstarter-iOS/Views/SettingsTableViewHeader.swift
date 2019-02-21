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
      |> \.layoutMargins .~ .init(top: Styles.grid(5),
                                  left: Styles.grid(2),
                                  bottom: Styles.grid(3),
                                  right: Styles.grid(2))

    _ = self.titleLabel
      |> settingsDescriptionLabelStyle
  }
}
