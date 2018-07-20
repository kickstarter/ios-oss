import Foundation
import Prelude
import Library

enum SettingsNotificationType {
  case projectUpdates
  case messages
  // etc...
}

let notificationButtonStyle = UIButton.lens.backgroundColor .~ .ksr_grey_200
  <> UIButton.lens.layer.cornerRadius .~ 20
  <> UIButton.lens.layer.borderColor .~ UIColor.ksr_grey_300.cgColor
  <> UIButton.lens.layer.borderWidth .~ 1.0

protocol SettingsNotificationCellDelegate {
  func didTapEmailNotificationsButton(withType: SettingsNotificationType)
  func didTapPushNotificationsButton(withType: SettingsNotificationType)
}

final class SettingsNotificationCell: UITableViewCell, NibLoading, ValueCell {
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var emailNotificationsButton: UIButton!
  @IBOutlet weak var pushNotificationsButton: UIButton!

  weak var delegate: SettingsNotificationCellDelegate?

  private var notificationType: SettingsNotificationType?

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)


  }

  func configureWith(value cellType: Any) {

  }

  override func bindStyles() {
    super.bindStyles()

    // TODO refactor into style variable
    _ = titleLabel
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_500
      |> UILabel.lens.font .~ .ksr_body()

    _ = self.emailNotificationsButton |> notificationButtonStyle
    _ = self.pushNotificationsButton |> notificationButtonStyle
  }

  @IBAction func emailNotificationsButtonTapped(_ sender: Any) {
    guard let notificationType = self.notificationType else {
      return
    }

    self.delegate?.didTapEmailNotificationsButton(withType: notificationType)
  }

  @IBAction func pushNotificationsButtonTapped(_ sender: Any) {
    guard let notificationType = self.notificationType else {
      return
    }

    self.delegate?.didTapPushNotificationsButton(withType: notificationType)
  }

  @IBAction func cellBackgroundTapped(_ sender: Any) {
    // Animation
  }
}
