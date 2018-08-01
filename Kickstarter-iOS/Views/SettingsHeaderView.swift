import Library
import Prelude

final class SettingsHeaderView: UITableViewHeaderFooterView {
  @IBOutlet fileprivate weak var titleLabel: UILabel!

  func configure(title: String) {
    _ = titleLabel
      |> UILabel.lens.text .~ title
  }

  override func bindStyles() {
    super.bindStyles()

    _ = titleLabel
      |> settingsSectionLabelStyle
  }
}
