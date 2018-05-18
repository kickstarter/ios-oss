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
      self.messageLabel.text = Strings.Pledge_to_your_favorites_then_view_all_the_projects()
      self.titleLabel.text = Strings.Explore_creative_projects()
      _ = self.iconImageView
        |> UIImageView.lens.image .~ UIImage(named: "icon--eye")
    case .saved:
      self.messageLabel.text = Strings.Tap_the_heart_on_a_project_to_get_notified()
      self.titleLabel.text = Strings.No_saved_projects()
      _ = self.iconImageView
        |> UIImageView.lens.image .~ UIImage(named: "icon--heart-outline")
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
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_400
      |> UILabel.lens.font .~ UIFont.ksr_body(size: 15.0)

    _ = self.titleLabel
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_900
      |> UILabel.lens.font .~ UIFont.ksr_headline(size: 21.0)
    
    _ = self.iconImageView
    |> UIImageView.lens.tintColor .~ .ksr_text_dark_grey_900
  }
}
