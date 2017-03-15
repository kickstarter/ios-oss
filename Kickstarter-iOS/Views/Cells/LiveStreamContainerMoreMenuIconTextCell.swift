import Library
import LiveStream
import Prelude

internal final class LiveStreamContainerMoreMenuIconTextCell: UITableViewCell, ValueCell {

  @IBOutlet private weak var contentStackView: UIStackView!
  @IBOutlet private weak var iconImageView: UIImageView!
  @IBOutlet private weak var rootStackView: UIStackView!
  @IBOutlet private weak var subtitleLabel: UILabel!
  @IBOutlet private weak var titleLabel: UILabel!

  internal override func awakeFromNib() {
    super.awakeFromNib()

    self.selectedBackgroundView = UIView()
      |> UIView.lens.backgroundColor .~ .hex(0x353535)
  }

  internal func configureWith(value moreMenuItem: LiveStreamContainerMoreMenuItem) {
    switch moreMenuItem {
    case .hideChat(let hidden):
      self.iconImageView.image = Library.image(named: "speech-icon")
      self.titleLabel.isHidden = true
      self.subtitleLabel.text = hidden
        ? localizedString(key: "Show_chat", defaultValue: "Show chat")
        : localizedString(key: "Hide_chat", defaultValue: "Hide chat")
    case .share:
      self.iconImageView.image = Library.image(named: "share-icon")
      self.titleLabel.isHidden = true
      self.subtitleLabel.text = localizedString(key: "Share_live_stream",
                                                defaultValue: "Share live stream")
    case .cancel:
      assertionFailure("Invalid type for this cell class.")
    }
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> UITableViewCell.lens.backgroundColor .~ .hex(0x1B1B1C)

    self.separatorInset = UIEdgeInsets(leftRight: Styles.grid(3))

    _ = self.rootStackView
      |> UIStackView.lens.alignment .~ .center
      |> UIStackView.lens.spacing .~ Styles.grid(2)
      |> UIStackView.lens.layoutMargins .~ UIEdgeInsets(leftRight: Styles.grid(3))
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true

    _ = self.contentStackView
      |> UIStackView.lens.layoutMargins .~ UIEdgeInsets(topBottom: Styles.grid(2))
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.spacing .~ Styles.gridHalf(1)

    _ = self.iconImageView
      |> UIImageView.lens.tintColor .~ .white
      |> UIImageView.lens.contentMode .~ .scaleAspectFit

    _ = self.titleLabel
      |> UILabel.lens.textColor .~ .white
      |> UILabel.lens.font .~ .ksr_headline(size: 13)

    _ = self.subtitleLabel
      |> UILabel.lens.textColor .~ .white
      |> UILabel.lens.font .~ .ksr_body(size: 13)
  }
}
