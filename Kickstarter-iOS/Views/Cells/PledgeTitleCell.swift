import KsApi
import Library
import Prelude
import UIKit

internal final class PledgeTitleCell: UITableViewCell, ValueCell {

  @IBOutlet fileprivate weak var pledgeTitleLabel: UILabel!
  @IBOutlet fileprivate weak var separatorView: UIView!

  func configureWith(value project: Project) {
    self.pledgeTitleLabel.textColor = discoveryPrimaryColor()
    self.separatorView.backgroundColor = .ksr_grey_200
    let date = Format.date(secondsInUTC: project.dates.deadline,
                           template: "MMM d, yyyy, h:mm a",
                           timeZone: .current)
    let amount = Format.currency(project.stats.goal, country: project.country)

    switch (project.personalization.isBacking, project.state) {
    case (true?, .live):
      self.pledgeTitleLabel.font = .ksr_headline(size: 16)
      self.pledgeTitleLabel.text = Strings.Manage_your_pledge()
    case (_, .live):
      self.pledgeTitleLabel.font = .ksr_body(size: 12)
      self.pledgeTitleLabel.text =
        Strings.This_project_will_only_be_funded_on_if_at_least_amount_is_pledged_by_date(amount: amount,
                                                                                          date: date)
      self.pledgeTitleLabel.textColor = .ksr_text_dark_grey_500
    default:
      self.pledgeTitleLabel.font = .ksr_headline(size: 16)
      self.pledgeTitleLabel.text = Strings.You_backed_this_project()
    }
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> (UITableViewCell.lens.contentView..UIView.lens.layoutMargins) %~~ { margins, cell in
        .init(top: Styles.grid(3),
              left: cell.traitCollection.isRegularRegular ? Styles.grid(20) : margins.left * 2,
              bottom: Styles.grid(2),
              right: cell.traitCollection.isRegularRegular ? Styles.grid(20) : margins.right * 2)
      }
      |> UITableViewCell.lens.contentView..UIView.lens.backgroundColor .~ projectCellBackgroundColor()

    _ = self.pledgeTitleLabel
      |> UILabel.lens.numberOfLines .~ 0
  }
}
