import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal protocol ProjectNotificationCellDelegate: class {
  /// Call with an error message when saving a notification fails.
  func projectNotificationCell(cell: ProjectNotificationCell?, notificationSaveError: String)
}

internal final class ProjectNotificationCell: UITableViewCell, ValueCell {
  private let viewModel = ProjectNotificationCellViewModel()
  internal weak var delegate: ProjectNotificationCellDelegate?

  @IBOutlet private weak var nameLabel: UILabel!
  private let notificationSwitch: UISwitch = UISwitch()
  @IBOutlet private weak var separatorView: UIView!

 internal override func awakeFromNib() {
    super.awakeFromNib()

    self.notificationSwitch.addTarget(
      self,
      action: #selector(notificationTapped),
      forControlEvents: UIControlEvents.ValueChanged
    )
    self.accessoryView = self.notificationSwitch
  }

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableViewCellStyle()

    self.nameLabel |> settingsSectionLabelStyle
    self.separatorView |> separatorStyle
  }

  internal override func bindViewModel() {
    super.bindViewModel()

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

  @objc private func notificationTapped(notificationSwitch: UISwitch) {
    self.viewModel.inputs.notificationTapped(on: self.notificationSwitch.on)
  }
}
