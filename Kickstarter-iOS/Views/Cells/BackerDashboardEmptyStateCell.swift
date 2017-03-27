import KsApi
import Library
import Prelude
import UIKit

internal final class BackerDashboardEmptyStateCell: UITableViewCell, ValueCell {

  @IBOutlet private weak var iconImageView: UIImageView!
  @IBOutlet private weak var messageLabel: UILabel!
  @IBOutlet private weak var titleLabel: UILabel!

  internal func configureWith(value: ProfileProjectsType) {
    switch value {
    case .backed:
      self.iconImageView.tintColor = .clear
      self.messageLabel.text = localizedString(
        key: "Pledge_to_your_favorites_then_view_all_the_projects",
        defaultValue: "Pledge to your favorites, then view all the projects you’ve backed here."
      )
      self.titleLabel.text = localizedString(key: "Explore_creative_projects",
                                             defaultValue: "Explore creative projects")
    case .saved:
      self.messageLabel.text = localizedString(
        key: "Tap_the_star_on_a_project_to_get_notified",
        defaultValue: "Tap the star icon on a project to get notified 48 hours before it ends."
      )
      self.titleLabel.text = localizedString(key: "Save_projects",
                                               defaultValue: "Save projects")
      self.iconImageView.tintColor = .black
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

    _ = self.titleLabel
      |> UILabel.lens.textColor .~ .black
      |> UILabel.lens.font .~ UIFont.ksr_headline(size: 17.0)
  }
}
