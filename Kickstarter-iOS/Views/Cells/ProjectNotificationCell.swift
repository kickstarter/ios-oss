import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal protocol ProjectNotificationCellDelegate: class {
  /// Call with an error message when saving a notification fails.
  func projectNotificationCell(_ cell: ProjectNotificationCell?, notificationSaveError: String)
}

internal final class ProjectNotificationCell: UITableViewCell, ValueCell {
  fileprivate let viewModel = ProjectNotificationCellViewModel()
  internal weak var delegate: ProjectNotificationCellDelegate?

  @IBOutlet fileprivate weak var nameLabel: UILabel!
  @IBOutlet fileprivate weak var notificationSwitch: UISwitch!
  @IBOutlet fileprivate weak var separatorView: UIView!

 internal override func awakeFromNib() {
    super.awakeFromNib()

    self.notificationSwitch.addTarget(
      self,
      action: #selector(notificationTapped),
      for: UIControlEvents.valueChanged
    )
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()

    _ = self.nameLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.numberOfLines .~ 1
      |> UILabel.lens.lineBreakMode .~ .byClipping

    _ = self.notificationSwitch |> settingsSwitchStyle
    _ = self.separatorView |> separatorStyle
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.nameLabel.rac.text = self.viewModel.outputs.name
    self.notificationSwitch.rac.on = self.viewModel.outputs.notificationOn

    self.viewModel.outputs.notifyDelegateOfSaveError
      .observeForUI()
      .observeValues { [weak self] message in
        self?.delegate?.projectNotificationCell(self, notificationSaveError: message)
    }
  }

  internal func configureWith(value: ProjectNotification) {
    self.viewModel.inputs.configureWith(notification: value)
  }

  @objc fileprivate func notificationTapped(_ notificationSwitch: UISwitch) {
    self.viewModel.inputs.notificationTapped(on: self.notificationSwitch.isOn)
  }
}
