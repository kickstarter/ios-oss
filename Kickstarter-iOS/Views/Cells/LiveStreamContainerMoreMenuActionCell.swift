import Library
import LiveStream
import Prelude

internal final class LiveStreamContainerMoreMenuActionCell: UITableViewCell, ValueCell {

  @IBOutlet private weak var creatorAvatarImageView: UIImageView!
  @IBOutlet private weak var rightActionActivityIndicatorView: UIActivityIndicatorView!
  @IBOutlet private weak var rightActionButton: UIButton!
  @IBOutlet private weak var rootStackView: UIStackView!
  @IBOutlet private weak var titleLabel: UILabel!


  let viewModel: LiveStreamContainerMoreMenuActionCellViewModelType =
    LiveStreamContainerMoreMenuActionCellViewModel()

  internal func configureWith(value moreMenuItem: LiveStreamContainerMoreMenuItem) {
    self.viewModel.inputs.configureWith(moreMenuItem: moreMenuItem)

    self.selectedBackgroundView = self.selectionView
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> UITableViewCell.lens.backgroundColor .~ .hex(0x1B1B1C)

    self.separatorInset = UIEdgeInsets(leftRight: 0)

    _ = self.rootStackView
      |> UIStackView.lens.alignment .~ .center
      |> UIStackView.lens.spacing .~ Styles.grid(2)
      |> UIStackView.lens.layoutMargins .~ UIEdgeInsets(leftRight: Styles.grid(3))
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true

    _ = self.creatorAvatarImageView
      |> UIImageView.lens.layer.masksToBounds .~ true
      |> UIImageView.lens.contentMode .~ .scaleAspectFit

    _ = self.titleLabel
      |> UILabel.lens.textColor .~ .white
      |> UILabel.lens.font .~ .ksr_body(size: 13)

    _ = self.rightActionButton
      |> lightSubscribeButtonStyle

    _ = self.rightActionActivityIndicatorView
      |> UIActivityIndicatorView.lens.tintColor .~ .white
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.rightActionActivityIndicatorView.rac.hidden =
      self.viewModel.outputs.rightActionActivityIndicatorViewHidden
    self.creatorAvatarImageView.rac.imageUrl = self.viewModel.outputs.creatorAvatarUrl

    self.titleLabel.rac.text = self.viewModel.outputs.titleLabelText
    self.rightActionButton.rac.hidden = self.viewModel.outputs.rightActionButtonHidden
  }

  internal override func layoutSubviews() {
    super.layoutSubviews()

    self.creatorAvatarImageView.layer.cornerRadius = self.creatorAvatarImageView.frame.size.width / 2
    self.rightActionButton.layer.cornerRadius = self.rightActionButton.frame.size.height / 2
  }

  private lazy var selectionView: UIView = {
    let view = UIView()
    view.backgroundColor = .hex(0x353535)
    return view
  }()
}
