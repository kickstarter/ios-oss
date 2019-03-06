import KsApi
import Prelude
import Prelude_UIKit
import UIKit

public let settingsSectionButtonStyle =
  UIButton.lens.title(for: .normal) .~ nil

public let settingsArrowViewStyle = UIImageView.lens.tintColor .~ .ksr_dark_grey_400

public let settingsSectionLabelStyle = { (label: UILabel) in
  label
    |> \.textColor .~ .ksr_soft_black
    |> \.font .~ .ksr_subhead()
    |> \.numberOfLines .~ 2
}

public let settingsTitleLabelStyle = { (label: UILabel) in
  label
    |> \.textColor .~ .ksr_soft_black
    |> \.font .~ .ksr_body()
}

public let settingsDetailLabelStyle = { (label: UILabel) in
  label
    |> \.font .~ .ksr_body()
    |> \.numberOfLines .~ 1
    |> \.textColor .~ .ksr_text_dark_grey_500
    |> \.lineBreakMode .~ .byTruncatingTail
}

public let settingsDescriptionLabelStyle = { (label: UILabel) in
  label
    |> \.font .~ .ksr_body(size: 13)
    |> \.numberOfLines .~ 0
    |> \.textColor .~ .ksr_dark_grey_400
    |> \.lineBreakMode .~ .byWordWrapping
}

public let settingsHeaderFooterLabelBaseStyle = { (label: UILabel) in
  label
    |> \.font .~ .ksr_footnote()
    |> \.numberOfLines .~ 0
}

public let settingsHeaderFooterLabelStyle = { (label: UILabel) in
  label
    |> \.backgroundColor .~ .ksr_grey_200
    |> \.textColor .~ .ksr_text_dark_grey_500
}

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

public let settingsSeparatorStyle = UIView.lens.backgroundColor .~ .ksr_grey_500
  <> UIView.lens.accessibilityElementsHidden .~ true

public let settingsNotificationIconButtonStyle =
  UIButton.lens.title(for: .normal) .~ nil
    <> UIButton.lens.tintColor .~ .ksr_text_dark_grey_400

public let settingsSwitchStyle = UISwitch.lens.onTintColor .~ .ksr_green_700
  <> UISwitch.lens.tintColor .~ .ksr_grey_300

public let notificationButtonStyle = UIButton.lens.layer.cornerRadius .~ 9
  <> UIButton.lens.accessibilityHint %~ { _ in Strings.Double_tap_to_toggle_setting() }
  <> UIButton.lens.accessibilityTraits .~ UIAccessibilityTraits.none.rawValue
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

public let settingsTableViewSeparatorStyle = UITableView.lens.separatorStyle .~ .singleLine
  <> \.separatorColor .~ .ksr_grey_400
  <> \.separatorInset .~ .zero

public func settingsAttributedPlaceholder(_ string: String) -> NSAttributedString {
  return NSAttributedString(
    string: string,
    attributes: [NSAttributedString.Key.foregroundColor: UIColor.ksr_text_dark_grey_400]
  )
}
