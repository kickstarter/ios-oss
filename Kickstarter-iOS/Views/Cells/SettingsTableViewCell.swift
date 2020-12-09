import Library
import Prelude
import UIKit

final class SettingsTableViewCell: UITableViewCell, ValueCell, NibLoading {
  @IBOutlet fileprivate var arrowImageView: UIImageView!
  @IBOutlet fileprivate var titleLabel: UILabel!

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  func configureWith(value cellValue: SettingsCellValue) {
    let cellType = cellValue.cellType

    _ = self
      |> \.accessibilityTraits .~ cellType.accessibilityTraits

    _ = self.titleLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text .~ cellType.title
      |> UILabel.lens.textColor .~ cellType.textColor

    _ = self.arrowImageView
      |> settingsArrowViewStyle
      |> UIImageView.lens.isHidden
      .~ !cellType.showArrowImageView
  }

  override func bindStyles() {
    super.bindStyles()
  }

  override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    super.setHighlighted(highlighted, animated: animated)

    let backgroundColor: UIColor = .ksr_support_300
    let highlightedColor = highlighted ? backgroundColor.withAlphaComponent(0.1) : .ksr_white

    _ = self
      |> UITableViewCell.lens.backgroundColor .~ highlightedColor
  }
}
