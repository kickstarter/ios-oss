import Library
import LiveStream
import Prelude

internal final class LiveStreamChatMessageCell: UITableViewCell, ValueCell {
  let viewModel: LiveStreamChatMessageCellViewModelType = LiveStreamChatMessageCellViewModel()

  @IBOutlet private weak var avatarImageView: UIImageView!
  @IBOutlet private weak var avatarImageViewWidthConstraint: NSLayoutConstraint!
  @IBOutlet private weak var contentStackView: UIStackView!
  @IBOutlet private weak var creatorIndicatorDotImageView: UIImageView!
  @IBOutlet private weak var creatorIndicatorDotImageViewWidthConstraint: NSLayoutConstraint!
  @IBOutlet private weak var creatorTextLabel: UILabel!
  @IBOutlet private weak var nameLabel: UILabel!
  @IBOutlet private weak var nameStackView: UIStackView!
  @IBOutlet private weak var messageLabel: UILabel!
  @IBOutlet private weak var rootStackView: UIStackView!

  internal func configureWith(value chatMessage: LiveStreamChatMessage) {
    self.viewModel.inputs.configureWith(chatMessage: chatMessage)
  }

  internal required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    self.selectionStyle = .none
    self.transform = CGAffineTransform(scaleX: 1, y: -1)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self.contentView
      |> UIView.lens.backgroundColor .~ UIColor.hex(0x353535)

    _  = self.avatarImageView
      |> UIImageView.lens.layer.masksToBounds .~ true
      |> UIImageView.lens.backgroundColor .~ .ksr_grey_500

    _ = self.rootStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)
      |> UIStackView.lens.layoutMargins .~ .init(leftRight: Styles.grid(1))
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true

    _ = self.creatorTextLabel
      |> UILabel.lens.text .~ localizedString(key: "Creator", defaultValue: "Creator")
      |> UILabel.lens.font .~ .ksr_body(size: 12)
      |> UILabel.lens.textColor .~ .white

    _ = self.nameLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ .white

    _ = self.nameStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)
      |> UIStackView.lens.alignment .~ .center

    _ = self.messageLabel
      |> UILabel.lens.font .~ .ksr_body(size: 12)
      |> UILabel.lens.textColor .~ .white
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.avatarImageView.rac.imageUrl = self.viewModel.outputs.avatarImageUrl
    self.creatorIndicatorDotImageView.rac.hidden = self.viewModel.outputs.creatorViewsHidden
    self.creatorTextLabel.rac.hidden = self.viewModel.outputs.creatorViewsHidden
    self.nameLabel.rac.text = self.viewModel.outputs.name
    self.messageLabel.rac.text = self.viewModel.outputs.message
  }

  internal override func layoutSubviews() {
    super.layoutSubviews()

    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2
  }
}
