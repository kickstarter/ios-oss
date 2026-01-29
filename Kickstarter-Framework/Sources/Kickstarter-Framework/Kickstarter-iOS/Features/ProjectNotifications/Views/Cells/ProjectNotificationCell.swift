import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal protocol ProjectNotificationCellDelegate: AnyObject {
  /// Call with an error message when saving a notification fails.
  func projectNotificationCell(_ cell: ProjectNotificationCell?, notificationSaveError: String)
}

internal final class ProjectNotificationCell: UITableViewCell, ValueCell {
  fileprivate let viewModel = ProjectNotificationCellViewModel()
  internal weak var delegate: ProjectNotificationCellDelegate?

  @IBOutlet fileprivate var nameLabel: UILabel!
  @IBOutlet fileprivate var notificationSwitch: UISwitch!

  internal override func awakeFromNib() {
    super.awakeFromNib()

    _ = self
      |> \.accessibilityElements .~ [self.notificationSwitch].compact()

    self.notificationSwitch.addTarget(self, action: #selector(self.notificationTapped), for: .valueChanged)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()

    _ = self.nameLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.numberOfLines .~ 1
      |> UILabel.lens.lineBreakMode .~ .byTruncatingTail

    _ = self.notificationSwitch |> settingsSwitchStyle
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.nameLabel.rac.text = self.viewModel.outputs.name
    self.notificationSwitch.rac.accessibilityLabel = self.viewModel.outputs.name
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

  @objc fileprivate func notificationTapped(_: UISwitch) {
    self.viewModel.inputs.notificationTapped(on: self.notificationSwitch.isOn)
  }
}
