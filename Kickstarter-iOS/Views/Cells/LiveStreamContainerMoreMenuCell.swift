import Library
import LiveStream
import Prelude

internal final class LiveStreamContainerMoreMenuCell: UITableViewCell, ValueCell {


  @IBOutlet private weak var contentStackView: UIStackView!
  @IBOutlet private weak var creatorAvatarImageView: UIImageView!
  @IBOutlet private weak var iconImageView: UIImageView!
  @IBOutlet private weak var rightActionActivityIndicatorView: UIActivityIndicatorView!
  @IBOutlet private weak var rightActionButton: UIButton!
  @IBOutlet private weak var rootStackView: UIStackView!
  @IBOutlet private weak var subtitleLabel: UILabel!
  @IBOutlet private weak var titleLabel: UILabel!


  let viewModel: LiveStreamContainerMoreMenuCellViewModelType = LiveStreamContainerMoreMenuCellViewModel()

  internal func configureWith(value moreMenuItem: LiveStreamContainerMoreMenuItem) {
    self.viewModel.inputs.configureWith(moreMenuItem: moreMenuItem)
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
      |> UIStackView.lens.spacing .~ (Styles.grid(1) / 2)

    _ = self.iconImageView
      |> UIImageView.lens.tintColor .~ .white
      |> UIImageView.lens.contentMode .~ .scaleAspectFit

    _ = self.creatorAvatarImageView
      |> UIImageView.lens.layer.masksToBounds .~ true
      |> UIImageView.lens.contentMode .~ .scaleAspectFit

    _ = self.titleLabel
      |> UILabel.lens.textColor .~ .white
      |> UILabel.lens.font .~ .ksr_headline(size: 13)

    _ = self.subtitleLabel
      |> UILabel.lens.textColor .~ .white
      |> UILabel.lens.font .~ .ksr_body(size: 13)

    _ = self.rightActionButton
      |> lightSubscribeButtonStyle

    _ = self.rightActionActivityIndicatorView
      |> UIActivityIndicatorView.lens.tintColor .~ .white
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.creatorAvatarImageView.rac.hidden = self.viewModel.outputs.creatorAvatarHidden
    self.creatorAvatarImageView.rac.imageUrl = self.viewModel.outputs.creatorAvatarUrl

    self.viewModel.outputs.iconImage
      .observeForUI()
      .observeValues { [weak self] in
        self?.iconImageView.image = $0
    }

    self.iconImageView.rac.hidden = self.viewModel.outputs.iconImageHidden
    self.titleLabel.rac.hidden = self.viewModel.outputs.titleLabelTextHidden
    self.titleLabel.rac.text = self.viewModel.outputs.titleLabelText
    self.subtitleLabel.rac.text = self.viewModel.outputs.subtitleLabelText
    self.rightActionButton.rac.hidden = self.viewModel.outputs.rightActionButtonHidden
  }

  internal override func layoutSubviews() {
    super.layoutSubviews()

    self.creatorAvatarImageView.layer.cornerRadius = self.creatorAvatarImageView.frame.size.width / 2
  }
}
