import Foundation
import Library
import KsApi
import UIKit
import Prelude

internal final class ActivityNegativeStateChangeCell: UITableViewCell, ValueCell {
  @IBOutlet private weak var messageLabel: UILabel!
  @IBOutlet private weak var projectImageView: UIImageView!

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

  override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.backgroundColor .~ .whiteColor()
      |> UITableViewCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(3), leftRight: Styles.grid(20))
          : .init(topBottom: Styles.grid(3), leftRight: Styles.grid(4))
    }

    self.messageLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_700
  }
}
