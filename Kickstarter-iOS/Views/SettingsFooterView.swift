import Library
import Prelude

final class SettingsFooterView: UITableViewHeaderFooterView {
  // MARK: - Properties

  @IBOutlet private weak var titleLabel: UILabel!

  // MARK: - Lifecycle

  public func configure(with text: String) {
    _ = self.titleLabel
      |> settingsHeaderFooterLabelBaseStyle
      |> \.text .~ text
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.titleLabel
      |> settingsHeaderFooterLabelStyle
  }
}
