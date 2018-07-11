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
      |> UILabel.lens.text .~ cellType.titleString
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
    _ = arrowImageView
    |> UIImageView.lens.image %~ { _ in
      UIImage(named: "chevron-right", in: .framework, compatibleWith: nil)
    }

    _ = titleLabel
    |> UILabel.lens.font .~ .ksr_body()

    _ = appVersionLabel
    |> UILabel.lens.textColor .~ .ksr_text_dark_grey_400

    _ = lineLayer
    |> UIView.lens.backgroundColor .~ .ksr_grey_400
  }
}
