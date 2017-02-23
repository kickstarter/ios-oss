import Library
import LiveStream
import Prelude

internal final class LiveStreamContainerMoreMenuCell: UITableViewCell, ValueCell {


  @IBOutlet private weak var contentStackView: UIStackView!
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

    _ = self.rootStackView
      |> UIStackView.lens.alignment .~ .center
      |> UIStackView.lens.spacing .~ Styles.grid(2)
      |> UIStackView.lens.layoutMargins .~ UIEdgeInsets(leftRight: Styles.grid(2))
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true

    _ = self.contentStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)

    _ = self.iconImageView
      |> UIImageView.lens.tintColor .~ .white

    _ = self.titleLabel
      |> UILabel.lens.textColor .~ .white
      |> UILabel.lens.font .~ .ksr_subhead(size: 13)

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

    
  }
}
