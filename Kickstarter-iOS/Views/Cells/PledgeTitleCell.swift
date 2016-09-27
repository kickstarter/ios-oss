import KsApi
import Library
import Prelude
import UIKit

internal final class PledgeTitleCell: UITableViewCell, ValueCell {

  @IBOutlet private weak var pledgeTitleLabel: UILabel!
  @IBOutlet private weak var separatorView: UIView!

  func configureWith(value project: Project) {
    self.contentView.backgroundColor = Library.backgroundColor(forCategoryId: project.category.rootId)
    self.pledgeTitleLabel.textColor = discoveryPrimaryColor(forCategoryId: project.category.rootId)
    self.separatorView.backgroundColor = strokeColor(forCategoryId: project.category.rootId)

    if project.personalization.isBacking == true {
      self.pledgeTitleLabel.font = .ksr_headline(size: 16)
      self.pledgeTitleLabel.text = Strings.Manage_your_pledge_below_colon()
    } else {
      self.pledgeTitleLabel.font = .ksr_headline(size: 17)
      self.pledgeTitleLabel.text = Strings.Back_this_project_below_colon()
    }
  }

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableViewCellStyle()
      |> (UITableViewCell.lens.contentView • UIView.lens.layoutMargins) %~ { margins in
        .init(top: Styles.grid(3), left: margins.left * 2, bottom: Styles.grid(2), right: margins.right * 2)
    }

    self.pledgeTitleLabel
      |> UILabel.lens.numberOfLines .~ 0

  }
}
