import KsApi
import Prelude
import Prelude_UIKit
import UIKit

public let settingsSectionButtonStyle =
  UIButton.lens.title(for: .normal) .~ nil

public let settingsArrowViewStyle = UIImageView.lens.tintColor .~ .ksr_dark_grey_400

public let settingsSectionLabelStyle =
  UILabel.lens.textColor .~ .ksr_soft_black
    <> UILabel.lens.font .~ .ksr_subhead()
    <> UILabel.lens.numberOfLines .~ 2

public let settingsTitleLabelStyle =
  UILabel.lens.textColor .~ .ksr_soft_black
    <> UILabel.lens.font .~ .ksr_body()

public let settingsDetailLabelStyle = UILabel.lens.font .~ .ksr_body()
  <> UILabel.lens.numberOfLines .~ 1
  <> UILabel.lens.textColor .~ .ksr_text_dark_grey_500
  <> UILabel.lens.lineBreakMode .~ .byTruncatingTail

public let settingsDescriptionLabelStyle = UILabel.lens.font .~ .ksr_body(size: 13)
    <> UILabel.lens.numberOfLines .~ 0
    <> UILabel.lens.textColor .~ .ksr_dark_grey_400
    <> UILabel.lens.lineBreakMode .~ .byWordWrapping

public let settingsFormFieldStyle =
  UITextField.lens.textColor .~ .ksr_text_dark_grey_500

public let settingsEmailFieldAutoFillStyle = emailFieldAutoFillStyle
  <> settingsFormFieldStyle
  <> UITextField.lens.textAlignment .~ .right

public let settingsPasswordFormFieldStyle = passwordFieldStyle
  <> settingsFormFieldStyle
  <> UITextField.lens.textAlignment .~ .right

public let settingsPasswordFormFieldAutoFillStyle = passwordFieldAutoFillStyle
  <> settingsPasswordFormFieldStyle

public let settingsNewPasswordFormFieldAutoFillStyle = newPasswordFieldAutoFillStyle
  <> settingsPasswordFormFieldStyle

public let settingsLogoutButtonStyle = borderButtonStyle
  <> UIButton.lens.titleLabel.font .~ .ksr_headline(size: 15)
  <> UIButton.lens.title(for: .normal) %~ { _ in Strings.profile_settings_log_out_button() }

public let settingsSeparatorStyle = UIView.lens.backgroundColor .~ .ksr_grey_500
  <> UIView.lens.accessibilityElementsHidden .~ true

public let settingsNotificationIconButtonStyle =
  UIButton.lens.title(for: .normal) .~ nil
    <> UIButton.lens.tintColor .~ .ksr_text_dark_grey_400

public let settingsSwitchStyle = UISwitch.lens.onTintColor .~ .ksr_green_700
  <> UISwitch.lens.tintColor .~ .ksr_grey_300

public let notificationButtonStyle = UIButton.lens.layer.cornerRadius .~ 9
  <> UIButton.lens.layer.borderColor .~ UIColor.ksr_grey_300.cgColor
  <> UIButton.lens.layer.borderWidth .~ 1.0
  <> UIButton.lens.backgroundColor(for: .normal) .~ .white
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ .ksr_grey_200
  <> UIButton.lens.backgroundColor(for: .selected) .~ .ksr_grey_200
  <> UIButton.lens.title(for: .normal) .~ nil
  <> UIButton.lens.clipsToBounds .~ true

public let settingsViewControllerStyle = baseControllerStyle()
  <> UIViewController.lens.view.backgroundColor .~ .ksr_grey_200

public let settingsTableViewStyle = UITableView.lens.backgroundColor .~ .ksr_grey_200
  <> UITableView.lens.separatorStyle .~ .none

public func settingsAttributedPlaceholder(_ string: String) -> NSAttributedString {
  return NSAttributedString(
    string: string,
    attributes: [NSAttributedString.Key.foregroundColor: UIColor.ksr_text_dark_grey_400]
  )
}
