import KsApi
import Library
import Prelude
import UIKit

internal final class BackerDashboardEmptyStateCell: UITableViewCell, ValueCell {

  @IBOutlet private weak var iconImageView: UIImageView!
  @IBOutlet private weak var messageLabel: UILabel!

  internal func configureWith(value: ProfileProjectsType) {
    switch value {
    case .backed:
      self.messageLabel.text = Strings.profile_projects_empty_state_message()
      self.iconImageView.tintColor = .clear
    case .saved:
      self.messageLabel.text = localizedString(key: "todo",
                                               defaultValue: "You haven't saved any projects yet.")
      self.iconImageView.tintColor = .ksr_text_navy_600
    }
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(4), leftRight: Styles.grid(20))
          : .init(topBottom: Styles.grid(10), leftRight: Styles.grid(3))
    }

    _ = self.messageLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_600
      |> UILabel.lens.font .~ UIFont.ksr_callout(size: 15.0)
  }
}
