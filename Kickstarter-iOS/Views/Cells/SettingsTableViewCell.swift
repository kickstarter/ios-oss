import Library
import Prelude

final class SettingsTableViewCell: UITableViewCell, ValueCell, NibLoading {
  @IBOutlet fileprivate weak var titleLabel: UILabel!
  @IBOutlet fileprivate weak var arrowImageView: UIImageView!
  @IBOutlet fileprivate weak var appVersionLabel: UILabel!
  @IBOutlet fileprivate weak var lineLayer: UIView!

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  func configureWith(value cellType: SettingsCellTypeProtocol) {
    _ = titleLabel
      |> UILabel.lens.text .~ cellType.title
      |> UILabel.lens.textColor .~ cellType.textColor

    _ = arrowImageView
      |> UIImageView.lens.isHidden
      .~ !cellType.showArrowImageView

    _ = appVersionLabel
      |> UILabel.lens.isHidden %~ { _ in
        return cellType.hideDescriptionLabel
      }
      |> UILabel.lens.text %~ { _ in
        let versionString = AppEnvironment.current.mainBundle.shortVersionString
        let build = AppEnvironment.current.mainBundle.isRelease
          ? ""
          : " #\(AppEnvironment.current.mainBundle.version)"
        return "\(versionString)\(build)"
    }
  }

  override func bindStyles() {
    _ = titleLabel
    |> UILabel.lens.font .~ .ksr_body()

    _ = appVersionLabel
    |> UILabel.lens.textColor .~ .ksr_text_dark_grey_400

    _ = lineLayer
    |> UIView.lens.backgroundColor .~ .ksr_grey_400
  }

  override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    super.setHighlighted(highlighted, animated: animated)

    let backgroundColor: UIColor = .ksr_grey_500
    let highlightedColor = highlighted ? backgroundColor.withAlphaComponent(0.1) : .white

    _ = self
      |> UITableViewCell.lens.backgroundColor .~ highlightedColor
  }
}
