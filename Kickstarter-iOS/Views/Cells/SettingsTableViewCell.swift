import Library
import Prelude

final class SettingsTableViewCell: UITableViewCell, ValueCell, NibLoading {
  @IBOutlet fileprivate weak var titleLabel: UILabel!
  @IBOutlet fileprivate weak var arrowImageView: UIImageView!
  @IBOutlet fileprivate weak var appVersionLabel: UILabel!
  @IBOutlet fileprivate weak var lineLayer: UIView!

  private var cellType: SettingsCellType!

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  func configureWith(value cellType: SettingsCellType) {
    self.cellType = cellType

    _ = titleLabel
      |> UILabel.lens.text .~ cellType.titleString
      |> UILabel.lens.textColor %~ { _ in
        print(cellType)
        return cellType == .logout ? .ksr_red_400 : .ksr_text_dark_grey_500
      }

    _ = arrowImageView
      |> UIImageView.lens.isHidden
      .~ !cellType.showArrowImageView

    _ = appVersionLabel
      |> UILabel.lens.isHidden %~ { _ in
        return !(cellType == .appVersion)
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
