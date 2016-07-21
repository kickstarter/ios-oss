import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal protocol DashboardActionCellDelegate: class {
  /// Call with project value when navigating to activity screen.
  func goToActivity(cell: DashboardActionCell?, project: Project)

  /// Call with project value when navigating to messages screen.
  func goToMessages(cell: DashboardActionCell?, project: Project)

  /// Call with project value when navigating to post update screen.
  func goToPostUpdate(cell: DashboardActionCell?, project: Project)
}

internal final class DashboardActionCell: UITableViewCell, ValueCell {
  internal weak var delegate: DashboardActionCellDelegate?
  private let viewModel: DashboardActionCellViewModelType = DashboardActionCellViewModel()

  @IBOutlet private weak var activityButton: UIButton!
  @IBOutlet private var drillDownIndicatorImageViews: [UIImageView]!
  @IBOutlet private weak var lastUpdatePublishedAtLabel: UILabel!
  @IBOutlet private weak var messagesButton: UIButton!
  @IBOutlet private weak var messagesRowStackView: UIStackView!
  @IBOutlet private weak var postUpdateButton: UIButton!
  @IBOutlet private weak var separatorView: UIView!
  @IBOutlet private weak var unseenActivitiesCountView: CountBadgeView!
  @IBOutlet private weak var unreadMessagesCountView: CountBadgeView!

  internal override func awakeFromNib() {
    super.awakeFromNib()

    self.activityButton.addTarget(self, action: #selector(activityTapped), forControlEvents: .TouchUpInside)

    self.messagesButton.addTarget(self, action: #selector(messagesTapped), forControlEvents: .TouchUpInside)

    self.postUpdateButton.addTarget(self,
                                    action: #selector(postUpdateTapped),
                                    forControlEvents: .TouchUpInside)
  }

  internal override func bindStyles() {
    self |> baseTableViewCellStyle()
    self.isAccessibilityElement = false
    self.accessibilityElements = [self.activityButton, self.messagesButton, self.postUpdateButton]
    self.activityButton |> dashboardActivityButtonStyle
    self.activityButton.accessibilityHint = "Opens activity."
    self.lastUpdatePublishedAtLabel |> dashboardLastUpdatePublishedAtLabelStyle
    self.messagesButton |> dashboardMessagesButtonStyle
    self.messagesButton.accessibilityHint = "Opens messages."
    self.postUpdateButton |> postUpdateButtonStyle
    self.postUpdateButton.accessibilityHint = "Opens editor."
    self.separatorView |> separatorStyle
  }

  internal override func bindViewModel() {
    self.activityButton.rac.accessibilityLabel = self.viewModel.outputs.activityButtonAccessibilityLabel
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
      .observeNext { [weak self] project in
        self?.delegate?.goToActivity(self, project: project)
    }

    self.viewModel.outputs.goToMessages
      .observeForUI()
      .observeNext { [weak self] project in
        self?.delegate?.goToMessages(self, project: project)
    }

    self.viewModel.outputs.goToPostUpdate
      .observeForUI()
      .observeNext { [weak self] project in
        self?.delegate?.goToPostUpdate(self, project: project)
    }
  }

  internal func configureWith(value value: Project) {
    self.viewModel.inputs.configureWith(project: value)
  }

  @objc private func activityTapped() {
    self.viewModel.inputs.activityTapped()
  }

  @objc private func messagesTapped() {
    self.viewModel.inputs.messagesTapped()
  }

  @objc private func postUpdateTapped() {
    self.viewModel.inputs.postUpdateTapped()
  }
}
