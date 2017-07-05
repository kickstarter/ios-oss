import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal protocol DashboardActionCellDelegate: class {
  /// Call with project value when navigating to activity screen.
  func goToActivity(_ cell: DashboardActionCell?, project: Project)

  /// Call with project value when navigating to messages screen.
  func goToMessages(_ cell: DashboardActionCell?)

  /// Call with project value when navigating to post update screen.
  func goToPostUpdate(_ cell: DashboardActionCell?, project: Project)
}

internal final class DashboardActionCell: UITableViewCell, ValueCell {
  internal weak var delegate: DashboardActionCellDelegate?
  fileprivate let viewModel: DashboardActionCellViewModelType = DashboardActionCellViewModel()

  @IBOutlet fileprivate weak var activityButton: UIButton!
  @IBOutlet fileprivate weak var activityRowStackView: UIStackView!
  @IBOutlet fileprivate weak var lastUpdatePublishedAtLabel: UILabel!
  @IBOutlet fileprivate weak var messagesButton: UIButton!
  @IBOutlet fileprivate weak var messagesRowStackView: UIStackView!
  @IBOutlet fileprivate weak var postUpdateButton: UIButton!
  @IBOutlet fileprivate weak var separatorView: UIView!
  @IBOutlet fileprivate weak var unseenActivitiesCountView: CountBadgeView!
  @IBOutlet fileprivate weak var unreadMessagesCountView: CountBadgeView!

  internal override func awakeFromNib() {
    super.awakeFromNib()

    self.activityButton.addTarget(self, action: #selector(activityTapped), for: .touchUpInside)

    self.messagesButton.addTarget(self, action: #selector(messagesTapped), for: .touchUpInside)

    self.postUpdateButton.addTarget(self,
                                    action: #selector(postUpdateTapped),
                                    for: .touchUpInside)
  }

  internal override func bindStyles() {
    _ = self |> baseTableViewCellStyle()
    self.isAccessibilityElement = false
    self.accessibilityElements = [self.activityButton, self.messagesButton, self.postUpdateButton]
    _ = self.activityButton |> dashboardActivityButtonStyle
    _ = self.lastUpdatePublishedAtLabel |> dashboardLastUpdatePublishedAtLabelStyle
    _ = self.messagesButton |> dashboardMessagesButtonStyle
    _ = self.postUpdateButton |> postUpdateButtonStyle
    _ = self.separatorView |> separatorStyle
  }

  internal override func bindViewModel() {
    self.activityButton.rac.accessibilityLabel = self.viewModel.outputs.activityButtonAccessibilityLabel
    self.activityRowStackView.rac.hidden = self.viewModel.outputs.activityRowHidden
    self.lastUpdatePublishedAtLabel.rac.text = self.viewModel.outputs.lastUpdatePublishedAt
    self.messagesButton.rac.accessibilityLabel = self.viewModel.outputs.messagesButtonAccessibilityLabel
    self.messagesRowStackView.rac.hidden = self.viewModel.outputs.messagesRowHidden
    self.unreadMessagesCountView.label.rac.text = self.viewModel.outputs.unreadMessagesCount
    self.unreadMessagesCountView.rac.hidden = self.viewModel.outputs.unreadMessagesCountHidden
    self.unseenActivitiesCountView.label.rac.text = self.viewModel.outputs.unseenActivitiesCount
    self.unseenActivitiesCountView.rac.hidden = self.viewModel.outputs.unseenActivitiesCountHidden
    self.lastUpdatePublishedAtLabel.rac.hidden = self.viewModel.outputs.lastUpdatePublishedLabelHidden
    self.postUpdateButton.rac.accessibilityValue = self.viewModel.outputs.postUpdateButtonAccessibilityValue
    self.postUpdateButton.rac.hidden = self.viewModel.outputs.postUpdateButtonHidden

    self.viewModel.outputs.goToActivity
      .observeForUI()
      .observeValues { [weak self] project in
        self?.delegate?.goToActivity(self, project: project)
    }

    self.viewModel.outputs.goToMessages
      .observeForUI()
      .observeValues { [weak self] in
        self?.delegate?.goToMessages(self)
    }

    self.viewModel.outputs.goToPostUpdate
      .observeForUI()
      .observeValues { [weak self] project in
        self?.delegate?.goToPostUpdate(self, project: project)
    }
  }

  internal func configureWith(value: Project) {
    self.viewModel.inputs.configureWith(project: value)
  }

  @objc fileprivate func activityTapped() {
    self.viewModel.inputs.activityTapped()
  }

  @objc fileprivate func messagesTapped() {
    self.viewModel.inputs.messagesTapped()
  }

  @objc fileprivate func postUpdateTapped() {
    self.viewModel.inputs.postUpdateTapped()
  }
}
