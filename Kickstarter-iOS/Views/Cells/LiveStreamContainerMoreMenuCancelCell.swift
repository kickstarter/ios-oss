import Library
import LiveStream
import Prelude

internal final class LiveStreamContainerMoreMenuCancelCell: UITableViewCell, ValueCell {

  @IBOutlet private weak var titleLabel: UILabel!

  internal func configureWith(value moreMenuItem: LiveStreamContainerMoreMenuItem) {
    self.titleLabel.text = localizedString(key: "Cancel", defaultValue: "Cancel")
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> UITableViewCell.lens.backgroundColor .~ .hex(0x1B1B1C)

    self.separatorInset = UIEdgeInsets(leftRight: self.frame.size.width)

    _ = self.titleLabel
      |> UILabel.lens.textAlignment .~ .center
      |> UILabel.lens.textColor .~ .white
      |> UILabel.lens.font .~ .ksr_body(size: 13)
  }
}
