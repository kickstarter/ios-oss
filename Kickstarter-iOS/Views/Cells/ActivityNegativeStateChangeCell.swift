import Foundation
import Library
import KsApi
import UIKit
import Prelude

internal final class ActivityNegativeStateChangeCell: UITableViewCell, ValueCell {
  @IBOutlet private weak var messageLabel: UILabel!
  @IBOutlet private weak var projectImageView: UIImageView!

  override func awakeFromNib() {
    super.awakeFromNib()
    self.backgroundColor = .ksr_gray
  }

  func configureWith(value activity: Activity) {
    switch activity.category {
    case .failure:
      self.messageLabel.text = Strings.activity_project_state_change_project_was_not_successfully_funded(
        project_name: activity.project?.name ?? ""
        )
    case .cancellation:
      self.messageLabel.text = Strings.activity_project_state_change_project_was_cancelled_by_creator(
        project_name: activity.project?.name ?? ""
        )
    case .suspension:
      self.messageLabel.text = Strings.activity_project_state_change_project_was_suspended(
        project_name: activity.project?.name ?? ""
        )
    default:
      assertionFailure("Unrecognized activity: \(activity).")
    }

    self.projectImageView.image = nil
    self.projectImageView.af_cancelImageRequest()
    if let url = (activity.project?.photo.med).flatMap(NSURL.init(string:)) {
      self.projectImageView.af_setImageWithURL(url)
    }
  }
}
