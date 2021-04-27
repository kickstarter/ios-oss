import KsApi
import Prelude
import Prelude_UIKit
import UIKit

public let settingsSectionButtonStyle =
  UIButton.lens.title(for: .normal) .~ nil

public let settingsArrowViewStyle = UIImageView.lens.tintColor .~ .ksr_support_400

public let settingsSectionLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.textColor .~ .ksr_support_700
    |> \.font .~ .ksr_subhead()
    |> \.numberOfLines .~ 2
}

public let settingsTitleLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.textColor .~ .ksr_support_700
    |> \.font .~ .ksr_body()
}

public let settingsDetailLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.font .~ .ksr_body()
    |> \.numberOfLines .~ 1
    |> \.textColor .~ .ksr_support_400
    |> \.lineBreakMode .~ .byTruncatingTail
}

public let settingsDescriptionLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.font .~ .ksr_body(size: 13)
    |> \.numberOfLines .~ 0
    |> \.textColor .~ .ksr_support_400
    |> \.lineBreakMode .~ .byWordWrapping
}

public let settingsHeaderFooterLabelBaseStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.font .~ .ksr_footnote()
    |> \.numberOfLines .~ 0
}

public let settingsHeaderFooterLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.backgroundColor .~ .ksr_support_100
    |> \.textColor .~ .ksr_support_400
}

public let settingsFormFieldStyle =
  UITextField.lens.textColor .~ .ksr_support_400

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

public let settingsSeparatorStyle = UIView.lens.backgroundColor .~ .ksr_support_300
  <> UIView.lens.accessibilityElementsHidden .~ true

public let settingsNotificationIconButtonStyle =
  UIButton.lens.title(for: .normal) .~ nil
    <> UIButton.lens.tintColor .~ .ksr_support_400

public let settingsSwitchStyle = UISwitch.lens.onTintColor .~ .ksr_create_700
  <> UISwitch.lens.tintColor .~ .ksr_support_100

public let notificationButtonStyle = UIButton.lens.layer.cornerRadius .~ 9
  <> UIButton.lens.accessibilityHint %~ { _ in Strings.Double_tap_to_toggle_setting() }
  <> UIButton.lens.accessibilityTraits .~ UIAccessibilityTraits.none
  <> UIButton.lens.layer.borderColor .~ UIColor.ksr_support_100.cgColor
  <> UIButton.lens.layer.borderWidth .~ 1.0
  <> UIButton.lens.backgroundColor(for: .normal) .~ .ksr_white
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ .ksr_support_100
  <> UIButton.lens.backgroundColor(for: .selected) .~ .ksr_support_100
  <> UIButton.lens.title(for: .normal) .~ nil
  <> UIButton.lens.clipsToBounds .~ true

public let settingsViewControllerStyle: (UIViewController) -> UIViewController = { tvc in
  tvc
    |> baseControllerStyle()
    |> UIViewController.lens.view.backgroundColor .~ .ksr_support_100
}

public let settingsTableViewStyle = UITableView.lens.backgroundColor .~ .ksr_support_100
  <> UITableView.lens.separatorStyle .~ .none

public let settingsTableViewSeparatorStyle = UITableView.lens.separatorStyle .~ .singleLine
  <> \.separatorColor .~ .ksr_support_300
  <> \.separatorInset .~ .zero

public func settingsAttributedPlaceholder(_ string: String) -> NSAttributedString {
  return NSAttributedString(
    string: string,
    attributes: [NSAttributedString.Key.foregroundColor: UIColor.ksr_support_400]
  )
}

public func settingsContentViewStyle(_ view: UIView) -> UIView {
  return view
    |> \.layoutMargins .~ .init(all: Styles.grid(2))
    |> \.preservesSuperviewLayoutMargins .~ false
}

public func settingsFooterContentViewStyle(_ view: UIView) -> UIView {
  return view
    |> settingsContentViewStyle
    |> \.layoutMargins .~ .init(
      top: Styles.grid(1),
      left: Styles.grid(2),
      bottom: Styles.grid(0),
      right: Styles.grid(2)
    )
}

public func settingsHeaderContentViewStyle(_ view: UIView) -> UIView {
  return view
    |> settingsContentViewStyle
    |> \.layoutMargins .~ .init(
      top: Styles.grid(5),
      left: Styles.grid(2),
      bottom: Styles.grid(2),
      right: Styles.grid(2)
    )
}

public func settingsLabelStyle(_ label: UILabel) -> UILabel {
  return label
    |> \.backgroundColor .~ .ksr_white
    |> \.font %~ { _ in .ksr_body() }
}

public func settingsStackViewStyle(_ stackView: UIStackView) -> UIStackView {
  return stackView
    |> \.axis %~~ { _, stackView in
      stackView.traitCollection.preferredContentSizeCategory.isAccessibilityCategory ? .vertical : .horizontal
    }
    |> \.alignment %~~ { _, stackView in
      stackView.traitCollection.preferredContentSizeCategory.isAccessibilityCategory ? .leading : .fill
    }
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.spacing .~ 8
}

public func settingsGroupedTableViewStyle(_ tableView: UITableView) -> UITableView {
  return tableView
    |> \.allowsSelection .~ false
    |> \.backgroundColor .~ .ksr_support_100
    |> \.separatorInset .~ .zero
}

public func settingsTextFieldStyle(_ textField: UITextField) -> UITextField {
  return textField
    |> \.backgroundColor .~ .ksr_white
    |> \.font %~ { _ in .ksr_body() }
    |> \.textAlignment %~~ { _, stackView in
      stackView.traitCollection.preferredContentSizeCategory.isAccessibilityCategory ? .left : .right
    }
}
