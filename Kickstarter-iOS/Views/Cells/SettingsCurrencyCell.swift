import Prelude
import Library
import KsApi

final class SettingsCurrencyCell: UITableViewCell, NibLoading, ValueCell {

  @IBOutlet fileprivate weak var titleLabel: UILabel!
  @IBOutlet fileprivate weak var currentCurrencyLabel: UILabel!
  @IBOutlet fileprivate weak var separatorView: UIView!

  // TODO - Add View Model Here

  func configureWith(value: SettingsCellValue) {
    _ = titleLabel
      |> UILabel.lens.text .~ value.cellType.title

    _ = currentCurrencyLabel
      |> UILabel.lens.textColor .~ value.cellType.detailTextColor
      |> UILabel.lens.text %~ { _ in value.cellType.description ?? "" }
  }

  override func bindStyles() {
    super.bindStyles()

    _ = titleLabel
      |> settingsTitleLabelStyle

    _ = separatorView
      |> separatorStyle
  }
}
