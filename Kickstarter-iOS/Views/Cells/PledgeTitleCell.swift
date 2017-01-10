import KsApi
import Library
import Prelude
import UIKit

internal final class PledgeTitleCell: UITableViewCell, ValueCell {

  @IBOutlet fileprivate weak var pledgeTitleLabel: UILabel!
  @IBOutlet fileprivate weak var separatorView: UIView!

  func configureWith(value project: Project) {
    self.contentView.backgroundColor = Library.backgroundColor(forCategoryId: project.category.rootId)
    self.pledgeTitleLabel.textColor = discoveryPrimaryColor(forCategoryId: project.category.rootId)
    self.separatorView.backgroundColor = strokeColor(forCategoryId: project.category.rootId)

    switch (project.personalization.isBacking, project.state) {
    case (true?, .live):
      self.pledgeTitleLabel.font = .ksr_headline(size: 16)
      self.pledgeTitleLabel.text = Strings.Manage_your_pledge()
    case (_, .live):
      self.pledgeTitleLabel.font = .ksr_headline(size: 17)
      self.pledgeTitleLabel.text = Strings.Back_this_project_below()
    default:
      self.pledgeTitleLabel.font = .ksr_headline(size: 16)
      self.pledgeTitleLabel.text = Strings.You_backed_this_project()
    }
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> (UITableViewCell.lens.contentView • UIView.lens.layoutMargins) %~~ { margins, cell in
        .init(top: Styles.grid(3),
              left: cell.traitCollection.isRegularRegular ? Styles.grid(20) : margins.left * 2,
              bottom: Styles.grid(2),
              right: cell.traitCollection.isRegularRegular ? Styles.grid(20) : margins.right * 2)
      }

    _ = self.pledgeTitleLabel
      |> UILabel.lens.numberOfLines .~ 0

  }
}
