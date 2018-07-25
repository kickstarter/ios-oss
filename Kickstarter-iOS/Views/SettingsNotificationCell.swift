import Foundation
import Prelude
import Library
import KsApi

protocol SettingsNotificationCellDelegate: class {
  func didFailToSaveChange(errorMessage: String)
  func didUpdateUser(user: User)
}

final class SettingsNotificationCell: UITableViewCell, NibLoading, ValueCell {
  @IBOutlet fileprivate weak var titleLabel: UILabel!
  @IBOutlet fileprivate weak var emailNotificationsButton: UIButton!
  @IBOutlet fileprivate weak var pushNotificationsButton: UIButton!
  @IBOutlet fileprivate weak var separatorView: UIView!
  @IBOutlet fileprivate weak var arrowImageView: UIImageView!
  @IBOutlet fileprivate weak var projectCountLabel: UILabel!

  weak var delegate: SettingsNotificationCellDelegate?

  private let viewModel: SettingsNotificationCellViewModelType = SettingsNotificationCellViewModel()
  private lazy var tapGesture: UITapGestureRecognizer = {
    return UITapGestureRecognizer(target: self, action: #selector(cellBackgroundTapped))
  }()

  private var notificationType: SettingsNotificationCellType?

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  func configureWith(value cellValue: SettingsNotificationCellValue) {
    self.notificationType = cellValue.cellType

    viewModel.inputs.configure(with: cellValue)

    _ = titleLabel
      |> UILabel.lens.text .~ cellValue.cellType.title

    _ = arrowImageView
      |> UIImageView.lens.isHidden .~ cellValue.cellType.shouldHideArrowView

    _ = projectCountLabel
      |> UILabel.lens.isHidden .~ cellValue.cellType.projectCountLabelHidden
  }

  override func bindStyles() {
    super.bindStyles()

    _ = titleLabel
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_500
      |> UILabel.lens.font .~ .ksr_body()

    _ = projectCountLabel
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_400
      |> UILabel.lens.font .~ .ksr_body()

    _ = self.emailNotificationsButton |> notificationButtonStyle
      |> UIButton.lens.image(for: .normal) .~ Library.image(named: "email-icon",
                                                              tintColor: .ksr_grey_400,
                                                              inBundle: Bundle.framework)
      |> UIButton.lens.image(for: .highlighted) .~ Library.image(named: "email-icon",
                                                            tintColor: .ksr_green_700,
                                                            inBundle: Bundle.framework)
      |> UIButton.lens.image(for: .selected) .~ Library.image(named: "email-icon",
                                                      tintColor: .ksr_green_700,
                                                      inBundle: Bundle.framework)
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.Email_notifications() }

    _ = self.pushNotificationsButton
      |> notificationButtonStyle
      |> UIButton.lens.image(for: .normal) .~ Library.image(named: "mobile-icon",
                                                              tintColor: .ksr_grey_400,
                                                              inBundle: Bundle.framework)
      |> UIButton.lens.image(for: .highlighted) .~ Library.image(named: "mobile-icon",
                                                              tintColor: .ksr_green_700,
                                                              inBundle: Bundle.framework)
      |> UIButton.lens.image(for: .selected) .~ Library.image(named: "mobile-icon",
                                                      tintColor: .ksr_green_700,
                                                      inBundle: Bundle.framework)
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.Push_notifications() }

    _ = self.separatorView |> separatorStyle
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.emailNotificationsButton.rac.selected = viewModel.outputs.emailNotificationsEnabled
    self.emailNotificationsButton.rac.hidden = viewModel.outputs.hideNotificationButtons
    self.projectCountLabel.rac.text = viewModel.outputs.projectCountText
    self.pushNotificationsButton.rac.selected = viewModel.outputs.pushNotificationsEnabled
    self.pushNotificationsButton.rac.hidden = viewModel.outputs.hideNotificationButtons

    viewModel.outputs.hideNotificationButtons
    .observeForUI()
    .observeValues { [weak self] shouldHide in
      guard let _self = self else { return }
        if shouldHide {
          _self.removeGestureRecognizer(_self.tapGesture)
        } else {
          _self.addGestureRecognizer(_self.tapGesture)
        }
    }
  }

  @IBAction func emailNotificationsButtonTapped(_ sender: UIButton) {
    self.viewModel.inputs.didTapEmailNotificationsButton()
  }

  @IBAction func pushNotificationsButtonTapped(_ sender: UIButton) {
    self.viewModel.inputs.didTapPushNotificationsButton()
  }

  @IBAction func cellBackgroundTapped(_ sender: Any) {
    let sizeTransform = CGAffineTransform(scaleX: 1.2, y: 1.2)

    UIView.animate(withDuration: 0.15, animations: {
      self.pushNotificationsButton.transform = sizeTransform
    }, completion: { (_) in
      self.identityAnimation(for: self.pushNotificationsButton)
    })

    UIView.animate(withDuration: 0.15, delay: 0.1, options: .curveEaseInOut, animations: {
      self.emailNotificationsButton.transform = sizeTransform
    }, completion: { (_) in
      self.identityAnimation(for: self.emailNotificationsButton)
    })
  }

  func identityAnimation(for button: UIButton) {
    UIView.animate(withDuration: 0.18, animations: {
      button.transform = .identity
    }, completion: nil)
  }
}
