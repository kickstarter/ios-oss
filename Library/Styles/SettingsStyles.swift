import KsApi
import Prelude
import Prelude_UIKit
import UIKit

public let settingsSectionButtonStyle =
  UIButton.lens.title(for: .normal) .~ nil

public let settingsArrowViewStyle = UIImageView.lens.tintColor .~ LegacyColors.ksr_support_400.uiColor()

public let settingsSectionLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.textColor .~ LegacyColors.ksr_support_700.uiColor()
    |> \.font .~ .ksr_subhead()
    |> \.numberOfLines .~ 2
}

public let settingsTitleLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.textColor .~ LegacyColors.ksr_support_700.uiColor()
    |> \.font .~ .ksr_body()
}

public let settingsDetailLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.font .~ .ksr_body()
    |> \.numberOfLines .~ 1
    |> \.textColor .~ LegacyColors.ksr_support_400.uiColor()
    |> \.lineBreakMode .~ .byTruncatingTail
}

public let settingsDescriptionLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.font .~ .ksr_body(size: 13)
    |> \.numberOfLines .~ 0
    |> \.textColor .~ LegacyColors.ksr_support_400.uiColor()
    |> \.lineBreakMode .~ .byWordWrapping
}

public let settingsHeaderFooterLabelBaseStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.font .~ .ksr_footnote()
    |> \.numberOfLines .~ 0
}

public let settingsHeaderFooterLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.backgroundColor .~ LegacyColors.ksr_support_100.uiColor()
    |> \.textColor .~ LegacyColors.ksr_support_400.uiColor()
}

public let settingsFormFieldStyle =
  UITextField.lens.textColor .~ LegacyColors.ksr_support_400.uiColor()

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

public let settingsSeparatorStyle = UIView.lens.backgroundColor .~ LegacyColors.ksr_support_300.uiColor()
  <> UIView.lens.accessibilityElementsHidden .~ true

public let settingsNotificationIconButtonStyle =
  UIButton.lens.title(for: .normal) .~ nil
    <> UIButton.lens.tintColor .~ LegacyColors.ksr_support_400.uiColor()

public let settingsSwitchStyle = UISwitch.lens.onTintColor .~ LegacyColors.ksr_create_700.uiColor()
  <> UISwitch.lens.tintColor .~ LegacyColors.ksr_support_100.uiColor()

public let notificationButtonStyle = UIButton.lens.layer.cornerRadius .~ 9
  <> UIButton.lens.accessibilityHint %~ { _ in Strings.Double_tap_to_toggle_setting() }
  <> UIButton.lens.accessibilityTraits .~ UIAccessibilityTraits.none
  <> UIButton.lens.layer.borderColor .~ LegacyColors.ksr_support_100.uiColor().cgColor
  <> UIButton.lens.layer.borderWidth .~ 1.0
  <> UIButton.lens.backgroundColor(for: .normal) .~ LegacyColors.ksr_white.uiColor()
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ LegacyColors.ksr_support_100.uiColor()
  <> UIButton.lens.backgroundColor(for: .selected) .~ LegacyColors.ksr_support_100.uiColor()
  <> UIButton.lens.title(for: .normal) .~ nil
  <> UIButton.lens.clipsToBounds .~ true

public let settingsViewControllerStyle: (UIViewController) -> UIViewController = { tvc in
  tvc
    |> baseControllerStyle()
    |> UIViewController.lens.view.backgroundColor .~ LegacyColors.ksr_support_100.uiColor()
}

public let settingsTableViewStyle = UITableView.lens.backgroundColor .~ LegacyColors.ksr_support_100.uiColor()
  <> UITableView.lens.separatorStyle .~ .none

public let settingsTableViewSeparatorStyle = UITableView.lens.separatorStyle .~ .singleLine
  <> \.separatorColor .~ LegacyColors.ksr_support_300.uiColor()
  <> \.separatorInset .~ .zero

public func settingsAttributedPlaceholder(_ string: String) -> NSAttributedString {
  return NSAttributedString(
    string: string,
    attributes: [NSAttributedString.Key.foregroundColor: LegacyColors.ksr_support_400.uiColor()]
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
    |> \.backgroundColor .~ LegacyColors.ksr_white.uiColor()
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
    |> \.backgroundColor .~ LegacyColors.ksr_support_100.uiColor()
    |> \.separatorInset .~ .zero
}

public func settingsTextFieldStyle(_ textField: UITextField) -> UITextField {
  return textField
    |> \.backgroundColor .~ LegacyColors.ksr_white.uiColor()
    |> \.font %~ { _ in .ksr_body() }
    |> \.textAlignment %~~ { _, stackView in
      stackView.traitCollection.preferredContentSizeCategory.isAccessibilityCategory ? .left : .right
    }
}
