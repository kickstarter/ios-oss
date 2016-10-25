import KsApi
import Library
import Prelude
import UIKit

internal final class ActivityLaunchCell: UITableViewCell, ValueCell {
  @IBOutlet private weak var projectImageView: UIImageView!
  @IBOutlet private weak var messageLabel: UILabel!

  internal func configureWith(value activity: Activity) {
    self.messageLabel.text = Strings.activity_project_state_change_creator_launched_a_project(
      creator_name: activity.project?.creator.name ?? "",
      project_name: activity.project?.name ?? ""
    )

    self.projectImageView.image = nil
    self.projectImageView.af_cancelImageRequest()
    if let url = (activity.project?.photo.med).flatMap(NSURL.init(string:)) {
      self.projectImageView.af_setImageWithURL(url)
    }
  }

  override func bindStyles() {
    super.bindStyles()

    self
      |> UITableViewCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(12), leftRight: Styles.grid(20))
          : .init(topBottom: Styles.grid(10), leftRight: Styles.grid(4))
    }
  }
}
