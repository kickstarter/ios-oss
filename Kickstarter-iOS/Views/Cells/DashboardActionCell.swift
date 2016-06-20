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

  /// Call with project value when should show share sheet.
  func showShareSheet(cell: DashboardActionCell?, project: Project)
}

internal final class DashboardActionCell: UITableViewCell, ValueCell {
  internal weak var delegate: DashboardActionCellDelegate?
  private let viewModel: DashboardActionCellViewModelType = DashboardActionCellViewModel()

  @IBOutlet internal weak var activityButton: UIButton!
  @IBOutlet private var drillDownIndicatorImageViews: [UIImageView]!
  @IBOutlet internal weak var lastUpdatePublishedAtLabel: UILabel!
  @IBOutlet internal weak var messagesButton: UIButton!
  @IBOutlet internal weak var postUpdateButton: UIButton!
  @IBOutlet internal weak var shareButton: UIButton!
  @IBOutlet private weak var unseenActivitiesCountView: CountBadgeView!
  @IBOutlet private weak var unreadMessagesCountView: CountBadgeView!

  internal override func awakeFromNib() {
    super.awakeFromNib()

    self.activityButton.addTarget(self, action: #selector(activityTapped), forControlEvents: .TouchUpInside)

    self.messagesButton.addTarget(self, action: #selector(messagesTapped), forControlEvents: .TouchUpInside)

    self.postUpdateButton.addTarget(self,
                                    action: #selector(postUpdateTapped),
                                    forControlEvents: .TouchUpInside)

    self.shareButton.addTarget(self, action: #selector(shareTapped), forControlEvents: .TouchUpInside)
  }

  internal override func bindStyles() {
    self |> baseTableViewCellStyle()
    self.activityButton |> dashboardActivityButtonStyle
    self.lastUpdatePublishedAtLabel |> lastUpdatePublishedAtLabelStyle
    self.messagesButton |> dashboardMessagesButtonStyle
    self.postUpdateButton |> postUpdateButtonStyle
    self.shareButton |> dashboardShareButtonStyle
    self.drillDownIndicatorImageViews.forEach { $0 |> UIImageView.lens.tintColor .~ .ksr_black }
  }

  internal override func bindViewModel() {
    self.lastUpdatePublishedAtLabel.rac.text = self.viewModel.outputs.lastUpdatePublishedAt
    self.unreadMessagesCountView.label.rac.text = self.viewModel.outputs.unreadMessagesCount
    self.unreadMessagesCountView.rac.hidden = self.viewModel.outputs.unreadMessagesCountHidden
    self.unseenActivitiesCountView.label.rac.text = self.viewModel.outputs.unseenActivitiesCount
    self.unseenActivitiesCountView.rac.hidden = self.viewModel.outputs.unseenActivitiesCountHidden

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

    self.viewModel.outputs.showShareSheet
      .observeForUI()
      .observeNext { [weak self] project in
        self?.delegate?.showShareSheet(self, project: project)
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

  @objc private func shareTapped() {
    self.viewModel.inputs.shareTapped()
  }
}
