import Library
import KsApi
import UIKit

internal protocol ProjectNotificationCellDelegate: class {
  /// Call with an error message when saving a notification fails.
  func projectNotificationCell(cell: ProjectNotificationCell?, notificationSaveError: String)
}

internal final class ProjectNotificationCell: UITableViewCell, ValueCell {
  private let viewModel = ProjectNotificationCellViewModel()
  internal weak var delegate: ProjectNotificationCellDelegate?

  @IBOutlet private weak var nameLabel: UILabel!
  @IBOutlet private weak var notificationSwitch: UISwitch!

  internal override func bindViewModel() {
    self.nameLabel.rac.text = self.viewModel.outputs.name
    self.notificationSwitch.rac.on = self.viewModel.outputs.notificationOn

    self.viewModel.outputs.notifyDelegateOfSaveError
      .observeForUI()
      .observeNext { [weak self] message in
        self?.delegate?.projectNotificationCell(self, notificationSaveError: message)
    }
  }

  internal func configureWith(value value: ProjectNotification) {
    self.viewModel.inputs.configureWith(notification: value)
  }

  @IBAction private func notificationTapped(notificationSwitch: UISwitch) {
    self.viewModel.inputs.notificationTapped(on: notificationSwitch.on)
  }
}
