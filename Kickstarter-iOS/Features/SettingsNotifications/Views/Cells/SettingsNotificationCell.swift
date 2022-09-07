import KsApi
import Library
import Prelude
import UIKit

protocol SettingsNotificationCellDelegate: AnyObject {
  func settingsNotificationCell(_ cell: SettingsNotificationCell, didFailToUpdateUser errorMessage: String)
  func settingsNotificationCell(_ cell: SettingsNotificationCell, didUpdateUser user: User)
}

final class SettingsNotificationCell: UITableViewCell, NibLoading, ValueCell {
  @IBOutlet fileprivate var arrowImageView: UIImageView!
  @IBOutlet fileprivate var emailNotificationsButton: UIButton!
  @IBOutlet fileprivate var projectCountLabel: UILabel!
  @IBOutlet fileprivate var pushNotificationsButton: UIButton!
  @IBOutlet fileprivate var stackView: UIStackView!
  @IBOutlet fileprivate var titleLabel: UILabel!

  weak var delegate: SettingsNotificationCellDelegate?

  private let viewModel: SettingsNotificationCellViewModelType = SettingsNotificationCellViewModel()
  private lazy var tapGesture: UITapGestureRecognizer = {
    UITapGestureRecognizer(target: self, action: #selector(cellBackgroundTapped))
  }()

  private var notificationType: SettingsNotificationCellType?

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  func configureWith(value cellValue: SettingsNotificationCellValue) {
    self.notificationType = cellValue.cellType

    self.viewModel.inputs.configure(with: cellValue)

    let accessibilityElementsHidden = cellValue.cellType.accessibilityElementsHidden

    _ = self
      |> \.accessibilityTraits .~ cellValue.cellType.accessibilityTraits

    _ = self.stackView
      |> \.accessibilityElements .~ (
        accessibilityElementsHidden
          ? [self.emailNotificationsButton, self.pushNotificationsButton].compact()
          : []
      )

    _ = self.titleLabel
      |> UILabel.lens.text .~ cellValue.cellType.title
      |> \.accessibilityElementsHidden .~ cellValue.cellType.accessibilityElementsHidden

    _ = self.arrowImageView
      |> UIImageView.lens.isHidden .~ cellValue.cellType.shouldHideArrowView
      |> UIImageView.lens.tintColor .~ .ksr_support_400

    _ = self.projectCountLabel
      |> UILabel.lens.isHidden .~ cellValue.cellType.projectCountLabelHidden
      |> \.accessibilityElementsHidden .~ accessibilityElementsHidden
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()

    _ = self.titleLabel
      |> settingsTitleLabelStyle

    _ = self.projectCountLabel
      |> UILabel.lens.textColor .~ .ksr_support_400
      |> UILabel.lens.font .~ .ksr_body()

    _ = self.emailNotificationsButton |> notificationButtonStyle
      |> UIButton.lens.image(for: .normal) .~ Library.image(
        named: "email-icon",
        tintColor: .ksr_support_400,
        inBundle: Bundle.framework
      )
      |> UIButton.lens.image(for: .highlighted) .~ Library.image(
        named: "email-icon",
        tintColor: .ksr_support_300,
        inBundle: Bundle.framework
      )
      |> UIButton.lens.image(for: .selected) .~ Library.image(
        named: "email-icon",
        tintColor: .ksr_create_700,
        inBundle: Bundle.framework
      )

    _ = self.pushNotificationsButton
      |> notificationButtonStyle
      |> UIButton.lens.image(for: .normal) .~ Library.image(
        named: "mobile-icon",
        tintColor: .ksr_support_400,
        inBundle: Bundle.framework
      )
      |> UIButton.lens.image(for: .highlighted) .~ Library.image(
        named: "mobile-icon",
        tintColor: .ksr_support_300,
        inBundle: Bundle.framework
      )
      |> UIButton.lens.image(for: .selected) .~ Library.image(
        named: "mobile-icon",
        tintColor: .ksr_create_700,
        inBundle: Bundle.framework
      )
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.emailNotificationsButton.rac.selected = self.viewModel.outputs.emailNotificationsEnabled
    self.emailNotificationsButton.rac.hidden = self.viewModel.outputs.emailNotificationButtonIsHidden
    self.emailNotificationsButton.rac.accessibilityLabel =
      self.viewModel.outputs.emailNotificationsButtonAccessibilityLabel
    self.projectCountLabel.rac.text = self.viewModel.outputs.projectCountText
    self.pushNotificationsButton.rac.selected = self.viewModel.outputs.pushNotificationsEnabled
    self.pushNotificationsButton.rac.hidden = self.viewModel.outputs.pushNotificationButtonIsHidden
    self.pushNotificationsButton.rac.accessibilityLabel =
      self.viewModel.outputs.pushNotificationsButtonAccessibilityLabel

    self.viewModel.outputs.enableButtonAnimation
      .observeForUI()
      .observeValues { [weak self] enableAnimation in
        guard let _self = self else { return }
        if enableAnimation {
          _self.addGestureRecognizer(_self.tapGesture)
        } else {
          _self.removeGestureRecognizer(_self.tapGesture)
        }
      }

    self.viewModel.outputs.updateCurrentUser
      .observeForControllerAction()
      .observeValues { [weak self] user in
        guard let _self = self else { return }
        _self.delegate?.settingsNotificationCell(_self, didUpdateUser: user)
      }

    self.viewModel.outputs.unableToSaveError
      .observeForControllerAction()
      .observeValues { [weak self] errorString in
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

  @IBAction func cellBackgroundTapped(_: Any) {
    let sizeTransform = CGAffineTransform(scaleX: 1.2, y: 1.2)
    let animationDuration: TimeInterval = 0.15

    UIView.animate(withDuration: animationDuration, animations: { [weak self] in
      self?.pushNotificationsButton.transform = sizeTransform
    }, completion: { [weak self] _ in
      guard let _self = self else { return }

      _self.identityAnimation(for: _self.pushNotificationsButton)
    })

    UIView.animate(
      withDuration: animationDuration,
      delay: 0.1,
      options: .curveEaseInOut,
      animations: { [weak self] in
        self?.emailNotificationsButton.transform = sizeTransform
      }, completion: { [weak self] _ in
        guard let _self = self else { return }

        _self.identityAnimation(for: _self.emailNotificationsButton)
      }
    )
  }

  private func identityAnimation(for button: UIButton, duration: TimeInterval = 0.15) {
    UIView.animate(withDuration: duration, animations: {
      button.transform = .identity
    }, completion: nil)
  }
}
