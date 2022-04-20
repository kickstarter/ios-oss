import Library
import Prelude
import UIKit

final class SettingsFooterView: UITableViewHeaderFooterView {
  static var defaultHeight: CGFloat = 44

  // MARK: - Properties

  @IBOutlet private var titleLabel: UILabel!

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
