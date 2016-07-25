import Library
import KsApi
import Prelude
import Prelude_UIKit
import UIKit

internal final class ProjectActivityDateCell: UITableViewCell, ValueCell {
  @IBOutlet private weak var dateLabel: UILabel!

  internal func configureWith(value date: NSDate) {
    self.dateLabel.text = Format.date(
      secondsInUTC: date.timeIntervalSince1970,
      dateStyle: .LongStyle,
      timeStyle: .NoStyle
    )
  }

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableViewCellStyle()
      |> (UITableViewCell.lens.contentView • UIView.lens.layoutMargins)
        .~ .init(top: 24, left: 16, bottom: 4, right: 16)

    self.dateLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 13)
      |> UILabel.lens.textColor .~ .ksr_text_navy_600
  }
}
