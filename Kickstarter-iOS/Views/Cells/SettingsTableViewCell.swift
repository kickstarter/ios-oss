import Library
import Prelude

final class SettingsTableViewCell: UITableViewCell, ValueCell, NibLoading {
  @IBOutlet fileprivate weak var arrowImageView: UIImageView!
  @IBOutlet fileprivate weak var detailLabel: UILabel!
  @IBOutlet fileprivate weak var lineLayer: UIView!
  @IBOutlet fileprivate weak var titleLabel: UILabel!

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  func configureWith(value cellValue: SettingsCellValue) {
    let cellType = cellValue.cellType

    _ = titleLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text .~ cellType.title
      |> UILabel.lens.textColor .~ cellType.textColor

    _ = arrowImageView
      |> settingsArrowViewStyle
      |> UIImageView.lens.isHidden
      .~ !cellType.showArrowImageView

    _ = detailLabel
      |> UILabel.lens.isHidden %~ { _ in
        return cellType.hideDescriptionLabel
      }
      |> UILabel.lens.text %~ { _ in
        return cellType.description ?? ""
    }
  }

  override func bindStyles() {
    super.bindStyles()

    _ = detailLabel
    |> UILabel.lens.textColor .~ .ksr_text_dark_grey_400

    _ = lineLayer
    |> separatorStyle
  }

  override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    super.setHighlighted(highlighted, animated: animated)

    let backgroundColor: UIColor = .ksr_grey_500
    let highlightedColor = highlighted ? backgroundColor.withAlphaComponent(0.1) : .white

    _ = self
      |> UITableViewCell.lens.backgroundColor .~ highlightedColor
  }
}
