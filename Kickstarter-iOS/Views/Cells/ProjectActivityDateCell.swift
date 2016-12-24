import Library
import KsApi
import Prelude
import Prelude_UIKit
import UIKit

internal final class ProjectActivityDateCell: UITableViewCell, ValueCell {
  @IBOutlet fileprivate weak var dateLabel: UILabel!

  internal func configureWith(value date: Date) {
    self.dateLabel.text = Format.date(
      secondsInUTC: date.timeIntervalSince1970,
      dateStyle: .long,
      timeStyle: .none
    )
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> ProjectActivityDateCell.lens.contentView.layoutMargins %~~ { layoutMargins, cell in
        cell.traitCollection.isRegularRegular
          ? .init(top: Styles.grid(4),
                  left: projectActivityRegularRegularLeftRight,
                  bottom: 0,
                  right: projectActivityRegularRegularLeftRight)
          : .init(top: Styles.grid(4), left: Styles.grid(2), bottom: Styles.grid(1), right: Styles.grid(2))
      }

    _ = self.dateLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 13)
      |> UILabel.lens.textColor .~ .ksr_text_navy_600
  }
}
