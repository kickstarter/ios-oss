import Foundation
import Prelude
import Library
import KsApi

protocol SettingsNotificationCellDelegate: class {
  func settingsNotificationCell(_ cell: SettingsNotificationCell, didFailToUpdateUser errorMessage: String)
  func settingsNotificationCell(_ cell: SettingsNotificationCell, didUpdateUser user: User)
}

final class SettingsNotificationCell: UITableViewCell, NibLoading, ValueCell {
  @IBOutlet fileprivate weak var arrowImageView: UIImageView!
  @IBOutlet fileprivate weak var emailNotificationsButton: UIButton!
  @IBOutlet fileprivate weak var projectCountLabel: UILabel!
  @IBOutlet fileprivate weak var pushNotificationsButton: UIButton!
  @IBOutlet fileprivate weak var separatorView: UIView!
  @IBOutlet fileprivate weak var titleLabel: UILabel!

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

    _ = self
      |> \.accessibilityTraits .~ cellValue.cellType.accessibilityTraits

    _ = titleLabel
      |> UILabel.lens.text .~ cellValue.cellType.title

    _ = arrowImageView
      |> UIImageView.lens.isHidden .~ cellValue.cellType.shouldHideArrowView
      |> UIImageView.lens.tintColor .~ .ksr_dark_grey_400

    _ = projectCountLabel
      |> UILabel.lens.isHidden .~ cellValue.cellType.projectCountLabelHidden
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()

    _ = titleLabel
      |> settingsTitleLabelStyle

    _ = projectCountLabel
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_400
      |> UILabel.lens.font .~ .ksr_body()

    _ = self.emailNotificationsButton |> notificationButtonStyle
      |> UIButton.lens.image(for: .normal) .~ Library.image(named: "email-icon",
                                                              tintColor: .ksr_dark_grey_400,
                                                              inBundle: Bundle.framework)
      |> UIButton.lens.image(for: .highlighted) .~ Library.image(named: "email-icon",
                                                            tintColor: .ksr_grey_500,
                                                            inBundle: Bundle.framework)
      |> UIButton.lens.image(for: .selected) .~ Library.image(named: "email-icon",
                                                      tintColor: .ksr_green_700,
                                                      inBundle: Bundle.framework)
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.Email_notifications() }

    _ = self.pushNotificationsButton
      |> notificationButtonStyle
      |> UIButton.lens.image(for: .normal) .~ Library.image(named: "mobile-icon",
                                                              tintColor: .ksr_dark_grey_400,
                                                              inBundle: Bundle.framework)
      |> UIButton.lens.image(for: .highlighted) .~ Library.image(named: "mobile-icon",
                                                              tintColor: .ksr_grey_500,
                                                              inBundle: Bundle.framework)
      |> UIButton.lens.image(for: .selected) .~ Library.image(named: "mobile-icon",
                                                      tintColor: .ksr_green_700,
                                                      inBundle: Bundle.framework)
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.Push_notifications() }

    _ = self.separatorView
      |> separatorStyle
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.emailNotificationsButton.rac.selected = viewModel.outputs.emailNotificationsEnabled
    self.emailNotificationsButton.rac.hidden = viewModel.outputs.emailNotificationButtonIsHidden
    self.projectCountLabel.rac.text = viewModel.outputs.projectCountText
    self.pushNotificationsButton.rac.selected = viewModel.outputs.pushNotificationsEnabled
    self.pushNotificationsButton.rac.hidden = viewModel.outputs.pushNotificationButtonIsHidden

    viewModel.outputs.enableButtonAnimation
    .observeForUI()
    .observeValues { [weak self] enableAnimation in
      guard let _self = self else { return }
        if enableAnimation {
          _self.addGestureRecognizer(_self.tapGesture)
        } else {
          _self.removeGestureRecognizer(_self.tapGesture)
        }
    }

    viewModel.outputs.updateCurrentUser
      .observeForControllerAction()
      .observeValues { [weak self] (user) in
        guard let _self = self else { return }
        _self.delegate?.settingsNotificationCell(_self, didUpdateUser: user)
    }

    viewModel.outputs.unableToSaveError
      .observeForControllerAction()
      .observeValues { [weak self] (errorString) in
        guard let _self = self else { return }
        _self.delegate?.settingsNotificationCell(_self, didFailToUpdateUser: errorString)
    }
  }

  @IBAction func emailNotificationsButtonTapped(_ sender: UIButton) {
    self.viewModel.inputs.didTapEmailNotificationsButton(selected: sender.isSelected)
  }

  @IBAction func pushNotificationsButtonTapped(_ sender: UIButton) {
    self.viewModel.inputs.didTapPushNotificationsButton(selected: sender.isSelected)
  }

  @IBAction func cellBackgroundTapped(_ sender: Any) {
    let sizeTransform = CGAffineTransform(scaleX: 1.2, y: 1.2)
    let animationDuration: TimeInterval = 0.15

    UIView.animate(withDuration: animationDuration, animations: { [weak self] in
      self?.pushNotificationsButton.transform = sizeTransform
    }, completion: { [weak self] (_) in
      guard let _self = self else { return }

      _self.identityAnimation(for: _self.pushNotificationsButton)
    })

    UIView.animate(withDuration: animationDuration,
                   delay: 0.1,
                   options: .curveEaseInOut,
                   animations: { [weak self] in
      self?.emailNotificationsButton.transform = sizeTransform
    }, completion: { [weak self] (_) in
      guard let _self = self else { return }

      _self.identityAnimation(for: _self.emailNotificationsButton)
    })
  }

  private func identityAnimation(for button: UIButton, duration: TimeInterval = 0.15) {
    UIView.animate(withDuration: duration, animations: {
      button.transform = .identity
    }, completion: nil)
  }
}
