import Library
import LiveStream
import Prelude

internal final class LiveStreamContainerMoreMenuCancelCell: UITableViewCell, ValueCell {

  @IBOutlet private weak var titleLabel: UILabel!

  internal override func awakeFromNib() {
    super.awakeFromNib()
    self.selectedBackgroundView = UIView()
    self.titleLabel.text = Strings.general_navigation_buttons_cancel()
  }

  internal func configureWith(value moreMenuItem: LiveStreamContainerMoreMenuItem) {
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> UITableViewCell.lens.backgroundColor .~ .hex(0x1B1B1C)

    _ = self.selectedBackgroundView
      ?|> UIView.lens.backgroundColor .~ .ksr_navy_700

    self.separatorInset = UIEdgeInsets(leftRight: self.frame.size.width)

    _ = self.titleLabel
      |> UILabel.lens.textAlignment .~ .center
      |> UILabel.lens.textColor .~ .white
      |> UILabel.lens.font .~ .ksr_body(size: 13)
  }
}
