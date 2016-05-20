import Library
import Models
import UIKit

internal final class ActivityLaunchCell: UITableViewCell, ValueCell {
  @IBOutlet private weak var projectImageView: UIImageView!
  @IBOutlet private weak var messageLabel: UILabel!

  internal func configureWith(value activity: Activity) {
    self.messageLabel.text = localizedString(
      key: "activity.project_state_change.creator_launched_a_project",
      defaultValue: "%{creator_name} launched a project: %{project_name}",
      substitutions: [
        "creator_name": activity.project?.creator.name ?? "",
        "project_name": activity.project?.name ?? ""
      ]
    )

    self.projectImageView.image = nil
    self.projectImageView.af_cancelImageRequest()
    if let url = (activity.project?.photo.med).flatMap(NSURL.init(string:)) {
      self.projectImageView.af_setImageWithURL(url)
    }
  }
}
